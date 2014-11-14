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

=item * L<DBIx::Class::Helper::Row::ToJSON>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime", "Helper::Row::ToJSON");

=head1 TABLE: C<organisms>

=cut

__PACKAGE__->table("organisms");

=head1 ACCESSORS

=head2 name

  data_type: 'text'
  is_nullable: 0

=head2 scientific_name

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
  "scientific_name",
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

=head2 gene_models

Type: has_many

Related object: L<TearDrop::Model::Result::GeneModel>

=cut

__PACKAGE__->has_many(
  "gene_models",
  "TearDrop::Model::Result::GeneModel",
  { "foreign.organism" => "self.name" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 genome_alignments

Type: has_many

Related object: L<TearDrop::Model::Result::GenomeAlignment>

=cut

__PACKAGE__->has_many(
  "genome_alignments",
  "TearDrop::Model::Result::GenomeAlignment",
  { "foreign.organism_name" => "self.name" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 genome_mappings

Type: has_many

Related object: L<TearDrop::Model::Result::GenomeMapping>

=cut

__PACKAGE__->has_many(
  "genome_mappings",
  "TearDrop::Model::Result::GenomeMapping",
  { "foreign.organism_name" => "self.name" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 transcripts

Type: has_many

Related object: L<TearDrop::Model::Result::Transcript>

=cut

__PACKAGE__->has_many(
  "transcripts",
  "TearDrop::Model::Result::Transcript",
  { "foreign.organism_name" => "self.name" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2014-11-02 18:46:59
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:qLMe5bGuIeDjWNOkZ39AJQ

sub _is_column_serializable { 1 };

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
