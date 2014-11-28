use utf8;
package TearDrop::Model::Result::TranscriptAssembly;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TearDrop::Model::Result::TranscriptAssembly

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

=head1 TABLE: C<transcript_assemblies>

=cut

__PACKAGE__->table("transcript_assemblies");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'transcript_assemblies_id_seq'

=head2 name

  data_type: 'text'
  is_nullable: 0

=head2 description

  data_type: 'text'
  is_nullable: 1

=head2 program

  data_type: 'text'
  is_nullable: 0

=head2 parameters

  data_type: 'text'
  is_nullable: 1

=head2 assembly_date

  data_type: 'timestamp'
  is_nullable: 1

=head2 path

  data_type: 'text'
  is_nullable: 1

=head2 is_primary

  data_type: 'boolean'
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
    sequence          => "transcript_assemblies_id_seq",
  },
  "prefix",
  { data_type => "text", is_nullable => 0 },
  "add_prefix",
  { data_type => "boolean", is_nullable => 0, default_value => \"false" },
  "name",
  { data_type => "text", is_nullable => 0 },
  "description",
  { data_type => "text", is_nullable => 1 },
  "program",
  { data_type => "text", is_nullable => 0 },
  "parameters",
  { data_type => "text", is_nullable => 1 },
  "assembly_date",
  { data_type => "timestamp", is_nullable => 1 },
  "path",
  { data_type => "text", is_nullable => 1 },
  "is_primary",
  { data_type => "boolean", is_nullable => 0 },
  "sha1",
  { data_type => "text", is_nullable => 1 },
  "imported",
  { data_type => "boolean", default_value => \"false", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<transcript_assemblies_name_key>

=over 4

=item * L</name>

=back

=cut

__PACKAGE__->add_unique_constraint("transcript_assemblies_name_key", ["name"]);

=head1 RELATIONS

=head2 assembled_files

Type: has_many

Related object: L<TearDrop::Model::Result::AssembledFile>

=cut

__PACKAGE__->has_many(
  "assembled_files",
  "TearDrop::Model::Result::AssembledFile",
  { "foreign.transcript_assembly_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


=head2 reverse_blast_results

Type: has_many

Related object: L<TearDrop::Model::Result::ReverseBlastResult>

=cut

__PACKAGE__->has_many(
  "reverse_blast_results",
  "TearDrop::Model::Result::ReverseBlastResult",
  { "foreign.transcript_assembly_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 genome_mappings

Type: has_many

Related object: L<TearDrop::Model::Result::GenomeMapping>

=cut

__PACKAGE__->has_many(
  "genome_mappings",
  "TearDrop::Model::Result::GenomeMapping",
  { "foreign.transcript_assembly_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 transcriptome_alignments

Type: has_many

Related object: L<TearDrop::Model::Result::TranscriptomeAlignment>

=cut

__PACKAGE__->has_many(
  "transcriptome_alignments",
  "TearDrop::Model::Result::TranscriptomeAlignment",
  { "foreign.transcript_assembly_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 transcripts

Type: has_many

Related object: L<TearDrop::Model::Result::Transcript>

=cut

__PACKAGE__->has_many(
  "transcripts",
  "TearDrop::Model::Result::Transcript",
  { "foreign.transcript_assembly_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2014-11-12 20:33:26
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:CQ35CwTEJv0B3C2YItUjUw


use Carp;
use Try::Tiny;

use Moo;
use namespace::clean;

with 'TearDrop::Model::HasFileImport';

sub _is_column_serializable { 1 };

sub import_file {
  my $self = shift;
  $self->delete_related('transcripts');
  open my $FA, "<".$self->path || confess 'open '.$self->path.": $!";
  my $cur_trans;
  my $count;
  my @rows;
  my %genes;
  my $flush_rows = sub {
    my @rows = @_;
    #debug '  ('.$count.') flushing '.@rows.' to db (line '. $. .')';
    my %create_genes;
    for my $r (@rows) {
      if ($r->{id} =~ m#(.*c\d+_g\d+)_i.+#) {
        $r->{gene_id}=$1;
        next if exists $genes{$r->{gene_id}};
        $create_genes{$r->{gene_id}} = { id => $r->{gene_id} };
        if ($self->add_prefix && $r->{original_id} =~ m#(.*c\d+_g\d+)_i.+#) {
          $create_genes{$r->{gene_id}}->{original_id}=$1;
        }
      }
    }
    if (values %create_genes) {
      $self->result_source->schema->resultset('Gene')->populate([ values %create_genes ]);
      $genes{$_->{id}}=1 for values %create_genes;
    }
    $self->result_source->schema->resultset('Transcript')->populate(\@rows);
    #debug '   done';
  };
  while(<$FA>) {
    chomp;
    if (m/^>\s*([^ ]+)\s*/) {
      my $trans_id=$1;
      if ($cur_trans) {
        $count++;
        push @rows, $cur_trans;
      }
      if (@rows >= 1000) {
      #if (@rows>=config->{import_flush_rows}) {
        $flush_rows->(@rows);
        @rows=();
      }
      $cur_trans={
        id => $trans_id,
        nsequence => '',
        assembly_id => $self->id,
      };
      if ($self->add_prefix) {
        $cur_trans->{original_id} = $cur_trans->{id};
        $cur_trans->{id} = $self->prefix.'.'.$trans_id;
      }
    }
    else {
      $cur_trans->{nsequence}.=$_;
    }
  }
  close $FA;

  push @rows, $cur_trans;

  #debug '  flushing remaining '.@rows.' to db (line '. $. .')';
  $flush_rows->(@rows);
  #debug '  done';
}

sub add_blast_result {
  my ($self, $line, $db) = @_;
  my $result = $self->result_source->schema->resultset('ReverseBlastResult')->new_result({});
  $result->parse_line($line);
  $result->transcript_id($self->prefix.".".$result->transcript_id) if ($self->add_prefix);
  $result->transcript_assembly_id($self->id);
  if ($db) {
    $result->db_source_id($db->id);
    $result->in_storage(1) if ($result->get_from_storage);
    $result->update_or_insert;
  }
  $result;
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
