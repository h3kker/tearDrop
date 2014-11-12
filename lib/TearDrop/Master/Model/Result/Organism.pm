use utf8;
package TearDrop::Master::Model::Result::Organism;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TearDrop::Master::Model::Result::Organism

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

=head1 TABLE: C<organisms>

=cut

__PACKAGE__->table("organisms");

=head1 ACCESSORS

=head2 name

  data_type: 'text'
  is_nullable: 0

=head2 scientific_name

  data_type: 'text'
  is_nullable: 0

=head2 genome_version

  data_type: 'text'
  is_nullable: 0

=head2 genome_path

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "name",
  { data_type => "text", is_nullable => 0 },
  "scientific_name",
  { data_type => "text", is_nullable => 0 },
  "genome_version",
  { data_type => "text", is_nullable => 0 },
  "genome_path",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</name>

=back

=cut

__PACKAGE__->set_primary_key("name");

=head1 RELATIONS

=head2 gene_models

Type: has_many

Related object: L<TearDrop::Master::Model::Result::GeneModel>

=cut

__PACKAGE__->has_many(
  "gene_models",
  "TearDrop::Master::Model::Result::GeneModel",
  { "foreign.organism" => "self.name" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2014-11-12 19:13:38
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:LQ46Qi0V2HQjqSa/C4EMxw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
