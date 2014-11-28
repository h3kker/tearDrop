package TearDrop::Task::ReverseBLAST;

use 5.12.0;

use warnings;
use strict;

use Mouse;

extends 'TearDrop::Task::BlastBase';

use Carp;
use Try::Tiny;
use IPC::Run qw/harness io/;
use File::Temp;

has 'dbtype_query_scripts' => ( is => 'rw', isa => 'HashRef', default => sub {
  {
    dbcmd => 'ext/blast/dbcmd.sh',
    prot => 'ext/blast/tblastn.sh',
    nucl => 'ext/blast/blastn.sh',
  }
});

has 'query_type' => ( is => 'rw', isa => 'Str', default => 'prot' );
has 'assembly' => ( is => 'rw', isa => 'Str' );
has 'entries' => ( is => 'rw', isa => 'ArrayRef[Str]', traits => ['Array'], 
  handles => {
    has_entries => 'count',
  },
  default => sub { [] },
);

sub run {
  my $self = shift;

  for my $f (qw/database assembly/) {
    confess 'No '.$f.' defined' unless $self->$f;
  }
  confess 'Nothing to blast!' unless $self->has_entries || $self->has_sequences;

  my $assembly = $self->app->schema($self->project)->resultset('TranscriptAssembly')->search({ name => $self->assembly })->first || confess "Invalid assembly: ".$self->assembly;

  my $fasta = File::Temp->new;
  $fasta->unlink_on_destroy(0);
  my $db_source;
  if ($self->has_entries) {
    $self->app->log->debug("Extracting ".join(",", @{$self->entries}));
    $db_source = $self->app->schema($self->project)->resultset('DbSource')->search({ name => $self->database })->first || confess "Invalid db source: ".$self->database;
    my $err;
    my @ext_cmd = ($self->dbtype_query_scripts->{dbcmd}, $db_source->path);
    my $ext = harness \@ext_cmd, "<pipe", \*IN, ">", $fasta->filename, "2>", \$err;
    $self->app->log->debug("Running ".join(" ", @ext_cmd));
    $ext->start or confess "Unable to run blastdbcmd: $err $?";
    confess $err if $err;
    print IN join("\n", @{$self->entries})."\n";
    close IN;
    $ext->finish;
    $self->app->log->debug("Extracted sequences to ".$fasta->filename);
  }
  elsif ($self->has_sequences) {
    $self->app->log->debug("adding ".scalar keys %{$self->sequences}." fasta sequences");
    for my $n (keys %{$self->sequences}) {
      print $fasta "> ".$n."\n";
      print $fasta $self->sequences->{$n}."\n";
    }
  }
  unless(-s $fasta->filename) {
    confess 'Query file is empty, something went wrong (entries not found?)';
  }
  my $script = $self->dbtype_query_scripts->{$self->query_type} ||
    confess "don't know how to handle ".$self->query_type;
  my @cmd = ($script, $assembly->path, $fasta->filename, $self->evalue_cutoff, $self->max_target_seqs);
  $self->app->log->debug("Running ".join(" ", @cmd));
  my @entries;
  try {
    my $out;
    my $err;
    my $blast = harness \@cmd, \undef, \$out, \$err;
    $blast->run or confess "Unable to run blast command: $err $?";
    if ($err) {
      confess $err;
    }
    for my $l (split "\n", $out) {
      push @entries, $assembly->add_blast_result($l, $db_source);
    }
  }
  catch {
    confess 'BLAST failed: '.$_;
  };
  \@entries;
}

1;
