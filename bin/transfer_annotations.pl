#!/usr/bin/perl

use warnings;
use strict;

use warnings;
use strict;

use Getopt::Long;

BEGIN {
  Getopt::Long::Configure('pass_through');
}

use Dancer ':script';
use Dancer::Plugin::DBIC 'schema';

use TearDrop;

my ($from_project, $project, $transcript_map, $legacy, $include_genes);

GetOptions('from_project|f=s' => \$from_project, 'include_genes' => \$include_genes, 'legacy' => \$legacy, 'project|t=s' => \$project, 'map|m=s' => \$transcript_map) || die "Usage!";

die "Usage: $0 --from_project [project] --project [project] --map [transcript id map]" unless $transcript_map && $project;

$from_project ||= $project;

my %legacy_map = qw/organism_name organism/;

## make sure tags are there
for my $tag (schema($from_project)->resultset('Tag')->search({}, { result_class => 'DBIx::Class::ResultClass::HashRefInflator' })) {
  schema($project)->resultset('Tag')->find_or_create($tag);
}

my $xfer = sub {
  my ($src, $dst) = @_;
  for (qw/name description reviewed rating best_homolog organism_name/) {
    my $src_attr = $legacy && exists $legacy_map{$_} ? $legacy_map{$_} : $_;
    next unless $dst->can($_) && $src->can($src_attr);
    my $src_val = $src->$src_attr;
    if ($legacy && $src_val && $src_attr eq 'organism') {
      $src_val=$src_val->name;
    }
    
    $dst->$_($src_val);
  }
  $dst->update;
};
my $xfer_relations = sub {
  my ($xfer_src, $xfer_dst) = @_;
  for my $class (qw/BlastResult BlastRun TranscriptTag GeneTag/) {
    my $tbl = schema($project)->resultset($class)->result_source->name;
    next unless $xfer_dst->relationship_info($tbl);
    debug '   Set '.$class.'/'.$tbl;
    my $fk = (keys %{$xfer_dst->relationship_info($tbl)->{cond}})[0];
    $fk =~ s/^foreign\.//;

    my $rows = [ map { $_->{$fk} = $xfer_dst->id; $_ } 
      $xfer_src->search_related($tbl, {}, { 
        result_class => 'DBIx::Class::ResultClass::HashRefInflator' 
      }) ];

    my %to_delete = map {
      my $col=$_;
      $col => [ map { $_->{$col} } @$rows ]
    } schema($project)->resultset($class)->result_source->primary_columns;
    schema($project)->resultset($class)->search(\%to_delete)->delete;
    schema($project)->resultset($class)->populate($rows);
  }
};


my %genes_done;
my $migrated=0;
open MAP, "<".$transcript_map or die "open $transcript_map: $!";
schema($project)->txn_begin;
while(<MAP>) {
  chomp;
  my ($src_id, $dst_id)=split ' ', $_, 2;
  $migrated++;
  debug "($migrated) migrate $src_id => $dst_id";
  my $src = schema($from_project)->resultset('Transcript')->find($src_id, { prefetch => [ 'gene', 'blast_results', 'blast_runs', 'transcript_tags' ] }) || die "Source transcript ".$src_id." not found in project $from_project";
  my $dst = schema($project)->resultset('Transcript')->find($dst_id) || die "Target transcript ".$dst_id." not found in project $project";

  debug '  Update transcript';
  $xfer->($src, $dst);

  debug '  Update relations';
  $xfer_relations->($src, $dst);
  if ($include_genes && !exists $genes_done{$dst->gene_id}) {
    my $src_gene = $src->search_related('gene', {}, { prefetch => [ 'gene_tags' ] })->first;
    if ($src_gene && $dst->gene) {
      debug '  Update gene '.$src_gene->id.' => '.$dst->gene->id;
      $xfer->($src_gene, $dst->gene);
      debug '  Update gene relations';
      $xfer_relations->($src_gene, $dst->gene);
      $genes_done{$dst->gene_id}=1;
    }
  }
  if ($migrated % 500 == 0) {
    debug "($migrated) COMMIT";
    schema($project)->txn_commit;
    schema($project)->txn_begin;
  }
}
schema($project)->txn_commit;
close MAP;

