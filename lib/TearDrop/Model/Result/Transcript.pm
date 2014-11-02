use utf8;
package TearDrop::Model::Result::Transcript;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TearDrop::Model::Result::Transcript

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

=head1 TABLE: C<transcripts>

=cut

__PACKAGE__->table("transcripts");

=head1 ACCESSORS

=head2 id

  data_type: 'text'
  is_nullable: 0

=head2 assembly_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 gene

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 1

=head2 name

  data_type: 'text'
  is_nullable: 1

=head2 nsequence

  data_type: 'text'
  is_nullable: 1

=head2 organism

  data_type: 'text'
  is_foreign_key: 1
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
  "assembly_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "gene",
  { data_type => "text", is_foreign_key => 1, is_nullable => 1 },
  "name",
  { data_type => "text", is_nullable => 1 },
  "nsequence",
  { data_type => "text", is_nullable => 1 },
  "organism",
  { data_type => "text", is_foreign_key => 1, is_nullable => 1 },
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

=head2 assembly

Type: belongs_to

Related object: L<TearDrop::Model::Result::TranscriptAssembly>

=cut

__PACKAGE__->belongs_to(
  "assembly",
  "TearDrop::Model::Result::TranscriptAssembly",
  { id => "assembly_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 blast_results

Type: has_many

Related object: L<TearDrop::Model::Result::BlastResult>

=cut

__PACKAGE__->has_many(
  "blast_results",
  "TearDrop::Model::Result::BlastResult",
  { "foreign.transcript_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 blast_runs

Type: has_many

Related object: L<TearDrop::Model::Result::BlastRun>

=cut

__PACKAGE__->has_many(
  "blast_runs",
  "TearDrop::Model::Result::BlastRun",
  { "foreign.transcript_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 gene

Type: belongs_to

Related object: L<TearDrop::Model::Result::Gene>

=cut

__PACKAGE__->belongs_to(
  "gene",
  "TearDrop::Model::Result::Gene",
  { id => "gene" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);

=head2 organism

Type: belongs_to

Related object: L<TearDrop::Model::Result::Organism>

=cut

__PACKAGE__->belongs_to(
  "organism",
  "TearDrop::Model::Result::Organism",
  { name => "organism" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);

=head2 raw_counts

Type: has_many

Related object: L<TearDrop::Model::Result::RawCount>

=cut

__PACKAGE__->has_many(
  "raw_counts",
  "TearDrop::Model::Result::RawCount",
  { "foreign.transcript_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 transcript_mappings

Type: has_many

Related object: L<TearDrop::Model::Result::TranscriptMapping>

=cut

__PACKAGE__->has_many(
  "transcript_mappings",
  "TearDrop::Model::Result::TranscriptMapping",
  { "foreign.transcript_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 transcript_tags

Type: has_many

Related object: L<TearDrop::Model::Result::TranscriptTag>

=cut

__PACKAGE__->has_many(
  "transcript_tags",
  "TearDrop::Model::Result::TranscriptTag",
  { "foreign.transcript_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 tags

Type: many_to_many

Composing rels: L</transcript_tags> -> tag

=cut

__PACKAGE__->many_to_many("tags", "transcript_tags", "tag");


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2014-11-02 18:46:59
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:GUU2VyHaGQIlfa+0R5/8Ng

sub _is_column_serializable { 1 };

sub to_fasta {
  my $self = shift;
  return ">".$self->id."\n".$self->nsequence."\n";
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
