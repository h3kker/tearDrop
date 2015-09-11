package TearDrop::Controller::Gene;

use Mojo::Base 'Mojolicious::Controller';
use Mojo::JSON qw/decode_json/;
use TearDrop::Task::BLAST;
use TearDrop::Task::MAFFT;

use Carp;

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

sub list_fasta {
  my $self = shift;
  $self->parse_query;
  my $rs = $self->stash('project_schema')->resultset($self->resultset)->search($self->stash('filters'), {
    order_by => $self->stash('sort'),
    prefetch => [ { 'transcripts' => [ 'organism' ] }, { 'gene_tags' => [ 'tag', ] } ],
  });
  my @ret;
  for my $t ($rs->all) {
    push @ret, $t->to_fasta;
  }
  my $headers = Mojo::Headers->new;
  $headers->add( 'Content-Disposition', 'attachment;filename=genes_export.fasta' );
  $self->res->content->headers($headers);
  $self->render(format => 'txt', text => join "\n", @ret);
}

sub read {
  my $self = shift;

  my $rs = $self->stash('project_schema')->resultset($self->resultset)->find($self->param('geneId'), {
    prefetch => [
      { 'transcripts' => [ 'organism', { 'transcript_tags' => 'tag' } ]},
      { 'gene_tags' => [ 'tag', ] },
    ]
  }) || croak 'not found';
  my $ser = $rs->TO_JSON;
  $ser->{organism} = $rs->organism;
  $ser->{transcripts} = [ map {
    my $tser = $_->TO_JSON;
    $tser->{tags} = [ $_->tags ];
    $tser->{transcript_mapping_count} = $_->transcript_mappings->count;
    $tser->{annotations} = $_->gene_model_annotations($self->app->config->{alignments}{default_context});
    $tser->{mappings} = $_->filtered_mappings;
    $tser;
  } $rs->transcripts ];
  $ser->{annotations} = $rs->gene_model_annotations($self->app->config->{alignments}{default_context});
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

sub read_fasta {
  my $self = shift;
  my $rs = $self->stash('project_schema')->resultset($self->resultset)->find($self->param('geneId'), {
    prefetch => [ { 'transcripts' => [ 'organism', ] } ],
  }) || croak 'not found';
  $self->render(text => $rs->to_fasta);
}

sub update {
  my $self = shift;
  my $rs = $self->stash('project_schema')->resultset($self->resultset)->find($self->param('geneId'), {
    prefetch => [ { 'gene_tags' => [ 'tag', ] }, ]
  }) || croak 'not found';
  my $upd = decode_json($self->req->body);
  $rs->$_($upd->{$_}) for qw/name description best_homolog rating reviewed/;
  $rs->update_tags(@{$upd->{tags}});
  $rs->update;
  $self->read;
}

sub mappings {
  my $self = shift;
  my $rs = $self->stash('project_schema')->resultset($self->resultset)->find($self->param('geneId')) || croak 'not found';

  my @ret = map {
    my $m_ser = $_->TO_JSON;
    $m_ser->{annotations} = [ $_->annotations($self->app->config->{alignments}{default_context}) ];
    $m_ser;
  } @{$rs->filtered_mappings};
  $self->render(json => \@ret); 
}

sub blast_results {
  my $self = shift;
  my $rs = $self->stash('project_schema')->resultset($self->resultset)->find($self->param('geneId')) || croak 'not found';

  my @ret;
  for my $trans ($rs->transcripts) {
    push @ret, map {
      my $bl_ser = $_->TO_JSON;
      $bl_ser->{db_source}=$_->db_source->TO_JSON;
      $bl_ser;
    } $trans->search_related('blast_results', undef, { prefetch => 'db_source' });
  }
  $self->render(json => \@ret);
}

sub run_blast {
  my $self = shift;
  my $rs = $self->stash('project_schema')->resultset($self->resultset)->find($self->param('geneId')) || croak 'not found';

  my $db = $self->stash('project_schema')->resultset('DbSource')->search({
    name => $self->param('database') || 'refseq_plant',
  })->first || croak 'db not found';

  my $task = new TearDrop::Task::BLAST(gene_id => $rs->id, database => $db->name, project => $self->stash('project')->name );
  my $item = $self->app->worker->enqueue($task);
  $self->render(json => { id => $item->id, status => $item->status });
}

sub blast_runs {
  my $self = shift;
  my $rs = $self->stash('project_schema')->resultset($self->resultset)->find($self->param('geneId')) || croak 'not found';

  $self->render(json => $rs->aggregate_blast_runs);
}

sub transcript_msa {
  my $self = shift;
  my $rs = $self->stash('project_schema')->resultset($self->resultset)->find($self->param('geneId'), { prefetch => [ 'transcripts' ]}) || croak 'not found';
  my $msa = TearDrop::Task::MAFFT->new(transcripts => [ $rs->transcripts ], algorithm => 'FFT-NS-i')->run;
  $self->render(json => $msa);
}


1;
