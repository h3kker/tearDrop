#!/usr/bin/perl

use warnings;
use strict;

use Getopt::Long::Descriptive;

use Dancer ':script';
use Dancer::Plugin::DBIC 'schema';
use Try::Tiny;
use File::Spec;

use TearDrop::Cmd;

my ($opt, $usage) = describe_options(
  '%c %o [key1] [key2...]',
  [ 'keys|k', 'dump list of valid keys and exit', { implies => [ 'project', 'basedir' ] } ],
  [ 'project|p=s', 'project name', { required => 1 } ],
  [ 'import_files|f', 'also import referenced files (may take a while)', ],
  [ 'basedir|b=s', 'directory with all the CSV data', { required => 1 } ],
  [],
  [ 'help_import', 'this message.', { implies => [ 'project', 'basedir' ] } ],
  [],
  [ 'If you do not provide any keys, all tables will be imported by default.' ],
);
print $usage->text, exit if $opt->help_import;

my %tbl_src = qw/
  db_sources DbSource 
  organisms Organism 
  transcript_assemblies TranscriptAssembly
  count_methods CountMethod
  alignments special
  genome_annotations special
  samples special
  genome_mappings special
  de_runs special
/;


if ($opt->keys) {
  print "Valid keys:\n\t";
  print join "\n\t", keys %tbl_src;
  print "\n";
  exit;
}

my %wanted = map { $_ => 1 } @ARGV;


sub read_csv {
  my ($file, $line_callback) = @_;
  open IF, "<$file" or die "open $file: $!";
  my $hline = <IF>;
  chomp $hline;
  my @header_fields = split ',', $hline;
  while(<IF>) {
    chomp;
    my @f = split ',';
    my %s = map {
      $header_fields[$_] => $f[$_]
    } 0..$#header_fields;
    $line_callback->(%s);
  }
}

for my $table (keys %tbl_src) {
  next if $tbl_src{$table} eq 'special';
  next if scalar keys %wanted && !exists $wanted{$table};
  info 'import '.$table;
  my $source_file = File::Spec->catfile($opt->dir, $table.".csv"); 
  unless (-f $source_file) {
    warning "File $source_file not found, skipping\n";
    next;
  }
  read_csv($source_file, sub {
    my %s = @_;
    info "   insert ".$s{name};
    try {
      my $rs = schema($opt->project)->resultset($tbl_src{$table})->update_or_create(\%s);
      if ($opt->import_files && $rs->can('import_file')) {
        info '   import file '.$rs->path;
        $rs->import_file;
      }
    } catch {
      warning $_;
    };
  });
}

if (!scalar keys %wanted || exists $wanted{genome_annotations}) {
  info 'import genome_annotations';
  read_csv(File::Spec->catfile($opt->bdir, "genome_annotations.csv"), sub {
    my %s = @_;
    debug "   insert ".$s{name};
    my $model = schema($opt->project)->resultset('GeneModel')->update_or_create(\%s);
    if ($opt->import_files) {
      info '   import file '.$model->path;
      $model->import_file;
    }
  })
}

if (!scalar keys %wanted || exists $wanted{samples}) {
  info 'import samples';
  my %conditions;
  read_csv(File::Spec->catfile($opt->bdir, "samples.csv"), sub {
    my %s = @_;
    debug "   insert ".$s{name};
    unless ($conditions{$s{condition}}) {
      $conditions{$s{condition}} = schema($opt->project)->resultset('Condition')->find_or_create({
        name => $s{condition},
      });
    }
    $s{description}||=$s{name};
    schema($opt->project)->resultset('Sample')->update_or_create(\%s);
  });
}

