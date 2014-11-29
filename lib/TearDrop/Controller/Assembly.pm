package TearDrop::Controller::Assembly;
use Mojo::Base 'Mojolicious::Controller';

use 5.12.0;

use warnings;
use strict;

use Carp;
use TearDrop::Task::ReverseBLAST;

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

sub run_blast {
  my $self = shift;


  croak 'need database name' unless $self->param('database');
  my $db = $self->stash('project_schema')->resultset('DbSource')->search({
    name => $self->param('database')
  })->first || croak 'db not found';

  croak 'need at least one entry id' unless scalar @{$self->every_param('entry')};

  my %blast_param = (
    project => $self->stash('project')->name,
    database => $db->name,
    entries => $self->every_param('entry'),
  );
  if ($self->param('assemblyId')) {
    my $rs = $self->stash('project_schema')->resultset($self->resultset)->find($self->param('assemblyId')) || croak 'not found';
    $blast_param{assembly} = $rs->name;
  }
  elsif ($self->param('transcript_id')) {
    my $rs = $self->stash('project_schema')->resultset('Transcript')->find($self->param('transcript_id'), { prefetch => 'assembly' }) || croak 'Transcript not found';
    $blast_param{assembly} = $rs->assembly->name;
  }
  elsif ($self->param('gene_id')) {
    my $rs = $self->stash('project_schema')->resultset('Gene')->find($self->param('gene_id'), { prefetch => [{ 'transcripts' => 'assembly' }] }) || croak 'Gene not found';
    $blast_param{assembly} = $rs->transcripts->first->assembly->name;
  }
  croak 'need assembly, transcript or gene parameters' unless $blast_param{assembly};

  $blast_param{evalue_cutoff} = $self->param('evalue_cutoff') if defined $self->param('evalue_cutoff');
  $blast_param{max_target_seqs} = $self->param('max_target_seqs') if defined $self->param('max_target_seqs');

  my $task = new TearDrop::Task::ReverseBLAST(%blast_param);
  # run directly, usually doesn't take too long.
  my $result = $task->run;
  my @ret;
  for my $r (@$result) {
    my $ser = $r->TO_JSON;
    $ser->{transcript} = $r->transcript;
    $ser->{db_source} = $r->db_source;
    push @ret, $ser;
  }
  $self->render(json => \@ret);
}

sub blast_results {
  my $self = shift;

  my %filters; my $prefetch = [ 'db_source', 'transcript' ];
  if ($self->param('assemblyId')) {
    $filters{'me.transcript_assembly_id'} = $self->param('assemblyId');
  }
  if ($self->param('gene_id')) {
    $filters{'transcript.gene_id'} = $self->param('gene_id');
  }
  if ($self->param('transcript_id')) {
    $filters{'me.transcript_id'} = $self->param('transcript_id');
  }
  if ($self->param('source_sequence_id')) {
    $filters{'me.source_sequence_id'} = $self->param('source_sequence_id');
  }
  if ($self->param('database')) {
    $filters{'db_source.name'} = $self->param('database');
  }

  my @ret;
  for my $r ($self->stash('project_schema')->resultset('ReverseBlastResult')->search(\%filters, { prefetch => $prefetch })) {
    my $ser = $r->TO_JSON;
    $ser->{transcript} = $r->transcript;
    $ser->{db_source} = $r->db_source;
    push @ret, $ser;
  }
  $self->render(json => \@ret);
}

1;
