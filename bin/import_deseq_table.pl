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

my ($project, $prefix, $name, $base, $contrast);
my $aggregate_genes=1;
GetOptions('project|p=s' => \$project, 'prefix=s', => \$prefix, 'name|n=s' => \$name, 'base|b=s' => \$base, 'contrast|c=s' => \$contrast) || die "Usage!";

die "Usage: $0 --project [project] --prefix [assembly prefix] --name [name] --base [base condition] --contrast [contrast condition]" unless $project && $name && $base && $contrast;

if ($prefix) {
  schema($project)->resultset('TranscriptAssembly')->search({ prefix => $prefix })->first || die $prefix." is not a valid assembly prefix!";
}

my $con = schema($project)->resultset('Contrast')->find({
  base_condition => $base,
  contrast_condition => $contrast,
}) || die "Invalid contrast ".$base.":".$contrast;

my $de = schema($project)->resultset('DeRun')->find({ name => $name }) || die "Invalid DE run: ".$name;

my $de_contrast = schema($project)->resultset('DeRunContrast')->find({
  de_run_id => $de->id,
  contrast_id => $con->id,
}) || die "Contrast $base:$contrast not in de_run $name";
$de_contrast->import_file(id_prefix => $prefix);

print "\nDone\n";
