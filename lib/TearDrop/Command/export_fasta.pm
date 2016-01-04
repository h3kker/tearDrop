package TearDrop::Command::export_fasta;

use 5.12.0;

use Mojo::Base 'Mojolicious::Command';

use Carp;
use Try::Tiny;

use Getopt::Long qw(GetOptionsFromArray :config no_auto_abbrev no_ignore_case);

has description => 'Export FASTA file with transcripts according to filter';
has usage => sub { shift->extract_usage };

sub run {
  my ($self, @args) = @_;

  my %opt = ();
  GetOptionsFromArray(\@args, \%opt, 'project|p=s', 'tags|t=s@', 'rating|r=i', 'assembly|a=s', 'organism|o=s', 'name|n=s', 'id=s') or croak $self->help;

  croak 'need project context' unless $opt{project};

  my %field_map = ('organism.scientific_name' => 'organism');
  my $comparisons = $self->app->schema($opt{project})->resultset('Transcript')->result_class->new->comparisons;
  my %search;
  for my $field (keys %$comparisons) {
    my $o_field = $field_map{$field} || $field;
    if (exists $opt{$o_field}) {
      my $col = $comparisons->{$field}{column};
      if ($comparisons->{$field}{cmp} eq 'like') {
        $opt{$o_field}='%'.lc($opt{$o_field}).'%';
        $col=sprintf 'LOWER(%s)' => $col;
      }
      if ($comparisons->{$field}{cmp} eq 'IN') {
        $search{$col} = $opt{$o_field};
      }
      else {
        $search{$col} = { $comparisons->{$field}{cmp} => $opt{$o_field} };
      }
    }
  }
  my $rs = $self->app->schema($opt{project})->resultset('Transcript')->search(\%search, {
    prefetch => [ 'organism', { 'transcript_tags' => [ 'tag' ] }, 'assembly' ],
  });
  warn "exporting ".$rs->count." transcripts...\n";
  while (my $t = $rs->next) {
    print $t->to_fasta;
    print "\n";
  }
}

=pod

=head1 NAME

TearDrop::Command::export_fasta - export transcripts in FASTA format

=head1 SYNOPSIS

  Usage: tear_drop export_fasta [OPTIONS]

  Required Options:
   -p, --project [project]
       Name of the project context in which to run. See L<TearDrop::Command::deploy_project>.

=head1 DESCRIPTION

=head1 METHODS

Inherits all methods from L<Mojolicious::Command> and implements the following new ones.

=head2 run

  $export_fasta->run(@ARGV);

=cut

1;
