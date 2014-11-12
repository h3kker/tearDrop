use utf8;
package TearDrop::Model::Result::AssembledFile;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TearDrop::Model::Result::AssembledFile

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

=head1 TABLE: C<assembled_files>

=cut

__PACKAGE__->table("assembled_files");

=head1 ACCESSORS

=head2 assembly_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 raw_file_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "assembly_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "raw_file_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);

=head1 RELATIONS

=head2 assembly

Type: belongs_to

Related object: L<TearDrop::Model::Result::TranscriptAssembly>

=cut

__PACKAGE__->belongs_to(
  "assembly",
  "TearDrop::Model::Result::TranscriptAssembly",
  { id => "assembly_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 raw_file

Type: belongs_to

Related object: L<TearDrop::Model::Result::RawFile>

=cut

__PACKAGE__->belongs_to(
  "raw_file",
  "TearDrop::Model::Result::RawFile",
  { id => "raw_file_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2014-10-26 17:42:56
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:JrkBYhRuvDEBWZMag0tevQ

sub _is_column_serializable { 1 };

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
