package TearDrop::Model::TranscriptLike;

use warnings;
use strict;

use Moo::Role;
use namespace::clean;

sub auto_annotate {
  my $self = shift;
  return if $self->reviewed;
  my $best_homolog = $self->best_blast_hit;
  unless($best_homolog) {
    #debug 'auto_annotate '.$self->id.': no homologs...';
    $self->set_tag({ tag => 'no homologs', category => 'homology' });
    return;
  }
  if (!defined $self->best_homolog || $self->best_homolog ne $best_homolog->source_sequence_id) {
    #debug 'auto_annotate '.$self->id.' setting best homolog to '.$best_homolog->stitle;
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
