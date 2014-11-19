package TearDrop::Worker;

use warnings;
use strict;

use Dancer qw/:moose !status/;
use Dancer::Plugin::DBIC 'schema';

use Mouse;

use Try::Tiny;
use Proc::Daemon;
use Parallel::ForkManager;

use TearDrop::Task::BLAST;
use TearDrop::Task::MAFFT;
use TearDrop::Task::Mpileup;

has 'threads' => ( is => 'rw', isa => 'Int', default => 4);


has 'pm' => ( is => 'rw', isa => 'Ref', lazy => 1, default => sub {
  my $self = shift;
  my $pm = Parallel::ForkManager->new($self->threads);
  $pm;
});

has 'daemon' => ( is => 'rw', isa => 'Ref', lazy => 1, default => sub {
    Proc::Daemon->new(
      work_dir => '.',
      dont_close_fh => [ 'STDOUT', 'STDERR' ],
      pid_file => config->{worker}{pid_file}
    );
  }
);

sub start_working {
  my $self = shift;

  $self->threads(config->{worker}{threads}) if defined config->{worker}{threads};
  return if $self->daemon->Status();

  my $pid = $self->daemon->Init();
  if ($pid) {
    info 'worker started with pid '.$pid;
    return;
  }
  $0 = 'teardrop work dispatcher';
  $self->run_dispatcher;
}

sub restart_working {
  my $self = shift;
  if (my $pid = $self->daemon_status) {
    info 'killing old worker '.$pid.' (no retirement here)';
    $self->daemon->Kill_Daemon();
  }
  $self->start_working;
}

sub daemon_status {
  my $self = shift;
  $self->daemon->Status();
}

1;
