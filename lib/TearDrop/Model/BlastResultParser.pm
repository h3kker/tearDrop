package TearDrop::Model::BlastResultParser;

use 5.12.0;

use warnings;
use strict;

use Moo::Role;
use namespace::clean;
use Try::Tiny;
use Carp;

requires qw(set_query_sequence_id set_source_sequence_id);

has 'field_map' => (
  is => 'rw', default => sub {
    {
      'set_query_sequence_id' => 0,
      'set_source_sequence_id' => 1,
      'bitscore' => 2,
      'qlen' => 3,
      'length' => 4,
      'nident' => 5,
      'pident' => 6,
      'ppos' => 7,
      'evalue' => 8,
      'slen' => 9,
      'qseq' => 10,
      'sseq' => 11,
      'qstart' => 12,
      'qend' => 13,
      'sstart' => 14,
      'send' => 15,
      'stitle' => 16,
    }
  }
);

sub parse_line {
  my ($self, $line) = @_;
  my @f = split "\t", $line;
  for my $meth (keys %{$self->field_map}) {
    $self->$meth($f[$self->field_map->{$meth}]);
  }
}

1;
