use utf8;
package TearDrop::Model::Result::DeRun;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TearDrop::Model::Result::DeRun

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

=head1 TABLE: C<de_runs>

=cut

__PACKAGE__->table("de_runs");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'de_runs_id_seq'

=head2 description

  data_type: 'text'
  is_nullable: 1

=head2 run_date

  data_type: 'timestamp'
  is_nullable: 1

=head2 parameters

  data_type: 'text'
  is_nullable: 1

=head2 path

  data_type: 'text'
  is_nullable: 1

=head2 count_table_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 name

  data_type: 'text'
  is_nullable: 0

=head2 sha1

  data_type: 'text'
  is_nullable: 1

=head2 imported

  data_type: 'boolean'
  default_value: false
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "de_runs_id_seq",
  },
  "description",
  { data_type => "text", is_nullable => 1 },
  "run_date",
  { data_type => "timestamp", is_nullable => 1 },
  "parameters",
  { data_type => "text", is_nullable => 1 },
  "path",
  { data_type => "text", is_nullable => 1 },
  "count_table_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "name",
  { data_type => "text", is_nullable => 0 },
  "sha1",
  { data_type => "text", is_nullable => 1 },
  "imported",
  { data_type => "boolean", default_value => \"false", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<de_runs_name_key>

=over 4

=item * L</name>

=back

=cut

__PACKAGE__->add_unique_constraint("de_runs_name_key", ["name"]);

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

=head2 de_results

Type: has_many

Related object: L<TearDrop::Model::Result::DeResult>

=cut

__PACKAGE__->has_many(
  "de_results",
  "TearDrop::Model::Result::DeResult",
  { "foreign.de_run_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 de_run_contrasts

Type: has_many

Related object: L<TearDrop::Model::Result::DeRunContrast>

=cut

__PACKAGE__->has_many(
  "de_run_contrasts",
  "TearDrop::Model::Result::DeRunContrast",
  { "foreign.de_run_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2014-11-12 20:33:26
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:BtYK8YD3NrXkv4wSmC2d+A

sub _is_column_serializable { 1 };

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
