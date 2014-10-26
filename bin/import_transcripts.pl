#!/usr/bin/perl

use warnings;
use strict;

use Dancer ':script';
use Dancer::Plugin::DBIC 'schema';

my $assembly = shift @ARGV;
my $fasta = shift @ARGV;

die "Usage: $0 [assembly name] [fasta]?" unless $assembly;

my $a = schema->resultset('TranscriptAssembly')->search({ name => $assembly })->first;
die "Assembly $assembly not in database!" unless $a;

schema->resultset('Transcript')->search({ assembly_id => $a->id })->delete;

if ($fasta && $fasta ne $a->path) {
  $a->path($fasta);
  $a->update;
}

$fasta = $a->path;
open(FA, "<$fasta") or die "open $fasta: $!";
my $cur_trans;
while(<FA>) {
  chomp;
  if (m/^>\s*([^ ]+)\s*/) {
    if ($cur_trans) {
      print "Insert ".$cur_trans->{id}."             \r";
      $|=1;
      schema->resultset('Transcript')->create($cur_trans);
    }
    my $trans_id=$1;
    my $gene = $trans_id;
    $gene =~ s/_i.+//;
    $cur_trans={
      id => $trans_id,
      assembly_id => $a->id,
      gene => $gene,
      sequence => '',
    }
  }
  else {
    $cur_trans->{sequence}.=$_;
  }
}
close FA;
schema->resultset('Transcript')->create($cur_trans);
