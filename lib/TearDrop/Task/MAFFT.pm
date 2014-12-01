package TearDrop::Task::MAFFT;

use warnings;
use strict;

use Mouse;

extends 'TearDrop::Task';

use Carp;
use IPC::Run 'harness';

has 'transcripts' => ( is => 'rw', isa => 'ArrayRef', default => sub { [] } );
has 'algorithm' => ( is => 'rw', isa => 'Str', default => 'FFT-NS-i' );

use File::Temp ();

sub run {
  my $self = shift;

  my $exe = sprintf "ext/mafft/mafft_%s.sh", $self->algorithm;
  confess 'No script $exe exists, invalid algorithm?' unless -f $exe;

  my $seq_f = File::Temp->new();
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
      $msa->{$cur_id}={id => $cur_id, seq => '', blocks => []};
    }
    elsif ($cur_id) {
      $msa->{$cur_id}{seq}.=$l;
    }
  }
  for my $t (keys %$msa) {
    my $cur=0;
    my $cur_block;
    my $match=0;
    my $state='init';
    for my $c (split '', $msa->{$t}{seq}) {
      if ($c ne '-' && $state ne 'match') {
        $state='match';
        $cur_block=[$cur, $cur];
        $match++;
      }
      elsif ($c ne '-') {
        $match++;
        $cur_block->[1]=$cur;
      }
      elsif ($c eq '-' && $state ne 'gap') {
        $state='gap';
        push @{$msa->{$t}{blocks}}, $cur_block if $cur_block;
      }
      $cur++;
    }
    push @{$msa->{$t}{blocks}}, $cur_block if $cur_block;
    $msa->{$t}{match}=$match;
    $msa->{$t}{match_ratio}=$match/length($msa->{$t}{seq});
  }
  [ sort { $b->{match_ratio} <=> $a->{match_ratio} } values %$msa ];
}

1;
