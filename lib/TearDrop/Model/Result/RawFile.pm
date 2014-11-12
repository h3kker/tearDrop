use utf8;
package TearDrop::Model::Result::RawFile;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TearDrop::Model::Result::RawFile

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

=head1 TABLE: C<raw_files>

=cut

__PACKAGE__->table("raw_files");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'raw_files_id_seq'

=head2 parent_file_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 sample_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 read

  data_type: 'integer'
  is_nullable: 0

=head2 description

  data_type: 'text'
  is_nullable: 0

=head2 path

  data_type: 'text'
  is_nullable: 0

=head2 sha1

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "raw_files_id_seq",
  },
  "parent_file_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "sample_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "read",
  { data_type => "integer", is_nullable => 0 },
  "description",
  { data_type => "text", is_nullable => 0 },
  "path",
  { data_type => "text", is_nullable => 0 },
  "sha1",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<raw_files_path_key>

=over 4

=item * L</path>

=back

=cut

__PACKAGE__->add_unique_constraint("raw_files_path_key", ["path"]);

=head1 RELATIONS

=head2 assembled_files

Type: has_many

Related object: L<TearDrop::Model::Result::AssembledFile>

=cut

__PACKAGE__->has_many(
  "assembled_files",
  "TearDrop::Model::Result::AssembledFile",
  { "foreign.raw_file_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 parent_file

Type: belongs_to

Related object: L<TearDrop::Model::Result::RawFile>

=cut

__PACKAGE__->belongs_to(
  "parent_file",
  "TearDrop::Model::Result::RawFile",
  { id => "parent_file_id" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);

=head2 raw_files

Type: has_many

Related object: L<TearDrop::Model::Result::RawFile>

=cut

__PACKAGE__->has_many(
  "raw_files",
  "TearDrop::Model::Result::RawFile",
  { "foreign.parent_file_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 sample

Type: belongs_to

Related object: L<TearDrop::Model::Result::Sample>

=cut

__PACKAGE__->belongs_to(
  "sample",
  "TearDrop::Model::Result::Sample",
  { id => "sample_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2014-11-12 20:33:26
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:OOMIPEUueJMfy2TAWNgn5w


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
