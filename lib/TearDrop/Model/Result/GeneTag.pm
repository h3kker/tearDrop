use utf8;
package TearDrop::Model::Result::GeneTag;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TearDrop::Model::Result::GeneTag

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

=head1 TABLE: C<gene_tags>

=cut

__PACKAGE__->table("gene_tags");

=head1 ACCESSORS

=head2 gene_id

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 0

=head2 tag

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "gene_id",
  { data_type => "text", is_foreign_key => 1, is_nullable => 0 },
  "tag",
  { data_type => "text", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</gene_id>

=item * L</tag>

=back

=cut

__PACKAGE__->set_primary_key("gene_id", "tag");

=head1 RELATIONS

=head2 gene

Type: belongs_to

Related object: L<TearDrop::Model::Result::Gene>

=cut

__PACKAGE__->belongs_to(
  "gene",
  "TearDrop::Model::Result::Gene",
  { id => "gene_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 tag

Type: belongs_to

Related object: L<TearDrop::Model::Result::Tag>

=cut

__PACKAGE__->belongs_to(
  "tag",
  "TearDrop::Model::Result::Tag",
  { tag => "tag" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2014-11-01 11:06:51
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:nlRZjx8VN8htvYAUjUNSwQ

sub _is_column_serializable { 1 };

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
