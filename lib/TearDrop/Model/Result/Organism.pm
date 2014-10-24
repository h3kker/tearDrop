use utf8;
package TearDrop::Model::Result::Organism;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TearDrop::Model::Result::Organism

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

=head1 TABLE: C<organisms>

=cut

__PACKAGE__->table("organisms");

=head1 ACCESSORS

=head2 name

  data_type: 'text'
  is_nullable: 0

=head2 genome_version

  data_type: 'text'
  is_nullable: 0

=head2 genome_path

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "name",
  { data_type => "text", is_nullable => 0 },
  "genome_version",
  { data_type => "text", is_nullable => 0 },
  "genome_path",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</name>

=back

=cut

__PACKAGE__->set_primary_key("name");

=head1 RELATIONS

=head2 transcripts

Type: has_many

Related object: L<TearDrop::Model::Result::Transcript>

=cut

__PACKAGE__->has_many(
  "transcripts",
  "TearDrop::Model::Result::Transcript",
  { "foreign.organism" => "self.name" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2014-10-24 18:23:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:NJcJMkoHt8zsBevA1nMw4w


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
