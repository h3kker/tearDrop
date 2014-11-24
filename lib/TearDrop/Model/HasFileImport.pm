package TearDrop::Model::HasFileImport;

use warnings;
use strict;

use Moo::Role;
use namespace::clean;

use Carp;
use Try::Tiny;
use Digest::SHA;

sub sha1_sum {
  my ($self, $file) = @_;
  $file ||= $self->path;
  my $digest;
  try {
    $digest = Digest::SHA->new('sha1')->addfile($file, 'p');
  } catch {
    confess $_;
  };
  $digest->hexdigest;
}

around 'import_file' => sub {
  my ($orig, $self, @args) = @_;

  #debug 'calculating checksum...';
  my $checksum = $self->sha1_sum;
  #debug 'file checksum '.$checksum.', current: '.($self->sha1 || '[undef]');
  if ($self->imported && $self->sha1 && $self->sha1 eq $checksum) {
    #info 'no import: checksum unchanged';
    return;
  }

  try {
    $self->result_source->schema->txn_do(sub {
      # do import
      $orig->($self, @args);
      # and set fields
      $self->sha1($checksum);
      $self->imported(1);
      $self->update;
    });
  } catch {
    confess 'Import failed: '.$_;
  };
};

1;
