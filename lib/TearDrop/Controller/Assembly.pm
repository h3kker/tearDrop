package TearDrop::Controller::Assembly;
use Mojo::Base 'Mojolicious::Controller';

use warnings;
use strict;

our $VERSION='0.01';

has 'resultset' => 'TranscriptAssembly';

sub list {
  my $self = shift;
  my @ret = map {
    my $a = $_;
    my $ser = $a->TO_JSON;
    $ser->{transcripts}=$a->transcripts->count+0;
    $ser->{annotated_transcripts}=$a->transcripts({ name => { '!=' => undef }})->count+0;
    $ser;
  } $self->stash('project_schema')->resultset($self->resultset)->all;
  $self->render(json => \@ret);
}

1;
