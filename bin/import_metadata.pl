#!/usr/bin/perl

use warnings;
use strict;

use Dancer ':script';
use Dancer::Plugin::DBIC 'schema';
use Try::Tiny;


my $bdir = shift @ARGV;

my %tbl_src = qw/
  db_sources DbSource 
  organisms Organism 
  transcript_assemblies TranscriptAssembly
  count_methods CountMethod
/;

for my $table (qw/db_sources organisms transcript_assemblies count_methods/) {
  my $source_file = sprintf "%s/%s.csv" => $bdir, $table;
  unless (-f $source_file) {
    warn "File $source_file not found, skipping\n";
    next;
  }
  open(IF, "<$source_file") or die("open $source_file: $!");
  my $hline = <IF>;
  chomp $hline;
  my @header_fields = split ',', $hline;
  while(<IF>) {
    chomp;
    my @f = split ',';
    warn "insert ".$f[0];
    try {
      schema->resultset($tbl_src{$table})->create({ map {
        $header_fields[$_] => $f[$_]
      } 0..$#header_fields });
    } catch {
      warn $_;
    };
  }
}

open(IF, "$bdir/samples.csv") or die "open $bdir/samples.csv";
my $hline = <IF>;
chomp $hline;
my @header_fields = split ',', $hline;

my %conditions;
while(<IF>) {
  chomp;
  my @f = split ',';
  my %s = map { 
    $header_fields[$_] => $f[$_]
  } 0..$#header_fields;
  unless ($conditions{$s{condition}}) {
    try {
      $conditions{$s{condition}} = schema->resultset('Condition')->create({
        name => $s{condition},
      });
    } catch {
      warn $_;
    };
  }
  schema->resultset('Sample')->create(\%s);
}
