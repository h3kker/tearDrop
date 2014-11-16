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

=head2 sha1

  data_type: 'text'
  is_nullable: 1

=head2 imported

  data_type: 'boolean'
  default_value: false
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


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2014-11-12 20:33:26
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:UWhGk9jMWAtFPMVl2R3XCA

use Dancer qw/:moose !status/;
use Dancer::Plugin::DBIC 'schema';
use Carp;
use Try::Tiny;

use Moo;
use namespace::clean;

with 'TearDrop::Model::HasFileImport';

sub _is_column_serializable { 1 };

sub as_tree {
  my ($self, $region) = @_;
  my $search = $region ? {
    -and => [
      contig => $region->{contig},
      -or => [
        cstart => { '>',  $region->{start}, '<', $region->{end} },
        cend => { '<', $region->{end}, '>', $region->{start} },
        -and => { cstart => { '<', $region->{start} }, cend => { '>', $region->{end} }},
      ]
    ]
  } : undef;
  
  my %nodes;
  for my $gm ($self->search_related('gene_model_mappings', $search)) {
    if ($gm->parent) {
      my $p = $gm->parent;
      $p=~s/\r?\n$//g;
      if ($p ne $gm->parent) {
        $gm->parent($p);
        $gm->update;
      }
    }
    if ($gm->mtype eq 'gene') {
      $nodes{$gm->id}||={
        mRNAs => [],
      };
      $nodes{$gm->id}->{$_} = $gm->$_ for keys %{$gm->TO_JSON};
    }
    elsif ($gm->mtype eq 'mRNA') {
      $nodes{$gm->parent}||={
        mRNAs => [],
      };
      $nodes{$gm->id}||={
        exons => [],
      };
      $nodes{$gm->id}->{$_} = $gm->$_ for keys %{$gm->TO_JSON};
      push @{$nodes{$gm->parent}->{mRNAs}}, $nodes{$gm->id};
    }
    elsif ($gm->mtype eq 'exon') {
      $nodes{$gm->parent}||={
        exons => [],
      };
      $nodes{$gm->id}||={};
      $nodes{$gm->id}->{$_} = $gm->$_ for keys %{$gm->TO_JSON};
      push @{$nodes{$gm->parent}->{exons}}, $nodes{$gm->id};
    }
    else {
      $nodes{$gm->id}||={};
      $nodes{$gm->id}->{$_} = $gm->$_ for keys %{$gm->TO_JSON};
      if ($gm->parent) {
        $nodes{$gm->parent}||={
          others => [],
        };
        push @{$nodes{$gm->parent}->{others}}, $nodes{$gm->id};
      }
    }
  }
  my %genes;
  for my $n (keys %nodes) {
    $nodes{$n}->{annotation_type} = 'gene_model';
    $genes{$n}=$nodes{$n} if $nodes{$n}->{mtype} eq 'gene';
  }
  wantarray ? values %genes : [ values %genes ];
}

sub import_file {
  my $self = shift;

  $self->delete_related('gene_model_mappings');
  open IF, "<".$self->path or confess "Open ".$self->path.": $!";
  my @rows;
  while(<IF>) {
    next if m/^#/;
    chomp;
    my @f = split " ", $_, 9;
    my %sf = map { split "=", $_ } split ";", $f[8];
    if (exists $sf{Note}) {
      $sf{Note}=~tr/\+/ /;
    }
    push @rows, {
      contig => $f[0],
      mtype => $f[2],
      cstart => $f[3],
      cend => $f[4],
      # score => $f[5], # ignore
      strand => $f[6],
      # frame => $f[7], # ignore
      id => $sf{ID},
      name => $sf{Name},
      parent => $sf{Parent},
      additional => $sf{Note},
      gene_model_id => $self->id,
    };
    if (@rows >= config->{import_flush_rows}) {
      debug 'flush '.@rows.' rows to database (line '. $. .')';
      $self->result_source->schema->resultset('GeneModelMapping')->populate(\@rows);
      @rows=();
      debug 'done.';
    }
  }
  if (@rows) {
    debug 'flush remaining '.@rows.' rows to database';
    $self->result_source->schema->resultset('GeneModelMapping')->populate(\@rows);
    debug 'done.';
  }
  close IF;
}


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
