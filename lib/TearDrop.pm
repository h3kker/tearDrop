package TearDrop;
use Dancer ':syntax';

use Dancer::Plugin::DBIC qw(schema resultset);
use TearDrop::Worker;

our $VERSION = '0.1';

set layout => undef;

hook 'before' => sub {
  TearDrop::Worker::start_worker() if config->{'start_worker'};
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

get '/transcripts' => sub {
  #new TearDrop::Task::BLAST(gene_id => 'c45045_g1', database => 'TAIR10 Proteins')->run;
  my $rs = schema->resultset('Transcript')->search(undef, { 
    page => param('page'), 
    rows => param('pagesize') || 50, 
    prefetch => 'organism' 
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

get '/transcripts/:id' => sub {
  my $rs = schema->resultset('Transcript')->find(param('id'));
  $rs;
};

get '/genes/:id' => sub {
  my $rs = schema->resultset('Gene')->find(param('id')) || send_error 'not found', 404;
  my $ser = $rs->TO_JSON;
  $ser->{transcripts} = [ 
    $rs->search_related('transcripts')
  ];
  $ser->{de_results} = [];
  for my $der (schema->resultset('DeResult')->search({ transcript_id => $rs->id },
    { prefetch => ['de_run', { 'contrast' => [ 'base_condition', 'contrast_condition' ] }]})) {
    my $d = $der->TO_JSON;
    $d->{contrast}=$der->contrast->TO_JSON;
    $d->{de_run}=$der->de_run->TO_JSON;
    push @{$ser->{de_results}}, $d;
  }
  $ser;
};

get '/genes/:id/run_blast' => sub {
  my $rs = schema->resultset('Gene')->find(param('id')) || send_error 'not found', 404;
  my $db = schema->resultset('DbSource')->search({
    description => param('database') || 'RefSeq Plant'
  })->first || send_error 'not found', 404;
  TearDrop::Worker::enqueue(new TearDrop::Task::BLAST(gene_id => $rs->id, database => $db->description));
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

get '/deruns/:id/contrasts/:contrast_id/results' => sub {
  my %filter = (de_run_id => param('id'), 'contrast_id' => param('contrast_id'));
  my @sort;
  my %comparisons = (base_mean => '>', adjp => '<', pvalue => '>', 'transcript_id' => 'like');
  for my $field (keys %comparisons) {
    if (exists params->{'filter.'.$field}) {
      if ($field eq 'transcript_id') { params->{'filter.'.$field}='%'.params->{'filter.'.$field}.'%'; }
      $filter{$field} = { $comparisons{$field} => param('filter.'.$field) };
    }
  }
  if (exists params->{'filter.log2_foldchange'}) {
    $filter{log2_foldchange} = [
      { '<', params->{'filter.log2_foldchange'}*-1 },
      { '>', params->{'filter.log2_foldchange'} },
    ];
  }
  for my $k (keys %{params()}) {
    if ($k=~ m/sort-(\d+)-(.+)/) {
      $sort[$1]={ '-'.param($k) => $2 };
    }
  }
  unless (scalar @sort) {
    @sort = ({ -asc => 'adjp' });
  }
  debug \@sort;
  my $rs = schema->resultset('DeResult')->search(\%filter, { 
    order_by => \@sort,
    page => param('page'), 
    rows => param('pagesize') || 50, 
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

get '/worker/status' => sub {
  TearDrop::Worker::get_status();
};


true;
