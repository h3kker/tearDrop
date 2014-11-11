use utf8;
package TearDrop::Model::Result::GeneModelMapping;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TearDrop::Model::Result::GeneModelMapping

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

=head1 TABLE: C<gene_model_mappings>

=cut

__PACKAGE__->table("gene_model_mappings");

=head1 ACCESSORS

=head2 contig

  data_type: 'text'
  is_nullable: 0

=head2 mtype

  data_type: 'text'
  is_nullable: 0

=head2 cstart

  data_type: 'integer'
  is_nullable: 0

=head2 cend

  data_type: 'integer'
  is_nullable: 0

=head2 id

  data_type: 'text'
  is_nullable: 0

=head2 name

  data_type: 'text'
  is_nullable: 1

=head2 parent

  data_type: 'text'
  is_nullable: 1

=head2 additional

  data_type: 'text'
  is_nullable: 1

=head2 gene_model_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 strand

  data_type: 'text'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "contig",
  { data_type => "text", is_nullable => 0 },
  "mtype",
  { data_type => "text", is_nullable => 0 },
  "cstart",
  { data_type => "integer", is_nullable => 0 },
  "cend",
  { data_type => "integer", is_nullable => 0 },
  "id",
  { data_type => "text", is_nullable => 0 },
  "name",
  { data_type => "text", is_nullable => 1 },
  "parent",
  { data_type => "text", is_nullable => 1 },
  "additional",
  { data_type => "text", is_nullable => 1 },
  "gene_model_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "strand",
  { data_type => "text", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=item * L</gene_model_id>

=back

=cut

__PACKAGE__->set_primary_key("id", "gene_model_id");

=head1 RELATIONS

=head2 gene_model

Type: belongs_to

Related object: L<TearDrop::Model::Result::GeneModel>

=cut

__PACKAGE__->belongs_to(
  "gene_model",
  "TearDrop::Model::Result::GeneModel",
  { id => "gene_model_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2014-11-11 15:52:06
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:6HEp2x5QyELrJt60F3niNQ

sub _is_column_serializable { 1 };


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
