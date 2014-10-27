use utf8;
package TearDrop::Model::Result::SampleCount;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TearDrop::Model::Result::SampleCount

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

=head1 TABLE: C<sample_counts>

=cut

__PACKAGE__->table("sample_counts");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'sample_counts_id_seq'

=head2 sample_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 count_method

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 0

=head2 call

  data_type: 'text'
  is_nullable: 1

=head2 path

  data_type: 'text'
  is_nullable: 0

=head2 mapped_ratio

  data_type: 'double precision'
  is_nullable: 1

=head2 run_date

  data_type: 'timestamp'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "sample_counts_id_seq",
  },
  "sample_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "count_method",
  { data_type => "text", is_foreign_key => 1, is_nullable => 0 },
  "call",
  { data_type => "text", is_nullable => 1 },
  "path",
  { data_type => "text", is_nullable => 0 },
  "mapped_ratio",
  { data_type => "double precision", is_nullable => 1 },
  "run_date",
  { data_type => "timestamp", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 count_method

Type: belongs_to

Related object: L<TearDrop::Model::Result::CountMethod>

=cut

__PACKAGE__->belongs_to(
  "count_method",
  "TearDrop::Model::Result::CountMethod",
  { name => "count_method" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 raw_counts

Type: has_many

Related object: L<TearDrop::Model::Result::RawCount>

=cut

__PACKAGE__->has_many(
  "raw_counts",
  "TearDrop::Model::Result::RawCount",
  { "foreign.sample_count_id" => "self.id" },
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


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2014-10-27 09:40:06
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:SVhruQtJxhZYkrenb72Upg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
