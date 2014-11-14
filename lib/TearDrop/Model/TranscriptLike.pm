package TearDrop::Model::TranscriptLike;

use warnings;
use strict;

use Dancer qw/:moose !status/;

use Moo::Role;
use namespace::clean;

sub original_id {
  my $self = shift;
  return index($self->id, $self->assembly->prefix)==-1 ? $self->id :
    substr $self->id, length($self->assembly->prefix)+1;
}

sub auto_annotate {
  my $self = shift;
  return if $self->reviewed;
  my $best_homolog = $self->best_blast_hit;
  unless($best_homolog) {
    debug 'auto_annotate '.$self->id.': no homologs...';
    $self->set_tag({ tag => 'no homologs', category => 'homology' });
    return;
  }
  if (!defined $self->best_homolog || $self->best_homolog ne $best_homolog->source_sequence_id) {
    debug 'auto_annotate '.$self->id.' setting best homolog to '.$best_homolog->stitle;
    $self->best_homolog($best_homolog->source_sequence_id);
    $self->name($best_homolog->stitle);
    $self->description($best_homolog->stitle);
    if ($best_homolog->evalue < 1e-10) {
      $self->set_tag({ tag => 'good homologs', category => 'homology' });
    }
    else {
      $self->set_tag({ tag => 'bad homologs', category => 'homology' });
    }
    $self->update;
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
  for my $o ($self->tags) {
    return if ($o->tag eq $tag->{tag});
  }
  $self->add_to_tags($self->result_source->schema->resultset('Tag')->find_or_create($tag));
}

sub gene_model_annotations {
  my ($self, $context) = @_;
  $context = 200 unless defined $context;
  my $annotations;
  for my $loc (@{$self->mappings}) {
    my $ann = $loc->genome_mapping->organism_name->gene_models->search_related('gene_model_mappings', {
      -and => [
        contig => $loc->tid,
        -or => [
          cstart => { '>',  $loc->tstart-$context, '<', $loc->tend+$context },
          cend => { '<', $loc->tend+$context, '>', $loc->tstart-$context },
          -and => { cstart => { '<', $loc->tstart-$context }, cend => { '>', $loc->tend+$context }},
        ]
      ]
    });
    push @$annotations, $_ for $ann->all;
  }
  $annotations;
}


1;
