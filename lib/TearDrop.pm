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

get '/transcripts' => sub {
  my %filter = ();
  my @sort;
  my %comparisons = (rating => '>', id => 'like', description => 'like', 'best_homolog' => 'like', 'reviewed' => '=', 'organism.scientific_name' => 'like');
  for my $field (keys %comparisons) {
    if (exists params->{'filter.'.$field}) {
      if ($comparisons{$field} eq 'like') { 
        params->{'filter.'.$field}='%'.params->{'filter.'.$field}.'%'; 
      }
      $filter{$field} = { $comparisons{$field} => param('filter.'.$field) };
    }
  }
  for my $k (keys %{params()}) {
    if ($k=~ m/sort-(\d+)-(.+)/) {
      $sort[$1]={ '-'.param($k) => $2 };
    }
  }
  unless (scalar @sort) {
    @sort = ({ -asc => 'id' });
  }
  debug \@sort;
  my $rs = schema->resultset('Transcript')->search(\%filter, { 
    order_by => \@sort,
    page => param('page'), 
    rows => param('pagesize') || 50, 
    prefetch => 'organism',
  });
  #new TearDrop::Task::BLAST(gene_id => 'c45045_g1', database => 'TAIR10 Proteins')->run;
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



  my @alignments;
  for my $galn ($genome->search_related('genome_alignments')->all) {
    push @alignments, $galn->alignment unless $genomePileups{$trans->id}->{$galn->alignment->sample->description};
  }


  if (@alignments) {
    use IPC::Run 'harness';
    my @cmd = ('ext/samtools/mpileup.sh', $genome->genome_path, sprintf("%s:%d-%d", $best_location->tid, $best_location->tstart-$context, $best_location->tend+$context), map { $_->bam_path } @alignments);
    debug 'running '.join(' ', @cmd);
    my ($out, $err);
    my $mp = harness \@cmd, \undef, \$out, \$err;
    $mp->run or send_error "unable to run mpileup: $err $?", 500;

    #debug $out;
    $genomePileups{$trans->id} = { map {
      $_->sample->description => []
    } @alignments };

    for my $l (split "\n", $out) {
      my @f = split "\t", $l;
      my $i=1;
      for my $aln (@alignments) {
        my $depth = () = $f[$i*3+1] =~ m#[\.\,]#g;
        my $mismatch = () = $f[$i*3+1] =~ m#[ACGTN]#gi;
        $depth+=$mismatch;
        push @{$genomePileups{$trans->id}->{$aln->sample->description}}, { 
          pos => $f[1]+0, 
          depth => $depth,
          mismatch => $mismatch+0,
          mismatch_rate => $depth>0 ? $mismatch/$depth : 0,
        };
        $i++;
      }
    }
  }
  use POSIX 'ceil';
  my $aggregate_to=1000;
  my $aggregate_factor=ceil(($best_location->tend-$best_location->tstart+$context*2)/$aggregate_to);

  my $ret = [ map {
    {
      key => $_,
      values => [ map { 
        [ $_->{pos}, { depth => $_->{depth}, mismatch => $_->{mismatch}, mismatch_rate => $_->{mismatch_rate} } ]
      } grep { $_->{pos} % $aggregate_factor == 0 } @{$genomePileups{$trans->id}->{$_}} ],
    }
  } sort keys %{$genomePileups{$trans->id}} ];
  $ret;
};

my %pileups;
get '/transcripts/:id/pileup' => sub {
  my $trans = schema->resultset('Transcript')->find(param('id')) || send_error 'not found', 404;
  my $assembly = $trans->assembly || send_error 'assembly '.$trans->assembly_id.' not found', 404;

  my @alignments;
  for my $taln ($assembly->search_related('transcriptome_alignments')->all) {
    push @alignments, $taln->alignment unless $pileups{$trans->id}->{$taln->alignment->sample->description};
  }

  if (@alignments) {
    use IPC::Run 'harness';
    my @cmd = ('ext/samtools/mpileup.sh', $assembly->path, $trans->id, map { $_->bam_path } @alignments);
    debug 'running '.join(' ', @cmd);
    my ($out, $err);
    my $mp = harness \@cmd, \undef, \$out, \$err;
    $mp->run or send_error "unable to run mpileup: $err $?", 500;

    #debug $out;
    $pileups{$trans->id} = { map {
      $_->sample->description => []
    } @alignments };

    for my $l (split "\n", $out) {
      my @f = split "\t", $l;
      my $i=1;
      for my $aln (@alignments) {
        my $depth=0; my $mismatch=0;
        if (defined $f[$i*3+1]) {
          $depth = () = $f[$i*3+1] =~ m#[\.\,]#g;
          $mismatch = () = $f[$i*3+1] =~ m#[ACGTN]#gi;
          $depth+=$mismatch;
        }
        push @{$pileups{$trans->id}->{$aln->sample->description}}, { 
          pos => $f[1]+0, 
          depth => $depth,
          mismatch => $mismatch+0,
          mismatch_rate => $depth>0 ? $mismatch/$depth : 0,
        };
        $i++;
      }
    }
  }

  my $ret = [ map {
    {
      key => $_,
      values => [ map { 
        [ $_->{pos}, { depth => $_->{depth}, mismatch => $_->{mismatch}, mismatch_rate => $_->{mismatch_rate} } ]
      } @{$pileups{$trans->id}->{$_}} ],
    }
  } sort keys %{$pileups{$trans->id}} ];
  $ret;
};

get '/genes' => sub {
  my %filter = ();
  my @sort;
  my %comparisons = (rating => '>', id => 'like', description => 'like', 'best_homolog' => 'like', 'reviewed' => '=');
  for my $field (keys %comparisons) {
    if (exists params->{'filter.'.$field}) {
      my $s_field='me.'.$field;
      if ($comparisons{$field} eq 'like') { 
        params->{'filter.'.$field}='%'.lc(params->{'filter.'.$field}).'%'; 
        $s_field='LOWER('.$s_field.')';
      }
      $filter{$s_field} = { $comparisons{$field} => param('filter.'.$field) };
    }
  }
  for my $k (keys %{params()}) {
    if ($k=~ m/sort-(\d+)-(.+)/) {
      my $f='me.'.$2;
      $sort[$1]={ '-'.param($k) => $f };
    }
  }
  unless (scalar @sort) {
    @sort = ({ -asc => 'me.id' });
  }
  debug \@sort;
  debug \%filter;
  my $rs = schema->resultset('Gene')->search(\%filter, { 
    order_by => \@sort,
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
  my $rs = schema->resultset('Gene')->find(param('id')) || send_error 'not found', 404;
  my $upd = params('body');
  $rs->$_($upd->{$_}) for qw/description best_homolog rating reviewed/;
  my %new_tags = map { $_->{tag} => $_ } @{$upd->{tags}};
  for my $o ($rs->tags) {
    if ($new_tags{$o->tag}) {
      delete $new_tags{$o->tag};
    }
    else {
      $rs->remove_from_tags($o);
    }
  }
  for my $n (values %new_tags) {
    $rs->add_to_tags($n);
  }
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

get '/deruns/:id/contrasts/:contrast_id/results' => sub {
  my $de_run = schema->resultset('DeRun')->find(param 'id') || send_error 'no such de run', 404;
  my $is_gene = $de_run->count_table->aggregate_genes;
  my %filter = (de_run_id => param('id'), 'contrast_id' => param('contrast_id'));
  my @sort;
  my %comparisons = (base_mean => '>', adjp => '<', pvalue => '<', 'transcript_id' => 'like');
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
