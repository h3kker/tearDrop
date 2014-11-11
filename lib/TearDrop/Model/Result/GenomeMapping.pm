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


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2014-11-02 19:09:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ZiKZI9dADt/Z4RvLrMdDQQ

use Carp;

sub _is_column_serializable { 1 };

sub import_file {
  my $self = shift;
  $self->delete_related('transcript_mappings');

  if ($self->program eq 'blat') {
    open IF, "<".$self->path or confess("Open ".$self->path.": $!");
    my $l=0;
    while(<IF>) {
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
      my $match_pct = sprintf "%.2f", $matchscore/$qsize;
      next unless $match_pct>.5;

      $self->create_related('transcript_mappings', {
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
      });
    }
  }
  else {
    confess "don't know how to handle ".$self->program." maps";
  }
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
