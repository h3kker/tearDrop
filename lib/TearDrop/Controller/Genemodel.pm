package TearDrop::Controller::GeneModel;
use Mojo::Base 'Mojolicious::Controller';

use warnings;
use strict;

our $VERSION='0.01';

has 'resultset' => 'GeneModel';

sub list {
  my $self = shift;
  $self->render(json => [ $self->stash('project_schema')->resultset($self->resultset)->all ]);
}

1;
