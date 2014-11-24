package TearDrop::Controller::Tag;
use Mojo::Base 'Mojolicious::Controller';

use warnings;
use strict;

our $VERSION='0.01';

has 'resultset' => 'Tag';

sub list_project_tag {
  my $self = shift;
  $self->render(json => [ $self->stash('project_schema')->resultset($self->resultset)->all ]);
}

1;
