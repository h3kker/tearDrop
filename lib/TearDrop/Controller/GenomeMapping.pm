package TearDrop::Controller::GenomeMapping;
use Mojo::Base 'Mojolicious::Controller';
use TearDrop::Task::Mpileup;

use 5.12.0;

use warnings;
use strict;

use Carp;

our $VERSION='0.01';

has 'resultset' => 'GenomeMapping';

sub list {
  my $self = shift;
  my @ret = map {
    my $gm = $_;
    my $ser = $gm->TO_JSON;
  } $self->stash('project_schema')->resultset($self->resultset)->search(undef)->all;
  $self->render(json => \@ret);
}

sub check_region_params {
  my $self = shift;
  my $context = $self->param('context') // $self->config->{alignments}{default_context};
  unless($self->param('tid') && $self->param('tstart') && $self->param('tend')) {
    croak 'need start/end coordinates';
  }
  if ($self->param('tend') - $self->param('tstart') + $context * 2 > $self->config->{alignments}{max_width}) {
    croak 'refusing to extract more than '.$self->config->{alignments}{max_width};
  }
  return { context => $context, contig => $self->param('tid'), start => $self->param('tstart')-$context, end => $self->param('tend')+$context };
}

sub annotations {
  my $self = shift;

  my $reg = $self->check_region_params;
  my $gm = $self->stash('project_schema')->resultset($self->resultset)->find($self->param('genomemappingId')) || croak 'no such mapping';
  my @ret;
  push @ret, @{$gm->as_tree($reg, { filter => 1 })};
  for my $mod ($gm->organism_name->gene_models) {
    push @ret, @{$mod->as_tree($reg)};
  }
  $self->render(json => \@ret);
}

sub pileup {
  my $self = shift;
  my $reg = $self->check_region_params;

  my $gm = $self->stash('project_schema')->resultset($self->resultset)->find($self->param('genomemappingId')) || croak 'no such mapping';
  
  my $task = TearDrop::Task::Mpileup->new(
    reference_path => $gm->organism_name->genome_path,
    region => $self->param('tid'), start => $self->param('tstart'), end => $self->param('tend'),
    context => $reg->{context},
    type => 'genome',
    alignments => [ map { $_->alignment } $gm->organism_name->genome_alignments ],
  )->run;

  $self->render(json => $task);
}

1;
