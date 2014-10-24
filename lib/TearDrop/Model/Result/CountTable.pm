use utf8;
package TearDrop::Model::Result::CountTable;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TearDrop::Model::Result::CountTable

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

=head1 TABLE: C<count_tables>

=cut

__PACKAGE__->table("count_tables");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'count_tables_id_seq'

=head2 description

  data_type: 'text'
  is_nullable: 0

=head2 count_method_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 subset_of

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 path

  data_type: 'text'
  is_nullable: 0

=head2 run_date

  data_type: 'timestamp'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "count_tables_id_seq",
  },
  "description",
  { data_type => "text", is_nullable => 0 },
  "count_method_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "subset_of",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "path",
  { data_type => "text", is_nullable => 0 },
  "run_date",
  { data_type => "timestamp", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<count_tables_description_key>

=over 4

=item * L</description>

=back

=cut

__PACKAGE__->add_unique_constraint("count_tables_description_key", ["description"]);

=head1 RELATIONS

=head2 count_method

Type: belongs_to

Related object: L<TearDrop::Model::Result::CountMethod>

=cut

__PACKAGE__->belongs_to(
  "count_method",
  "TearDrop::Model::Result::CountMethod",
  { id => "count_method_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 count_tables

Type: has_many

Related object: L<TearDrop::Model::Result::CountTable>

=cut

__PACKAGE__->has_many(
  "count_tables",
  "TearDrop::Model::Result::CountTable",
  { "foreign.subset_of" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 de_runs

Type: has_many

Related object: L<TearDrop::Model::Result::DeRun>

=cut

__PACKAGE__->has_many(
  "de_runs",
  "TearDrop::Model::Result::DeRun",
  { "foreign.count_table_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 raw_counts

Type: has_many

Related object: L<TearDrop::Model::Result::RawCount>

=cut

__PACKAGE__->has_many(
  "raw_counts",
  "TearDrop::Model::Result::RawCount",
  { "foreign.count_table_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 subset_of

Type: belongs_to

Related object: L<TearDrop::Model::Result::CountTable>

=cut

__PACKAGE__->belongs_to(
  "subset_of",
  "TearDrop::Model::Result::CountTable",
  { id => "subset_of" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2014-10-24 18:23:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:FVhO4pXO6Xbizzzf4Ij9vw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
