package TearDrop;
use Dancer ':syntax';

use Dancer::Plugin::DBIC qw(schema resultset);
use TearDrop::Worker;
use Carp;

our $VERSION = '0.1';

set layout => undef;

hook 'before' => sub {
  header 'Access-Control-Allow-Origin' => '*';
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
  schema->resultset('Sample');
  template 'teardrop/app/index';
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

sub parse_params {
  my ($comparisons, $filters, $sort) = @_;
  if ($comparisons->isa('DBIx::Class::ResultSet')) {
    $comparisons = $comparisons->result_class->new->comparisons;
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
      $sort->[$1]={ '-'.param($k) => 'me.'.$2 };
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
  
  parse_params(schema->resultset('Transcript'), $filter, $sort);
  debug $sort;
  debug $filter;
  my $rs = schema->resultset('Transcript')->search($filter, { 
    order_by => $sort,
    page => param('page'), 
    rows => param('pagesize') || 50, 
    prefetch => [ 'organism', { 'transcript_tags' => [ 'tag' ] } ]
  });
  if (param('page')) {
    return {
      total_items => $rs->pager->total_entries,
      data => [ $rs->all ],
    };
  }
  else {
    return [ $rs->all ];
  }
};

get '/transcripts/fasta' => sub {
  my $filter = {};
  my $sort = [ { -asc => 'me.id' } ];
  
  parse_params(schema->resultset('Transcript'), $filter, $sort);
  debug $sort;
  debug $filter;
  my $rs = schema->resultset('Transcript')->search($filter, { 
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
  my $rs = schema->resultset('Transcript')->find(param('id')) || send_error 'not found', 404;
  $rs;
};

my %genomePileups;
get '/transcripts/:id/genomePileup' => sub {
  my $trans = schema->resultset('Transcript')->find(param 'id') || send_error 'not found', 404;
  my $context=200;
  my $best_location = $trans->search_related('transcript_mappings', {}, { order_by => { -desc => 'match_ratio' } })->first; 
  send_error 'no valid genome mapping!', 500 unless $best_location;
  my $genome = $best_location->genome_mapping->organism_name;

  my $others = $best_location->genome_mapping->search_related('transcript_mappings', {
    -or => [
      tstart => { '>',  $best_location->tstart-$context, '<', $best_location->tend+$context },
      tend => { '<', $best_location->tend+$context, '>', $best_location->tstart-$context },
      -and => { tstart => { '<', $best_location->tstart-$context }, tend => { '>', $best_location->tend+$context }},
    ]
  });
  debug map { $_->transcript->id } $others->all;

  return TearDrop::Task::Mpileup->new(
    reference_path => $genome->genome_path,
    region => $best_location->tid, start => $best_location->tstart, end => $best_location->tend,
    context => $context,
    type => 'genome',
    alignments => [ map { $_->alignment } $genome->search_related('genome_alignments')->all ],
  )->run;
};

my %pileups;
get '/transcripts/:id/pileup' => sub {
  my $trans = schema->resultset('Transcript')->find(param('id')) || send_error 'not found', 404;
  my $assembly = $trans->assembly || send_error 'assembly '.$trans->assembly_id.' not found', 404;

  return TearDrop::Task::Mpileup->new(
    reference_path => $assembly->path,
    region => $trans->id,
    effective_size => length($trans->nsequence),
    context => 0,
    type => 'transcript',
    alignments => [ map { $_->alignment } $assembly->search_related('transcriptome_alignments')->all ],
  )->run;

};

get '/genes' => sub {
  my $filter = {};
  my $sort = [ { -asc => 'me.id' } ];

  parse_params(schema->resultset('Gene'), $filter, $sort);
  debug $sort;
  debug $filter;
  my $rs = schema->resultset('Gene')->search($filter, { 
    order_by => $sort,
    page => param('page'), 
    rows => param('pagesize') || 50, 
    prefetch => [ 
      { 'transcripts' => [ 
          { 'transcript_tags' => [ 'tag' ] }, 
          #{ 'transcript_mappings' => [ 'genome_mapping' ] } 
      ]}, 
      { 'gene_tags' => [ 'tag' ] } ]
  });
  debug 'done';
  my @ret;
  for my $r ($rs->all) {
    my $ser = $r->TO_JSON;
    $ser->{organism}=$r->organism;
    $ser->{transcripts} = [ map {
      my $tser = $_->TO_JSON;
      $tser->{tags} = [ $_->tags ];
      #$tser->{transcript_mappings} = [ $_->transcript_mappings ];
      $tser;
    } $r->search_related('transcripts')->all ];
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

  parse_params(schema->resultset('Gene'), $filter, $sort);
  debug $sort;
  debug $filter;
  my $rs = schema->resultset('Gene')->search($filter, { 
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

get '/genes/:id/fasta' => sub {
  my $gene = schema->resultset('Gene')->find(param('id')) || send_error 'not found', 404;
  content_type 'text/plain';
  $gene->to_fasta;
};

get '/genes/:id' => sub {
  my $gene = schema->resultset('Gene')->find(param('id')) || send_error 'not found', 404;
  my $transcripts = [ $gene->search_related('transcripts')->all ];
  my $ser = $gene->TO_JSON;
  $ser->{transcripts} = [ map {
    my $tser = $_->TO_JSON;
    $tser->{tags} = [ $_->tags ];
    $tser->{transcript_mappings} = [ $_->transcript_mappings ];
    $tser;
  } @$transcripts ];
  $ser->{tags} = [ $gene->tags ];
  $ser->{de_results} = [];
  for my $der (schema->resultset('DeResult')->search({ transcript_id => $gene->id },
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
  } schema->resultset('Tag')->all;
  my $rs = schema->resultset('Gene')->find(param('id')) || send_error 'not found', 404;
  my $upd = params('body');
  $rs->$_($upd->{$_}) for qw/description best_homolog rating reviewed/;
  $rs->set_tags(@{$upd->{tags}});
  $rs->update;
  forward config->{base_uri}.'/api/genes/'.$rs->id, {}, { method => 'GET' };
};

get '/genes/:id/run_blast' => sub {
  my $rs = schema->resultset('Gene')->find(param('id')) || send_error 'gene not found', 404;
  my $db = schema->resultset('DbSource')->search({
    name => param('database') || 'refseq_plant'
  })->first || send_error 'db not found', 404;
  my $task = new TearDrop::Task::BLAST(gene_id => $rs->id, database => $db->name);
  TearDrop::Worker::enqueue($task);
  { pid => $task->pid, status => $task->status };
};

get '/genes/:id/blast_runs' => sub {
  my $rs = schema->resultset('Gene')->find(param('id')) || send_error 'not found', 404;
  $rs->aggregate_blast_runs;
};

get '/genes/:id/blast_results' => sub {
  my $rs = schema->resultset('Gene')->find(param('id')) || send_error 'not found', 404;
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
  my $rs = schema->resultset('DeRun')->search(undef, { prefetch => { 'de_run_contrasts' => { 'contrast' => [ 'base_condition', 'contrast_condition' ] } } });
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
  my $de_run = schema->resultset('DeRun')->find(param 'id') || send_error 'no such de run', 404;
  my $is_gene = $de_run->count_table->aggregate_genes;
  my $filters = {de_run_id => param('id'), 'contrast_id' => param('contrast_id')};
  my $sort = [{ -asc => 'adjp' }];
  parse_params(schema->resultset('DeResult'), $filters, $sort);
  my $rs = schema->resultset('DeResult')->search($filters, { 
    order_by => $sort,
  });
  my @f;
  for my $r ($rs->all) {
    push @f, schema->resultset($is_gene ? 'Gene' : 'Transcript')->find($r->transcript_id)->to_fasta;
  }
  content_type 'text/plain';
  join "\n", @f;
};


get '/deruns/:id/contrasts/:contrast_id/results' => sub {
  my $de_run = schema->resultset('DeRun')->find(param 'id') || send_error 'no such de run', 404;
  my $is_gene = $de_run->count_table->aggregate_genes;
  my $filters = {de_run_id => param('id'), 'contrast_id' => param('contrast_id')};
  my $sort = [{ -asc => 'adjp' }];
  parse_params(schema->resultset('DeResult'), $filters, $sort);
  debug $filters;
  debug $sort;
  my $rs = schema->resultset('DeResult')->search($filters, { 
    order_by => $sort,
    page => param('page'), 
    rows => param('pagesize') || 50, 
  });
  my @ret;
  for my $r ($rs->all) {
    my $ser = $r->TO_JSON;
    $ser->{transcript}=schema->resultset($is_gene ? 'Gene' : 'Transcript')->find($r->transcript_id);
    push @ret, $ser;
  }
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

get '/db_sources' => sub {
  [ schema->resultset('DbSource')->all ];
};

get '/tags' => sub {
  [ schema->resultset('Tag')->all ];
};

get '/worker/status' => sub {
  TearDrop::Worker::get_status();
};

get '/worker/status/:job' => sub {
  TearDrop::Worker::get_job_status(param 'job');
};


true;
