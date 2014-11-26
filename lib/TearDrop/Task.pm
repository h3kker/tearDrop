package TearDrop::Task;

use warnings;
use strict;

use TearDrop;
use Mouse;

has 'app' => ( is => 'rw', isa => 'Ref', lazy => 1, default => sub {
  my $app = TearDrop->new;
  $app->init unless $app->can('worker');
  $app;
});

has 'post_processing' => ( is => 'rw', isa => 'Bool', default => 0 );

has 'project' => ( is => 'rw', isa => 'Str' );
has 'result' => ( is => 'rw', isa => 'ArrayRef | Undef' );
has 'id' => ( is => 'rw', isa => 'Str' );
has 'pid' => ( is => 'rw', isa => 'Int | Undef' );
has 'status' => ( is => 'rw', isa => 'Str | Undef' );

#after run => sub {
#  my $self = shift;
#  $self->do_post_processing if ($self->post_processing);
#};

sub TO_JSON {
  my $self = shift;
  my %ser = map { $_ => $self->{$_} } keys %$self;
  \%ser;
}

1;
