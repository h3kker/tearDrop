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

my ($project, $bdir);

GetOptions('project|p=s' => \$project, 'basedir|b=s' => \$bdir) || die "Usage!";

die "Usage: $0 --project [project] --basedir [basedir]" unless $project && $bdir;

my %wanted = map { $_ => 1 } @ARGV;

my %tbl_src = qw/
  db_sources DbSource 
  organisms Organism 
  transcript_assemblies TranscriptAssembly
  count_methods CountMethod
/;

for my $table (keys %tbl_src) {
  next if scalar keys %wanted && !exists $wanted{$table};
  info 'import '.$table;
  my $source_file = sprintf "%s/%s.csv" => $bdir, $table;
  unless (-f $source_file) {
    warning "File $source_file not found, skipping\n";
    next;
  }
  open(IF, "<$source_file") or die("open $source_file: $!");
  my $hline = <IF>;
  chomp $hline;
  my @header_fields = split ',', $hline;
  while(<IF>) {
    chomp;
    my @f = split ',';
    info "insert ".$f[0];
    try {
      schema($project)->resultset($tbl_src{$table})->update_or_create({ map {
        $header_fields[$_] => $f[$_]
      } 0..$#header_fields });
    } catch {
      warning $_;
    };
  }
}

if (!scalar keys %wanted || exists $wanted{genome_annotations}) {
  info 'import genome_annotations';
  open(IF, "$bdir/genome_annotations.csv") or die "open $bdir/genome_annotations.csv";
  my $hline = <IF>;
  chomp $hline;
  my @header_fields = split ',', $hline;
  while(<IF>) {
    chomp;
    my @f = split ',';
    my %s = map { 
      $header_fields[$_] => $f[$_]
    } 0..$#header_fields;
    my $model = schema($project)->resultset('GeneModel')->update_or_create(\%s);
    info 'import file '.$model->path;
    $model->import_file;
  }
}

if (!scalar keys %wanted || exists $wanted{samples}) {
  info 'import samples';
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
      $conditions{$s{condition}} = schema($project)->resultset('Condition')->find_or_create({
        name => $s{condition},
      });
    }
    $s{description}||=$s{name};
    schema($project)->resultset('Sample')->create(\%s);
  }
}

if (!scalar keys %wanted || exists $wanted{genome_mappings}) {
  info 'import genome_mappings';
  open(IF, "$bdir/genome_mappings.csv") or die "open $bdir/genome_mappings.csv";
  my $hline = <IF>;
  chomp $hline;
  my @header_fields = split ',', $hline;
  while(<IF>) {
    chomp;
    my @f = split ',';
    my %s = map {
      $header_fields[$_] => $f[$_]
    } 0..$#header_fields;
    my $organism = schema($project)->resultset('Organism')->find($s{genome});
    unless ($organism) {
      warning "no such genome: ".$s{genome};
      next;
    }
    my $transcripts = schema($project)->resultset('TranscriptAssembly')->search({ name => $s{assembly}})->first;
    unless ($transcripts) {
      warning "no such transcript assembly: ".$s{assembly};
      next;
    }
    my $genome_mapping = schema($project)->resultset('GenomeMapping')->search({
      path => $s{path}
    })->first;
    unless($genome_mapping) {
      $genome_mapping = schema($project)->resultset('GenomeMapping')->create({
        program => $s{program},
        parameters => $s{parameters},
        transcript_assembly_id => $transcripts->id,
        organism_name => $organism->name,
        path => $s{path},
      });
    }
    info 'import file '.$genome_mapping->path;
    $genome_mapping->import_file;
  }
}

if (!scalar keys %wanted || exists $wanted{alignments}) {
  info 'import alignments';
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

    my $sample = schema($project)->resultset('Sample')->search({ name => $s{sample_id} })->first;
    unless($sample) {
      warning "no such sample: ".$s{sample_id};
      next;
    }
    my $alignment = schema($project)->resultset('Alignment')->search({ bam_path => $s{bam_path} })->first;
    unless($alignment) {
      $alignment = schema($project)->resultset('Alignment')->create({
        program => $s{program},
        sample_id => $sample->id,
        bam_path => $s{bam_path},
      });
    }
    else {
      $alignment->program($s{program});
      $alignment->sample_id($sample->id);
      $alignment->update;
    }
    try {
      $alignment->read_stats;
      $alignment->update;
    } catch {
      warn 'unable to read stats for '.$alignment->bam_path.": $_";
    };

    my $assembly = schema($project)->resultset($s{type} eq 'transcriptome' ? 'TranscriptAssembly' : 'Organism')->search({ name => $s{assembly} })->first;
    unless($assembly) {
      warn "no such assembly: ".$s{assembly};
      next;
    }
    my ($k, $v) = $s{type} eq 'transcriptome' ? ('transcript_assembly_id', $assembly->id) : ('organism_name', $assembly->name);
    my $res = $s{type} eq 'transcriptome' ? 'TranscriptomeAlignment' : 'GenomeAlignment';
    schema($project)->resultset($res)->update_or_create({
      alignment_id => $alignment->id,
      $k => $v,
    });
  }
}

