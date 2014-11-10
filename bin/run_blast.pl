#!/usr/bin/perl

use warnings;
use strict;

use Dancer ':script';
use Dancer::Plugin::DBIC 'schema';

use TearDrop::Worker;

my $dbs = schema->resultset('DbSource')->search({
  name => [ 'refseq_plant', 'refseq_fungi', 'ncbi_cdd' ]
});
my @genes;
for my $g (schema->resultset('Gene')->search({ 'me.reviewed' => 0 }, )->all) {
  #my %has_runs;
  #for my $t ($g->transcripts) {
  #  $has_runs{$_->db_source_id}=1 for $t->blast_runs;
  #}
  push @genes, $g; 
  if (@genes > 50) {
    for my $db ($dbs->all) {
      #if ($has_runs{$db->id}) {
      #  debug 'gene '.$g->id.' already blasted against '.$db->name.' ('.$db->id.')';
      #  next;
      #}
      my $task = new TearDrop::Task::BLAST(replace => 0, gene_ids => [ map { $_->id } @genes ], database => $db->name, post_processing => sub {
        for my $g (@genes) {
          my $sg = schema->resultset('Gene')->find($g->id);
          return if $sg->reviewed;
          for my $t ($sg->transcripts) {
            $t->auto_annotate;
          }
          $sg->auto_annotate;
        }
      });
      TearDrop::Worker::enqueue($task);
    }
    @genes=();
  }
}
TearDrop::Worker::wait();
