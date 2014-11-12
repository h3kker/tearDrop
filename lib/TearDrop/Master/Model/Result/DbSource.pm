use utf8;
package TearDrop::Master::Model::Result::DbSource;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TearDrop::Master::Model::Result::DbSource

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=item * L<DBIx::Class::Helper::Row::ToJSON>

=item * L<DBIx::Class::InflateColumn::Serializer>

=back

=cut

__PACKAGE__->load_components(
  "InflateColumn::DateTime",
  "Helper::Row::ToJSON",
  "InflateColumn::Serializer",
);

=head1 TABLE: C<db_sources>

=cut

__PACKAGE__->table("db_sources");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'db_sources_id_seq'

=head2 name

  data_type: 'text'
  is_nullable: 0

=head2 description

  data_type: 'text'
  is_nullable: 0

=head2 dbtype

  data_type: 'text'
  is_nullable: 1

=head2 url

  data_type: 'text'
  is_nullable: 1

=head2 version

  data_type: 'text'
  is_nullable: 1

=head2 downloaded

  data_type: 'timestamp'
  is_nullable: 1

=head2 path

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "db_sources_id_seq",
  },
  "name",
  { data_type => "text", is_nullable => 0 },
  "description",
  { data_type => "text", is_nullable => 0 },
  "dbtype",
  { data_type => "text", is_nullable => 1 },
  "url",
  { data_type => "text", is_nullable => 1 },
  "version",
  { data_type => "text", is_nullable => 1 },
  "downloaded",
  { data_type => "timestamp", is_nullable => 1 },
  "path",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<db_sources_description_key>

=over 4

=item * L</description>

=back

=cut

__PACKAGE__->add_unique_constraint("db_sources_description_key", ["description"]);

=head2 C<db_sources_name_key>

=over 4

=item * L</name>

=back

=cut

__PACKAGE__->add_unique_constraint("db_sources_name_key", ["name"]);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2014-11-12 19:13:38
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:j/5+UMLiHHb+JP/XIXgySg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
