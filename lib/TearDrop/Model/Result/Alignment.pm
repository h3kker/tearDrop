use utf8;
package TearDrop::Model::Result::Alignment;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TearDrop::Model::Result::Alignment

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

=head1 TABLE: C<alignments>

=cut

__PACKAGE__->table("alignments");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'alignments_id_seq'

=head2 program

  data_type: 'text'
  is_nullable: 0

=head2 parameters

  data_type: 'text'
  is_nullable: 1

=head2 description

  data_type: 'text'
  is_nullable: 1

=head2 alignment_date

  data_type: 'timestamp'
  is_nullable: 1

=head2 sample_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 bam_path

  data_type: 'text'
  is_nullable: 0

=head2 total_reads

  data_type: 'double precision'
  is_nullable: 1

=head2 mapped_reads

  data_type: 'double precision'
  is_nullable: 1

=head2 unique_reads

  data_type: 'double precision'
  is_nullable: 1

=head2 multiple_reads

  data_type: 'double precision'
  is_nullable: 1

=head2 discordant_pairs

  data_type: 'double precision'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "alignments_id_seq",
  },
  "program",
  { data_type => "text", is_nullable => 0 },
  "parameters",
  { data_type => "text", is_nullable => 1 },
  "description",
  { data_type => "text", is_nullable => 1 },
  "alignment_date",
  { data_type => "timestamp", is_nullable => 1 },
  "sample_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "bam_path",
  { data_type => "text", is_nullable => 0 },
  "total_reads",
  { data_type => "double precision", is_nullable => 1 },
  "mapped_reads",
  { data_type => "double precision", is_nullable => 1 },
  "unique_reads",
  { data_type => "double precision", is_nullable => 1 },
  "multiple_reads",
  { data_type => "double precision", is_nullable => 1 },
  "discordant_pairs",
  { data_type => "double precision", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 genome_alignment

Type: might_have

Related object: L<TearDrop::Model::Result::GenomeAlignment>

=cut

__PACKAGE__->might_have(
  "genome_alignment",
  "TearDrop::Model::Result::GenomeAlignment",
  { "foreign.alignment_id" => "self.id" },
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

=head2 transcriptome_alignment

Type: might_have

Related object: L<TearDrop::Model::Result::TranscriptomeAlignment>

=cut

__PACKAGE__->might_have(
  "transcriptome_alignment",
  "TearDrop::Model::Result::TranscriptomeAlignment",
  { "foreign.alignment_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2014-10-29 13:28:04
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:0pDhsqt0l/AjJIvpSgM+aA

sub _is_column_serializable { 1 };

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
