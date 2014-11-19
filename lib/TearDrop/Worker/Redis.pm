package TearDrop::Worker::Redis;

use warnings;
use strict;

use Dancer qw/:moose !status/;

use Mouse;

use Try::Tiny;
use Parallel::Prefork;

use Redis::JobQueue qw/DEFAULT_SERVER DEFAULT_PORT/;
use Redis::JobQueue::Job qw/STATUS_WORKING STATUS_COMPLETED STATUS_FAILED STATUS_CREATED/;

extends 'TearDrop::Worker';


has 'redis_server' => ( is => 'rw', isa => 'Str', lazy => 1, default => sub {
    config->{redis_server} || sprintf "%s:%s" => DEFAULT_SERVER, DEFAULT_PORT;
  }
);

has 'redis_queue' => ( is => 'rw', isa => 'Str', default => 'teardrop_jobs' );

has 'jq' => ( is => 'rw', isa => 'Ref', lazy => 1, default => sub {
  Redis::JobQueue->new(redis => $_[0]->redis_server);
});

sub start_worker {
  my $self = shift;
  debug 'waiting...';
  while(my $job = $self->jq->get_next_job(queue => $self->redis_queue, blocking => 1)) {
    debug 'XXXstarting '.$job->id;
    $self->run_job($job);
    debug 'waiting...';
  }
  $self->jq->quit;
  info 'worker closing...';
}

sub run_job {
  my ($self, $item) = @_;
  my $pid = $self->pm->start;
  if ($pid) {
    $item->meta_data('pid' => $pid);
    debug 'return';
    $self->jq->update_job($item);
    return;
  }
  else {
    try {
      debug 'starting '.$item->id.' class '.$item->meta_data('task_class');
      $item->status(STATUS_WORKING);
      $self->jq->update_job($item);
      my $task = $item->workload;
      $task->project($item->meta_data('project'));
      $item->result($task->run);
      $item->status(STATUS_COMPLETED);
      debug $item->id.' done';
    } catch {
      debug $item->id.' failed';
      confess $_;
      $item->status(STATUS_FAILED);
    };
    $item->meta_data('pid' => undef);
    $self->jq->update_job($item);
    debug 'worker exiting...';
    $self->pm->finish;
  };
}

sub enqueue {
  my ($self, $task) = @_;
  #confess 'worker died?' unless $self->daemon_status;
  debug 'queuing job '.ref($task);
  debug $self->serialize_task($task);
  my $job = Redis::JobQueue::Job->new({
    queue => $self->redis_queue,
    workload => $task,
    meta_data => { task_class => ref($task), project => var('project') },
    expire => 0,
  });
  my $item = $self->jq->add_job($job);
  $task->status('queued');
  $task->id($item->id);
  $task;
}

sub status {
  my ($self) = @_;
  confess 'worker died?' unless $self->daemon_status;
  my %status_map = ( STATUS_CREATED.'' => 'queued', STATUS_WORKING.'' => 'running', STATUS_FAILED.'' => 'failed', STATUS_COMPLETED.'' => 'done');
  my $ret = { queued => [], running => [], failed => [], done => 0 };
  for my $id ($self->jq->get_job_ids(status => [ STATUS_CREATED, STATUS_WORKING, STATUS_FAILED ])) {
    my $j = $self->jq->load_job($id);
    push @{$ret->{$status_map{$j->status}}}, {
      id => $j->id,
      pid => $j->meta_data('pid'),
      queue => $j->queue,
      created => $j->created,
      started => $j->started,
      completed => $j->completed,
      failed => $j->failed,
      elapsed => $j->elapsed,
      class => $j->meta_data('task_class'),
    };
  }
  $ret;
}

sub job_status {
  my ($self, $id) = @_;
  debug 'job status '.$id;
  my %status_map = ( STATUS_CREATED.'' => 'queued', STATUS_WORKING.'' => 'running', STATUS_FAILED.'' => 'failed', STATUS_COMPLETED.'' => 'done');

  my $j = $self->jq->load_job($id);
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

sub deserialize_item {
  my ($self, $item) = @_;
  my $o = YAML::Load($item->workload);
  $o->project($item->meta_data('project'));
  $o;
}

sub serialize_task {
  my ($self, $task) = @_;
  YAML::Dump($task);
}

1;
