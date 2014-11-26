package TearDrop::Model::TranscriptLike;

use warnings;
use strict;

use Moo::Role;
use namespace::clean;
use Try::Tiny;
use TearDrop::Logger;

sub auto_annotate {
  my $self = shift;
  return if $self->reviewed;

  my $best_homolog = $self->best_blast_hit;
  if($best_homolog) {
    if (!defined $self->best_homolog || $self->best_homolog ne $best_homolog->source_sequence_id) {
      $self->best_homolog($best_homolog->source_sequence_id);
      $self->name($best_homolog->stitle);
      try {
        $self->delete_tags('no homologs', 'bad homologs', 'lots of mappings');
      } catch {
        logger->debug('remove tag error '.$_);
        # maybe we should tell somebody about this, but otherwise it's ok
      };
      if ($best_homolog->evalue < 1e-5) {
        $self->set_tag({ tag => 'good homologs', category => 'homology', level => 'success' });
      }
      else {
        $self->set_tag({ tag => 'bad homologs', category => 'homology', level => 'warning' });
      }
      $self->update;
    }
  }
  elsif ($self->blast_runs({finished => 1})->count) {
    # at least one blast, but no results
    $self->set_tag({ tag => 'no homologs', category => 'homology', level => 'danger' });
  }
  
  my @mappings = $self->filtered_mappings;
  try {
    $self->delete_tags('unmapped', 'good mapping', 'lots of mappings');
  } catch {
    logger->debug('remove tag error '.$_);
    # maybe we should tell somebody about this, but otherwise it's ok
  };
  if (@mappings == 0) {
    $self->set_tag({ tag => 'unmapped', category => 'mapping', level => 'danger' });
  }
  elsif (@mappings < 6) {
    $self->set_tag({ tag => 'good mapping', category => 'mapping', level => 'success' });
  }
  else {
    $self->set_tag({ tag => 'lots of mappings', category => 'mapping', level => 'warning' });
  }
}

sub delete_tags {
  my ($self, @clear) = @_;
  for (@clear) {
    my $t = $self->result_source->schema->resultset('Tag')->find($_);
    $self->remove_from_tags($t) if $t;
  }
}

sub update_tags {
  my ($self, @upd_tags) = @_;
  my %new_tags = map { $_->{tag} => $_ } @upd_tags;
  for my $o ($self->tags) {
    if ($new_tags{$o->tag}) {
      delete $new_tags{$o->tag};
    }
    else {
      $self->remove_from_tags($o);
    }
  }
  for my $n (values %new_tags) {
    my $ntag = $self->result_source->schema->resultset('Tag')->find_or_create($n);
    $self->add_to_tags($ntag);
  }
}

sub set_tag {
  my ($self, $tag) = @_;
  $self->result_source->schema->txn_do(sub {
    for my $o ($self->tags) {
      return if ($o->tag eq $tag->{tag});
    }
    $self->add_to_tags($self->result_source->schema->resultset('Tag')->find_or_create($tag));
  });
}

sub gene_model_annotations {
  my ($self, $context, $param) = @_;
  $context = 200 unless defined $context;
  my $annotations=[];
  for my $loc (@{$self->filtered_mappings($param)}) { 
    for my $gm ($loc->genome_mapping->organism_name->gene_models) {
      push @$annotations, @{$gm->as_tree({
        contig => $loc->tid, start => $loc->tstart-$context, end => $loc->tend+$context
      }, $param)};
    }
  }
  $annotations;
}


1;
