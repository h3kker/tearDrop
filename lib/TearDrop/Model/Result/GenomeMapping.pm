use utf8;
package TearDrop::Model::Result::GenomeMapping;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TearDrop::Model::Result::GenomeMapping

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

=head1 TABLE: C<genome_mappings>

=cut

__PACKAGE__->table("genome_mappings");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'genome_mappings_id_seq'

=head2 program

  data_type: 'text'
  is_nullable: 0

=head2 parameters

  data_type: 'text'
  is_nullable: 1

=head2 description

  data_type: 'text'
  is_nullable: 1

=head2 alignment_date

  data_type: 'timestamp'
  is_nullable: 1

=head2 transcript_assembly_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 organism_name

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 0

=head2 path

  data_type: 'text'
  is_nullable: 0

=head2 sha1

  data_type: 'text'
  is_nullable: 1

=head2 imported

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
    sequence          => "genome_mappings_id_seq",
  },
  "program",
  { data_type => "text", is_nullable => 0 },
  "parameters",
  { data_type => "text", is_nullable => 1 },
  "description",
  { data_type => "text", is_nullable => 1 },
  "alignment_date",
  { data_type => "timestamp", is_nullable => 1 },
  "transcript_assembly_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "organism_name",
  { data_type => "text", is_foreign_key => 1, is_nullable => 0 },
  "path",
  { data_type => "text", is_nullable => 0 },
  "sha1",
  { data_type => "text", is_nullable => 1 },
  "needs_prefix",
  { data_type => "boolean", default_value => \"false", is_nullable => 0 },
  "imported",
  { data_type => "boolean", default_value => \"false", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 organism_name

Type: belongs_to

Related object: L<TearDrop::Model::Result::Organism>

=cut

__PACKAGE__->belongs_to(
  "organism_name",
  "TearDrop::Model::Result::Organism",
  { name => "organism_name" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 transcript_assembly

Type: belongs_to

Related object: L<TearDrop::Model::Result::TranscriptAssembly>

=cut

__PACKAGE__->belongs_to(
  "transcript_assembly",
  "TearDrop::Model::Result::TranscriptAssembly",
  { id => "transcript_assembly_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 transcript_mappings

Type: has_many

Related object: L<TearDrop::Model::Result::TranscriptMapping>

=cut

__PACKAGE__->has_many(
  "transcript_mappings",
  "TearDrop::Model::Result::TranscriptMapping",
  { "foreign.genome_mapping_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2014-11-12 20:33:26
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:oo+Yen9VgMl9yahAY5KvAQ

use Carp;
use Try::Tiny;

use Moo;
use namespace::clean;

with 'TearDrop::Model::HasFileImport';

sub _is_column_serializable { 1 };

sub as_tree {
  my ($self, $region, $param) = @_;
  $param||={};
  my $search = $region ? { 
    -and => [
      tid => $region->{contig},
      -or => [
        tstart => { '>', $region->{start}, '<', $region->{end} },
        tend => { '<', $region->{end}, '>', $region->{start} },
        -and => { tstart => { '<', $region->{start} }, tend => { '>', $region->{end} }},
      ]
    ]
  } : undef;
  my $transcripts = $self->search_related('transcript_mappings', $search, { prefetch => { 'transcript' => 'gene' } });
  my %g;
  for my $tm ($transcripts->all) {
    if ($param->{filter}) {
      next unless $tm->is_good(ref $param->{filter} eq 'HASH' ? $param->{filter} : undef);
    }
    $g{$tm->transcript->gene_id} ||= {
      id => $tm->transcript->gene_id, 
      additional => $tm->transcript->gene->description,
      annotation_type => 'transcript',
      cend => $tm->tend,
      cstart => $tm->tstart,
      contig => $tm->tid,
      genome_mapping_id => $tm->genome_mapping_id,
      mtype => 'gene',
      children => [],
      name => $tm->transcript->gene->name,
      parent => undef,
      strand => $tm->strand,
    };
    my $gene = $g{$tm->transcript->gene_id};
    $gene->{cstart} = $tm->tstart if ($gene->{cstart} < $tm->tstart);
    $gene->{cend} = $tm->tend if ($gene->{cend} > $tm->tend);
    my $mrna = {
      id => $tm->transcript_id,
      additional => $tm->transcript->description,
      annotation_type => 'transcript',
      cend => $tm->tend,
      cstart => $tm->tstart,
      contig => $tm->tid,
      genome_mapping_id => $tm->genome_mapping_id,
      mtype => 'mRNA',
      children => [],
      name => $tm->transcript->name,
      parent => $tm->transcript->gene_id,
      strand => $tm->strand,
      original => $tm,
    };
    push @{$gene->{children}}, $mrna;
    my @bs = split ',', $tm->blocksizes;
    my @blocks = split ',', $tm->tstarts;
    for my $idx (0..$#blocks) {
      push @{$mrna->{children}}, {
        id => $tm->transcript_id.'.'.$idx,
        additional => undef,
        annotation_type => 'transcript',
        cend => $blocks[$idx]+$bs[$idx],
        cstart => $blocks[$idx],
        contig => $tm->tid,
        genome_mapping_id => $tm->genome_mapping_id,
        mtype => 'CDS',
        name => $tm->transcript_id.'.'.$idx,
        parent => $tm->transcript_id,
        strand => $tm->strand,
      };
    }
  }
  wantarray ? values %g : [ values %g ];
}

sub import_file {
  my $self = shift;

  $self->delete_related('transcript_mappings');

  my @rows;
  if ($self->program eq 'blat') {
    open my $IF, "<".$self->path or confess("Open ".$self->path.": $!");
    my $l=0;
    while(<$IF>) {
      $l++;
      my $ispsl=1 ; ## if m/^psLayout/; # should do but want some slack here?
      # skip header
      next unless(/^\d/);
      chomp;
      my @v= split "\t";
      confess 'unknown format line '.$l.': not 22 fields' unless $ispsl and @v==21;
      my( $matchscore, $mismatches, $rep_matches, $orient,
          $qid, $qsize, $qstart, $qend,
          $tid, $tsize, $tstart, $tend,
          $blocksizes, $qstarts, $tstarts
      ) = @v[0..2, 8..16, 18..20];
      $qid=$self->transcript_assembly->prefix.'.'.$qid if $self->needs_prefix;
      my $match_pct = sprintf "%.2f", $matchscore/$qsize;
      next unless $match_pct>.5;

      push @rows, {
        genome_mapping_id => $self->id,
        transcript_id => $qid,
        matches => $matchscore,
        match_ratio => $match_pct,
        mismatches => $mismatches,
        rep_matches => $rep_matches,
        strand => $orient,
        qstart => $qstart,
        qend => $qend,
        tid => $tid,
        tsize => $tsize,
        tstart => $tstart,
        tend => $tend,
        blocksizes => $blocksizes,
        qstarts => $qstarts,
        tstarts => $tstarts
      };

      if (@rows >= 1000) {
      #if (@rows >= config->{import_flush_rows}) {
        #debug 'flushing '.@rows.' to database (line '. $. .')';
        $self->result_source->schema->resultset('TranscriptMapping')->populate(\@rows);
        @rows=();
        #debug 'done.';
      }
    }
    close $IF;
    if (@rows) {
      #debug 'flushing remaining '.@rows.' to database';
      $self->result_source->schema->resultset('TranscriptMapping')->populate(\@rows);
      #debug 'done.';
    }
  }
  else {
    confess "don't know how to handle ".$self->program." maps";
  }

}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
