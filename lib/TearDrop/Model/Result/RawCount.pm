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

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 TABLE: C<raw_counts>

=cut

__PACKAGE__->table("raw_counts");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'raw_counts_id_seq'

=head2 count_table_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 transcript_id

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 0

=head2 sample_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 count

  data_type: 'double precision'
  is_nullable: 1

=head2 tpm

  data_type: 'double precision'
  is_nullable: 1

=head2 include

  data_type: 'boolean'
  default_value: true
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
  "count_table_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "transcript_id",
  { data_type => "text", is_foreign_key => 1, is_nullable => 0 },
  "sample_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "count",
  { data_type => "double precision", is_nullable => 1 },
  "tpm",
  { data_type => "double precision", is_nullable => 1 },
  "include",
  { data_type => "boolean", default_value => \"true", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

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


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2014-10-24 18:23:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:7LBh1WS+KfuD9eDb3ip7QQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
