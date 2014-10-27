use utf8;
package TearDrop::Model::Result::DbSource;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TearDrop::Model::Result::DbSource

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

=head1 TABLE: C<db_sources>

=cut

__PACKAGE__->table("db_sources");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'db_sources_id_seq'

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

=head1 RELATIONS

=head2 blast_results

Type: has_many

Related object: L<TearDrop::Model::Result::BlastResult>

=cut

__PACKAGE__->has_many(
  "blast_results",
  "TearDrop::Model::Result::BlastResult",
  { "foreign.db_source_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2014-10-26 17:42:56
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:B6kxTDvS5SGCfxQIiwjIyw

sub _is_column_serializable { 1 };

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
