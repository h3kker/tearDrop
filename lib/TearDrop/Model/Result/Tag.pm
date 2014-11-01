use utf8;
package TearDrop::Model::Result::Tag;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TearDrop::Model::Result::Tag

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

=head1 TABLE: C<tags>

=cut

__PACKAGE__->table("tags");

=head1 ACCESSORS

=head2 tag

  data_type: 'text'
  is_nullable: 0

=head2 level

  data_type: 'text'
  default_value: 'info'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "tag",
  { data_type => "text", is_nullable => 0 },
  "level",
  { data_type => "text", default_value => "info", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</tag>

=back

=cut

__PACKAGE__->set_primary_key("tag");

=head1 RELATIONS

=head2 gene_tags

Type: has_many

Related object: L<TearDrop::Model::Result::GeneTag>

=cut

__PACKAGE__->has_many(
  "gene_tags",
  "TearDrop::Model::Result::GeneTag",
  { "foreign.tag" => "self.tag" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 transcript_tags

Type: has_many

Related object: L<TearDrop::Model::Result::TranscriptTag>

=cut

__PACKAGE__->has_many(
  "transcript_tags",
  "TearDrop::Model::Result::TranscriptTag",
  { "foreign.tag" => "self.tag" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 genes

Type: many_to_many

Composing rels: L</gene_tags> -> gene

=cut

__PACKAGE__->many_to_many("genes", "gene_tags", "gene");

=head2 transcripts

Type: many_to_many

Composing rels: L</transcript_tags> -> transcript

=cut

__PACKAGE__->many_to_many("transcripts", "transcript_tags", "transcript");


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2014-11-01 12:09:10
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:0gCo99ZTeQRoH/MoF9Yd4g

sub _is_column_serializable { 1 };

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
