package TearDrop::Worker;

use Dancer ':syntax';
use Dancer::Plugin::DBIC 'schema';

use Try::Tiny;
use Thread::Queue;
use Parallel::ForkManager;

my $work_queue = Thread::Queue->new();

my $worker;

sub TearDrop::Worker::start_worker {
  return;
  return unless config->{start_worker};
  $worker ||= threads->create(sub {
    debug 'start worker';
    while(defined(my $item = $work_queue->dequeue(1))) {
      debug $item;
      try {
        $item->run;
        debug 'done';
      } catch {
        error $_;
      };
    }
    debug 'finished';
  })->detach;
}

use Parallel::ForkManager;
my $pm = Parallel::ForkManager->new(4);

sub TearDrop::Worker::enqueue {
  my $item = shift;
  return unless config->{start_worker};
  #$work_queue->enqueue($item);
  $pm->start and return;
  debug $item;
  try {
    $item->run;
    debug 'done';
  } catch {
    error $_;
  };
  $pm->finish;
}

sub TearDrop::Worker::get_status {
  debug $work_queue->pending;
  return {
    pending => $work_queue->pending,
  };
}

1;

package TearDrop::Task::BLAST;

use Dancer ':moose';
use Dancer::Plugin::DBIC;
use Mouse;
use Carp;
use File::Temp ();
use IPC::Run 'harness';

has 'transcript_id' => ( is => 'rw', isa => 'Str' );
has 'gene_id' => ( is => 'rw', isa => 'Str' );
has 'sequences' => ( is => 'rw', isa => 'HashRef[Str]' );

has 'database' => ( is => 'rw', isa => 'Str' );

has 'replace' => ( is => 'rw', isa => 'Bool', default => 0 );

sub run {
  my $self = shift;

  my $db_source = schema->resultset('DbSource')->search({ description => $self->database })->first;
  unless($db_source) {
    confess 'Unknown database source '.$self->database;
  }
  my $seq_f = File::Temp->new();
  if ($self->gene_id) {
    my $gene = schema->resultset('Gene')->find($self->gene_id);
    confess 'Unknown gene '.$self->gene_id unless defined $gene;
    for my $trans ($gene->search_related('transcripts')->all) {
      print $seq_f $trans->to_fasta;
    }
  }
  elsif ($self->transcript_id) {
    my $trans = schema->resultset('Transcript')->find($self->transcript_id);
    confess 'Unknown transcript '.$self->transcript_id unless defined $trans;
    print $seq_f $trans->to_fasta;
  }
  else {
    confess 'Need gene_id or transcript_id';
  }

  #my @cmd = ('ext/blast/run_blast.sh', $db_source->path, $seq_f->filename);
  my @cmd = ('sleep', 10);
  my $out;
  my $err;
  my $blast = harness \@cmd, \undef, \$out, \$err;
  $blast->run or confess "unable to run blast command: $err $?";
  if ($err) {
    confess $err;
  }
  for my $l (split "\n", $out) {
    my @f = split "\t", $l;
    schema->resultset('BlastResult')->find_or_create({
      transcript_id => $f[0],
      parameters => 'XXX',
      db_source_id => $db_source->id,
      source_sequence_id => $f[1],
      bitscore => $f[2],
      length => $f[4],
      nident => $f[5],
      pident => $f[6],
      ppos => $f[7],
      evalue => $f[8],
      slen => $f[9],
      qlen => $f[3],
      stitle => $f[10]
    });
  }
}

1;
