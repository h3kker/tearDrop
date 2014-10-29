#!/usr/bin/perl

use warnings;
use strict;

use Dancer ':script';
use Dancer::Plugin::DBIC 'schema';
use Try::Tiny;


my $bdir = shift @ARGV;

my %wanted = map { $_ => 1 } @ARGV;

my %tbl_src = qw/
  db_sources DbSource 
  organisms Organism 
  transcript_assemblies TranscriptAssembly
  count_methods CountMethod
/;

for my $table (keys %tbl_src) {
  next if scalar keys %wanted && !exists $wanted{$table};
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

if (!scalar keys %wanted || exists $wanted{samples}) {
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
}

if (!scalar keys %wanted || exists $wanted{alignments}) {
  open(IF, "$bdir/alignments.csv") or die "open $bdir/alignments.csv";
  my $hline = <IF>;
  chomp $hline;
  my @header_fields = split ',', $hline;

  while(<IF>) {
    chomp;
    my @f = split ',';
    my %s = map { 
      $header_fields[$_] => $f[$_]
    } 0..$#header_fields;
    my $sample = schema->resultset('Sample')->search({ description => $s{sample_id} })->first;
    unless($sample) {
      warn "no such sample: ".$s{sample_id};
      next;
    }
    my $alignment = schema->resultset('Alignment')->create({
      program => $s{program},
      sample_id => $sample->id,
      bam_path => $s{bam_path},
    });

    my $assembly = schema->resultset($s{type} eq 'transcriptome' ? 'TranscriptAssembly' : 'Organism')->search({ name => $s{assembly} })->first;
    unless($assembly) {
      warn "no such assembly: ".$s{assembly};
      next;
    }
    my ($k, $v) = $s{type} eq 'transcriptome' ? ('transcript_assembly_id', $assembly->id) : ('organism_name', $assembly->name);
    schema->resultset($s{type} eq 'transcriptome' ? 'TranscriptomeAlignment' : 'GenomeAlignment')->create({
      alignment_id => $alignment->id,
      $k => $v,
    });
  }
}

