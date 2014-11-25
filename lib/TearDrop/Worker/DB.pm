package TearDrop::Worker::DB;

use warnings;
use strict;

use Mouse;

use Try::Tiny;
use Carp;
use Parallel::ForkManager;

extends 'TearDrop::Worker';

use POSIX qw(mkfifo :errno_h);

has 'pm' => ( is => 'rw', isa => 'Ref', lazy => 1, default => sub {
  my $self = shift;
  my $pm = Parallel::ForkManager->new($self->threads);
  $pm;
});

sub run_dispatcher {
  my $self = shift;
  if (config->{worker}{fifo}) {
    for my $j ($self->queued_jobs->all) {
      $self->run_job($j);
    }
    unless(-e config->{worker}{fifo}) {
      mkfifo(config->{worker}{fifo}, 0700) or confess 'mkfifo '.config->{worker}{fifo}." failed: $!";
    }
    open(FIFO, "<".config->{worker}{fifo}) or confess "open ".config->{worker}{fifo}." failed: $!";
    while(1) {
      while(<FIFO>) {
        debug 'wakey!';
        for my $j ($self->queued_jobs->all) {
          $self->run_job($j);
        }
        debug 'yawn.';
      }
    }
    close FIFO;
  }
  else {
    while(1) {
      debug 'wakey!';
      for my $j ($self->queued_jobs->all) {
        $self->run_job($j);
      }
      debug 'yawn.';
      sleep(config->{worker}{poll_interval}||30);
    }
  }

  info 'closing worker?';
}

sub job_started {
  my ($self, $pid, $id) = @_;
  debug 'process '.$pid.' started';
}

sub job_finished {
  my ($self, $pid, $code) = @_;
  debug 'process '.$pid.' finished';
}

sub queued_jobs {
  my $self = shift;
  schema->resultset('Workqueue')->search({status => 'queued'}, { orderBy => [ { -asc => 'batch ' }, { -desc => 'submit_date' } ]})
}

sub run_job {
  my ($self, $item) = @_;
  my $pid = $self->pm->start;
  if ($pid) {
    debug 'pid '.$pid.' started for job '.$item->id.' '.$item->class;
    $item->pid($pid);
    $item->status('running');
    $item->update;
    return;
  }
  $0 = 'teardrop worker ('.$item->id.')';
  try {
    debug 'starting '.$item->id.' class '.$item->class;
    my $task = $self->deserialize_item($item);
    $task->run;
    $item->status('done');
    debug $item->id.' done';
  } catch {
    debug $item->id.' failed: '.$_;
    $item->status('failed');
    error $_;
  };
  $item->pid(undef);
  $item->update;
  debug $item->id.' process finished';
  $self->pm->finish;
}

sub enqueue {
  my ($self, $task) = @_;
  $task->status('queued');
  my $queue_item = schema->resultset('Workqueue')->create({
    status => $task->status,
    class => ref($task),
    project => var('project'),
    task_object => $self->serialize_task($task)
  });
  $task->id($queue_item->id);
  debug 'task '.ref($task).' queued with id '.$task->id;
  unless ($self->daemon_status) {
    debug 'restarting daemon';
    $self->start_working;
  }
  if (config->{worker}{fifo}) {
    open(OUT, ">".config->{worker_fifo}) or confess("open ".config->{worker_fifo}.": $!");
    print OUT "job queued\n";
    close OUT;
  }
  $task;
}

sub status {
  my ($self) = @_;
  $self->pm->wait_children;
  my $ret = { queued => 0, running => 0, failed => 0, done => 0 };
  my $rs=schema->resultset('Workqueue')->search({}, { 
    select   => [ 'status', { count => 'status' } ],
    as       => [ 'status', 'count' ],
    group_by => [ 'status']
  });
  for my $r ($rs->all) {
    $ret->{$r->get_column('status')}=$r->get_column('count');
  }
  $ret;
}

sub job_status {
  my ($self, $id) = @_;
  $self->pm->wait_children;
  schema->resultset('Workqueue')->find($id) || confess 'no such job: '.$id;
}

sub deserialize_item {
  my ($self, $item) = @_;
  my $o = YAML::Load($item->task_object);
  $o->project($item->project->name);
  $o;
}

sub serialize_task {
  my ($self, $task) = @_;
  YAML::Dump($task);
}

1;