if (!scalar keys %wanted || exists $wanted{genome_mappings}) {
  info 'import genome_mappings';
  read_csv(File::Spec->catfile($opt->bdir, "genome_mappings.csv"), sub {
    my %s = @_;
    debug '   insert '.$s{genome}.' '.$s{assembly}.' '.$s{program};
    my $organism = schema($opt->project)->resultset('Organism')->find($s{genome});
    unless ($organism) {
      warning "no such genome: ".$s{genome};
      next;
    }
    my $transcripts = schema($opt->project)->resultset('TranscriptAssembly')->search({ name => $s{assembly}})->first;
    unless ($transcripts) {
      warning "no such transcript assembly: ".$s{assembly};
      next;
    }
    my $genome_mapping = schema($opt->project)->resultset('GenomeMapping')->search({
      path => $s{path}
    })->first;
    unless($genome_mapping) {
      $genome_mapping = schema($opt->project)->resultset('GenomeMapping')->create({
        program => $s{program},
        parameters => $s{parameters},
        transcript_assembly_id => $transcripts->id,
        organism_name => $organism->name,
        needs_prefix => $s{needs_prefix},
        path => $s{path},
      });
    }
    if ($opt->import_files) {
      info '   import file '.$genome_mapping->path;
      $genome_mapping->import_file;
    }
  });
}


if (!scalar keys %wanted || exists $wanted{de_runs}) {
  info 'import de_runs';
  read_csv(File::Spec->catfile($opt->bdir, "de_run_contrasts.csv"), sub {
    my %s = @_;
    debug '   insert '.$s{count_table}.' '.$s{base_condition}.' '.$s{contrast_condition};
    my $assembly = schema($opt->project)->resultset('TranscriptAssembly')->find({ name => $s{assembly} }) || die 'Invalid assembly: '.$s{assembly};
    my $count_table = schema($opt->project)->resultset('CountTable')->update_or_create({ name => $s{count_table}, aggregate_genes => $s{aggregate_genes} });
    my $contrast = schema($opt->project)->resultset('Contrast')->update_or_create({ base_condition => $s{base_condition}, contrast_condition => $s{contrast_condition} });
    my $de = $count_table->update_or_create_related('de_runs', {
      name => $s{count_table}, 
      description => $s{count_table},
    });
    my $de_contrast = $de->update_or_create_related('de_run_contrasts', {
      contrast_id => $contrast->id,
      parameters => $s{contrast_parameters},
      needs_prefix => $s{needs_prefix},
      path => $s{path}
    });
    if ($opt->import_files) {
      info '   import file '.$de_contrast->path;
      $de_contrast->import_file(id_prefix => $assembly->prefix);
    }
  });
}

if (!scalar keys %wanted || exists $wanted{alignments}) {
  info 'import alignments';
  read_csv(File::Spec->catfile($opt->bdir, "alignments.csv"), sub {
    my %s = @_;
    debug '   insert '.$s{program}.' '.$s{sample_id};
    my $sample = schema($opt->project)->resultset('Sample')->search({ name => $s{sample_id} })->first;
    unless($sample) {
      warning "no such sample: ".$s{sample_id};
      next;
    }
    unless(-f $s{bam_path}) {
      warning "BAM file ".$s{bam_path}." not found, check path!";
      next;
    }
    unless(-f $s{bam_path}.".bai") {
      warning "BAM file ".$s{bam_path}." not indexed, please to do so.";
      next;
    }
    my $alignment = schema($opt->project)->resultset('Alignment')->search({ bam_path => $s{bam_path} })->first;
    unless($alignment) {
      $alignment = schema($opt->project)->resultset('Alignment')->create({
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

    my $assembly = schema($opt->project)->resultset($s{type} eq 'transcriptome' ? 'TranscriptAssembly' : 'Organism')->search({ name => $s{assembly} })->first;
    unless($assembly) {
      warn "no such assembly: ".$s{assembly};
      next;
    }
    my %vals = $s{type} eq 'transcriptome' ? 
      ('transcript_assembly_id' => $assembly->id, 'use_original_id' => $s{use_original_id}) : 
      ('organism_name', $assembly->name);
    $vals{alignment_id} = $alignment->id;

    my $res = $s{type} eq 'transcriptome' ? 'TranscriptomeAlignment' : 'GenomeAlignment';
    schema($opt->project)->resultset($res)->update_or_create(\%vals);
  });
}

