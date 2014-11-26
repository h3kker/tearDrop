package TearDrop::Command::annotate;

use Mojo::Base 'Mojolicious::Command';

use 5.12.0;

use Carp;

use Getopt::Long qw(GetOptionsFromArray :config no_auto_abbrev no_ignore_case);

has description => 'Annotate transcripts/genes from BLAST hits and mapping';
has usage => sub { shift->extract_usage };

sub run {
  my ($self, @args) = @_;

  my %opt = (type => 'both');
  GetOptionsFromArray(\@args, \%opt, 'project|p=s', 'id|i=s', 'type|t=s') or croak $self->help;

  croak "Need project!\n\n".$self->help unless $opt{project};

  my %search = ('me.reviewed' => 0);
  my $prefetch = [ 'transcripts' ];
  if ($opt{assembly}) {
    $search{'transcript_assemblies.name'}=$opt{assembly};
    $prefetch = [ { 'transcripts' => 'assembly' } ];
  }
  if ($opt{id}) {
    $search{'LOWER(me.id)'}={ like => '%'.lc($opt{id}).'%' };
  }
  my $batch_no=1;
  while(1) {
    my @g = $self->app->schema($opt{project})->resultset('Gene')->search(\%search, {
      prefetch => $prefetch,
      page => $batch_no,
      rows => $self->app->config->{import_flush_rows}/10,
    })->all;
    last unless @g;
    say "$batch_no: Working on ".scalar @g." genes";
    $self->app->schema($opt{project})->txn_do(sub {
      for my $g (@g) {
        if ($opt{type} eq 'transcript' || $opt{type} eq 'both') {
          for my $t ($g->transcripts) {
            $t->auto_annotate;
          }
        }
        if ($opt{type} eq 'gene' || $opt{type} eq 'both') {
          $g->auto_annotate;
        }
      }
    });
    say "$batch_no: finished ".scalar @g." genes";
    $batch_no++;
  }
  
}

1;

=pod

=head1 NAME

TearDrop::Command::annotate - Annotate transcripts/genes from BLAST hits and mapping

=head1 SYNOPSIS

  Usage: tear_drop annotate [OPTIONS]

  Required Options:
    -p, --project
        Name of the project context in which to run. See L<TearDrop::Command::deploy_project>.

  Optional Options for transcript selection:
    -i, --id
        Pattern for transcript/gene id 
    -a, --assembly
        Pattern for assembly 

  Processing:
    -t, --type [gene,transcript,both]
        Process genes and/or transcripts. Defaults to C<both>.

    XXX provide options for various cutoffs

=head1 DESCRIPTION

=head1 METHODS

Inherits all methods from L<Mojolicious::Command> and implements the following new ones.

=head2 run

  $run_blast->run(@ARGV);

=cut
