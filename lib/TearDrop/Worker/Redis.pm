package TearDrop::Worker::Redis;

use 5.12.0;

use warnings;
use strict;

use Mouse;

use Try::Tiny;

use Redis::JobQueue qw/DEFAULT_SERVER DEFAULT_PORT/;
use Redis::JobQueue::Job qw/STATUS_WORKING STATUS_COMPLETED STATUS_FAILED STATUS_CREATED/;

extends 'TearDrop::Worker';

has 'redis_server' => ( is => 'rw', isa => 'Str', lazy => 1, default => sub {
    my $self = shift;
    $self->app->config->{redis_server} || sprintf "%s:%s" => DEFAULT_SERVER, DEFAULT_PORT;
  }
);

has 'redis_queue' => ( is => 'rw', isa => 'Str', default => 'teardrop_jobs' );

has 'jq' => ( is => 'rw', isa => 'Ref', lazy => 1, default => sub {
  Redis::JobQueue->new(redis => $_[0]->redis_server);
});

sub run_dispatcher {
  my $self = shift;
  $self->app->log->debug('waiting...');
  while(my $job = $self->jq->get_next_job(queue => $self->redis_queue, blocking => 1)) {
    next unless defined $job;
    $self->app->log->debug('dispatching job '.$job->id);
    $self->run_job($job);
    $self->app->log->debug('waiting...');
  }
  $self->jq->quit;
  $self->app->log->info('worker closing...');
}

sub run_job {
  my ($self, $item) = @_;
  my $pid = $self->pm->start;
  if ($pid) {
    $item->meta_data('pid' => $pid);
    $self->jq->update_job($item);
    return;
  }
  else {
    $0 = 'teardrop worker ('.$item->id.')';
    try {
      $self->app->log->info('starting '.$item->id.' class '.$item->meta_data('task_class'));
      $item->status(STATUS_WORKING);
      $self->jq->update_job($item);
      my $task = $item->workload;
      $task->project($item->meta_data('project'));
      $item->result($task->run);
      $item->status(STATUS_COMPLETED);
      $self->app->log->debug($item->id.' done');
      $self->jq->update_job($item);
    } catch {
      $self->app->log->debug($item->id.' failed');
      $item->status(STATUS_FAILED);
      $self->jq->update_job($item);
      $self->app->log->error($_);
    };
    $item->meta_data('pid' => undef);
    $self->app->log->debug('worker exiting...');
    $self->pm->finish;
  };
}

sub enqueue {
  my ($self, $task) = @_;
  $self->app->log->debug('queuing job '.ref($task));
  my $job = Redis::JobQueue::Job->new({
    queue => $self->redis_queue,
    workload => $task,
    meta_data => { task_class => ref($task), project => $task->project },
    expire => 0,
  });
  my $item = $self->jq->add_job($job);
  $task->status('queued');
  $task->id($item->id);
  $task;
}

sub status {
  my ($self) = @_;
  my $ret = { queued => [], running => [], failed => [], done => 0 };
  for my $id ($self->jq->get_job_ids(status => [ STATUS_CREATED, STATUS_WORKING, STATUS_FAILED ])) {
    my $j = $self->serialize_job($self->jq->load_job($id));
    # status might have changed between get_job_ids and load_job!
    if ($j->{status} eq 'done')) { $ret->{done}++ }
    else { push @{$ret->{$j->{status}}}, $j }
  }
  $ret;
}

sub job_status {
  my ($self, $id) = @_;

  $self->serialize_job($self->jq->load_job($id));
}

sub serialize_job {
  my ($self, $j) = @_;
  my %status_map = ( STATUS_CREATED, 'queued', STATUS_WORKING, 'running', STATUS_FAILED, 'failed', STATUS_COMPLETED, 'done');
  {
    id => $j->id,
    pid => $j->meta_data('pid'),
    status => $status_map{$j->status},
    queue => $j->queue,
    created => $j->created,
    started => $j->started,
    completed => $j->completed,
    failed => $j->failed,
    elapsed => $j->elapsed,
    class => $j->meta_data('task_class'),
  };
}

1;
