package TearDrop;
use Dancer ':syntax';

use Dancer::Plugin::DBIC qw(schema resultset);
use Dancer::FileUtils qw/read_file_content/;

use TearDrop::Worker;

use Text::Markdown 'markdown';
use Carp;
use Try::Tiny;

our $VERSION = '0.1';

set layout => undef;

sub setup_projects {
  for my $project (schema->resultset('Project')->search()->all) {
    my %conf = %{config->{plugins}{DBIC}{default}};
    my $project_name=$project->name;
    $conf{dsn}=~s/dbname=\w+;/dbname=teardrop_$project_name;/;
    $conf{schema_class}='TearDrop::Model';
    config->{plugins}{DBIC}{$project_name}=\%conf;
  }
}
setup_projects();

require TearDrop::Worker::Redis;
my $worker = new TearDrop::Worker::Redis;
$worker->restart_working;

hook 'before' => sub {
  header 'Access-Control-Allow-Origin' => '*';
  debug request->path;
  var 'project' => cookie 'project';
  if (var('project') && !exists config->{plugins}{DBIC}{var 'project'}) {
    send_error 'invalid project: '.var('project'), 500;
  }
  try {
    schema(var 'project')->storage->ensure_connected;
  } catch {
    warning 'invalid project cookie '.var 'project';
    delete cookies->{project};
  };
};

# make sure user variable is available in all views
hook 'before_template' => sub {
  my $tokens = shift;
  $tokens->{request}=request;
  $tokens->{config}=config;
  $tokens->{user}=session 'user';
};

prefix config->{base_uri};

get '/' => sub {
  template 'teardrop/app/index';
};

get '/roadmap' => sub {
  my $todo = read_file_content(path('doc', 'todo.md'));
  $todo =~ s|DONE(.*)$|<span class="text-muted"><i class="fa fa-check-circle"></i>$1</span>|mg;
  $todo =~ s|XXX(.*)$|<span class="bg-danger"><i class="fa fa-fire text-danger"></i>$1</span>|mg;
  template 'teardrop/roadmap', { roadmap => markdown $todo };
};

prefix config->{base_uri}.'/api';

set serializer => 'JSON';

hook before_error_render => sub {
  my $error = shift;
  error $error;
  if ($error->exception) {
    my $exc = $error->exception;
    $exc =~ s/ at .*//s;
    $error->{exception} =$exc;
  }
  if ($error->message) {
    my $msg = $error->message;
    $msg =~ s/ at .*//s;
    $error->{message} =$msg;
  }
};

get '/projects' => sub {
  [ schema->resultset('Project')->all ];
};

