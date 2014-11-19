package TearDrop::Task;

use warnings;
use strict;

use Dancer qw/:moose !status/;
use Mouse;

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
