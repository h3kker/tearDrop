package TearDrop::Controller::Genemodel;
use Mojo::Base 'Mojolicious::Controller';

use warnings;
use strict;

our $VERSION='0.01';

has 'resultset' => 'GeneModel';

sub list_project_genemodel {
  my $self = shift;
  $self->render(json => [ $self->stash('project_schema')->resultset($self->resultset)->all ]);
}

1;
