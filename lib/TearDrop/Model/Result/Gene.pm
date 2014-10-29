use utf8;
package TearDrop::Model::Result::Gene;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TearDrop::Model::Result::Gene

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

=head1 TABLE: C<genes>

=cut

__PACKAGE__->table("genes");

=head1 ACCESSORS

=head2 id

  data_type: 'text'
  is_nullable: 0

=head2 description

  data_type: 'text'
  is_nullable: 1

=head2 flagged

  data_type: 'boolean'
  default_value: false
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

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "text", is_nullable => 0 },
  "description",
  { data_type => "text", is_nullable => 1 },
  "flagged",
  { data_type => "boolean", default_value => \"false", is_nullable => 1 },
  "best_homolog",
  { data_type => "text", is_nullable => 1 },
  "rating",
  { data_type => "integer", is_nullable => 1 },
  "reviewed",
  { data_type => "boolean", default_value => \"false", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 transcripts

Type: has_many

Related object: L<TearDrop::Model::Result::Transcript>

=cut

__PACKAGE__->has_many(
  "transcripts",
  "TearDrop::Model::Result::Transcript",
  { "foreign.gene" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2014-10-29 15:37:17
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Jhe9M4KG7hwIfahQtE6BnA

use Dancer::Plugin::DBIC 'schema';

sub _is_column_serializable { 1 };

sub aggregate_blast_runs {
  my $self = shift;
  my %blast_runs;
  for my $trans ($self->search_related('transcripts')) {
    for my $brun ($trans->search_related('blast_runs')) {
      my $brun_ser = $brun->TO_JSON;
      $brun_ser->{db_source}=$brun->db_source->TO_JSON;
      $blast_runs{$brun->db_source->name} ||= $brun_ser;
      my $hit_count = schema->resultset('BlastResult')->search({
        transcript_id => $trans->id, db_source_id => $brun->db_source_id
      })->count;
      $blast_runs{$brun->db_source->name}->{matched_transcripts} ||= 0;
      $blast_runs{$brun->db_source->name}->{matched_transcripts}++ if $hit_count;
      $blast_runs{$brun->db_source->name}->{hits} += $hit_count;
    }
  }
  [ values %blast_runs ];
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
