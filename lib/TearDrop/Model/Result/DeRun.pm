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

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");

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
  is_nullable: 0

=head2 run_date

  data_type: 'timestamp'
  is_nullable: 1

=head2 parameters

  data_type: 'text'
  is_nullable: 1

=head2 count_table_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

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
  { data_type => "text", is_nullable => 0 },
  "run_date",
  { data_type => "timestamp", is_nullable => 1 },
  "parameters",
  { data_type => "text", is_nullable => 1 },
  "count_table_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<de_runs_description_key>

=over 4

=item * L</description>

=back

=cut

__PACKAGE__->add_unique_constraint("de_runs_description_key", ["description"]);

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


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2014-10-24 18:23:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:+iXGi6XGb+WxMkLOT+kIJQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
