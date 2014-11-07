package TearDrop::Task::MAFFT;

use warnings;
use strict;

use Dancer ':moose';
use Dancer::Plugin::DBIC;
use Mouse;

extends 'TearDrop::Task';

use Carp;
use IPC::Run 'harness';

has 'transcripts' => ( is => 'rw', isa => 'ArrayRef', default => sub { [] } );
has 'algorithm' => ( is => 'rw', isa => 'Str', default => 'FFT-NS-i' );

sub run {
  my $self = shift;

  my $exe = sprintf "ext/mafft/mafft_%s.sh", $self->algorithm;
  confess 'No script $exe exists, invalid algorithm?' unless -f $exe;

  my $seq_f = $self->tmpfile;
  for my $trans (@{$self->transcripts}) {
    print $seq_f $trans->to_fasta."\n";
  }

  my @cmd = ($exe, $seq_f->filename);
  my $out;
  my $err;
  
  my $mafft = harness \@cmd, \undef, \$out, \$err;
  $mafft->run or confess "unable to run mafft: $? $err";
  my $msa;
  my $cur_id;
  for my $l (split "\n", $out) {
    if ($l =~ m#^>\s*([^\s]+)\s*#) {
      $cur_id=$1;
      $msa->{$cur_id}={
        key => $cur_id,
        last_pos => 0,
        values => [],
      };
    }
    elsif ($cur_id) {
      for my $c (split '', $l) {
        push @{$msa->{$cur_id}{values}}, [$msa->{$cur_id}{last_pos}++, $c eq '-' ? 0 : 1];
      }
    }
  }
  $self->result([ sort { $a->{key} cmp $b->{key} } values %$msa ]);
}

1;
