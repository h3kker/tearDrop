package TearDrop::Controller::Alignment;
use Mojo::Base 'Mojolicious::Controller';

use warnings;
use strict;

our $VERSION='0.01';

has 'resultset' => 'Alignment';

sub list_project_alignment {
  my $self = shift;
  my @ret = map {
    my $gm = $_;
    my $ser = $gm->TO_JSON;
    $ser->{sample} = $gm->sample;
    $ser->{genome_alignment} = $gm->genome_alignment->TO_JSON if $gm->genome_alignment;
    $ser->{transcriptome_alignment} = $gm->transcriptome_alignment->TO_JSON if $gm->transcriptome_alignment;
    $ser->{type} = $ser->{genome_alignment} ? 'genome' : 'transcriptome';
    $ser;
  } $self->stash('project_schema')->resultset($self->resultset)->search(undef, { prefetch => [ 'sample', 'genome_alignment', 'transcriptome_alignment' ]})->all;
  $self->render(json => \@ret);
}

1;
