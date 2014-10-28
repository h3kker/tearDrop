use utf8;
package TearDrop::Model::Result::BlastResult;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TearDrop::Model::Result::BlastResult

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

=head1 TABLE: C<blast_results>

=cut

__PACKAGE__->table("blast_results");

=head1 ACCESSORS

=head2 transcript_id

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 0

=head2 db_source_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 source_sequence_id

  data_type: 'text'
  is_nullable: 0

=head2 bitscore

  data_type: 'double precision'
  is_nullable: 1

=head2 length

  data_type: 'double precision'
  is_nullable: 1

=head2 pident

  data_type: 'double precision'
  is_nullable: 1

=head2 ppos

  data_type: 'double precision'
  is_nullable: 1

=head2 evalue

  data_type: 'double precision'
  is_nullable: 1

=head2 stitle

  data_type: 'text'
  is_nullable: 1

=head2 organism

  data_type: 'text'
  is_nullable: 1

=head2 nident

  data_type: 'double precision'
  is_nullable: 1

=head2 staxid

  data_type: 'text'
  is_nullable: 1

=head2 slen

  data_type: 'double precision'
  is_nullable: 1

=head2 qlen

  data_type: 'double precision'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "transcript_id",
  { data_type => "text", is_foreign_key => 1, is_nullable => 0 },
  "db_source_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "source_sequence_id",
  { data_type => "text", is_nullable => 0 },
  "bitscore",
  { data_type => "double precision", is_nullable => 1 },
  "length",
  { data_type => "double precision", is_nullable => 1 },
  "pident",
  { data_type => "double precision", is_nullable => 1 },
  "ppos",
  { data_type => "double precision", is_nullable => 1 },
  "evalue",
  { data_type => "double precision", is_nullable => 1 },
  "stitle",
  { data_type => "text", is_nullable => 1 },
  "organism",
  { data_type => "text", is_nullable => 1 },
  "nident",
  { data_type => "double precision", is_nullable => 1 },
  "staxid",
  { data_type => "text", is_nullable => 1 },
  "slen",
  { data_type => "double precision", is_nullable => 1 },
  "qlen",
  { data_type => "double precision", is_nullable => 1 },
);

=head1 UNIQUE CONSTRAINTS

=head2 C<blast_results_uniq>

=over 4

=item * L</transcript_id>

=item * L</db_source_id>

=item * L</source_sequence_id>

=back

=cut

__PACKAGE__->add_unique_constraint(
  "blast_results_uniq",
  ["transcript_id", "db_source_id", "source_sequence_id"],
);

=head1 RELATIONS

=head2 db_source

Type: belongs_to

Related object: L<TearDrop::Model::Result::DbSource>

=cut

__PACKAGE__->belongs_to(
  "db_source",
  "TearDrop::Model::Result::DbSource",
  { id => "db_source_id" },
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


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2014-10-28 13:51:39
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:lSTr2BW50r4V2KgaXL+hPQ

sub _is_column_serializable { 1 };

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
