#!/usr/bin/perl

use warnings;
use strict;

use Dancer ':script';
use Dancer::Plugin::DBIC 'schema';

use Try::Tiny;

my ($method, $sample, $table_path) = @ARGV;

die "Usage $0 [method] [sample] [path]" unless $method && $sample && $table_path;

my $m = schema->resultset('CountMethod')->find($method) || die "Unknown count method: $method";
my $s = schema->resultset('Sample')->search({ description => $sample })->first || die "Unknown sample: $sample";

my $count = schema->resultset('SampleCount')->search({ sample_id => $s->id, count_method => $m->name })->first;
if ($count) {
  if ($count->path eq $table_path) {
    die "Already imported.";
  }
  else {
    warn "Count entry for sample/method already exists, replacing counts...";
    $count->path($table_path);
    $count->call('');
    $count->update;
    schema->resultset('RawCount')->search({ sample_count_id => $count->id })->delete;
  }
}
else {
  $count = schema->resultset('SampleCount')->create({
    sample_id => $s->id, 
    count_method => $m->name, 
    call => '',
    path => $table_path,
  });
}
if ($m->program eq 'sailfish') {
  print "read mapping info\n";
  open INF, "<$table_path/reads.count_info" or die "open $table_path/reads.count_info: $!";
  while(<INF>) {
    chomp;
    my @f = split "\t";
    $count->mapped_ratio($f[1]) if ($f[0] eq 'mapped_ratio');
  }
  close INF;
  print "read count file\n";
  open CNT, "<$table_path/quant_bias_corrected.sf" or die "open $table_path/quant_bias_corrected.sf: $!";
  while(<CNT>) {
    chomp;
    if (m/^#\s*(.+)/) {
      $count->call(($count->call ? $count->call.';' : '').$1);
    }
    else {
      my @f = split "\t";
      print "import ".$f[0]."          \r";
      $|=1;
      try {
        schema->resultset('RawCount')->create({
          transcript_id => $f[0],
          sample_count_id => $count->id,
          count => $f[6],
          tpm => $f[2],
        });
      } catch {
        warn "\n$_\n";
      };
    }
  }
  close(CNT);
}
else {
  die "don't really know how to handle ".$m->program." counts yet, sorry";
}
$count->update;

print "\ndone\n";
