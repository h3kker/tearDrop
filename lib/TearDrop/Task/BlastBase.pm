package TearDrop::Task::BlastBase;

use 5.8.12;

use warnings;
use strict;

use Mouse;

extends 'TearDrop::Task';

use Carp;
use Try::Tiny;

has 'sequences' => ( is => 'rw', isa => 'HashRef[Str]', traits => ['Hash'], 
  default => sub { {} },  
  handles => {
    'has_sequences' => 'count',
    'seqnames' => 'keys',
    'seqs' => 'values',
  },
);
has 'evalue_cutoff' => ( is => 'rw', isa => 'Num', default => .01 );
has 'max_target_seqs' => ( is => 'rw', isa => 'Int', default => 20 );

has 'database' => ( is => 'rw', isa => 'Str' );

1;
