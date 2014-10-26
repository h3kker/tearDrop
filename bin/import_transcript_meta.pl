#!/usr/bin/perl

use warnings;
use strict;

use Dancer ':script';
use Dancer::Plugin::DBIC 'schema';

my $hline = <>;
chomp $hline;
my @header_fields = split ',', $hline;

while(<>) {
  chomp;
  my @f = split ',';
  my %h = map { 
    $header_fields[$_] => $f[$_]
  } 0..$#header_fields;
  my $trans = schema->resultset('Transcript')->find($h{id}) || die("Transcript ".$h{id}." not found.");
  $trans->$_($h{$_}) for keys %h;
  print "setting ".$h{id}."         \r";
  $|=1;
  $trans->update;
}
