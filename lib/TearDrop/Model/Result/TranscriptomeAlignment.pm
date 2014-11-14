use utf8;
package TearDrop::Model::Result::TranscriptomeAlignment;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TearDrop::Model::Result::TranscriptomeAlignment

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

=head1 TABLE: C<transcriptome_alignments>

=cut

__PACKAGE__->table("transcriptome_alignments");

=head1 ACCESSORS

=head2 alignment_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 transcript_assembly_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "alignment_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "transcript_assembly_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "use_original_id",
  { data_type => "boolean", default => \"false", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</alignment_id>

=back

=cut

__PACKAGE__->set_primary_key("alignment_id");

=head1 RELATIONS

=head2 alignment

Type: belongs_to

Related object: L<TearDrop::Model::Result::Alignment>

=cut

__PACKAGE__->belongs_to(
  "alignment",
  "TearDrop::Model::Result::Alignment",
  { id => "alignment_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 transcript_assembly

Type: belongs_to

Related object: L<TearDrop::Model::Result::TranscriptAssembly>

=cut

__PACKAGE__->belongs_to(
  "transcript_assembly",
  "TearDrop::Model::Result::TranscriptAssembly",
  { id => "transcript_assembly_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2014-10-29 13:28:04
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ca3eS+twtFuRHWE3ZdXTqA

sub _is_column_serializable { 1 };

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
