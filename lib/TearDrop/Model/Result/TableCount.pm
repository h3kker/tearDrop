use utf8;
package TearDrop::Model::Result::TableCount;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TearDrop::Model::Result::TableCount

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

=head1 TABLE: C<table_counts>

=cut

__PACKAGE__->table("table_counts");

=head1 ACCESSORS

=head2 count_table_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 raw_count_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "count_table_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "raw_count_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);

=head1 UNIQUE CONSTRAINTS

=head2 C<table_counts_count_table_id_raw_count_id_key>

=over 4

=item * L</count_table_id>

=item * L</raw_count_id>

=back

=cut

__PACKAGE__->add_unique_constraint(
  "table_counts_count_table_id_raw_count_id_key",
  ["count_table_id", "raw_count_id"],
);

=head1 RELATIONS

=head2 count_table

Type: belongs_to

Related object: L<TearDrop::Model::Result::CountTable>

=cut

__PACKAGE__->belongs_to(
  "count_table",
  "TearDrop::Model::Result::CountTable",
  { id => "count_table_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 raw_count

Type: belongs_to

Related object: L<TearDrop::Model::Result::RawCount>

=cut

__PACKAGE__->belongs_to(
  "raw_count",
  "TearDrop::Model::Result::RawCount",
  { id => "raw_count_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2014-10-26 17:42:56
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:c4PiNA6/e45hZPdvl2pdVA

sub _is_column_serializable { 1 };

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
