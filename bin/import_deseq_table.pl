#!/usr/bin/perl

use warnings;
use strict;

use Dancer ':script';
use Dancer::Plugin::DBIC 'schema';

my ($name, $base, $contrast, $path) = @ARGV;

die "Usage: $0 [name] [base condition] [contrast condition] [path]" unless $name && $base && $contrast && $path;

my $count_table = schema->resultset('CountTable')->search({ name => $name })->first;

unless($count_table) {
  $count_table = schema->resultset('CountTable')->create({
    name => $name,
    aggregate_genes => 1,
  });
  warn "count table $name created";
}

my $con = schema->resultset('Contrast')->search({
  base_condition => $base,
  contrast_condition => $contrast,
})->first;
unless($con) {
  $con = schema->resultset('Contrast')->create({
    base_condition => $base,
    contrast_condition => $contrast,
  });
  warn "Contrast $base <-> $contrast created";
}

my $de = schema->resultset('DeRun')->search({
  name => $name,
})->first;
if($de) {
  warn "DE run $name exists, overwriting...";
  $de->count_table_id($count_table->id);
  $de->update;
}
else {
  $de = schema->resultset('DeRun')->create({
    name => $name,
    description => $name,
    count_table_id => $count_table->id
  });
  warn "DE run $name created";
}

my $de_contrast = schema->resultset('DeRunContrast')->search({
  de_run_id => $de->id,
  contrast_id => $con->id,
})->first;
if ($de_contrast) {
  warn "Overwriting existing de contrast";
  $de_contrast->path($path);
  $de_contrast->update;
  $de_contrast->delete_related('de_result');
}
else {
  $de_contrast = schema->resultset('DeRunContrast')->create({
    de_run_id => $de->id,
    contrast_id => $con->id,
    path => $path,
  });
  warn "Contrast for DE run $name linked";
}


open(IF, "<$path") or die "open $path: $!";
my $hline = <IF>;
chomp $hline;
my @h = split "\t", $hline;
push @h, qw/contrast_id de_run_id/;

my %field_map = qw/
  transcript transcript_id
  pvalue pvalue
  padj adjp
  baseMean base_mean
  log2FoldChange log2_foldchange
  contrast_id contrast_id
  de_run_id de_run_id
/;

while(<IF>) {
  chomp;
  my @f = split "\t";
  push @f, $con->id, $de->id;
  schema->resultset('DeResult')->create({ map {
    $field_map{$h[$_]} => $f[$_] eq 'NA' ? undef : $f[$_]
  } grep { exists $field_map{$h[$_]} } 0..$#h });
  print "Inserted ".$f[0]."        \r";
  $|=1;
}
print "\nDone\n";
