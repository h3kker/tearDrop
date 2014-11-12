use utf8;
package TearDrop::Master::Model::Result::Tag;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TearDrop::Master::Model::Result::Tag

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=item * L<DBIx::Class::Helper::Row::ToJSON>

=item * L<DBIx::Class::InflateColumn::Serializer>

=back

=cut

__PACKAGE__->load_components(
  "InflateColumn::DateTime",
  "Helper::Row::ToJSON",
  "InflateColumn::Serializer",
);

=head1 TABLE: C<tags>

=cut

__PACKAGE__->table("tags");

=head1 ACCESSORS

=head2 tag

  data_type: 'text'
  is_nullable: 0

=head2 category

  data_type: 'text'
  default_value: 'general'
  is_nullable: 0

=head2 level

  data_type: 'text'
  default_value: 'info'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "tag",
  { data_type => "text", is_nullable => 0 },
  "category",
  { data_type => "text", default_value => "general", is_nullable => 0 },
  "level",
  { data_type => "text", default_value => "info", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</tag>

=back

=cut

__PACKAGE__->set_primary_key("tag");


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2014-11-12 19:13:38
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:COnE+fftyrb1pmtJyZ/zLg

sub _is_column_serializable { 1 };

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
