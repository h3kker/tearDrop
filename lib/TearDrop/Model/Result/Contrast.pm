use utf8;
package TearDrop::Model::Result::Contrast;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TearDrop::Model::Result::Contrast

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

=head1 TABLE: C<contrasts>

=cut

__PACKAGE__->table("contrasts");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'contrasts_id_seq'

=head2 base_condition

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 0

=head2 contrast_condition

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "contrasts_id_seq",
  },
  "base_condition",
  { data_type => "text", is_foreign_key => 1, is_nullable => 0 },
  "contrast_condition",
  { data_type => "text", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 base_condition

Type: belongs_to

Related object: L<TearDrop::Model::Result::Condition>

=cut

__PACKAGE__->belongs_to(
  "base_condition",
  "TearDrop::Model::Result::Condition",
  { name => "base_condition" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 contrast_condition

Type: belongs_to

Related object: L<TearDrop::Model::Result::Condition>

=cut

__PACKAGE__->belongs_to(
  "contrast_condition",
  "TearDrop::Model::Result::Condition",
  { name => "contrast_condition" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 de_results

Type: has_many

Related object: L<TearDrop::Model::Result::DeResult>

=cut

__PACKAGE__->has_many(
  "de_results",
  "TearDrop::Model::Result::DeResult",
  { "foreign.contrast_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 de_run_contrasts

Type: has_many

Related object: L<TearDrop::Model::Result::DeRunContrast>

=cut

__PACKAGE__->has_many(
  "de_run_contrasts",
  "TearDrop::Model::Result::DeRunContrast",
  { "foreign.contrast_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2014-10-26 23:28:20
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:PgRjqAXhFrOsbJt1vf+q5A

sub _is_column_serializable { 1 };

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
