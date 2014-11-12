use utf8;
package TearDrop::Master::Model::Result::GeneModel;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TearDrop::Master::Model::Result::GeneModel

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

=head1 TABLE: C<gene_models>

=cut

__PACKAGE__->table("gene_models");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'gene_models_id_seq'

=head2 organism

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 1

=head2 name

  data_type: 'text'
  is_nullable: 0

=head2 description

  data_type: 'text'
  is_nullable: 1

=head2 sha1

  data_type: 'text'
  is_nullable: 1

=head2 imported

  data_type: 'boolean'
  default_value: false
  is_nullable: 1

=head2 path

  data_type: 'text'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "gene_models_id_seq",
  },
  "organism",
  { data_type => "text", is_foreign_key => 1, is_nullable => 1 },
  "name",
  { data_type => "text", is_nullable => 0 },
  "description",
  { data_type => "text", is_nullable => 1 },
  "sha1",
  { data_type => "text", is_nullable => 1 },
  "imported",
  { data_type => "boolean", default_value => \"false", is_nullable => 1 },
  "path",
  { data_type => "text", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<gene_models_name_key>

=over 4

=item * L</name>

=back

=cut

__PACKAGE__->add_unique_constraint("gene_models_name_key", ["name"]);

=head1 RELATIONS

=head2 organism

Type: belongs_to

Related object: L<TearDrop::Master::Model::Result::Organism>

=cut

__PACKAGE__->belongs_to(
  "organism",
  "TearDrop::Master::Model::Result::Organism",
  { name => "organism" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2014-11-12 19:13:38
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:MRkA0CnM9UAWDXYdos1aqQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
