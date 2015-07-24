package TearDrop::Command::import_metadata;

use 5.12.0;

use Mojo::Base 'Mojolicious::Command';

use Carp;
use Try::Tiny;
use File::Spec;
use File::Basename;
use Text::CSV;

use Getopt::Long qw(GetOptionsFromArray :config no_auto_abbrev no_ignore_case);

has description => 'Import metadata';
has usage => sub { shift->extract_usage };

has tbl_src => sub {
  return { qw/
    db_sources DbSource
    organisms Organism
    transcript_assemblies TranscriptAssembly
    count_methods CountMethod
    alignments special
    genome_annotations GeneModel
    samples special
    genome_mappings special
    de_runs special
  /}
};

has 'separator' => ',';

sub read_csv {
  my ($self, $file, $line_callback) = @_;
  unless (-f $file) {
    warn "File $file not found, skipping\n";
    return;
  }
  my $csv = Text::CSV->new ({ sep_char => $self->separator, empty_is_undef => 1 });
  open my $fh, "<", $file or croak "open $file: $!";
  my $hr = $csv->getline($fh) || croak $csv->error_diag;
  $csv->column_names(@$hr);
  while(my $r = $csv->getline_hr($fh)) {
    $line_callback->(%$r);
  }
  close $fh;
}

sub run {
  my ($self, @args) = @_;

  my %opt = ( import_files => 0, separator => ',', basedir => 'data' );
  GetOptionsFromArray(\@args, \%opt, 'project|p=s', 'import_files|f', 'basedir|b=s', 'separator|s=s', 'help|h', 'list_filenames') or croak $self->help;
  if ($opt{help}) {
    print $self->help;
    return;
  }
  if ($opt{list_filenames}) {
    say "Valid filenames:";
    print map { "\t".$_."\n" } keys $self->tbl_src;
    print "\n";
    return;
  }

  croak 'need project name!' unless($opt{project});


  $self->separator($opt{separator});
  my %wanted = map { $_ => 1 } @args;

  for my $table (keys $self->tbl_src) {
    next if $self->tbl_src->{$table} eq 'special';
    next if scalar keys %wanted && !exists $wanted{$table};
    my $source_file = File::Spec->catfile($opt{basedir}, $table.'.csv');

    say 'import '.$table.' ('.$source_file.')';

    $self->read_csv($source_file, sub {
      my %s = @_;
      say "\tinsert ".$s{name};
      try {
        my $rs = $self->app->schema($opt{project})->resultset($self->tbl_src->{$table})->update_or_create(\%s);
        if ($opt{import_files} && $rs->can('import_file')) {
          say "\timport file ".$rs->path;
          $rs->import_file; 
        }
      } catch {
        warn $_;
      }
    });
  }

  if (!scalar keys %wanted || exists $wanted{samples}) {
    my $source_file = File::Spec->catfile($opt{basedir}, "samples.csv"); 
    say "import samples ($source_file)";
    my %conditions;
    $self->read_csv($source_file, sub {
      my %s = @_;
      say "\tinsert ".$s{name};
      unless ($conditions{$s{condition}}) {
        $conditions{$s{condition}} = $self->app->schema($opt{project})->resultset('Condition')->find_or_create({
          name => $s{condition},
        });
      }
      $s{description}||=$s{name};
      $self->app->schema($opt{project})->resultset('Sample')->update_or_create(\%s);
    });
  }

  if (!scalar keys %wanted || exists $wanted{genome_mappings}) {
    my $source_file = File::Spec->catfile($opt{basedir}, "genome_mappings.csv");
    say "import genome_mappings ($source_file)";
    $self->read_csv($source_file, sub {
      my %s = @_;
      say "\tinsert ".$s{genome}." ".$s{assembly}." ".$s{program};
      my $organism = $self->app->schema($opt{project})->resultset('Organism')->find($s{genome});
      unless ($organism) {
        warn "no such genome: ".$s{genome};
        return;
      }
      my $transcripts = $self->app->schema($opt{project})->resultset('TranscriptAssembly')->search({ name => $s{assembly} })->first;
      unless ($transcripts) {
        warn "no such transcript assembly: ".$s{assembly};
        return;
      }
      my $genome_mapping = $self->app->schema($opt{project})->resultset('GenomeMapping')->update_or_create({
        program => $s{program},
        parameters => $s{parameters},
        transcript_assembly_id => $transcripts->id,
        organism_name => $organism->name,
        needs_prefix => $s{needs_prefix},
        path => $s{path},
      });
      if ($opt{import_files}) {
        say "\timport file ".$genome_mapping->path;
        $genome_mapping->import_file;
      }
    });
  }

  if (!scalar keys %wanted || exists $wanted{de_runs}) {
    my $source_file = File::Spec->catfile($opt{basedir}, "de_run_contrasts.csv");
    say "import de_runs ($source_file)";
    $self->read_csv($source_file, sub {
      my %s = @_;
      say "\tinsert ".$s{count_table}." ".$s{base_condition}." ".$s{contrast_condition};
      my $assembly = $self->app->schema($opt{project})->resultset('TranscriptAssembly')->find({ name => $s{assembly} }) || die 'Invalid assembly: '.$s{assembly};
      my $count_table = $self->app->schema($opt{project})->resultset('CountTable')->update_or_create({ name => $s{count_table}, aggregate_genes => $s{aggregate_genes} });
      my $contrast = $self->app->schema($opt{project})->resultset('Contrast')->update_or_create({ base_condition => $s{base_condition}, contrast_condition => $s{contrast_condition} });
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
      if ($opt{import_files}) {
        say "\timport file ".$de_contrast->path;
        $de_contrast->import_file(id_prefix => $assembly->prefix);
      }
    });
  }

  if (!scalar keys %wanted || exists $wanted{alignments}) {
    my $source_file = File::Spec->catfile($opt{basedir}, "alignments.csv");
    say "import alignments ($source_file)";
    $self->read_csv($source_file, sub {
      my %s = @_;
      say "\tinsert ".$s{program}." ".$s{sample_id};
      my $sample = $self->app->schema($opt{project})->resultset('Sample')->search({ name => $s{sample_id} })->first;
      unless($sample) {
        warn "no such sample: ".$s{sample_id};
        return;
      }
      unless(-f $s{bam_path}) {
        warn "BAM file ".$s{bam_path}." not found, check path!";
        return;
      }
      unless(-f $s{bam_path}.".bai" && ! -f File::Spec->catfile(dirname($s{bam_path}), basename($s{bam_path}, '.bam').'.bai')) {
        warn "BAM file ".$s{bam_path}." not indexed, please to do so.";
        return;
      }
      # XXX bam_path is not primary key or even unique!!
      my $alignment = $self->app->schema($opt{project})->resultset('Alignment')->search({ bam_path => $s{bam_path} })->first;
      unless($alignment) {
        $alignment = $self->app->schema($opt{project})->resultset('Alignment')->create({
          program => $s{program},
          sample_id => $sample->id,
          bam_path => $s{bam_path},
        });
      }
      else {
        $alignment->program($s{program});
        $alignment->sample_id($sample->id),
        $alignment->update;
      }
      try {
        $alignment->read_stats;
        $alignment->update;
      } catch {
        warn "unable to read stats for ".$alignment->bam_path.": $_";
      };

      my $assembly = $self->app->schema($opt{project})->resultset($s{type} eq 'transcriptome' ? 'TranscriptAssembly' : 'Organism')->search({ name => $s{assembly} })->first;
      unless($assembly) {
        warn "no such assembly: ".$s{assembly};
        return;
      }
      my %vals = $s{type} eq 'transcriptome' ? 
        ('transcript_assembly_id' => $assembly->id, 'use_original_id' => $s{use_original_id}) :
        ('organism_name', $assembly->name);
      $vals{alignment_id} = $alignment->id;
      my $res = $s{type} eq 'transcriptome' ? 'TranscriptomeAlignment' : 'GenomeAlignment';
      $self->app->schema($opt{project})->resultset($res)->update_or_create(\%vals);
    });
  }
}

1;

=pod

=head1 NAME

TearDrop::Command::import_metadata - import metadata

=head1 SYNOPSIS

  Usage: tear_drop import_metadata [OPTIONS] [table(s)...]

  Required Options:
  -p, --project [project]
      Name of the project context in which to run. See L<TearDrop::Command::deploy_project>.

  Optional:
  -b, --basedir [dir]
      Base directory
  -f, --import_files
      Also import referenced files, e.g. transcript alignments
  -s, --separator [char]
      character for field delimiter, default: C<,>  

  --transcript_map [file]
      transcript[tab]gene mapping file for importing transcripts - one gene can have many transcripts

  -h, --help
      Display this message
  --list_filenames
      List valid filenames

  By default, all files in the base directory are imported. You can supply table/file names 
  to import specific metadata tables. Use --list_filenames to get a list of filenames.

  You can perform imports multiple times without producing duplicate entries,
  entries are overwritten and/or created as needed.

=head1 DESCRIPTION

=cut
