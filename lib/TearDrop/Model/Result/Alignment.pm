use utf8;
package TearDrop::Model::Result::Alignment;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TearDrop::Model::Result::Alignment

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

=head1 TABLE: C<alignments>

=cut

__PACKAGE__->table("alignments");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'alignments_id_seq'

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

=head2 sample_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 bam_path

  data_type: 'text'
  is_nullable: 0

=head2 total_reads

  data_type: 'double precision'
  is_nullable: 1

=head2 mapped_reads

  data_type: 'double precision'
  is_nullable: 1

=head2 unique_reads

  data_type: 'double precision'
  is_nullable: 1

=head2 multiple_reads

  data_type: 'double precision'
  is_nullable: 1

=head2 discordant_pairs

  data_type: 'double precision'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "alignments_id_seq",
  },
  "program",
  { data_type => "text", is_nullable => 0 },
  "parameters",
  { data_type => "text", is_nullable => 1 },
  "description",
  { data_type => "text", is_nullable => 1 },
  "alignment_date",
  { data_type => "timestamp", is_nullable => 1 },
  "sample_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "bam_path",
  { data_type => "text", is_nullable => 0 },
  "total_reads",
  { data_type => "double precision", is_nullable => 1 },
  "mapped_reads",
  { data_type => "double precision", is_nullable => 1 },
  "unique_reads",
  { data_type => "double precision", is_nullable => 1 },
  "multiple_reads",
  { data_type => "double precision", is_nullable => 1 },
  "discordant_pairs",
  { data_type => "double precision", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 genome_alignment

Type: might_have

Related object: L<TearDrop::Model::Result::GenomeAlignment>

=cut

__PACKAGE__->might_have(
  "genome_alignment",
  "TearDrop::Model::Result::GenomeAlignment",
  { "foreign.alignment_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 sample

Type: belongs_to

Related object: L<TearDrop::Model::Result::Sample>

=cut

__PACKAGE__->belongs_to(
  "sample",
  "TearDrop::Model::Result::Sample",
  { id => "sample_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 transcriptome_alignment

Type: might_have

Related object: L<TearDrop::Model::Result::TranscriptomeAlignment>

=cut

__PACKAGE__->might_have(
  "transcriptome_alignment",
  "TearDrop::Model::Result::TranscriptomeAlignment",
  { "foreign.alignment_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2014-10-29 13:28:04
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:0pDhsqt0l/AjJIvpSgM+aA

use Carp;
use Dancer qw/:moose !status !dirname/;
use File::Basename;

sub _is_column_serializable { 1 };

sub read_stats {
  my $self = shift;

  my $aln_dir = dirname($self->bam_path);
  $self->$_(0) for qw/total_reads unique_reads multiple_reads mapped_reads/;
  if ($self->program eq 'star') {
    open(STAT, "<$aln_dir/Log.final.out") or confess("open $aln_dir/Log.final.out: $!");
    while(<STAT>) {
      chomp;
      if (m#Number of input reads.*\s(\d+)#) {
        $self->total_reads($1);
      }
      elsif (m#Uniquely mapped reads number.*\s(\d+)#) {
        $self->unique_reads($1);
      }
      elsif (m#Number of reads mapped to multiple loci.*\s(\d+)#) {
        $self->multiple_reads($1);
      }
    }
    close STAT;
    $self->mapped_reads($self->unique_reads+$self->multiple_reads);
  }
  elsif ($self->program eq 'tophat') {
    open(STAT, "<$aln_dir/align_summary.txt") or confess("open $aln_dir/align_summary.txt: $!");
    while(<STAT>) {
      chomp;
      if (m#Input\s*:\s*(\d+)#) {
        $self->total_reads($self->total_reads+$1);
      }
      elsif (m#Mapped\s*:\s*(\d+)#) {
        $self->mapped_reads($self->mapped_reads+$1);
      }
      elsif (m#of these\s*:\s*(\d+)#) {
        $self->multiple_reads($self->multiple_reads+$1);
      }
      elsif (m#(\d+).* are discordant#) {
        $self->discordant_pairs($1);
      }
    }
    close STAT;
    $self->unique_reads($self->mapped_reads - $self->multiple_reads);
  }
  elsif ($self->program eq 'bowtie2') {
    open(STAT, "<$aln_dir/bowtie_stats.txt") or confess("open $aln_dir/bowtie_stats.txt: $!");
    while(<STAT>) {
      chomp;
      if (m#(\d+) reads; of these#) {
        $self->total_reads($1);
      }
      elsif (m#(\d+).*aligned concordantly exactly 1 time#) {
        $self->unique_reads($1);
      }
      elsif (m#(\d+).*aligned concordantly >1 times#) {
        $self->multiple_reads($1);
      }
      elsif (m#(\d+).*aligned discordantly 1 time#) {
        $self->discordant_pairs($1);
      }
      # unpaired reads - add! I think they're added in tophat too
      elsif (m#(\d+).*aligned exactly 1 time#) {
        $self->unique_reads($self->unique_reads + $1);
      }
      elsif (m#(\d+).*aligned >1 times#) {
        $self->multiple_reads($self->multiple_reads + $1);
      }
    }
    close STAT;
    $self->mapped_reads($self->unique_reads + $self->multiple_reads);
  }
  else {
    Carp::cluck("don't know how to get stats for ".$self->program." alignments");
  }
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
