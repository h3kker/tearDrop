use utf8;
package TearDrop::Model::Result::Gene;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TearDrop::Model::Result::Gene

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=item * L<DBIx::Class::Helper::Row::ToJSON>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime", "Helper::Row::ToJSON");

=head1 TABLE: C<genes>

=cut

__PACKAGE__->table("genes");

=head1 ACCESSORS

=head2 id

  data_type: 'text'
  is_nullable: 0

=head2 description

  data_type: 'text'
  is_nullable: 1

=head2 flagged

  data_type: 'boolean'
  default_value: false
  is_nullable: 1

=head2 best_homolog

  data_type: 'text'
  is_nullable: 1

=head2 rating

  data_type: 'integer'
  is_nullable: 1

=head2 reviewed

  data_type: 'boolean'
  default_value: false
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "text", is_nullable => 0 },
  "description",
  { data_type => "text", is_nullable => 1 },
  "flagged",
  { data_type => "boolean", default_value => \"false", is_nullable => 1 },
  "best_homolog",
  { data_type => "text", is_nullable => 1 },
  "rating",
  { data_type => "integer", is_nullable => 1 },
  "reviewed",
  { data_type => "boolean", default_value => \"false", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 gene_tags

Type: has_many

Related object: L<TearDrop::Model::Result::GeneTag>

=cut

__PACKAGE__->has_many(
  "gene_tags",
  "TearDrop::Model::Result::GeneTag",
  { "foreign.gene_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 transcripts

Type: has_many

Related object: L<TearDrop::Model::Result::Transcript>

=cut

__PACKAGE__->has_many(
  "transcripts",
  "TearDrop::Model::Result::Transcript",
  { "foreign.gene" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 tags

Type: many_to_many

Composing rels: L</gene_tags> -> tag

=cut

__PACKAGE__->many_to_many("tags", "gene_tags", "tag");


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2014-11-01 11:06:51
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:tzOLaDw/VqGZAsGpTylGCA

use Dancer::Plugin::DBIC 'schema';

use Moo;
use namespace::clean;

sub _is_column_serializable { 1 };

around set_tags => sub {
  my ($orig, $self, @upd_tags) = @_;
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
    my $ntag = schema->resultset('Tag')->find_or_create($n);
    $self->add_to_tags($ntag);
  }
};

sub aggregate_blast_runs {
  my $self = shift;
  my %blast_runs;
  for my $trans ($self->search_related('transcripts')) {
    for my $brun ($trans->search_related('blast_runs', { finished => 1 })) {
      my $brun_ser = $brun->TO_JSON;
      $brun_ser->{db_source}=$brun->db_source->TO_JSON;
      $blast_runs{$brun->db_source->name} ||= $brun_ser;
      my $hit_count = schema->resultset('BlastResult')->search({
        transcript_id => $trans->id, db_source_id => $brun->db_source_id
      })->count;
      $blast_runs{$brun->db_source->name}->{matched_transcripts} ||= 0;
      $blast_runs{$brun->db_source->name}->{matched_transcripts}++ if $hit_count;
      $blast_runs{$brun->db_source->name}->{hits} += $hit_count;
    }
  }
  [ values %blast_runs ];
}

sub to_fasta {
  my $self = shift;
  my @ret;
  for my $t ($self->transcripts) {
    $t->name($self->description) unless $t->name;
    push @ret, $t->to_fasta;
  }
  join("\n", @ret);
}

sub comparisons {
  {
    rating => { cmp => '>', column => 'me.rating' }, id => { cmp => 'like', column => 'me.id' },
    description => { cmp => 'like', column => 'me.description' }, 'best_homolog' => { cmp => 'like', column => 'me.best_homolog' }, 'reviewed' => { cmp => '=', column => 'me.reviewed' },
    'tags' => { cmp => 'IN', column => 'gene_tags.tag' },
    'organism' => { cmp => 'like', column => 'transcripts.organism' },
  };
}

sub organism {
  my $self = shift;
  my %organisms;
  for my $t ($self->transcripts) {
    next unless $t->organism;
    $organisms{$t->organism->scientific_name}++;
  }
  [
    map { 
      {
        scientific_name => $_,
        count => $organisms{$_},
      }
    } keys %organisms
  ];
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
