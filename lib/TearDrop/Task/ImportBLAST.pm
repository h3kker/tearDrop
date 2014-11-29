package TearDrop::Task::ImportBLAST;

use 5.12.0;

use warnings;
use strict;

use Mouse;

extends 'TearDrop::Task::BlastBase';

use Carp;
use Try::Tiny;
use IO::File;

has 'assembly' => ( is => 'rw', isa => 'Str|Undef' );
has 'reverse' => ( is => 'rw', isa => 'Bool', default => 0 );
has 'files' => ( is => 'rw', isa => 'ArrayRef[Str]', default => sub { [] } );

sub run {
  my $self = shift;

  confess 'Need database' unless $self->database;
  confess 'Need assembly for reverse blasts' if $self->reverse && !$self->assembly;

  my $db_source = $self->app->schema($self->project)->resultset('DbSource')->search({ name => $self->database })->first || confess "Invalid db source: ".$self->database;

  my $assembly;
  if ($self->reverse) {
    $assembly = $self->app->schema($self->project)->resultset('TranscriptAssembly')->search({ name => $self->assembly })->first || confess "Invalid assembly: ".$self->assembly;
  }

  my $io_h = IO::Handle->new;
  my @io = @{$self->files} ? 
    map { IO::File->new($_, "r") || confess 'Unable to open '.$_.": $?" } @{$self->files} : 
    ( $io_h->fdopen(fileno(STDIN), "r") );

  my $cnt=0;
  for my $io (@io) {
    while(!$io->eof) {
      $self->app->schema($self->project)->txn_do(sub {
        while(<$io>) {
          $cnt++;
          chomp;
          if ($self->reverse) {
            $assembly->add_blast_result($_, $db_source);
          }
          else {
            my $res = $db_source->add_result($_);
            $db_source->update_or_create_related('blast_runs', {
              transcript_id => $res->transcript_id,
              finished => 1,
            });
          }
          if ($cnt % 100 == 0) {
            $self->app->log->debug("... Imported $cnt entries...");
          }
          last if $cnt % $self->app->config->{import_flush_rows}==0;
        }
        $self->app->log->debug("... commit!");
      });
    }
    $io->close;
    return { count => $cnt };
  }
}

1;
