use utf8;
package TearDrop::Model::Result::CountRawFile;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TearDrop::Model::Result::CountRawFile

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

=head1 TABLE: C<count_raw_files>

=cut

__PACKAGE__->table("count_raw_files");

=head1 ACCESSORS

=head2 count_table_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 raw_file_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "count_table_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "raw_file_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);

=head1 RELATIONS

=head2 count_table

Type: belongs_to

Related object: L<TearDrop::Model::Result::CountTable>

=cut

__PACKAGE__->belongs_to(
  "count_table",
  "TearDrop::Model::Result::CountTable",
  { id => "count_table_id" },
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


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2014-10-25 14:43:49
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:uLVFfKlz3YESaLmdBcgWDA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
