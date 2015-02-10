package TearDrop::Controller::Assembly;
use Mojo::Base 'Mojolicious::Controller';

use 5.12.0;

use warnings;
use strict;

use Carp;
use TearDrop::Task::ReverseBLAST;
use Mojo::JSON qw/decode_json/;

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


  my %blast_param = (
    project => $self->stash('project')->name,
  );
  my $req_params = $self->req->params->to_hash;
  if ($self->req->method eq 'POST') {
    my $p = decode_json($self->req->body);
    for my $k (keys %$p) {
      $req_params->{$k}=$p->{$k};
    }
  }
  $req_params->{assemblyId} ||= $self->param('assemblyId');
  if($req_params->{sequence}) {
    my $seq = $req_params->{sequence};
    $blast_param{sequences}={ 'noName' => $seq };
    $blast_param{query_type}=$req_params->{type};
  }
  else {
    croak 'need database name' unless $req_params->{database};
    my $db = $self->stash('project_schema')->resultset('DbSource')->search({
      name => $req_params->{database},
    })->first || croak 'db not found';

    croak 'need at least one entry id' unless scalar @{$req_params->{entry}};
    $blast_param{database} = $db->name;
    $blast_param{entries} = $req_params->{entry};
  }
  if ($req_params->{assemblyId}) {
    my $rs = $self->stash('project_schema')->resultset($self->resultset)->find($req_params->{'assemblyId'}) || croak 'not found';
    $blast_param{assembly} = $rs->name;
  }
  elsif ($req_params->{'transcript_id'}) {
    my $rs = $self->stash('project_schema')->resultset('Transcript')->find($req_params->{'transcript_id'}, { prefetch => 'assembly' }) || croak 'Transcript not found';
    $blast_param{assembly} = $rs->assembly->name;
  }
  elsif ($req_params->{'gene_id'}) {
    my $rs = $self->stash('project_schema')->resultset('Gene')->find($req_params->{'gene_id'}, { prefetch => [{ 'transcripts' => 'assembly' }] }) || croak 'Gene not found';
    $blast_param{assembly} = $rs->transcripts->first->assembly->name;
  }
  croak 'need assembly, transcript or gene parameters' unless $blast_param{assembly};

  $blast_param{evalue_cutoff} = $req_params->{'evalue_cutoff'} if defined $req_params->{'evalue_cutoff'};
  $blast_param{max_target_seqs} = $req_params->{'max_target_seqs'} if defined $req_params->{'max_target_seqs'};

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
