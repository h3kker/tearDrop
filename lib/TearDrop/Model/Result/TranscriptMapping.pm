use utf8;
package TearDrop::Model::Result::TranscriptMapping;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TearDrop::Model::Result::TranscriptMapping

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

=head1 TABLE: C<transcript_mappings>

=cut

__PACKAGE__->table("transcript_mappings");

=head1 ACCESSORS

=head2 transcript_id

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 0

=head2 genome_mapping_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 matches

  data_type: 'integer'
  is_nullable: 1

=head2 match_ratio

  data_type: 'double precision'
  is_nullable: 1

=head2 mismatches

  data_type: 'integer'
  is_nullable: 1

=head2 rep_matches

  data_type: 'integer'
  is_nullable: 1

=head2 strand

  data_type: 'text'
  is_nullable: 1

=head2 qstart

  data_type: 'integer'
  is_nullable: 1

=head2 qend

  data_type: 'integer'
  is_nullable: 1

=head2 tid

  data_type: 'text'
  is_nullable: 1

=head2 tsize

  data_type: 'integer'
  is_nullable: 1

=head2 tstart

  data_type: 'integer'
  is_nullable: 1

=head2 tend

  data_type: 'integer'
  is_nullable: 1

=head2 blocksizes

  data_type: 'text'
  is_nullable: 1

=head2 qstarts

  data_type: 'text'
  is_nullable: 1

=head2 tstarts

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "transcript_id",
  { data_type => "text", is_foreign_key => 1, is_nullable => 0 },
  "genome_mapping_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "matches",
  { data_type => "integer", is_nullable => 1 },
  "match_ratio",
  { data_type => "double precision", is_nullable => 1 },
  "mismatches",
  { data_type => "integer", is_nullable => 1 },
  "rep_matches",
  { data_type => "integer", is_nullable => 1 },
  "strand",
  { data_type => "text", is_nullable => 1 },
  "qstart",
  { data_type => "integer", is_nullable => 1 },
  "qend",
  { data_type => "integer", is_nullable => 1 },
  "tid",
  { data_type => "text", is_nullable => 1 },
  "tsize",
  { data_type => "integer", is_nullable => 1 },
  "tstart",
  { data_type => "integer", is_nullable => 1 },
  "tend",
  { data_type => "integer", is_nullable => 1 },
  "blocksizes",
  { data_type => "text", is_nullable => 1 },
  "qstarts",
  { data_type => "text", is_nullable => 1 },
  "tstarts",
  { data_type => "text", is_nullable => 1 },
);

=head1 RELATIONS

=head2 genome_mapping

Type: belongs_to

Related object: L<TearDrop::Model::Result::GenomeMapping>

=cut

__PACKAGE__->belongs_to(
  "genome_mapping",
  "TearDrop::Model::Result::GenomeMapping",
  { id => "genome_mapping_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 transcript

Type: belongs_to

Related object: L<TearDrop::Model::Result::Transcript>

=cut

__PACKAGE__->belongs_to(
  "transcript",
  "TearDrop::Model::Result::Transcript",
  { id => "transcript_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2014-11-02 19:09:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:QTkgXlwf8J/ZnarhwLJsfg

sub _is_column_serializable { 1 };

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
