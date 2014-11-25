package TearDrop::Controller::Transcript;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::JSON qw/decode_json/;
use TearDrop::Task::Mpileup;
use TearDrop::Task::BLAST;

use warnings;
use strict;

our $VERSION='0.01';

has 'resultset' => 'Transcript';

sub list {
  my $self = shift;
  $self->parse_query;
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

sub list_fasta {
  my $self = shift;
  $self->parse_query;
  my $rs = $self->stash('project_schema')->resultset($self->resultset)->search($self->stash('filters'), {
    order_by => $self->stash('sort'),
    prefetch => [ 'organism', { 'transcript_tags' => [ 'tag' ] } ],
  });
  my @ret;
  for my $t ($rs->all) {
    push @ret, $t->to_fasta;
  }
  $self->render(text => join "\n", @ret);
}

sub read {
  my $self = shift;
  my $rs = $self->stash('project_schema')->resultset($self->resultset)->find($self->param('transcriptId'), {
    prefetch => 'organism', 'gene', { 'transcript_tags' => 'tag' },
  });
  unless($rs) {
    $self->app->log->debug('not found:'.$self->param('transcriptId'));
    return $self->reply->not_found;
  }
  my $tser = $rs->TO_JSON;
  $tser->{organism} = $rs->organism;
  $tser->{tags} = [ $rs->tags ];
  $tser->{transcript_mapping_count} = $rs->transcript_mappings->count;
  $tser->{annotations} = $rs->gene_model_annotations;
  $tser->{de_results} = [];
  for my $der ($self->stash('project_schema')->resultset('DeResult')->search({ transcript_id => $rs->id },
    { prefetch => ['de_run', { 'contrast' => [ 'base_condition', 'contrast_condition' ] }]})) {
    my $d = $der->TO_JSON;
    $d->{contrast}=$der->contrast->TO_JSON;
    $d->{de_run}=$der->de_run->TO_JSON;
    push @{$tser->{de_results}}, $d;
  }
  $self->render(json => $tser);

}

sub update {
  my $self = shift;

  my $rs = $self->stash('project_schema')->resultset($self->resultset)->find($self->param('transcriptId'));
  unless($rs) {
    $self->app->log->debug('not found:'.$self->param('transcriptId'));
    return $self->reply->not_found;
  }
  my $upd = decode_json( $self->req->body );
  $rs->$_($upd->{$_}) for qw/name description best_homolog rating reviewed/;
  $rs->organism_name($upd->{organism}{name}) if $upd->{organism};
  $rs->update_tags(@{$upd->{tags}});
  $rs->update;
  $self->read;
}

sub mappings {
  my $self = shift;

  my $rs = $self->stash('project_schema')->resultset($self->resultset)->find($self->param('transcriptId'));
  unless($rs) {
    $self->app->log->debug('not found:'.$self->param('transcriptId'));
    return $self->reply->not_found;
  }

  my $maps = $rs->filtered_mappings;
  my @ret;
  for my $m (@$maps) {
    my $m_ser = $m->TO_JSON;
    $m_ser->{annotations} = [ $m->annotations ];
    push @ret, $m_ser;
  }
  $self->render(json => \@ret);
}

sub blast_results {
  my $self = shift;
  my $rs = $self->stash('project_schema')->resultset($self->resultset)->find($self->param('transcriptId'));
  unless($rs) {
    $self->app->log->debug('not found:'.$self->param('transcriptId'));
    return $self->reply->not_found;
  }
  my @ret;
  for my $bl ($rs->search_related('blast_results', undef, { prefetch => 'db_source' })) {
    my $bl_ser = $bl->TO_JSON;
    $bl_ser->{db_source}=$bl->db_source->description;
    push @ret, $bl_ser;
  }
  $self->render(json => \@ret);
}

sub run_blast {
  my $self = shift;
  my $rs = $self->stash('project_schema')->resultset($self->resultset)->find($self->param('transcriptId'));
  unless($rs) {
    $self->app->log->debug('not found:'.$self->param('transcriptId'));
    return $self->reply->not_found;
  }
  my $db = $self->stash('project_schema')->resultset('DbSource')->search({
    name => $self->param('database') || 'refseq_plant'
  })->first;
  unless($db) {
    return $self->reply->not_found;
  }
  my $task = new TearDrop::Task::BLAST(transcript_id => $rs->id, database => $db->name, project => $self->stash('project')->name);
  my $item = $self->app->worker->enqueue($task);
  $self->render(json => { id => $item->id, status => $item->status });
}

sub blast_runs {
  my $self = shift;
  my $rs = $self->stash('project_schema')->resultset($self->resultset)->find($self->param('transcriptId'));
  unless($rs) {
    $self->app->log->debug('not found:'.$self->param('transcriptId'));
    return $self->reply->not_found;
  }
  my %blast_runs;
  for my $br ($rs->blast_runs) {
    next unless $br->finished;
    my $br_ser = $br->TO_JSON;
    $br_ser->{db_source}=$br->db_source->TO_JSON;
    $blast_runs{$br->db_source->name} ||= $br_ser;
    my $hit_count = $rs->search_related('blast_results', {
      db_source_id => $br->db_source_id
    })->count;
    $blast_runs{$br->db_source->name}->{hits} += $hit_count;
  }
  $self->render(json => [ values %blast_runs ]);
}

sub pileup {
  my $self = shift;
  my $rs = $self->stash('project_schema')->resultset($self->resultset)->find($self->param('transcriptId'));
  unless($rs) {
    $self->app->log->debug('not found:'.$self->param('transcriptId'));
    return $self->reply->not_found;
  }
  my $assembly = $rs->assembly || die 'assembly '.$rs->assembly_id.' not found';

  my @alns = $assembly->transcriptome_alignments;
  die 'no alignments for transcript' unless @alns;

  # XXX should check if original_id settings is consistent for all alignments
  my $pileup = TearDrop::Task::Mpileup->new(
    reference_path => $assembly->path,
    region => $alns[0]->use_original_id ? $rs->original_id : $rs->id,
    effective_length => length($rs->nsequence),
    context => 0,
    type => 'transcript',
    alignments => [ map { $_->alignment } @alns ],
  )->run;
  $self->render(json => $pileup);
};

1;
