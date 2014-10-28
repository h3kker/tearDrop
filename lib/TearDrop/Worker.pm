package TearDrop::Worker;

use Dancer ':syntax';
use Dancer::Plugin::DBIC 'schema';

use Try::Tiny;
use Parallel::ForkManager;

my $pm = Parallel::ForkManager->new(4);

my %status = (
  queue => [],
  running => {},
  failed => {},
);
my %jobs;

$pm->run_on_finish(sub {
  my ($pid, $code) = @_;
  debug "child $pid finished";
  my $job = delete $status{running}->{$pid};
  if ($code) {
    debug "setting $pid to failed";
    $job->pid(undef);
    $job->status('failed');
    $status{failed}->{$pid} = $job;
  }
  else {
    $job->status('done');
  }
});
$pm->run_on_start(sub {
  my ($pid, $id) = @_;
  debug 'process '.$pid.' started';
  my $j = shift @{$status{queue}};
  $j->pid($pid);
  $j->status('running');
  $status{running}->{$pid} = $j;
  $jobs{$pid}=$j;
});

sub TearDrop::Worker::enqueue {
  my $item = shift;
  $item->status('queued');
  push @{$status{queue}}, $item;
  $pm->start and return;
  debug $item;
  try {
    $item->run;
    debug 'done';
  } catch {
    error $_;
    $pm->finish(-1);
  };
  debug 'process finished';
  $pm->finish;
}

sub TearDrop::Worker::get_status {
  $pm->wait_children;
  return {
    pending => scalar @{$status{queue}},
    failed => scalar keys %{$status{failed}},
    running => scalar keys %{$status{running}},
  };
}

sub TearDrop::Worker::get_job_status {
  my $pid = shift;
  $pm->wait_children;
  if ($jobs{$pid}) {
    return {
      pid => $jobs{$pid}->pid,
      status => $jobs{$pid}->status,
    }
  }
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

has 'pid' => ( is => 'rw', isa => 'Int | Undef' );
has 'status' => ( is => 'rw', isa => 'Str | Undef' );

sub run {
  my $self = shift;

  my $db_source = schema->resultset('DbSource')->search({ name => $self->database })->first;
  unless($db_source) {
    confess 'Unknown database source '.$self->database;
  }
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
  my $seq_f = File::Temp->new();
  my $kept=0;
  for my $trans (@transcripts) {
    if (schema->resultset('BlastRun')->search({ transcript_id => $trans->id, db_source_id => $db_source->id})->first) {
      debug 'Transcript '.$trans->id.' already blasted against '.$db_source->name.', skipping';
      next;
    }
    schema->resultset('BlastRun')->create({
      transcript_id => $trans->id, db_source_id => $db_source->id, parameters => 'XXX'
    });
    print $seq_f $trans->to_fasta;
    $kept++;
  }
  unless ($kept) {
    debug 'no transcripts to blast, finished';
    return;
  }

  my @cmd = ('ext/blast/run_blast.sh', $db_source->path, $seq_f->filename);
  #my @cmd = ('sleep', 10);
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
