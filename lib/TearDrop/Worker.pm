package TearDrop::Worker;

use warnings;
use strict;

use Dancer ':syntax';
use Dancer::Plugin::DBIC 'schema';

use Try::Tiny;
use Parallel::ForkManager;

use TearDrop::Task::BLAST;
use TearDrop::Task::MAFFT;
use TearDrop::Task::Mpileup;

my $pm = Parallel::ForkManager->new(4);

my %status = (
  queue => [],
  running => {},
  failed => {},
);
my %jobs;

$pm->run_on_finish(sub {
  my ($pid, $code) = @_;
  debug "child $pid finished";
  my $job = delete $status{running}->{$pid};
  if ($code) {
    debug "setting $pid to failed";
    $job->pid(undef);
    $job->status('failed');
    $status{failed}->{$pid} = $job;
  }
  else {
    $job->status('done');
  }
});
$pm->run_on_start(sub {
  my ($pid, $id) = @_;
  debug 'process '.$pid.' started';
  my $j = shift @{$status{queue}};
  $j->pid($pid);
  $j->status('running');
  $status{running}->{$pid} = $j;
  $jobs{$pid}=$j;
});

sub TearDrop::Worker::enqueue {
  my $item = shift;
  $item->status('queued');
  push @{$status{queue}}, $item;
  $pm->start and return;
  debug $item;
  try {
    $item->run;
    debug 'done';
  } catch {
    error $_;
    $pm->finish(-1);
  };
  debug 'process finished';
  $pm->finish;
}

sub TearDrop::Worker::wait {
  $pm->wait_all_children;
}

sub TearDrop::Worker::get_status {
  $pm->wait_children;
  return {
    pending => scalar @{$status{queue}},
    failed => scalar keys %{$status{failed}},
    running => scalar keys %{$status{running}},
  };
}

sub TearDrop::Worker::get_job_status {
  my $pid = shift;
  $pm->wait_children;
  if ($jobs{$pid}) {
    return {
      pid => $jobs{$pid}->pid,
      status => $jobs{$pid}->status,
    }
  }
}

1;
