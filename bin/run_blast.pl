#!/usr/bin/perl

use warnings;
use strict;

use Dancer ':script';
use Dancer::Plugin::DBIC 'schema';

use TearDrop::Worker;

my $dbs = schema->resultset('DbSource')->search({
  name => [ 'refseq_plant', 'refseq_fungi', 'ncbi_cdd' ]
});
for my $t (schema->resultset('Gene')->search({ reviewed => 1 })->all) {
  for my $db ($dbs->all) {
    my $task = new TearDrop::Task::BLAST(replace => 1, gene_id => $t->id, database => $db->name);
    TearDrop::Worker::enqueue($task);
  }
}
TearDrop::Worker::wait();
