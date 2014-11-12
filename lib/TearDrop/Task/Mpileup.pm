package TearDrop::Task::Mpileup;

use warnings;
use strict;

use Dancer ':moose';
use Dancer::Plugin::DBIC;
use Mouse;

extends 'TearDrop::Task';

use Carp;
use IPC::Run 'harness';
use POSIX 'ceil';

has 'reference_path' => ( is => 'rw', isa => 'Str' );
has 'region' => ( is => 'rw', isa => 'Str' );
has 'start' => ( is => 'rw', isa => 'Int | Undef' );
sub effective_start {
  $_[0]->start - $_[0]->context
}
has 'end' => ( is => 'rw', isa => 'Int | Undef' );
sub effective_end {
  $_[0]->end + $_[0]->context
}
has 'context' => ( is => 'rw', isa => 'Int', default => 0 );
has 'aggregate_to' => ( is => 'rw', isa => 'Int', default => 750 );
has 'effective_size' => ( is => 'rw', isa => 'Int | Undef' );

sub region_spec {
  my $self = shift;
  $self->type eq 'genome' ? 
    sprintf("%s:%d-%d" => $self->region, $self->effective_start, $self->effective_end) : 
    $self->region;
}

has 'type' => ( is => 'rw', isa => 'Str', default => 'transcript' );

has 'alignments' => ( is => 'rw', isa => 'ArrayRef', default => sub { [] }, traits => [ 'Array' ], 
  handles => { 
    filter_alignments => 'grep',
    alignments_count => 'count',
  },
);

my %cache;

sub run {
  my $self = shift;

  unless($self->reference_path) {
    confess 'no reference fasta';
  }
  unless($self->alignments_count) {
    confess 'nothing to extract!';
  }
  unless($self->region) {
    confess 'please provide region (won\'t read whole alignment)';
  }
  if ($self->type eq 'genome') { 
    confess 'need start/end coordinates for genomic regions' unless defined $self->start && defined $self->end;
    $self->effective_size($self->effective_end - $self->effective_start);
    confess 'negative region: '.$self->start.' - '.$self->end if ($self->effective_size < 0);
  }
  elsif ($self->type eq 'transcript') {
    confess 'need effective size' unless $self->effective_size;
  }
  else {
    confess 'invalid alignment type '.$self->type;
  }
  my $aln_key = sprintf "%s %s", $self->reference_path, $self->region_spec;
  $cache{$aln_key}||={};
  my $cache = $cache{$aln_key};

  my @run_alignments = grep { !exists $cache->{$_->bam_path} } @{$self->alignments};
#  use Bio::DB::Sam;
#  for my $aln (@run_alignments) {
#    my $sam = Bio::DB::Sam->new(-bam => $aln->bam_path, -fasta => $self->reference_path);
#    $sam->fast_pileup($self->region_spec, sub {
#      my ($seqid, $pos, $p) = @_;
#      my $refbase = $sam->segment($seqid,$pos,$pos)->dna;
#      my $mismatch=0;
#      my $depth=0;
#      for my $pileup (@$p) {
#        $depth++;
#        if ($pileup->indel || $pileup->is_refskip) {
#          $mismatch++;
#          next;
#        }
#        my $b = $pileup->alignment;
#        my $qbase  = substr($b->qseq,$pileup->qpos,1);
#        $mismatch++ if $refbase ne $qbase;
#      }
#      push @{$cache->{$aln->bam_path}}, {
#        pos => $pos,
#        depth => $depth,
#        mismatch => $mismatch,
#        mismatch_rate => $depth>0 ? $mismatch/$depth : 0,
#      };
#    });
#  }

  if (@run_alignments) {
    my @cmd = ('ext/samtools/mpileup.sh', $self->reference_path, $self->region_spec, map { $_->bam_path } @run_alignments);
    debug 'running '.join(' ', @cmd);
    my ($out, $err);
    my $mp = harness \@cmd, \undef, \$out, \$err;
    $mp->run or confess "unable to run mpileup: $? $err";

    $cache->{$_->bam_path} = [] for @run_alignments;
    for my $l (split "\n", $out) {
      my @f = split "\t", $l;
      my $i=1;
      for my $aln (@run_alignments) {
        my $depth=0; my $mismatch=0;
        if (defined $f[$i*3+1]) {
          $depth = () = $f[$i*3+1] =~ m#[\.\,]#g;
          $mismatch = () = $f[$i*3+1] =~ m#[ACGTN]#gi;
          $depth+=$mismatch;
        }
        push @{$cache->{$aln->bam_path}}, {
          pos => $f[1]+0,
          depth => $depth,
          mismatch => $mismatch+0,
          mismatch_rate => $depth>0 ? $mismatch/$depth : 0,
        };
        $i++;
      }
    }
  }
  $cache{$aln_key}=$cache;

  my $aggregate_factor = ceil($self->effective_size/$self->aggregate_to);
  my @ret;
  for my $aln (@{$self->alignments}) {
    my $r = { key => $aln->sample->name, bins => {} };
    for my $p (@{$cache->{$aln->bam_path}}) {
      my $bin = int($p->{pos}/$aggregate_factor);
      $r->{bins}{$bin}||=[];
      push @{$r->{bins}{$bin}}, $p;
    }
    push @ret, $r;
  }
  for my $r (@ret) {
    $r->{values}=[];
    for my $bins (values %{$r->{bins}}) {
      my $pos=$bins->[0]{pos};
      my $sum_depth=0;
      my $max_mismatch=0;
      my $max_mismatch_rate=0;
      for my $b (@$bins) {
        $sum_depth+=$b->{depth};
        $max_mismatch=$b->{mismatch} if $b->{mismatch}>$max_mismatch;
        $max_mismatch_rate=$b->{mismatch_rate} if $b->{mismatch}>$max_mismatch_rate;
      }
      push @{$r->{values}}, [ $pos, $sum_depth/scalar @$bins, $max_mismatch, $max_mismatch_rate ];
    }
    $r->{values} = [ sort { $a->[0] <=> $b->[0] } @{$r->{values}} ];
    delete $r->{bins};
  }
  $self->result([ sort { $a->{key} cmp $b->{key} } @ret ]);
#  $self->result([ map {
#    { 
#      key => $_->sample->name,
#      values => [ map {
#        [ $_->{pos}, $_->{depth}, $_->{mismatch}, $_->{mismatch_rate} ],
#      } grep { $_->{pos} % $aggregate_factor == 0 } @{$cache->{$_->bam_path}} ],
#    }
#  } sort { $a->sample->name cmp $b->sample->name } @{$self->alignments} ]);
  $self->result;
}

1;
