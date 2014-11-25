package TearDrop::Task;

use warnings;
use strict;

use TearDrop;
use Mouse;

my $app;

sub app {
  unless($app) {
    $app = TearDrop->new;
    warn $app->can('worker');
    $app->init unless $app->can('worker');
  }
  $app;
}

has 'post_processing' => ( is => 'rw', isa => 'CodeRef | Undef', predicate => 'has_post_processing' );

has 'project' => ( is => 'rw', isa => 'Str' );
has 'result' => ( is => 'rw', isa => 'ArrayRef | Undef' );
has 'id' => ( is => 'rw', isa => 'Str' );
has 'pid' => ( is => 'rw', isa => 'Int | Undef' );
has 'status' => ( is => 'rw', isa => 'Str | Undef' );

sub TO_JSON {
  my $self = shift;
  my %ser = map { $_ => $self->{$_} } keys %$self;
  \%ser;
}

1;
