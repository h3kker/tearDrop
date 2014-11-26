package TearDrop::Command::run_blast;

use 5.12.0;

use Mojo::Base 'Mojolicious::Command';

use Carp;
use TearDrop::Task::BLAST;

use Getopt::Long qw(GetOptionsFromArray :config no_auto_abbrev no_ignore_case);

has description => 'Run blast for transcripts/genes';
has usage => sub { shift->extract_usage };

sub run {
  my ($self, @args) = @_;

  my %opt = (db_source => [ qw/refseq_plant ncbi_cdd/ ], evalue_cutoff => .01, max_target_seqs => 20, batch_size => 50);
  GetOptionsFromArray(\@args, \%opt, 'project|p=s', 'db_source|db=s@', 'assembly|a=s',
      'id|i=s', 'no-annotate', 'evalue_cutoff=f', 'max_target_seqs=i', 'batch_size=i') 
    or croak $self->help;

  croak "Please provide project context!\n\n".$self->help unless $opt{project};
  my @dbs = $self->app->schema($opt{project})->resultset('DbSource')->search({
    name => $opt{db_source}
  })->all;

  croak 'no valid database found' unless @dbs;
  say "BLASTing against ".join(",", map { $_->name } @dbs);

  my %search = ('me.reviewed' => 0);
  if ($opt{assembly}) {
    $search{'transcript_assemblies.name'}=$opt{assembly};
  }
  if ($opt{id}) {
    $search{'LOWER(me.id)'}={ like => '%'.lc($opt{id}).'%' };
  }
  my $batch_no=1;
  while(1) {
    my @genes = $self->app->schema($opt{project})->resultset('Gene')->search(\%search, { 
      prefetch => [ { 'transcripts' => 'assembly' } ],
      page => $batch_no,
      rows => $opt{batch_size},
    })->all;
    last unless @genes;
    for my $db (@dbs) {
      warn "BLAST ".$db->name;
      my $task = new TearDrop::Task::BLAST(
        project => $opt{project},
        replace => 0, 
        gene_ids => [ map { $_->id } @genes ],
        database => $db->name,
        evalue_cutoff => $opt{evalue_cutoff},
        max_target_seqs => $opt{max_target_seqs},
        post_processing => !$opt{'no-annotate'},
      );
      $self->app->worker->enqueue($task);
    }
    $batch_no++;
  }
}

=pod

=head1 NAME

TearDrop::Command::run_blast - Run automatic BLAST for transcripts/genes

=head1 SYNOPSIS

  Usage: tear_drop run_blast [OPTIONS]

  Required Options:
    -p, --project     
        Name of the project context in which to run. See L<TearDrop::Command::deploy_project>.
    --db, --db_source 
        Databases in which to search, eg. C<refseq_plant>. Can be specified multiple times.

  Optional Options for transcript selection:
    -a, --assembly    
        Name of the assembly (XXX test me)
    -i, --id        
        Pattern for id (XXX test me)

  Processing:
    --no-annotate     
        Do not run automatic annotation postprocessing
    --batch_size
        Start individual BLAST jobs every n genes. Defaults to 50
    --evalue_cutoff
        Defaults to .01
    --max_target_seqs
        Defaults to 20

=head1 DESCRIPTION

=head1 METHODS

Inherits all methods from L<Mojolicious::Command> and implements the following new ones.

=head2 run

  $run_blast->run(@ARGV);

=cut

1;
