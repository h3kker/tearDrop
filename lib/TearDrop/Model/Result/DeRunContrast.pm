use utf8;
package TearDrop::Model::Result::DeRunContrast;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TearDrop::Model::Result::DeRunContrast

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

=head1 TABLE: C<de_run_contrasts>

=cut

__PACKAGE__->table("de_run_contrasts");

=head1 ACCESSORS

=head2 de_run_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 contrast_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 path

  data_type: 'text'
  is_nullable: 0

=head2 parameters

  data_type: 'text'
  is_nullable: 1

=head2 imported

  data_type: 'boolean'
  default_value: false
  is_nullable: 1

=head2 sha1

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "de_run_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "contrast_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "path",
  { data_type => "text", is_nullable => 0 },
  "parameters",
  { data_type => "text", is_nullable => 1 },
  "imported",
  { data_type => "boolean", default_value => \"false", is_nullable => 1 },
  "sha1",
  { data_type => "text", is_nullable => 1 },
);

=head1 UNIQUE CONSTRAINTS

=head2 C<de_run_contrasts_de_run_id_contrast_id_key>

=over 4

=item * L</de_run_id>

=item * L</contrast_id>

=back

=cut

__PACKAGE__->set_primary_key("de_run_id", "contrast_id");

=head1 RELATIONS

=head2 contrast

Type: belongs_to

Related object: L<TearDrop::Model::Result::Contrast>

=cut

__PACKAGE__->belongs_to(
  "contrast",
  "TearDrop::Model::Result::Contrast",
  { id => "contrast_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 de_results

Type: has_many

Related object: L<TearDrop::Model::Result::DeResult>

=cut

__PACKAGE__->has_many(
  "de_results",
  "TearDrop::Model::Result::DeResult",
  {
    "foreign.contrast_id" => "self.contrast_id",
    "foreign.de_run_id"   => "self.de_run_id",
  },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 de_run

Type: belongs_to

Related object: L<TearDrop::Model::Result::DeRun>

=cut

__PACKAGE__->belongs_to(
  "de_run",
  "TearDrop::Model::Result::DeRun",
  { id => "de_run_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2014-11-12 20:33:26
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:x7goJMvFcVcmUmMcR2b5jg

use Dancer qw/:moose !status/;
use Dancer::Plugin::DBIC 'schema';
use Try::Tiny;
use Carp;

use Moo;
use namespace::clean;

with 'TearDrop::Model::HasFileImport';

sub _is_column_serializable { 1 };

sub import_file {
  my ($self, %param) = @_;

  my %field_map = qw/
    transcript transcript_id
    pvalue pvalue
    padj adjp
    baseMean base_mean
    log2FoldChange log2_foldchange
  /;

  $self->delete_related('de_results');

  open IF, "<".$self->path or die "open ".$self->path.": $!";
  my $hline = <IF>;
  chomp $hline;
  my @header_fields = split "\t", $hline;
  my @rows;
  while(<IF>) {
    chomp;
    my @f = split "\t";
    my %s = map {
      $field_map{$header_fields[$_]} => $f[$_] eq 'NA' ? undef : $f[$_]
    } grep { exists $field_map{$header_fields[$_]} } 0..$#header_fields;
    $s{transcript_id} = $param{id_prefix}.'.'.$s{transcript_id} if $param{id_prefix};
    $s{de_run_id} = $self->de_run->id;
    $s{contrast_id} = $self->contrast->id;
    push @rows, \%s;
    if (@rows >= config->{import_flush_rows}) {
      debug 'flushing '.@rows.' to database (line '. $. .')';
      $self->result_source->schema->resultset('DeResult')->populate(\@rows);
      @rows=();
      debug 'done.';
    }
  }
  if (@rows) {
    debug 'flushing remaining '.@rows.' to database';
    $self->result_source->schema->resultset('DeResult')->populate(\@rows);
    debug 'done.';
  }
  close IF;
}


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
