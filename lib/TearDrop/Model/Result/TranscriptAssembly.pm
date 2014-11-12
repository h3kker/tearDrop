use utf8;
package TearDrop::Model::Result::TranscriptAssembly;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TearDrop::Model::Result::TranscriptAssembly

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

=head1 TABLE: C<transcript_assemblies>

=cut

__PACKAGE__->table("transcript_assemblies");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'transcript_assemblies_id_seq'

=head2 name

  data_type: 'text'
  is_nullable: 0

=head2 description

  data_type: 'text'
  is_nullable: 1

=head2 program

  data_type: 'text'
  is_nullable: 0

=head2 parameters

  data_type: 'text'
  is_nullable: 1

=head2 assembly_date

  data_type: 'timestamp'
  is_nullable: 1

=head2 path

  data_type: 'text'
  is_nullable: 1

=head2 is_primary

  data_type: 'boolean'
  is_nullable: 0

=head2 sha1

  data_type: 'text'
  is_nullable: 1

=head2 imported

  data_type: 'boolean'
  default_value: false
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "transcript_assemblies_id_seq",
  },
  "name",
  { data_type => "text", is_nullable => 0 },
  "description",
  { data_type => "text", is_nullable => 1 },
  "program",
  { data_type => "text", is_nullable => 0 },
  "parameters",
  { data_type => "text", is_nullable => 1 },
  "assembly_date",
  { data_type => "timestamp", is_nullable => 1 },
  "path",
  { data_type => "text", is_nullable => 1 },
  "is_primary",
  { data_type => "boolean", is_nullable => 0 },
  "sha1",
  { data_type => "text", is_nullable => 1 },
  "imported",
  { data_type => "boolean", default_value => \"false", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<transcript_assemblies_name_key>

=over 4

=item * L</name>

=back

=cut

__PACKAGE__->add_unique_constraint("transcript_assemblies_name_key", ["name"]);

=head1 RELATIONS

=head2 assembled_files

Type: has_many

Related object: L<TearDrop::Model::Result::AssembledFile>

=cut

__PACKAGE__->has_many(
  "assembled_files",
  "TearDrop::Model::Result::AssembledFile",
  { "foreign.assembly_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 genome_mappings

Type: has_many

Related object: L<TearDrop::Model::Result::GenomeMapping>

=cut

__PACKAGE__->has_many(
  "genome_mappings",
  "TearDrop::Model::Result::GenomeMapping",
  { "foreign.transcript_assembly_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 transcriptome_alignments

Type: has_many

Related object: L<TearDrop::Model::Result::TranscriptomeAlignment>

=cut

__PACKAGE__->has_many(
  "transcriptome_alignments",
  "TearDrop::Model::Result::TranscriptomeAlignment",
  { "foreign.transcript_assembly_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 transcripts

Type: has_many

Related object: L<TearDrop::Model::Result::Transcript>

=cut

__PACKAGE__->has_many(
  "transcripts",
  "TearDrop::Model::Result::Transcript",
  { "foreign.assembly_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2014-11-12 20:33:26
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:CQ35CwTEJv0B3C2YItUjUw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
