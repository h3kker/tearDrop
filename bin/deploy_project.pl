#!/usr/bin/env perl

use warnings;
use strict;

use Getopt::Long;

BEGIN {
  Getopt::Long::Configure('pass_through');
}

use Dancer ':script';
use Dancer::Plugin::DBIC 'schema';
use Try::Tiny;
use Carp;
use DBIx::Class::ResultClass::HashRefInflator;

use TearDrop;

my $project;
my $overwrite=0;
GetOptions('project|p=s' => \$project, 'overwrite' => \$overwrite) || die "Usage!";

die "Usage: $0 --project [project]" unless $project;

my $p = schema->resultset('Project')->find($project) || confess "No such project: $project!";

if ($p->status eq 'done' || $p->status eq 'active') {
  confess 'Project '.$p->name.' is '.$p->status.', won\'t touch it.';
}

my $trans_test;
try {
  schema($project)->resultset('Transcript')->first;
  $trans_test=1; #survived!
} catch {
  if ($_ =~ m#DBI connect.*failed#) {
    info 'create database...';
    schema->storage->dbh_do(sub {
      my ($storage, $dbh) = @_;
      $dbh->do(qq{CREATE DATABASE teardrop_}.$p->name.qq{ OWNER }.config->{plugins}{DBIC}{$p->name}{user});
    })
  }
};

if (!$overwrite && $trans_test) {
  info "Schema seems to be deployed to project database, quitting.";
  exit;
}

info 'Create db schema...';

schema($project)->deploy({ add_drop_table => 1 });

info 'Populate tables from templates...';
for my $tbl (qw/Organism GeneModel DbSource Tag/) {
  schema($project)->resultset($tbl)->populate([
    schema->resultset($tbl)->search({}, {
         result_class => 'DBIx::Class::ResultClass::HashRefInflator',
    })
  ]);
}
$p->status('import');
$p->update;
