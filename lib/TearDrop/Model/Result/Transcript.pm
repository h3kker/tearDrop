use utf8;
package TearDrop::Model::Result::Transcript;

use TearDrop::Logger;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TearDrop::Model::Result::Transcript

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

=head1 TABLE: C<transcripts>

=cut

__PACKAGE__->table("transcripts");

=head1 ACCESSORS

=head2 id

  data_type: 'text'
  is_nullable: 0

=head2 transcript_assembly_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 gene

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 1

=head2 name

  data_type: 'text'
  is_nullable: 1

=head2 nsequence

  data_type: 'text'
  is_nullable: 1

=head2 organism

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 1

=head2 best_homolog

  data_type: 'text'
  is_nullable: 1

=head2 rating

  data_type: 'integer'
  is_nullable: 1

=head2 reviewed

  data_type: 'boolean'
  default_value: false
  is_nullable: 1

=head2 description

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "text", is_nullable => 0 },
  "original_id",
  { data_type => "text", is_nullable => 1 },
  "transcript_assembly_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "gene_id",
  { data_type => "text", is_foreign_key => 1, is_nullable => 1 },
  "name",
  { data_type => "text", is_nullable => 1 },
  "nsequence",
  { data_type => "text", is_nullable => 1 },
  "organism_name",
  { data_type => "text", is_foreign_key => 1, is_nullable => 1 },
  "best_homolog",
  { data_type => "text", is_nullable => 1 },
  "rating",
  { data_type => "integer", is_nullable => 1 },
  "reviewed",
  { data_type => "boolean", default_value => \"false", is_nullable => 1 },
  "description",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 assembly

Type: belongs_to

Related object: L<TearDrop::Model::Result::TranscriptAssembly>

=cut

__PACKAGE__->belongs_to(
  "assembly",
  "TearDrop::Model::Result::TranscriptAssembly",
  { id => "transcript_assembly_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 blast_results

Type: has_many

Related object: L<TearDrop::Model::Result::BlastResult>

=cut

__PACKAGE__->has_many(
  "blast_results",
  "TearDrop::Model::Result::BlastResult",
  { "foreign.transcript_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 reverse_blast_results

Type: has_many

Related object: L<TearDrop::Model::Result::ReverseBlastResult>

=cut

__PACKAGE__->has_many(
  "reverse_blast_results",
  "TearDrop::Model::Result::ReverseBlastResult",
  { "foreign.transcript_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 blast_runs

Type: has_many

Related object: L<TearDrop::Model::Result::BlastRun>

=cut

__PACKAGE__->has_many(
  "blast_runs",
  "TearDrop::Model::Result::BlastRun",
  { "foreign.transcript_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 gene

Type: belongs_to

Related object: L<TearDrop::Model::Result::Gene>

=cut

__PACKAGE__->belongs_to(
  "gene",
  "TearDrop::Model::Result::Gene",
  { id => "gene_id" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);

=head2 organism

Type: belongs_to

Related object: L<TearDrop::Model::Result::Organism>

=cut

__PACKAGE__->belongs_to(
  "organism",
  "TearDrop::Model::Result::Organism",
  { name => "organism_name" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);

=head2 raw_counts

Type: has_many

Related object: L<TearDrop::Model::Result::RawCount>

=cut

__PACKAGE__->has_many(
  "raw_counts",
  "TearDrop::Model::Result::RawCount",
  { "foreign.transcript_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 transcript_mappings

Type: has_many

Related object: L<TearDrop::Model::Result::TranscriptMapping>

=cut

__PACKAGE__->has_many(
  "transcript_mappings",
  "TearDrop::Model::Result::TranscriptMapping",
  { "foreign.transcript_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 transcript_tags

Type: has_many

Related object: L<TearDrop::Model::Result::TranscriptTag>

=cut

__PACKAGE__->has_many(
  "transcript_tags",
  "TearDrop::Model::Result::TranscriptTag",
  { "foreign.transcript_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 tags

Type: many_to_many

Composing rels: L</transcript_tags> -> tag

=cut

__PACKAGE__->many_to_many("tags", "transcript_tags", "tag");


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2014-11-06 22:03:08
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:LD1cL5MN/ZHhpiox6g+3bw

use Moo;
use namespace::clean;

with 'TearDrop::Model::TranscriptLike';

sub _is_column_serializable { 1 };

sub to_fasta {
  my $self = shift;
  return ">".$self->id.($self->name ? " ".$self->name:"")."\n".$self->nsequence;
}

# XXX should be done in the DB for better performance 
# (and flexibility, i.e. order_by and where clauses)
# only problem is intron size...
sub filtered_mappings {
  my ($self, $params) = @_;
  $params||={};
  $params->{limit}||=10;
  $params->{match_cutoff}||=.85;
  $params->{order_by}||={ -desc => 'match_ratio' };
  my @ret;
  my @all = $self->transcript_mappings({ match_ratio => { '>', $params->{match_cutoff} } }, { order_by => $params->{order_by} });

  MAP: for my $map (@all) {
    #debug $map->TO_JSON;
    unless($map->is_good($params)) {
      #debug '   skip map '; debug $map->TO_JSON;
      next;
    }
    push @ret, $map;
    last if @ret > $params->{limit};
  }
  wantarray ? @ret : \@ret;
}

sub comparisons {
  {
    rating => { cmp => '>', column => 'me.rating' }, 
    assembly => { cmp => '=', column => 'transcript_assemblies.name' },
    transcript_assembly_id => { cmp => '=', column => 'me.transcript_assembly_id' },
    id => { cmp => 'like', column => 'me.id' },
    'gene.id' => { cmp => 'like', column => 'gene.id' },
    name => { cmp => 'like', column => 'me.name' }, 
    description => { cmp => 'like', column => 'me.description' }, 
    'best_homolog' => { cmp => 'like', column => 'me.best_homolog' }, 
    'reviewed' => { cmp => '=', column => 'me.reviewed' },
    'tags' => { cmp => 'IN', column => 'transcript_tags.tag' },
    'organism.scientific_name' => { cmp => 'like', column => 'organism.scientific_name' },
  };
}

sub best_blast_hit {
  my $self = shift;
  $self->search_related('blast_results', undef, { order_by => [ { -asc => 'evalue' }, { -desc => 'pident' } ]})->first;
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
