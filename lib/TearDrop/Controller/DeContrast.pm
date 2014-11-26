package TearDrop::Controller::DeContrast;

use Mojo::Base 'Mojolicious::Controller';
use Mojo::JSON qw/decode_json/;

use Carp;

use warnings;
use strict;

our $VERSION='0.01';

has 'resultset' => 'DeRunContrast';

sub list {
  my $self = shift;
  $self->stash('filters' => {}) unless $self->stash('filters');
  $self->stash('filters')->{de_run_id} = $self->param('derunId');
  my $rs = $self->stash('project_schema')->resultset($self->resultset)->search($self->stash('filters'), {
    order_by => $self->stash('sort'),
  });
  my @ret = map {
    $_->TO_JSON;
  } $rs->all;
  $self->render(json => \@ret);
}

sub read {
  my $self = shift;

  my $rs = $self->stash('project_schema')->resultset($self->resultset)->find({ de_run_id => $self->param('derunId'), contrast_id => $self->param('decontrastId') }, {
    prefetch => [ { 'contrast' => [ 
        { 'contrast_condition' => [ 'samples' ] }, 
        { 'base_condition' => [ 'samples' ] } 
      ] }, 'de_run' ],
  }) || croak 'not found';
  my $ser = $rs->TO_JSON;
  $ser->{$_} = $rs->$_->TO_JSON for qw/contrast de_run/;
  for (qw/contrast_condition base_condition/) {
    $ser->{contrast}{$_} = $rs->contrast->$_->TO_JSON;
  }
  $self->render(json => $ser);
}

1;
