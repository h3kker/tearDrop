use utf8;
package TearDrop::Model::Result::DeResult;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TearDrop::Model::Result::DeResult

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

=head1 TABLE: C<de_results>

=cut

__PACKAGE__->table("de_results");

=head1 ACCESSORS

=head2 de_run_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 contrast_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 transcript_id

  data_type: 'text'
  is_nullable: 0

=head2 pvalue

  data_type: 'double precision'
  is_nullable: 1

=head2 adjp

  data_type: 'double precision'
  is_nullable: 1

=head2 base_mean

  data_type: 'double precision'
  is_nullable: 1

=head2 log2_foldchange

  data_type: 'double precision'
  is_nullable: 1

=head2 flagged

  data_type: 'boolean'
  default_value: false
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "de_run_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "contrast_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "transcript_id",
  { data_type => "text", is_nullable => 0 },
  "pvalue",
  { data_type => "double precision", is_nullable => 1 },
  "adjp",
  { data_type => "double precision", is_nullable => 1 },
  "base_mean",
  { data_type => "double precision", is_nullable => 1 },
  "log2_foldchange",
  { data_type => "double precision", is_nullable => 1 },
  "flagged",
  { data_type => "boolean", default_value => \"false", is_nullable => 1 },
);

=head1 UNIQUE CONSTRAINTS

=head2 C<de_results_de_run_id_contrast_id_transcript_id_key>

=over 4

=item * L</de_run_id>

=item * L</contrast_id>

=item * L</transcript_id>

=back

=cut

__PACKAGE__->add_unique_constraint(
  "de_results_de_run_id_contrast_id_transcript_id_key",
  ["de_run_id", "contrast_id", "transcript_id"],
);

=head1 RELATIONS

=head2 contrast

Type: belongs_to

Related object: L<TearDrop::Model::Result::Contrast>

=cut

__PACKAGE__->belongs_to(
  "contrast",
  "TearDrop::Model::Result::Contrast",
  { id => "contrast_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 de_run

Type: belongs_to

Related object: L<TearDrop::Model::Result::DeRun>

=cut

__PACKAGE__->belongs_to(
  "de_run",
  "TearDrop::Model::Result::DeRun",
  { id => "de_run_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 de_run_contrast

Type: belongs_to

Related object: L<TearDrop::Model::Result::DeRunContrast>

=cut

__PACKAGE__->belongs_to(
  "de_run_contrast",
  "TearDrop::Model::Result::DeRunContrast",
  { contrast_id => "contrast_id", de_run_id => "de_run_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2014-10-26 23:28:20
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:1HMTfl9GHdcU3H/mZWOs4w

sub _is_column_serializable { 1 };

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
