#!/usr/bin/perl

use warnings;
use strict;

use Getopt::Long;

BEGIN {
  Getopt::Long::Configure('pass_through');
}

use Dancer ':script';
use Dancer::Plugin::DBIC 'schema';

use TearDrop;

my ($project, $prefix);
GetOptions('project|p=s' => \$project, 'prefix=s' => \$prefix) || die "Usage!";
die "Usage: $0 --project [project] --prefix [assembly prefix]? [input]" unless $project;

my $hline = <>;
chomp $hline;
my @header_fields = split ',', $hline;

while(<>) {
  chomp;
  my @f = split ',';
  my %h = map { 
    $header_fields[$_] => $f[$_]
  } 0..$#header_fields;
  $h{id}=$prefix.'.'.$h{id} if $prefix;
  my $trans = schema($project)->resultset('Transcript')->find($h{id}) || die("Transcript ".$h{id}." not found.");
  delete $h{id};
  $trans->$_($h{$_}) for keys %h;
  print "setting ".$h{id}."         \r";
  $|=1;
  $trans->update;
}
