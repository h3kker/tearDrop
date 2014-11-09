#!/usr/bin/perl

use warnings;
use strict;

use Dancer ':script';
use Dancer::Plugin::DBIC 'schema';

use TearDrop::Worker;

my $dbs = schema->resultset('DbSource')->search({
  name => [ 'refseq_plant', 'refseq_fungi', 'ncbi_cdd' ]
});
for my $g (schema->resultset('Gene')->search({ 'me.reviewed' => 0 }, )->all) {
  my %has_runs;
  for my $t ($g->transcripts) {
    $has_runs{$_->db_source_id}=1 for $t->blast_runs;
  }
  for my $db ($dbs->all) {
    if ($has_runs{$db->id}) {
      debug 'gene '.$g->id.' already blasted against '.$db->name.' ('.$db->id.')';
      next;
    }
    my $task = new TearDrop::Task::BLAST(replace => 1, gene_id => $g->id, database => $db->name, post_processing => sub {
      return if $g->reviewed;
      for my $t ($g->transcripts) {
        next if $t->reviewed;
        my $best_homolog = $t->search_related('blast_results', undef, { order_by => [ { -asc => 'evalue' }, { -desc => 'pident' } ] })->first;
        next unless $best_homolog;
        if (!defined $t->best_homolog || $t->best_homolog ne $best_homolog->stitle) {
          debug 'setting '.$t->id.' best homolog '.$best_homolog->stitle.' (evalue '.$best_homolog->evalue.')';
          $t->best_homolog($best_homolog->source_sequence_id);
          $t->name($best_homolog->stitle);
          $t->description($best_homolog->stitle);
          $t->update;
        }
      }
    });
    TearDrop::Worker::enqueue($task);
  }
}
TearDrop::Worker::wait();