sub parse_params {
  my ($comparisons, $filters, $sort) = @_;
  if ($comparisons->isa('DBIx::Class::ResultSet')) {
    $comparisons = $comparisons->result_class->new->comparisons;
  }
  elsif (!ref $comparisons) {
    $comparisons = schema(var 'project')->resultset($comparisons)->result_class->new->comparisons;
  }
  for my $field (keys %$comparisons) {
    if (exists params->{'filter.'.$field}) {
      my $col=$comparisons->{$field}{column};
      if ($comparisons->{$field}{cmp} eq 'like') { 
        params->{'filter.'.$field}='%'.lc(params->{'filter.'.$field}).'%'; 
        $col='LOWER('.$col.')';
      }
      if ($comparisons->{$field}{cmp} eq 'IN') {
        $filters->{$col} = ref params->{'filter.'.$field} eq 'ARRAY' ? params->{'filter.'.$field} : [ params->{'filter.'.$field} ];
      }
      $filters->{$col} = { $comparisons->{$field}{cmp} => param('filter.'.$field) };
    }
  }
  for my $k (keys %{params()}) {
    if ($k=~ m/sort-(\d+)-(.+)/) {
      my ($w, $f) = ($1, $2);
      $sort->[$w]={ '-'.param($k) => $f =~ m#\.# ? $f : 'me.'.$f };
    }
  }
  if (exists params->{'filter.log2_foldchange'}) {
    $filters->{log2_foldchange} = [
      { '<', params->{'filter.log2_foldchange'}*-1 },
      { '>', params->{'filter.log2_foldchange'} },
    ];
  }
}


get '/transcripts' => sub {
  my $filter = {};
  my $sort = [ { -asc => 'me.id' } ];
  
  parse_params('Transcript', $filter, $sort);
  debug $sort;
  debug $filter;
  my $rs = schema(var 'project')->resultset('Transcript')->search($filter, { 
    order_by => $sort,
    page => param('page'), 
    rows => param('pagesize') || 50, 
    prefetch => [ 'organism', 'gene', { 'transcript_tags' => [ 'tag' ] } ]
  });
  my $ser = [ map {
    my $t=$_;
    my $tser = $t->TO_JSON;
    for (qw/organism gene/) {
      $tser->{$_} = $t->$_->TO_JSON if $t->$_;
    }
    $tser;
  } $rs->all ];
  if (param('page')) {
    return {
      total_items => $rs->pager->total_entries,
      data => $ser,
    };
  }
  else {
    return $ser;
  }
};

get '/transcripts/fasta' => sub {
  my $filter = {};
  my $sort = [ { -asc => 'me.id' } ];
  
  parse_params('Transcript', $filter, $sort);
  debug $sort;
  debug $filter;
  my $rs = schema(var 'project')->resultset('Transcript')->search($filter, { 
    order_by => $sort,
    prefetch => [ 'organism', { 'transcript_tags' => [ 'tag' ] } ]
  });

  my @ret;
  for my $t ($rs->all) {
    push @ret, $t->to_fasta;
  }

  content_type 'text/plain';
  join "\n", @ret;
};

get '/transcripts/:id' => sub {
  my $rs = schema(var 'project')->resultset('Transcript')->find(param('id'), { prefetch => [
    'organism', 'gene', { 'transcript_tags' => 'tag' }, 
  ]}) || send_error 'not found', 404;
  my $tser = $rs->TO_JSON;
  $tser->{organism} = $rs->organism;
  $tser->{tags} = [ $rs->tags ];
  $tser->{transcript_mapping_count} = $rs->transcript_mappings->count;
  $tser->{annotations} = $rs->gene_model_annotations;
  $tser->{de_results} = [];
  for my $der (schema(var 'project')->resultset('DeResult')->search({ transcript_id => $rs->id },
    { prefetch => ['de_run', { 'contrast' => [ 'base_condition', 'contrast_condition' ] }]})) {
    my $d = $der->TO_JSON;
    $d->{contrast}=$der->contrast->TO_JSON;
    $d->{de_run}=$der->de_run->TO_JSON;
    push @{$tser->{de_results}}, $d;
  }
  $tser;
};

post '/transcripts/:id' => sub {
  my %tags = map {
    $_->tag => 1,
  } schema(var 'project')->resultset('Tag')->all;
  my $rs = schema(var 'project')->resultset('Transcript')->find(param('id')) || send_error 'not found', 404;
  my $upd = params('body');
  $rs->$_($upd->{$_}) for qw/name description best_homolog rating reviewed/;
  $rs->organism_name($upd->{organism}{name}) if $upd->{organism};
  $rs->update_tags(@{$upd->{tags}});
  $rs->update;
  forward config->{base_uri}.'/api/transcripts/'.$rs->id, {}, { method => 'GET' };
};

get '/transcripts/:id/mappings' => sub {
  my $rs = schema(var 'project')->resultset('Transcript')->find(param('id')) || send_error 'not found', 404;
  my $maps = $rs->filtered_mappings;
  my @ret;
  for my $m (@$maps) {
    my $m_ser = $m->TO_JSON;
    $m_ser->{annotations} = [ $m->annotations ];
    push @ret, $m_ser;
  }
  \@ret;
};

get '/transcripts/:id/blast_results' => sub {
  my $trans = schema(var 'project')->resultset('Transcript')->find(param('id')) || send_error 'not found', 404;
  my @results;
  for my $bl ($trans->search_related('blast_results', undef, { prefetch => 'db_source' })) {
    my $bl_ser = $bl->TO_JSON;
    $bl_ser->{db_source}=$bl->db_source->description;
    push @results, $bl_ser;
  }
  \@results;
};

get '/transcripts/:id/run_blast' => sub {
  my $rs = schema(var 'project')->resultset('Transcript')->find(param('id')) || send_error 'transcript not found', 404;
  my $db = schema(var 'project')->resultset('DbSource')->search({
    name => param('database') || 'refseq_plant'
  })->first || send_error 'db not found', 404;
  my $task = new TearDrop::Task::BLAST(transcript_id => $rs->id, database => $db->name);
  my $item = $worker->enqueue($task);
  { id => $item->id, status => $item->status };
};


get '/transcripts/:id/blast_runs' => sub {
  my $rs = schema(var 'project')->resultset('Transcript')->find(param('id')) || send_error 'not found', 404;
  my %blast_runs;
  for my $br ($rs->blast_runs) {
    next unless $br->finished;
    my $br_ser = $br->TO_JSON;
    $br_ser->{db_source}=$br->db_source->TO_JSON;
    $blast_runs{$br->db_source->name} ||= $br_ser;
    my $hit_count = schema(var 'project')->resultset('BlastResult')->search({
      transcript_id => $rs->id, db_source_id => $br->db_source_id
    })->count;
    $blast_runs{$br->db_source->name}->{hits} += $hit_count;
  }
  [ values %blast_runs ];
};


get '/transcripts/:id/pileup' => sub {
  my $trans = schema(var 'project')->resultset('Transcript')->find(param('id')) || send_error 'not found', 404;
  my $assembly = $trans->assembly || send_error 'assembly '.$trans->assembly_id.' not found', 404;

  my @alns = $assembly->transcriptome_alignments;
  send_error 'no alignments for transcript', 404 unless @alns;

  # XXX should check if original_id settings is consistent for all alignments
  return TearDrop::Task::Mpileup->new(
    reference_path => $assembly->path,
    region => $alns[0]->use_original_id ? $trans->original_id : $trans->id,
    effective_length => length($trans->nsequence),
    context => 0,
    type => 'transcript',
    alignments => [ map { $_->alignment } @alns ],
  )->run;

};

get '/genes' => sub {
  my $filter = {};
  my $sort = [ { -asc => 'me.id' } ];

  parse_params('Gene', $filter, $sort);
  debug $sort;
  debug $filter;
  my $rs = schema(var 'project')->resultset('Gene')->search($filter, { 
    order_by => $sort,
    page => param('page'), 
    rows => param('pagesize') || 50, 
    prefetch => [ 
      { 'transcripts' => [ 'organism', ]}, #{ 'transcript_tags' => [ 'tag' ] }, ]}, 
      { 'gene_tags' => [ 'tag' ] } ]
  });
  debug 'done';
  my @ret;
  for my $r ($rs->all) {
    my $ser = $r->TO_JSON;
    $ser->{organism}=$r->organism;
    $ser->{transcripts} = [ map {
      my $tser = $_->TO_JSON;
      #$tser->{tags} = [ $_->tags ];
      $tser;
    } $r->transcripts ];
    $ser->{tags} = [ $r->tags ];
    push @ret, $ser;
  }
  debug 'fetched';
  if (param('page')) {
    return {
      total_items => $rs->pager->total_entries,
      data => \@ret,
    };
  }
  else {
    return \@ret;
  }
};

get '/genes/fasta' => sub {
  my $filter = {};
  my $sort = [ { -asc => 'me.id' } ];

  parse_params('Gene', $filter, $sort);
  debug $sort;
  debug $filter;
  my $rs = schema(var 'project')->resultset('Gene')->search($filter, { 
    order_by => $sort,
    prefetch => [ 
      { 'transcripts' => [ 
          { 'transcript_tags' => [ 'tag' ] }, 
      ]}, 
      { 'gene_tags' => [ 'tag' ] } ]
  });
  debug 'done';
  my @ret;
  for my $g ($rs->all) {
    push @ret, $g->to_fasta;
  }
  content_type 'text/plain';
  join "\n", @ret;
};

get '/genes/:id' => sub {
  my $gene = schema(var 'project')->resultset('Gene')->find(param('id'), {
    prefetch => [ 
      { 'transcripts' => [ 'organism', { 'transcript_tags' => 'tag' } ] },
      { 'gene_tags' => 'tag' },
    ]
  }) || send_error 'not found', 404;
  my $ser = $gene->TO_JSON;
  $ser->{organism} = $gene->organism;
  $ser->{transcripts} = [ map {
    my $tser = $_->TO_JSON;
    $tser->{tags} = [ $_->tags ];
    $tser->{transcript_mapping_count} = $_->transcript_mappings->count;
    $tser->{mappings} = [ $_->filtered_mappings ];
    $tser;
  } $gene->transcripts ];
  $ser->{annotations} = $gene->gene_model_annotations;
  $ser->{tags} = [ $gene->tags ];
  $ser->{de_results} = [];
  for my $der (schema(var 'project')->resultset('DeResult')->search({ transcript_id => $gene->id },
    { prefetch => ['de_run', { 'contrast' => [ 'base_condition', 'contrast_condition' ] }]})) {
    my $d = $der->TO_JSON;
    $d->{contrast}=$der->contrast->TO_JSON;
    $d->{de_run}=$der->de_run->TO_JSON;
    push @{$ser->{de_results}}, $d;
  }
  $ser->{blast_runs} = $gene->aggregate_blast_runs;
  $ser;
};

post '/genes/:id' => sub {
  my %tags = map {
    $_->tag => 1,
  } schema(var 'project')->resultset('Tag')->all;
  my $rs = schema(var 'project')->resultset('Gene')->find(param('id')) || send_error 'not found', 404;
  my $upd = params('body');
  $rs->$_($upd->{$_}) for qw/name description best_homolog rating reviewed/;
  $rs->update_tags(@{$upd->{tags}});
  $rs->update;
  forward config->{base_uri}.'/api/genes/'.$rs->id, {}, { method => 'GET' };
};

get '/genes/:id/mappings' => sub {
  my $rs = schema(var 'project')->resultset('Gene')->find(param('id')) || send_error 'not found', 404;
  my $maps = $rs->filtered_mappings;
  my @ret;
  for my $m (@$maps) {
    my $m_ser = $m->TO_JSON;
    $m_ser->{annotations} = [ $m->annotations ];
    push @ret, $m_ser;
  }
  \@ret;
};

get '/genes/:id/fasta' => sub {
  my $gene = schema(var 'project')->resultset('Gene')->find(param('id')) || send_error 'not found', 404;
  content_type 'text/plain';
  $gene->to_fasta;
};

get '/genes/:id/run_blast' => sub {
  my $rs = schema(var 'project')->resultset('Gene')->find(param('id')) || send_error 'gene not found', 404;
  my $db = schema(var 'project')->resultset('DbSource')->search({
    name => param('database') || 'refseq_plant'
  })->first || send_error 'db not found', 404;
  my $task = new TearDrop::Task::BLAST(gene_id => $rs->id, database => $db->name);
  my $item = $worker->enqueue($task);
  { id => $item->id, status => $item->status };
};

get '/genes/:id/transcripts/msa' => sub {
  my $gene = schema(var 'project')->resultset('Gene')->find(param 'id') || send_error 'not found', 404;
  TearDrop::Task::MAFFT->new(transcripts => [ $gene->transcripts ], algorithm => 'FFT-NS-i')->run;
};

get '/genes/:id/blast_runs' => sub {
  my $rs = schema(var 'project')->resultset('Gene')->find(param('id')) || send_error 'not found', 404;
  $rs->aggregate_blast_runs;
};

get '/genes/:id/blast_results' => sub {
  my $rs = schema(var 'project')->resultset('Gene')->find(param('id')) || send_error 'not found', 404;
  my @results;
  my $transcripts = $rs->search_related('transcripts');
  for my $trans ($transcripts->all) {
    for my $bl ($trans->search_related('blast_results', undef, { prefetch => 'db_source' })) {
      my $bl_ser = $bl->TO_JSON;
      $bl_ser->{db_source}=$bl->db_source->description;
      push @results, $bl_ser;
    }
  }
  \@results;
};

get '/deruns' => sub {
  my $rs = schema(var 'project')->resultset('DeRun')->search(undef, { prefetch => { 'de_run_contrasts' => { 'contrast' => [ 'base_condition', 'contrast_condition' ] } } });
  my @ret;
  for my $r ($rs->all) {
    my $ser = $r->TO_JSON;
    $ser->{contrasts}=[];
    for my $con ($r->de_run_contrasts->all) {
      push @{$ser->{contrasts}}, $con->contrast->TO_JSON;
    }
    push @ret, $ser;
  }
  \@ret;
};

get '/deruns/:id/contrasts/:contrast_id/results/fasta' => sub {
  my $de_run = schema(var 'project')->resultset('DeRun')->find(param 'id') || send_error 'no such de run', 404;
  my $is_gene = $de_run->count_table->aggregate_genes;
  my $filters = {de_run_id => param('id'), 'contrast_id' => param('contrast_id')};
  my $sort = [{ -asc => 'adjp' }];
  parse_params('DeResult', $filters, $sort);
  my $rs = schema(var 'project')->resultset('DeResult')->search($filters, { 
    order_by => $sort,
  });
  my @f;
  for my $r ($rs->all) {
    push @f, schema(var 'project')->resultset($is_gene ? 'Gene' : 'Transcript')->find($r->transcript_id)->to_fasta;
  }
  content_type 'text/plain';
  join "\n", @f;
};


get '/deruns/:id/contrasts/:contrast_id/results' => sub {
  schema(var 'project')->storage->debug(1);
  my $de_run = schema(var 'project')->resultset('DeRun')->find(param 'id') || send_error 'no such de run', 404;
  my $filters = {de_run_id => param('id'), 'contrast_id' => param('contrast_id')};
  my $sort = [{ -asc => 'adjp' }];
  parse_params('DeResult', $filters, $sort);
  debug $filters;
  debug $sort;
  my @ret;
  my $rs = $de_run->get_results($filters, { 
    order_by => $sort,
    page => param('page'), 
    rows => param('pagesize') || 50, 
  });
  for my $r ($rs->all) {
    my $ser = $r->TO_JSON;
    my $obj = $de_run->count_table->aggregate_genes ? 'gene' : 'transcript';
    $ser->{transcript} = $r->$obj->TO_JSON;
    $ser->{transcript}{$_} = $r->$obj->$_ for qw/organism tags/;
    push @ret, $ser;
  }
  schema(var 'project')->storage->debug(1);
  if (param('page')) {
    return {
      total_items => $rs->pager->total_entries,
      data => \@ret,
    };
  }
  else {
    return \@ret;
  }
};

get '/gene_models' => sub {
  my @gm = schema(var 'project')->resultset('GeneModel')->all;
  \@gm;
};

get '/genome_mappings/:id/annotations' => sub {
  my $context=param('context')||200;
  unless(param('tid') && param('tstart') && param('tend')) {
    send_error 'need start/end coordinates', 500;
  }
  if (param('tend')-param('tstart') + $context*2 > 50000) {
    send_error 'refusing to extract more than 50kb', 500;
  }
  my $gm = schema(var 'project')->resultset('GenomeMapping')->find(param 'id') || send_error 'no such mapping', 404;
  my @ret;
  push @ret, @{$gm->as_tree({ contig => params->{tid}, start => params->{tstart}-$context, end => params->{tend}+$context}, { filter => 1 })};
  for my $mod ($gm->organism_name->gene_models) {
    push @ret, @{$mod->as_tree({ contig => params->{tid}, start => params->{tstart}-$context, end => params->{tend}+$context})};
  }
  \@ret;
};

get '/genome_mappings/:id/pileup' => sub {
  my $context=param('context')||100;
  unless(param('tid') && param('tstart') && param('tend')) {
    send_error 'need start/end coordinates', 500;
  }
  if (param('tend')-param('tstart') + $context*2 > 50000) {
    send_error 'refusing to extract more than 50kb', 500;
  }
  my $gm = schema(var 'project')->resultset('GenomeMapping')->find(param 'id') || send_error 'no such mapping', 404;

  my $genome = $gm->organism_name;

  return TearDrop::Task::Mpileup->new(
    reference_path => $genome->genome_path,
    region => params->{tid}, start => params->{tstart}, end => params->{tend},
    context => $context,
    type => 'genome',
    alignments => [ map { $_->alignment } $genome->search_related('genome_alignments')->all ],
  )->run;
};

get '/alignments' => sub {
  my @gm = schema(var 'project')->resultset('Alignment')->search(undef, { prefetch => [ 'sample', 'genome_alignment', 'transcriptome_alignment' ]})->all;
  my @ret;
  for my $gm (@gm) {
    my $ser = $gm->TO_JSON;;
    $ser->{sample} = $gm->sample;
    $ser->{genome_alignment} = $gm->genome_alignment->TO_JSON if $gm->genome_alignment;
    $ser->{transcriptome_alignment} = $gm->transcriptome_alignment->TO_JSON if $gm->transcriptome_alignment;
    $ser->{type} = $ser->{genome_alignment} ? 'genome' : 'transcriptome';
    push @ret, $ser;
  }
  \@ret;
};

get '/assemblies' => sub {
  my @ret = map {
    my $a = $_;
    my $ser = $a->TO_JSON;
    $ser->{transcripts}=$a->transcripts->count+0;
    $ser->{annotated_transcripts}=$a->transcripts({ name => { '!=' => undef }})->count+0;
    #$ser->{genes}=schema(var 'project')->resultset('Gene')->search({ 'transcripts.assembly_id' => $a->id }, { prefetch => [ 'transcripts' ] })->count+0;
    #$ser->{annotated_genes}=schema(var 'project')->resultset('Gene')->search({ 'transcripts.assembly_id' => $a->id, 'me.name' => { '!=' => undef }}, { prefetch => [ 'transcripts' ] })->count+0;
    $ser;
  } schema(var 'project')->resultset('TranscriptAssembly')->all;
  \@ret;
};

get '/samples' => sub {
  my @ret = map {
    my $s = $_;
    my $ser = $s->TO_JSON;
    $ser->{alignments} = [ $s->alignments ];
    $ser;
  } schema(var 'project')->resultset('Sample')->search(undef, { prefetch => [ { 'alignments' => [ 'genome_alignment', 'transcriptome_alignment'] }, 'condition']})->all;
  \@ret;
};

get '/samples/:id' => sub {
  my $rs = schema(var 'project')->resultset('Sample')->find(param 'id', { prefetch => ['alignments', 'condition']}) || send_error 'not found', 404;
  my $ser = $rs->TO_JSON;
  $ser->{alignments} = [ $rs->alignments ];
  $ser;
};

post '/samples' => sub {
  my $upd = params('body');
  my $h = { map {
    $_ => $upd->{$_}
  } qw/name description replicate_number forskalle_id/ };
  $h->{condition}=$upd->{condition}{name};
  my $rs = schema(var 'project')->resultset('Sample')->create($h);
  forward config->{base_uri}.'/api/samples/'.$rs->id, {}, { method => 'GET' };
};

post '/samples/:id' => sub {
  my $rs = schema(var 'project')->resultset('Sample')->find(param 'id') || send_error 'not found', 404;

  my $upd = params('body');
  $upd->{flagged}=$upd->{flagged} ? 1 : 0;
  $rs->$_($upd->{$_}) for qw/name description replicate_number flagged forskalle_id/;
  $rs->condition($upd->{condition}{name});
  $rs->update;
  forward config->{base_uri}.'/api/samples/'.$rs->id, {}, { method => 'GET' };
};

del '/samples/:id' => sub {
  my $rs = schema(var 'project')->resultset('Sample')->find(param 'id') || send_error 'not found', 404;
  $rs->delete;
};

get '/db_sources' => sub {
  [ schema(var 'project')->resultset('DbSource')->all ];
};

get '/tags' => sub {
  [ schema(var 'project')->resultset('Tag')->all ];
};

get '/organisms' => sub {
  [ schema(var 'project')->resultset('Organism')->all ];
};

get '/conditions' => sub {
  [ schema(var 'project')->resultset('Condition')->all ];
};

get '/worker/status' => sub {
  $worker->status;
};

get '/worker/status/:job' => sub {
  $worker->job_status(param 'job');
};

true;
