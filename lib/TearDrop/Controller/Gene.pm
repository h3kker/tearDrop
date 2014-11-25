package TearDrop::Controller::Gene;

use Mojo::Base 'Mojolicious::Controller';
use Mojo::JSON qw/decode_json/;
use TearDrop::Task::Mpileup;
use TearDrop::Task::BLAST;

use warnings;
use strict;

our $VERSION='0.01';

has 'resultset' => 'Gene';

sub list {
  my $self = shift;
  $self->parse_query;

  my $rs = $self->stash('project_schema')->resultset($self->resultset)->search($self->stash('filters'), {
    order_by => $self->stash('sort'),
    page => $self->param('page'),
    rows => $self->param('pagesize') || 50,
    prefetch => [
      { 'transcripts' => [ 'organism', ]},
      { 'gene_tags' => [ 'tag', ] },
    ]
  });
  my @ret;
  for my $r ($rs->all) {
    my $ser = $r->TO_JSON;
    $ser->{organism} = $r->organism;
    $ser->{transcripts} = [ map { $_->TO_JSON } $r->transcripts ];
    $ser->{tags} = [ $r->tags ];
    push @ret, $ser;
  }
  if ($self->param('page')) {
    $self->render(json => {
      total_items => $rs->pager->total_entries,
      data => \@ret,
    });
  }
  else {
    $self->render(json => \@ret);
  }
}

sub read {
  my $self = shift;

  my $rs = $self->stash('project_schema')->resultset($self->resultset)->find($self->param('geneId'), {
    prefetch => [
      { 'transcripts' => [ 'organism', { 'transcript_tags' => 'tag' } ]},
      { 'gene_tags' => [ 'tag', ] },
    ]
  });
  unless($rs) {
    return $self->reply->not_found;
  }
  my $ser = $rs->TO_JSON;
  $ser->{organism} = $rs->organism;
  $ser->{transcripts} = [ map {
    my $tser = $_->TO_JSON;
    $tser->{tags} = [ $_->tags ];
    $tser->{transcript_mapping_count} = $_->transcript_mappings->count;
    $tser->{mappings} = [ $_->filtered_mappings ];
    $tser;
  } $rs->transcripts ];
  $ser->{annotations} = $rs->gene_model_annotations;
  $ser->{tags} = [ $rs->tags ];

  $ser->{deresults} = [];
  for my $der ($self->stash('project_schema')->resultset('DeResult')->search({ transcript_id => $rs->id }, { 
        prefetch => ['de_run', { 'contrast' => [ 'base_condition', 'contrast_condition' ]} ],
      })) {
    my $d = $der->TO_JSON;
    $d->{contrast} = $der->contrast->TO_JSON;
    $d->{de_run} = $der->de_run->TO_JSON;
    push @{$ser->{de_results}}, $d;
  }
  $ser->{blast_runs} = $rs->aggregate_blast_runs;
  $self->render(json => $ser);
}

1;
