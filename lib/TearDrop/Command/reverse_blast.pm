package TearDrop::Command::reverse_blast;

use 5.12.0;

use Mojo::Base 'Mojolicious::Command';

use Carp;
use TearDrop::Task::ReverseBLAST;

use Getopt::Long qw(GetOptionsFromArray :config no_auto_abbrev no_ignore_case);

has description => 'Run blast against transcriptome assembly';
has usage => sub { shift->extract_usage };

sub run {
  my ($self, @args) = @_;

  my %opt = (evalue_cutoff => 0.01, max_target_seqs => 20);
  GetOptionsFromArray(\@args, \%opt, 'project|p=s', 
    'db_source|db=s', 'entry|e=s@', 'fasta|fa:s', 
    'assembly|a=s', 'evalue_cutoff=f', 'max_target_seqs=i')
      or croak $self->help;

  croak 'need project context' unless $opt{project};
  croak 'either blast sequences from a known db or provide a fasta, not both' if $opt{db_source} && defined $opt{fasta};

  my @entries;
  my %sequences;
  if ($opt{db_source}) {
    if ($opt{entry}) {
      @entries = @{$opt{entry}};
    }
    else {
      say "Read entry ids, one per line...";
      my $in = IO::Handle->new;
      $in->fdopen(fileno(STDIN), "r");
      while(<$in>) {
        chomp;
        push @entries, $_;
      }
      $in->close;
    }
  }
  elsif(defined $opt{fasta}) {
    my $in = IO::Handle->new;
    if ($opt{fasta}) {
      $in = IO::File->new($opt{fasta}, "r");
    }
    else {
      say "Read sequences in fasta format...";
      $in->fdopen(fileno(STDIN), "r");
    }
    my $cur_seq;
    while(<$in>) {
      chomp;
      if (m#^>\s*(.+)#) {
        $cur_seq=$1;
      }
      $sequences{$cur_seq}.=$_;
    }
    $in->close;
  }
  croak 'could not find any sequences to blast (and I tried really hard!)' unless (@entries || %sequences);
  
  my $task = new TearDrop::Task::ReverseBLAST(
    project => $opt{project},
    assembly => $opt{assembly},
    evalue_cutoff => $opt{evalue_cutoff},
    max_target_seqs => $opt{max_target_seqs},
    database => $opt{db_source},
    entries => \@entries,
    sequences => \%sequences,
  );
  my $res = $task->run || croak 'task failed!';

  for my $e (@$res) {
    print $self->app->dumper($e->TO_JSON);
  }
}

1;

=pod

=head1 NAME

TearDrop::Command::reverse_blast - run tblastn against transcriptome assembly

=head1 SYNOPSIS

  Usage: tear_drop reverse_blast [OPTIONS]

  Required Options:
   -p, --project [project]
       Name of the project context in which to run. See L<TearDrop::Command::deploy_project>.
   -a, --assembly [assembly]
       Name of the assembly to BLAST against. Currently you need to build the index yourself
       with the same basename as the assembly fasta.
       
  Input:
   -f, --fasta [file]
       Read sequences in FASTA format. If no filename is specified, read from STDIN 
   -d, --db_source [db]    
       Name of a configured BLAST database to extract entries from
   -e, --entry [id]
       Entries to fish out. If no entry option is specified, read sequence ids from STDIN. Can be specified multiple times.

   Filtering:
    --evalue_cutoff
        default .01
    --max_target_seqs
        default 20

All results are also inserted into the project database for future reference.

=head1 DESCRIPTION

=head1 METHODS

=head1 METHODS

Inherits all methods from L<Mojolicious::Command> and implements the following new ones.

=head2 run

  $reverse_blast->run(@ARGV);

=cut
