#!/usr/bin/env perl

use warnings;
use strict;

use Getopt::Long::Descriptive;

use Dancer ':script';
use Dancer::Plugin::DBIC 'schema';
use Try::Tiny;
use Carp;
use DBIx::Class::ResultClass::HashRefInflator;

use TearDrop::Cmd;

my ($opt, $usage) = describe_options(
  '%c %o',
  [ 'project|p=s', "project name", { required => 1 } ],
  [ 'overwrite', 'drop tables before creating' ],
  [ 'create|c', 'create project in master database', ],
  [ 'status|s', 'set project status and quit' ],
  [],
  [ 'title|t=s', 'title (display name) for new project' ],
  [ 'description|d=s', 'description text for new project' ],
  [ 'forskalle_group|g=s', 'group name, owner of new project' ],
  [],
  [ 'help_deploy', 'this message.' ],
);
print $usage->text, exit if $opt->help_deploy;

my $p;
if ($opt->create) {
  die "Need title and group for a new project!\n".$usage->text unless $opt->title && $opt->forskalle_group;
  $p = schema->resultset('Project')->create({
    name => $opt->project,
    title => $opt->title,
    description => $opt->description,
    forskalle_group => $opt->forskalle_group,
    status => 'setup',
  });
  info 'Project entry created.';
}
else {
  $p = schema->resultset('Project')->find($opt->project) || die "No such project: ".$opt->project."!";
  info 'project read from master';
}

if ($p->status eq 'done' || $p->status eq 'active') {
  die 'Project '.$p->name.' is '.$p->status.', won\'t touch it.';
}

if ($opt->status) {
  $p->status($opt->status);
  $p->update;
  info 'Status updated. Ciao.';
  exit;
}

my $trans_test;
try {
  schema($opt->project)->resultset('Transcript')->first;
  $trans_test=1; #survived!
} catch {
  if ($_ =~ m#DBI connect.*failed#) {
    info 'Create database...';
    schema->storage->dbh_do(sub {
      my ($storage, $dbh) = @_;
      $dbh->do(qq{CREATE DATABASE teardrop_}.$p->name.qq{ OWNER }.config->{plugins}{DBIC}{$p->name}{user});
    })
  }
};

if (!$opt->overwrite && $trans_test) {
  info "Schema seems to be deployed to project database, quitting.";
  exit;
}

info 'Create db schema...';

schema($opt->project)->deploy({ add_drop_table => 1 });

info 'Populate tables from templates...';
for my $tbl (qw/Organism GeneModel DbSource Tag/) {
  schema($opt->project)->resultset($tbl)->populate([
    schema->resultset($tbl)->search({}, {
         result_class => 'DBIx::Class::ResultClass::HashRefInflator',
    })
  ]);
}
$p->status('import');
$p->update;
