package TearDrop::Worker::DB;

use warnings;
use strict;

use Dancer qw/:moose !status/;
use Dancer::Plugin::DBIC;

use Mouse;

use Try::Tiny;
use Carp;

extends 'TearDrop::Worker';

use TearDrop::Task::BLAST;
use TearDrop::Task::MAFFT;
use TearDrop::Task::Mpileup;

use POSIX qw(mkfifo :errno_h);

sub start_worker {
  my $self = shift;
  my $pid = fork;
  if ($pid) {
    info 'worker started with pid '.$pid;
    return;
  }
  for my $j ($self->queued_jobs->all) {
    $self->start_job($j);
  }
  unless(-e config->{worker_fifo}) {
    mkfifo(config->{worker_fifo}, 0700) or confess 'mkfifo '.config->{worker_fifo}." failed: $!";
  }
  open(FIFO, "<".config->{worker_fifo}) or confess "open ".config->{worker_fifo}." failed: $!";
  while(1) {
    while(<FIFO>) {
      debug 'wakey!';
      for my $j ($self->queued_jobs->all) {
        $self->start_job($j);
      }
      debug 'yawn.';
    }
  }
  info 'closing worker?';
  close FIFO;
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

sub start_job {
  my ($self, $item) = @_;
  my $pid = $self->pm->start;
  if ($pid) {
    debug 'pid '.$pid.' started for job '.$item->id.' '.$item->class;
    $item->pid($pid);
    $item->status('running');
    $item->update;
    return;
  }
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
  $SIG{ALRM} = sub {
    $self->new->start_worker;
  };
  alarm(10);
  try {
    debug 'signalling worker';
    open(OUT, ">".config->{worker_fifo}) or confess("open ".config->{worker_fifo}.": $!");
    print OUT "job queued\n";
    close OUT;
  } catch {
    info 'worker process has gone away? hopefully we got a new one now.';
  };
  alarm(0);
  $SIG{ALRM}=undef;
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
