package TearDrop::Task::BLAST;

use warnings;
use strict;


use Dancer qw/:moose !status/;
use Dancer::Plugin::DBIC;
use Mouse;

extends 'TearDrop::Task';

use Carp;
use IPC::Run 'harness';

has 'transcript_id' => ( is => 'rw', isa => 'Str' );
has 'gene_id' => ( is => 'rw', isa => 'Str' );
has 'sequences' => ( is => 'rw', isa => 'HashRef[Str]' );

has 'evalue_cutoff' => ( is => 'rw', isa => 'Num', default => .01 );
has 'max_target_seqs' => ( is => 'rw', isa => 'Int', default => 20 );

has 'database' => ( is => 'rw', isa => 'Str' );

has 'replace' => ( is => 'rw', isa => 'Bool', default => 0 );

has 'dbtype_query_scripts' => ( is => 'rw', isa => 'HashRef', default => sub {
    { 
      blastp => 'ext/blast/blastx.sh',
      rpsblast => 'ext/blast/rpstblastn.sh',
    }
  },
);

sub run {
  my $self = shift;

  my $db_source = schema->resultset('DbSource')->search({ name => $self->database })->first;
  unless($db_source) {
    confess 'Unknown database source '.$self->database;
  }
  my $exe = $self->dbtype_query_scripts->{$db_source->dbtype} || confess "don't know how to handle ".$db_source->dbtype." databases!";

  my @transcripts;
  if ($self->gene_id) {
    my $gene = schema->resultset('Gene')->find($self->gene_id);
    confess 'Unknown gene '.$self->gene_id unless defined $gene;
    for my $trans ($gene->search_related('transcripts')->all) {
      push @transcripts, $trans;
    }
  }
  elsif ($self->transcript_id) {
    my $trans = schema->resultset('Transcript')->find($self->transcript_id);
    confess 'Unknown transcript '.$self->transcript_id unless defined $trans;
    push @transcripts, $trans;
  }
  else {
    confess 'Need gene_id or transcript_id';
  }
  my $seq_f = $self->tmpfile;
  my $kept=0;
  my @blast_runs;
  my @cmd = ($exe, $db_source->path, $seq_f->filename, $self->evalue_cutoff, $self->max_target_seqs);
  #my @cmd = ('sleep', 10);
  for my $trans (@transcripts) {
    if (!$self->replace && schema->resultset('BlastRun')->search({ transcript_id => $trans->id, db_source_id => $db_source->id})->first) {
      debug 'Transcript '.$trans->id.' already blasted against '.$db_source->name.', skipping';
      next;
    }
    push @blast_runs, schema->resultset('BlastRun')->update_or_create({
      transcript_id => $trans->id, db_source_id => $db_source->id, parameters => join(" ", @cmd), finished => 0
    });
    schema->resultset('BlastResult')->search({
      transcript_id => $trans->id, db_source_id => $db_source->id
    })->delete;
    print $seq_f $trans->to_fasta."\n";
    $kept++;
  }
  unless ($kept) {
    debug 'no transcripts to blast, finished';
    return;
  }

  my $out;
  my $err;
  my $blast = harness \@cmd, \undef, \$out, \$err;
  $blast->run or confess "unable to run blast command: $err $?";
  if ($err) {
    confess $err;
  }
  for my $l (split "\n", $out) {
    my @f = split "\t", $l;
    schema->resultset('BlastResult')->update_or_create({
      transcript_id => $f[0],
      db_source_id => $db_source->id,
      source_sequence_id => $f[1],
      bitscore => $f[2],
      qlen => $f[3],
      length => $f[4],
      nident => $f[5],
      pident => $f[6],
      ppos => $f[7],
      evalue => $f[8],
      slen => $f[9],
      qseq => $f[10],
      sseq => $f[11],
      qstart => $f[12],
      qend => $f[13],
      sstart => $f[14],
      send => $f[15],
      stitle => $f[16]
    });
  }
  for my $r (@blast_runs) {
    $r->finished(1);
    $r->update;
  }
  if ($self->has_post_processing) {
    $self->post_processing->($self);
  }
}

1;
