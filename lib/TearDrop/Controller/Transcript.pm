package TearDrop::Controller::Transcript;
use Mojo::Base 'Mojolicious::Controller';

use warnings;
use strict;

our $VERSION='0.01';

has 'resultset' => 'Transcript';

sub list_project_transcript {
  my $self = shift;
  my $rs = $self->stash('project_schema')->resultset($self->resultset)->search($self->stash('filters'), {
    order_by => $self->stash('sort'),
    page => $self->param('page'),
    rows => $self->param('rows')||50,
    prefetch => [ 'organism', 'gene', { 'transcript_tags' => [ 'tag' ] } ],
  });
  my $ser = [ map {
    my $t=$_;
    my $tser = $t->TO_JSON;
    for (qw/organism gene/) {
      $tser->{$_} = $t->$_->TO_JSON if $t->$_;
    }
    $tser;
  } $rs->all ];

  if ($self->param('page')) {
    $self->render(json => {
      total_items => $rs->pager->total_entries,
      data => $ser,
    });
  }
  else {
    $self->render(json => $ser);
  }
}

1;
