package TearDrop::Worker;

use warnings;
use strict;

use Mouse;

use Try::Tiny;
use Proc::Daemon;
use Parallel::ForkManager;
use Mojo::Server;

use TearDrop::Task::BLAST;
use TearDrop::Task::MAFFT;
use TearDrop::Task::Mpileup;

has 'app' => ( is => 'rw', isa => 'Ref', default => sub {
  Mojo::Server->new->build_app('Mojo::HelloWorld');
});

has 'threads' => ( is => 'rw', isa => 'Int', default => 4);


has 'pm' => ( is => 'rw', isa => 'Ref', lazy => 1, default => sub {
  my $self = shift;
  my $pm = Parallel::ForkManager->new($self->threads);
  $pm;
});

has 'daemon' => ( is => 'rw', isa => 'Ref', lazy => 1, default => sub {
    my $self = shift;
    Proc::Daemon->new(
      work_dir => '.',
      dont_close_fh => [ 'STDOUT', 'STDERR' ],
      pid_file => $self->app->config->{worker}{pid_file}
    );
  }
);

sub start_working {
  my $self = shift;

  $self->threads($self->app->config->{worker}{threads}) if defined $self->app->config->{worker}{threads};
  if ($self->daemon->Status()) {
  }
  return if $self->daemon->Status();

  my $pid = $self->daemon->Init();
  if ($pid) {
    $self->app->log->info('worker started with pid '.$pid);
    return $self;
  }
  $0 = 'teardrop work dispatcher';
  $self->run_dispatcher;
}

sub restart_working {
  my $self = shift;
  if (my $pid = $self->daemon_status) {
    $self->app->log->info('killing old worker '.$pid.' (no retirement here)');
    $self->daemon->Kill_Daemon();
  }
  $self->start_working;
}

sub daemon_status {
  my $self = shift;
  $self->daemon->Status();
}

1;
