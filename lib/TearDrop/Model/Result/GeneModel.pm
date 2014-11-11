use utf8;
package TearDrop::Model::Result::GeneModel;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TearDrop::Model::Result::GeneModel

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

=head1 TABLE: C<gene_models>

=cut

__PACKAGE__->table("gene_models");

=head1 ACCESSORS

=head2 organism

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 1

=head2 path

  data_type: 'text'
  is_nullable: 0

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'gene_models_id_seq'

=head2 name

  data_type: 'text'
  is_nullable: 0

=head2 description

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "organism",
  { data_type => "text", is_foreign_key => 1, is_nullable => 1 },
  "path",
  { data_type => "text", is_nullable => 0 },
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "gene_models_id_seq",
  },
  "name",
  { data_type => "text", is_nullable => 0 },
  "description",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<gene_models_name_key>

=over 4

=item * L</name>

=back

=cut

__PACKAGE__->add_unique_constraint("gene_models_name_key", ["name"]);

=head1 RELATIONS

=head2 gene_model_mappings

Type: has_many

Related object: L<TearDrop::Model::Result::GeneModelMapping>

=cut

__PACKAGE__->has_many(
  "gene_model_mappings",
  "TearDrop::Model::Result::GeneModelMapping",
  { "foreign.gene_model_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 organism

Type: belongs_to

Related object: L<TearDrop::Model::Result::Organism>

=cut

__PACKAGE__->belongs_to(
  "organism",
  "TearDrop::Model::Result::Organism",
  { name => "organism" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2014-11-11 15:43:37
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:9ad3ry2vkpC3pWOBpEMx/w

use Dancer qw/:moose !status/;
use Dancer::Plugin::DBIC 'schema';
use Carp;

sub _is_column_serializable { 1 };

sub import_file {
  my $self = shift;
  $self->delete_related('gene_model_mappings');

  open IF, "<".$self->path or confess "Open ".$self->path.": $!";
  while(<IF>) {
    next if m/^#/;
    my @f = split " ", $_, 9;
    my %sf = map { split "=", $_ } split ";", $f[8];
    schema->resultset('GeneModelMapping')->create({
      contig => $f[0],
      mtype => $f[2],
      cstart => $f[3],
      cend => $f[4],
      strand => $f[6],
      id => $sf{ID},
      name => $sf{Name},
      parent => $sf{Parent},
      gene_model_id => $self->id,
    });
  }
}


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
