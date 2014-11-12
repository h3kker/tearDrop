use utf8;
package TearDrop::Model::Result::RawCount;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TearDrop::Model::Result::RawCount

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

=head1 TABLE: C<raw_counts>

=cut

__PACKAGE__->table("raw_counts");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'raw_counts_id_seq'

=head2 transcript_id

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 0

=head2 sample_count_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 count

  data_type: 'double precision'
  is_nullable: 1

=head2 tpm

  data_type: 'double precision'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "raw_counts_id_seq",
  },
  "transcript_id",
  { data_type => "text", is_foreign_key => 1, is_nullable => 0 },
  "sample_count_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "count",
  { data_type => "double precision", is_nullable => 1 },
  "tpm",
  { data_type => "double precision", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<raw_counts_transcript_id_sample_count_id_key>

=over 4

=item * L</transcript_id>

=item * L</sample_count_id>

=back

=cut

__PACKAGE__->add_unique_constraint(
  "raw_counts_transcript_id_sample_count_id_key",
  ["transcript_id", "sample_count_id"],
);

=head1 RELATIONS

=head2 sample_count

Type: belongs_to

Related object: L<TearDrop::Model::Result::SampleCount>

=cut

__PACKAGE__->belongs_to(
  "sample_count",
  "TearDrop::Model::Result::SampleCount",
  { id => "sample_count_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 table_counts

Type: has_many

Related object: L<TearDrop::Model::Result::TableCount>

=cut

__PACKAGE__->has_many(
  "table_counts",
  "TearDrop::Model::Result::TableCount",
  { "foreign.raw_count_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 transcript

Type: belongs_to

Related object: L<TearDrop::Model::Result::Transcript>

=cut

__PACKAGE__->belongs_to(
  "transcript",
  "TearDrop::Model::Result::Transcript",
  { id => "transcript_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2014-10-26 17:42:56
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:D73FShpbmzMsHJnMXsW5wQ

sub _is_column_serializable { 1 };

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
