package TearDrop::Controller::Sample;

use 5.12.0;

use Mojo::Base 'Mojolicious::Controller';
use Mojo::JSON qw/decode_json/;

use warnings;
use strict;

use Carp;

our $VERSION='0.01';

has 'resultset' => 'Sample';

sub list {
  my $self = shift;
  my @ret = map {
    my $s = $_;
    my $ser = $s->TO_JSON;
    $ser->{alignments} = [ $s->alignments ];
    $ser;
  } $self->stash('project_schema')->resultset($self->resultset)->search(undef, { prefetch => [{ 'alignments' => [ 'genome_alignment', 'transcriptome_alignment']}, 'condition' ]})->all;
  $self->render(json => \@ret);
}

sub create {
  my $self = shift;
  my $o = $self->_set_from_update->insert;
  $self->param('sampleId' => $o->id);
  $self->read;
}

sub remove {
  my $self = shift;
  my $rs = $self->stash('project_schema')->resultset($self->resultset)->find($self->param('sampleId')) || croak 'not found!';
  $rs->delete;
  $self->render(json => $rs->TO_JSON);
}

sub read {
  my $self = shift;
  my $rs = $self->stash('project_schema')->resultset($self->resultset)->find($self->param('sampleId'), {  prefetch => ['alignments', 'condition']}) || croak 'not found!';
  my $ser = $rs->TO_JSON;
  $ser->{alignments} = [ $rs->alignments ];
  $self->render(json => $ser);
}

sub update {
  my $self = shift;
  my $rs = $self->stash('project_schema')->resultset($self->resultset)->find($self->param('sampleId'), {  prefetch => ['alignments', 'condition']}) || croak 'not found!';
  $self->_set_from_update($rs)->update;
  $self->read;

}

sub _set_from_update {
  my ($self, $obj) = @_;
  my $update = decode_json( $self->req->body );
  $obj||=$self->stash('project_schema')->resultset($self->resultset)->new_result({});
  $obj->$_($update->{$_}) for qw/name description replicate_number flagged forskalle_id flagged/;
  $obj->condition($update->{condition}{name});
  $obj;
}


1;
