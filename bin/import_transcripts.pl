#!/usr/bin/perl

use warnings;
use strict;

use Getopt::Long;

BEGIN {
  Getopt::Long::Configure('pass_through');
}


use Dancer ':script';
use Dancer::Plugin::DBIC 'schema';

use Try::Tiny;

use TearDrop;

my ($project, $assembly, $fasta);

GetOptions('project|p=s' => \$project, 'assembly|a=s' => \$assembly, 'fasta|f=s' => \$fasta) || die "Usage!";

die "Usage: $0 --project [project] --assembly [assembly name] --fasta [fasta]?" unless $project && $assembly;

my $a = schema($project)->resultset('TranscriptAssembly')->search({ name => $assembly })->first;
die "Assembly $assembly not in database!" unless $a;

$a->delete_related('transcripts');

if ($fasta && $fasta ne $a->path) {
  $a->path($fasta);
  $a->sha1(undef);
  $a->update;
}

$a->import_file;
