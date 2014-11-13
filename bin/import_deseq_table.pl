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

my ($project, $name, $base, $contrast, $path);
GetOptions('project|p=s' => \$project, 'name|n=s' => \$name, 'base|b=s' => \$base, 'contrast|c=s' => \$contrast) || die "Usage!";

my $path = shift @ARGV;

die "Usage: $0 --project [project] --name [name] --base [base condition] --contrast [contrast condition] [path]" unless $project && $name && $base && $contrast && $path;

my $count_table = schema($project)->resultset('CountTable')->search({ name => $name })->first;

unless($count_table) {
  $count_table = schema($project)->resultset('CountTable')->create({
    name => $name,
    aggregate_genes => 1,
  });
  warn "count table $name created";
}

my $con = schema($project)->resultset('Contrast')->search({
  base_condition => $base,
  contrast_condition => $contrast,
})->first;
unless($con) {
  $con = schema($project)->resultset('Contrast')->create({
    base_condition => $base,
    contrast_condition => $contrast,
  });
  warn "Contrast $base <-> $contrast created";
}

my $de = schema($project)->resultset('DeRun')->search({
  name => $name,
})->first;
if($de) {
  warn "DE run $name exists, overwriting...";
  $de->count_table_id($count_table->id);
  $de->update;
}
else {
  $de = schema($project)->resultset('DeRun')->create({
    name => $name,
    description => $name,
    count_table_id => $count_table->id
  });
  warn "DE run $name created";
}

my $de_contrast = schema($project)->resultset('DeRunContrast')->search({
  de_run_id => $de->id,
  contrast_id => $con->id,
})->first;
if ($de_contrast) {
  warn "Overwriting existing de contrast";
  if ($de_contrast->path && $path ne $de_contrast->path) {
    $de_contrast->path($path);
    $de_contrast->sha1(undef);
  }
  $de_contrast->update;
}
else {
  $de_contrast = schema($project)->resultset('DeRunContrast')->create({
    de_run_id => $de->id,
    contrast_id => $con->id,
    path => $path,
  });
  warn "Contrast for DE run $name linked";
}

$de_contrast->import_file;

print "\nDone\n";
