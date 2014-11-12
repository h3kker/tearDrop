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

=item * L<DBIx::Class::Helper::Row::ToJSON>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime", "Helper::Row::ToJSON");

=head1 TABLE: C<count_methods>

=cut

__PACKAGE__->table("count_methods");

=head1 ACCESSORS

=head2 name

  data_type: 'text'
  is_nullable: 0

=head2 program

  data_type: 'text'
  is_nullable: 0

=head2 index_path

  data_type: 'text'
  is_nullable: 1

=head2 arguments

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "name",
  { data_type => "text", is_nullable => 0 },
  "program",
  { data_type => "text", is_nullable => 0 },
  "index_path",
  { data_type => "text", is_nullable => 1 },
  "arguments",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</name>

=back

=cut

__PACKAGE__->set_primary_key("name");

=head1 RELATIONS

=head2 sample_counts

Type: has_many

Related object: L<TearDrop::Model::Result::SampleCount>

=cut

__PACKAGE__->has_many(
  "sample_counts",
  "TearDrop::Model::Result::SampleCount",
  { "foreign.count_method" => "self.name" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2014-10-26 17:42:56
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:dONielpMbUBxKd2SQeUqYQ

sub _is_column_serializable { 1 };

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
