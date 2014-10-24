use utf8;
package TearDrop::Model::Result::CountMethod;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TearDrop::Model::Result::CountMethod

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

=head1 TABLE: C<count_methods>

=cut

__PACKAGE__->table("count_methods");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'count_methods_id_seq'

=head2 program

  data_type: 'text'
  is_nullable: 0

=head2 arguments

  data_type: 'text'
  is_nullable: 1

=head2 index_path

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "count_methods_id_seq",
  },
  "program",
  { data_type => "text", is_nullable => 0 },
  "arguments",
  { data_type => "text", is_nullable => 1 },
  "index_path",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 count_tables

Type: has_many

Related object: L<TearDrop::Model::Result::CountTable>

=cut

__PACKAGE__->has_many(
  "count_tables",
  "TearDrop::Model::Result::CountTable",
  { "foreign.count_method_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2014-10-24 18:23:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:G9SEeZcg8nQOocq0lZ48DQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
