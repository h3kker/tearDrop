package TearDrop::Command::import_blast;

use 5.12.0;

use Mojo::Base 'Mojolicious::Command';

use Carp;
use Try::Tiny;
use TearDrop::Task::ImportBLAST;

use Getopt::Long qw(GetOptionsFromArray :config no_auto_abbrev no_ignore_case);

has description => 'Import BLAST results (currently only custom format)';
has usage => sub { shift->extract_usage };

sub run {
  my ($self, @args) = @_;

  my %opt = (evalue_cutoff => 0.01, max_target_seqs => 20);
  GetOptionsFromArray(\@args, \%opt, 'project|p=s', 'reverse',
    'db_source|db=s', 'assembly|a=s', 'evalue_cutoff=f', 'max_target_seqs=i')
      or croak $self->help;

  croak 'need project context' unless $opt{project};
  croak 'need db_source that was blasted' unless $opt{db_source};
  croak 'need assembly that was blasted against for reverse' if $opt{reverse} && !$opt{assembly};
  
  my $task = new TearDrop::Task::ImportBLAST(
    project => $opt{project},
    assembly => $opt{assembly},
    database => $opt{db_source},
    reverse => $opt{reverse},
    files => \@args,
    evalue_cutoff => $opt{evalue_cutoff},
    max_target_seqs => $opt{max_target_seqs},
  );
  try {
    my $res = $task->run || croak 'task failed!';
    say $res->{count}." entries imported.\n";
  } catch {
    croak 'import failed: '.$_;
  };
}

1;

=pod

=head1 NAME

TearDrop::Command::import_blast - import BLAST results 

=head1 SYNOPSIS

  Usage: tear_drop import_blast [OPTIONS] [files...]

  Required Options:
   -p, --project [project]
       Name of the project context in which to run. See L<TearDrop::Command::deploy_project>.

  "Forward" BLAST:
   --db, --db_source [db]
       Name of a configured db source that was queried

  "Reverse" BLAST:
   --reverse
       This was a reverse BLAST, ie. you extracted sequences from a BLAST db and blasted against a transcript assembly.
   -a, --assembly [assembly]
       Name of the assembly that was queried
   --db, --db_source [db]
       Name of the database that was BLASTed, ie. where you extracted the sequences from. This database needs to be configured!

   Filtering (currently non-functional, please set the corresponding BLAST options).
    --evalue_cutoff
        default .01
    --max_target_seqs
        default 20

If no files are specified, input is read from STDIN.

Currently only a custom tabular format is understood, please use
    -outfmt "6 qseqid sseqid bitscore qlen length nident pident ppos evalue slen qseq sseq qstart qend sstart send stitle"

=head1 DESCRIPTION

=head1 METHODS

Inherits all methods from L<Mojolicious::Command> and implements the following new ones.

=head2 run

  $import_blast->run(@ARGV);

=cut
