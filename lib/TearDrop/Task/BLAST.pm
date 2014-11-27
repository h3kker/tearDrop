package TearDrop::Task::BLAST;

use warnings;
use strict;

use Mouse;

extends 'TearDrop::Task';

use Carp;
use Try::Tiny;
use IPC::Run 'harness';
use File::Temp ();

has 'transcript_id' => ( is => 'rw', isa => 'Str' );
has 'gene_id' => ( is => 'rw', isa => 'Str' );
has 'gene_ids' => ( is => 'rw', isa => 'ArrayRef[Str]', traits => ['Array'], handles => {
    has_gene_ids => 'count',
    all_gene_ids => 'elements',
  },
  default => sub { [] },
);
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

sub do_post_processing {
  my $self = shift;
  my @genes = $self->has_gene_ids ? $self->all_gene_ids : ( $self->gene_id || $self->transcript_id );
  for my $g (@genes) {
    my $sg = $self->app->schema($self->project)->resultset('Gene')->find($g);
    return if $sg->reviewed;
    for my $t ($sg->transcripts) {
      $t->auto_annotate;
    }
    $sg->auto_annotate;
  }
}

sub run {
  my $self = shift;

  my $db_source = $self->app->schema($self->project)->resultset('DbSource')->search({ name => $self->database })->first;
  unless($db_source) {
    confess 'Unknown database source '.$self->database;
  }
  my $exe = $self->dbtype_query_scripts->{$db_source->dbtype} || confess "don't know how to handle ".$db_source->dbtype." databases!";

  my @transcripts;
  if ($self->has_gene_ids) {
    my $genes = $self->app->schema($self->project)->resultset('Gene')->search({ 'me.id' => $self->gene_ids }, { prefetch => 'transcripts' });
    for my $g ($genes->all) {
      for my $trans ($g->transcripts) {
        push @transcripts, $trans;
      }
    }
  }
  elsif ($self->gene_id) {
    my $gene = $self->app->schema($self->project)->resultset('Gene')->find($self->gene_id);
    confess 'Unknown gene '.$self->gene_id unless defined $gene;
    for my $trans ($gene->transcripts) {
      push @transcripts, $trans;
    }
  }
  elsif ($self->transcript_id) {
    my $trans = $self->app->schema($self->project)->resultset('Transcript')->find($self->transcript_id);
    confess 'Unknown transcript '.$self->transcript_id unless defined $trans;
    push @transcripts, $trans;
  }
  else {
    confess 'Need gene_id(s) or transcript_id';
  }
  my $seq_f = File::Temp->new;
  my $kept=0;
  my @blast_runs;
  my @cmd = ($exe, $db_source->path, $seq_f->filename, $self->evalue_cutoff, $self->max_target_seqs);
  #my @cmd = ('sleep', 10);
  for my $trans (@transcripts) {
    if (!$self->replace && $self->app->schema($self->project)->resultset('BlastRun')->search({ transcript_id => $trans->id, db_source_id => $db_source->id, finished => 1 })->first) {
      $self->app->log->debug('Transcript '.$trans->id.' already blasted against '.$db_source->name.', skipping');
      next;
    }
    push @blast_runs, $self->app->schema($self->project)->resultset('BlastRun')->update_or_create({
      transcript_id => $trans->id, db_source_id => $db_source->id, parameters => join(" ", @cmd), finished => 0
    });
    $self->app->schema($self->project)->resultset('BlastResult')->search({
      transcript_id => $trans->id, db_source_id => $db_source->id
    })->delete;
    print $seq_f $trans->to_fasta."\n";
    $kept++;
  }
  unless ($kept) {
    $self->app->log->debug('no transcripts to blast, finished');
    $self->do_post_processing if $self->post_processing;
    return;
  }

  $self->app->log->debug('running BLAST on '.$kept.' transcripts.');

  try {
    my $out;
    my $err;
    my $blast = harness \@cmd, \undef, \$out, \$err;
    $blast->run or confess "unable to run blast command: $err $?";
    if ($err) {
      confess $err;
    }
    for my $l (split "\n", $out) {
      $db_source->add_result($l);
    }
    for my $r (@blast_runs) {
      $r->finished(1);
      $r->update;
    }
  } catch {
    for my $r (@blast_runs) {
      $r->delete unless $r->finished;
    }
  };
  $self->do_post_processing if ($self->post_processing);
}

1;
