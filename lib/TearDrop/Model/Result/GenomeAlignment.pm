use utf8;
package TearDrop::Model::Result::GenomeAlignment;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TearDrop::Model::Result::GenomeAlignment

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

=head1 TABLE: C<genome_alignments>

=cut

__PACKAGE__->table("genome_alignments");

=head1 ACCESSORS

=head2 alignment_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 organism_name

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "alignment_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "organism_name",
  { data_type => "text", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</alignment_id>

=back

=cut

__PACKAGE__->set_primary_key("alignment_id");

=head1 RELATIONS

=head2 alignment

Type: belongs_to

Related object: L<TearDrop::Model::Result::Alignment>

=cut

__PACKAGE__->belongs_to(
  "alignment",
  "TearDrop::Model::Result::Alignment",
  { id => "alignment_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 organism_name

Type: belongs_to

Related object: L<TearDrop::Model::Result::Organism>

=cut

__PACKAGE__->belongs_to(
  "organism_name",
  "TearDrop::Model::Result::Organism",
  { name => "organism_name" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2014-10-29 13:28:04
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:iSXm0/kXUNW5bBjq4ZFA1Q

sub _is_column_serializable { 1 };

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
