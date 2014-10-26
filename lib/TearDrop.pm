package TearDrop;
use Dancer ':syntax';

use Dancer::Plugin::DBIC qw(schema resultset);

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

get '/transcripts' => sub {
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
  my $rs = schema->resultset('Gene')->find(param('id'));
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
  my %comparisons = (base_mean => '>', adjp => '<', pvalue => '>');
  for my $field (keys %comparisons) {
    if (exists params->{'filter.'.$field}) {
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


true;
