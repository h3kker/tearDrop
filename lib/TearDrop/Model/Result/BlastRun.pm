use utf8;
package TearDrop::Model::Result::BlastRun;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TearDrop::Model::Result::BlastRun

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

=head1 TABLE: C<blast_runs>

=cut

__PACKAGE__->table("blast_runs");

=head1 ACCESSORS

=head2 transcript_id

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 0

=head2 db_source_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 parameters

  data_type: 'text'
  is_nullable: 1

=head2 finished

  data_type: 'boolean'
  default_value: false
  is_nullable: 1

=head2 run_date

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 1
  original: {default_value => \"now()"}

=cut

__PACKAGE__->add_columns(
  "transcript_id",
  { data_type => "text", is_foreign_key => 1, is_nullable => 0 },
  "db_source_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "parameters",
  { data_type => "text", is_nullable => 1 },
  "finished",
  { data_type => "boolean", default_value => \"false", is_nullable => 1 },
  "run_date",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 1,
    original      => { default_value => \"now()" },
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</transcript_id>

=item * L</db_source_id>

=back

=cut

__PACKAGE__->set_primary_key("transcript_id", "db_source_id");

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


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2014-11-06 22:19:45
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:eV5ff0xZC97ROcBaMXEF4w

sub _is_column_serializable { 1 };

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
