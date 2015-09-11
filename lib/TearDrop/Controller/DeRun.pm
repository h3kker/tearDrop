package TearDrop::Controller::DeRun;

use Mojo::Base 'Mojolicious::Controller';
use Mojo::JSON qw/decode_json/;

use Carp;

use warnings;
use strict;

our $VERSION='0.01';

has 'resultset' => 'DeRun';

sub list {
  my $self = shift;
  
  my $rs = $self->stash('project_schema')->resultset($self->resultset)->search($self->stash('filters'), {
    order_by => $self->stash('sort'),
    prefetch => [
      { 'de_run_contrasts' => [ { 'contrast' => [ 'base_condition', 'contrast_condition' ] }]},
    ]
  });
  my @ret;
  for my $r ($rs->all) {
    my $ser = $r->TO_JSON;
    $ser->{contrasts} = [ map {
      $_->contrast->TO_JSON
    } $r->de_run_contrasts ];
    push @ret, $ser;
  }
  $self->render(json => \@ret);
}

sub results {
  my $self = shift;
  $self->parse_query('DeResult');

  my $de_run = $self->stash('project_schema')->resultset($self->resultset)->find($self->param('derunId')) || croak 'not found';
  $self->stash('filters')->{de_run_id} = $de_run->id;
  $self->stash('filters')->{contrast_id} = $self->param('decontrastId');
  $self->stash('sort' => [ { -asc => 'adjp' }]) unless $self->stash('sort') && @{$self->stash('sort')};
  my $obj = $de_run->count_table->aggregate_genes ? 'gene' : 'transcript';

  my $rs = $de_run->get_results($self->stash('filters'), {
    order_by => $self->stash('sort'),
    page => $self->param('page'),
    rows => $self->param('pagesize') || 50,
  });
  my @ret = map {
    my $r = $_;
    my $ser = $r->TO_JSON;
    $ser->{transcript} = $r->$obj->TO_JSON;
    $ser->{transcript}{$_} = $r->$obj->$_ for qw/organism tags/;
    $ser;
  } $rs->all;
  if ($self->param('page')) {
    $self->render(json => { total_items => $rs->pager->total_entries, data => \@ret });
  }
  else {
    $self->render(json => \@ret);
  }
}

sub results_fasta {
  my $self = shift;
  $self->parse_query('DeResult');

  my $de_run = $self->stash('project_schema')->resultset($self->resultset)->find($self->param('derunId')) || croak 'not found';
  $self->stash('filters')->{de_run_id} = $de_run->id;
  $self->stash('filters')->{contrast_id} = $self->param('decontrastId');
  $self->stash('sort' => [ { -asc => 'adjp' }]) unless $self->stash('sort') && @{$self->stash('sort')};
  my $obj = $de_run->count_table->aggregate_genes ? 'gene' : 'transcript';

  my $rs = $de_run->get_results($self->stash('filters'), {
    order_by => $self->stash('sort'),
  });
  my @f;
  for my $r ($rs->all) {
    push @f, $r->$obj->to_fasta;
  }
  my $headers = Mojo::Headers->new;
  $headers->add( 'Content-Disposition', 'attachment;filename=deresults_export.fasta' );
  $self->res->content->headers($headers);
  $self->render(format => 'txt', text => join "\n", @f);
}


1;
