use utf8;
package TearDrop::Model::Result::Sample;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TearDrop::Model::Result::Sample

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

=head1 TABLE: C<samples>

=cut

__PACKAGE__->table("samples");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'samples_id_seq'

=head2 forskalle_id

  data_type: 'integer'
  is_nullable: 1

=head2 description

  data_type: 'text'
  is_nullable: 0

=head2 condition

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 0

=head2 replicate_number

  data_type: 'integer'
  is_nullable: 1

=head2 flagged

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
    sequence          => "samples_id_seq",
  },
  "forskalle_id",
  { data_type => "integer", is_nullable => 1 },
  "description",
  { data_type => "text", is_nullable => 0 },
  "condition",
  { data_type => "text", is_foreign_key => 1, is_nullable => 0 },
  "replicate_number",
  { data_type => "integer", is_nullable => 1 },
  "flagged",
  { data_type => "boolean", default_value => \"false", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<samples_forskalle_id_key>

=over 4

=item * L</forskalle_id>

=back

=cut

__PACKAGE__->add_unique_constraint("samples_forskalle_id_key", ["forskalle_id"]);

=head1 RELATIONS

=head2 alignments

Type: has_many

Related object: L<TearDrop::Model::Result::Alignment>

=cut

__PACKAGE__->has_many(
  "alignments",
  "TearDrop::Model::Result::Alignment",
  { "foreign.sample_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 condition

Type: belongs_to

Related object: L<TearDrop::Model::Result::Condition>

=cut

__PACKAGE__->belongs_to(
  "condition",
  "TearDrop::Model::Result::Condition",
  { name => "condition" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 raw_files

Type: has_many

Related object: L<TearDrop::Model::Result::RawFile>

=cut

__PACKAGE__->has_many(
  "raw_files",
  "TearDrop::Model::Result::RawFile",
  { "foreign.sample_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 sample_counts

Type: has_many

Related object: L<TearDrop::Model::Result::SampleCount>

=cut

__PACKAGE__->has_many(
  "sample_counts",
  "TearDrop::Model::Result::SampleCount",
  { "foreign.sample_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2014-10-29 11:56:47
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:wEclHE+WxNbb8g9auTEL2Q

sub _is_column_serializable { 1 };

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
