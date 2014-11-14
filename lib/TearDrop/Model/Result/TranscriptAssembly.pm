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
  { "foreign.assembly_id" => "self.id" },
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
  { "foreign.assembly_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2014-11-12 20:33:26
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:CQ35CwTEJv0B3C2YItUjUw

sub _is_column_serializable { 1 };

use Dancer qw/:moose !status/;
use Carp;
use Try::Tiny;

use Moo;
use namespace::clean;

with 'TearDrop::Model::HasFileImport';

sub import_file {
  my $self = shift;
  $self->delete_related('transcripts');
  open FA, "<".$self->path || confess 'open '.$self->path.": $!";
  my $cur_trans;
  my $count;
  my @rows;
  my %genes;
  while(<FA>) {
    chomp;
    if (m/^>\s*([^ ]+)\s*/) {
      if ($cur_trans) {
        #debug "Insert ".$cur_trans->{id};
        $count++;
        $cur_trans->{assembly_id}=$self->id;
        push @rows, $cur_trans;
      }
      if (@rows>=config->{import_flush_rows}) {
        debug '  ('.$count.') flushing '.@rows.' to db (line '. $. .')';
        my %create_genes = map { $_->{gene_id} => { id => $_->{gene_id} } } grep { !exists $genes{$_->{gene_id}} } @rows;
        $self->result_source->schema->resultset('Gene')->populate([ values %create_genes ]);
        $genes{$_->{id}}=1 for values %create_genes;
        $self->result_source->schema->resultset('Transcript')->populate(\@rows);
        @rows=();
        debug '  done';
      }
      my $trans_id=$self->prefix.'.'.$1;
      $cur_trans={
        id => $trans_id,
        nsequence => '',
      };
      if ($trans_id =~ m#(c\d+_g\d+)_i.+#) {
        $cur_trans->{gene_id}=$self->prefix.'.'.$1;
      }
    }
    else {
      $cur_trans->{nsequence}.=$_;
    }
  }
  close FA;

  $cur_trans->{assembly_id}=$self->id;
  push @rows, $cur_trans;

  debug '  flushing remaining '.@rows.' to db (line '. $. .')';
  my %create_genes = map { $_->{gene_id} => { id => $_->{gene_id} } } grep { !exists $genes{$_->{gene_id}} } @rows;
  $self->result_source->schema->resultset('Gene')->populate([ values %create_genes ]);
  $self->result_source->schema->resultset('Transcript')->populate(\@rows);
  debug '  done';
}



# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
