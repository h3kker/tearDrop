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

my ($project, $assembly);
GetOptions('project|p=s' => \$project, 'assembly|a=s' => \$assembly) || die "Usage!";
die "Usage: $0 --project [project] --assembly [assembly]? [input]" unless $project;

my $hline = <>;
chomp $hline;
my @header_fields = split ',', $hline;

my $as;
if ($assembly) {
  $as=schema($project)->resultset('TranscriptAssembly')->find({ name => $assembly }) || die "Assembly ".$assembly." not found.";
}

while(<>) {
  chomp;
  my @f = split ',';
  my %h = map { 
    $header_fields[$_] => $f[$_]
  } 0..$#header_fields;
  if ($as && $as->add_prefix) {
    $h{id}=$as->prefix.'.'.$h{id};
  }
  my $trans = schema($project)->resultset('Transcript')->find($h{id}) || die("Transcript ".$h{id}." not found.");
  $trans->$_($h{$_}) for keys %h;
  print "setting ".$h{id}."         \r";
  $|=1;
  $trans->update;
}
