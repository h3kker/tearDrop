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

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");

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


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2014-10-24 18:23:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:4tUDkcbXneeCAa2guuglUQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
