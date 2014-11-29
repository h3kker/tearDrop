package TearDrop;
use Mojo::Base 'Mojolicious';

use Mojo::Cache;
use Mojo::Asset::File;

use File::Spec;
use Text::Markdown 'markdown';
use Module::Load;

# global worldwide universal access to config
# don't know how else to pass config to models?

sub new {
  my $self = shift->SUPER::new(@_);
}

sub init {
  my $self = shift;
  push @{$self->plugins->namespaces}, 'TearDrop::Plugin';
  push @{$self->commands->namespaces}, 'TearDrop::Command';
  $self->plugin('YamlConfig' => {
    file => 'config.yml',
    class => 'YAML',
  });
  $self->config->{alignments}{max_width}||=50000;
  $self->config->{alignments}{default_context}||=200;
  if($self->config->{log} && $self->config->{log}{path} && $self->config->{log}{path}=~m#^/#) {
    $self->config->{log}{path}=$self->home->rel_file($self->config->{log}{path});
  }
  $self->log(Mojo::Log->new(%{$self->config->{log}})) if $self->config->{log};

  $self->plugin('DBIxClass' => $self->config->{plugins}{DBIxClass});
  $self->setup_projects;
  $self->helper(cache => sub { state $cache = Mojo::Cache->new(max_keys => 50) });
  $self;
}

# This method will run once at server start
sub startup {
  my $self = shift;
  $self->secrets([$self->config->{session_name}]);
  $self->init;

  #$self->helper(config => sub { state $config = $self->stash('config') });

  unless ($self->can('worker')) {
    $self->attr(worker => sub {
      load $self->config->{working_class};
      my $worker = $self->config->{working_class}->new(app => $self);
      $worker->start_working;
      $worker;
    });
  }

  # XXX proper error handling!
  $self->hook('before_render' => sub {
    my ($c, $args)=@_;
    return unless my $template = $args->{template};
    return unless $template eq 'exception';
    if ($c->stash('exception')) {
      my $msg = $c->stash('exception')->message;
      $msg =~ s/ at \/.*//s;
      $args->{json} = {error => $msg || 'muh?', } # exception => $c->stash('exception')};
        #if $c->accepts('json');
    }
  });

  $self->helper('parse_query' => sub {
    my ($c, $class) = @_;
    return unless $c->can('resultset');
    $c->stash(filters => {}, sort => []);
    my $o = $c->stash('project_schema')->resultset($class || $c->resultset)->result_class->new;
    return unless $o->can('comparisons');
    my $comparisons = $o->comparisons;
    for my $field (keys %$comparisons) {
      my $fname = 'filter.'.$field;
      if (defined $c->param($fname)) {
        my $col = $comparisons->{$field}{column};
        if ($comparisons->{$field}{cmp} eq 'like') {
          $c->param($fname=>'%'.lc($c->param($fname)).'%');
          $col=sprintf 'LOWER(%s)' => $col;
        }
        if ($comparisons->{$field}{cmp} eq 'IN') {
          $c->stash('filters')->{$col} = $c->every_param($fname);
        }
        else {
          $c->stash('filters')->{$col} = { $comparisons->{$field}{cmp} => $c->param($fname) };
        }
      }
    }
    for my $k (grep { m#^sort-# } $c->req->param) {
      if ($k =~ m/sort-(\d+)-(.+)/) {
        my ($w, $f) = ($1, $2);
        $c->stash('sort')->[$w]={ '-'.$c->param($k) => $f =~ m#\.# ? $f : 'me.'.$f };
      }
    }
    if (defined $c->param('filter.log2_foldchange')) {
      $c->stash('filters')->{'log2_foldchange'} = [
        { '<', $c->param('filter.log2_foldchange')*-1 },
        { '>', $c->param('filter.log2_foldchange') },
      ];
    }
    $c->app->log->debug($c->dumper($c->stash('filters')));
    $c->app->log->debug($c->dumper($c->stash('sort')));
  });

  # Router
  my $base = $self->routes;
  $base->get('/', sub { my $c = shift; $c->render; } => 'index' );
  my $r = $base->under($self->config->{base_uri});


  $r->get('/', sub { 
    my $c = shift; 
    $c->render(template => 'teardrop/index') 
  });
  $r->get('/roadmap', sub {
    my $c = shift;
    my $todo = Mojo::Asset::File->new(path => $self->home->rel_file(File::Spec->catfile('doc', 'todo.md')))->slurp;
    $todo =~ s|DONE(.*)$|<span class="text-muted"><i class="fa fa-check-circle"></i>$1</span>|mg;
    $todo =~ s|XXX(.*)$|<span class="bg-danger"><i class="fa fa-fire text-danger"></i>$1</span>|mg;
    $c->stash('roadmap' => markdown($todo));
    $c->render(template => 'teardrop/roadmap');
  });

  my $api = $r->under('/api');

  $api->route('/projects')->via('get')->to('Project#list')->name('Project::list');
  $api->route('/projects/:projectId')->via('get')->to('Project#read')->name('Project::read');

  $api->route('/worker/status')->via('get')->to(cb => sub {
    my $c = shift;
    $c->render(json => $c->app->worker->status);
  })->name('Worker::status');
  $api->route('/worker/status/:job')->via('get')->to(cb => sub {
    my $c = shift;
    $c->render(json => $c->app->worker->job_status($c->param('job')));
  })->name('Worker::status(job)');

  $api->root->add_shortcut('project_bridge' => sub {
    my ($routes, %param) = @_;
    if ($param{parent}) {
      $param{url}=$param{parent}->parent->pattern->pattern.$param{url};
    }
    else {
      $param{url}='/projects/#projectId'.$param{url};
    }
    my %project_chain = (controller => 'Project', action => 'chained');
    $routes->bridge($param{url})->to(%project_chain)->name('Project::chained')
      ->route->via($param{method})->to(controller => $param{controller}, action => $param{action})
      ->name($param{controller}.'::'.$param{action});
  });

  $api->root->add_shortcut('project_resource' => sub {
    my ($routes, %param) = @_;
    my %collection_actions = (get => 'list', post => 'create');
    my %resource_actions = (get => 'read', post => 'update', delete => 'remove');
    my $return_route;
    for my $method (keys %collection_actions) {
      $routes->project_bridge(parent => $param{parent}, url => $param{url}, method => $method, controller => $param{controller}, action => ($param{action_prefix}||'').$collection_actions{$method});
    }
    for my $method (keys %resource_actions) {
      my $url = $param{url}.'/#'.lc($param{controller}).'Id';
      my $r = $routes->project_bridge(parent => $param{parent}, url => $url, method => $method, controller => $param{controller}, action => ($param{action_prefix}||'').$resource_actions{$method});
      $return_route = $r if $method eq 'get';
    }
    $return_route;
  });

  my $de_run = $api->project_resource(url => '/deruns', controller => 'DeRun');
    my $de_contrast = $api->project_resource(parent => $de_run, url => '/contrasts', controller => 'DeContrast');
    my $de_result = $api->project_bridge(parent => $de_contrast, url => '/results', method => 'get', controller => 'DeRun', action => 'results');
      $api->project_bridge(parent => $de_result, url => '/fasta', method => 'get', controller => 'DeRun', action => 'results_fasta');

  $api->project_bridge(url => '/transcripts/fasta', method => 'get', controller => 'Transcript', action => 'list_fasta');
  my $t = $api->project_resource(url => '/transcripts', controller => 'Transcript');
    $api->project_bridge(parent => $t, url => '/mappings', method => 'get', controller => 'Transcript' , action => 'mappings');
    $api->project_bridge(parent => $t, url => '/blast_results', method => 'get', controller => 'Transcript' , action => 'blast_results');
    $api->project_bridge(parent => $t, url => '/run_blast', method => 'get', controller => 'Transcript' , action => 'run_blast');
    $api->project_bridge(parent => $t, url => '/blast_runs', method => 'get', controller => 'Transcript' , action => 'blast_runs');
    $api->project_bridge(parent => $t, url => '/pileup', method => 'get', controller => 'Transcript' , action => 'pileup');

  $api->project_bridge(url => '/genes/fasta', method => 'get', controller => 'Gene', action => 'list_fasta');
  my $g = $api->project_resource(url => '/genes', controller => 'Gene');
    $api->project_bridge(parent => $g, url => '/fasta', method => 'get', controller => 'Gene', action => 'read_fasta');
    $api->project_bridge(parent => $g, url => '/mappings', method => 'get', controller => 'Gene', action => 'mappings');
    $api->project_bridge(parent => $g, url => '/blast_results', method => 'get', controller => 'Gene', action => 'blast_results');
    $api->project_bridge(parent => $g, url => '/run_blast', method => 'get', controller => 'Gene', action => 'run_blast');
    $api->project_bridge(parent => $g, url => '/blast_runs', method => 'get', controller => 'Gene', action => 'blast_runs');
    $api->project_bridge(parent => $g, url => '/msa', method => 'get', controller => 'Gene', action => 'transcript_msa');


  my $gm = $api->project_resource(url => '/genomemappings', controller => 'GenomeMapping');
    $api->project_bridge(parent => $gm, url => '/annotations', method => 'get', controller => 'GenomeMapping', action => 'annotations');
    $api->project_bridge(parent => $gm, url => '/pileup', method => 'get', controller => 'GenomeMapping', action => 'pileup');
  $api->project_resource(url => '/alignments', controller => 'Alignment');
  $api->project_bridge(url => '/assemblies/blast_results', method => 'get', controller => 'Assembly', action => 'blast_results');
  $api->project_bridge(url => '/assemblies/run_blast', method => 'get', controller => 'Assembly', action => 'run_blast');
  my $a = $api->project_resource(url => '/assemblies', controller => 'Assembly');
    $api->project_bridge(parent => $a, url => '/run_blast', method => 'get', controller => 'Assembly', action => 'run_blast');
    $api->project_bridge(parent => $a, url => '/blast_results', method => 'get', controller => 'Assembly', action => 'blast_results');
  $api->project_resource(url => '/conditions', controller => 'Condition');
  $api->project_resource(url => '/dbsources', controller => 'DbSource');
  $api->project_resource(url => '/genemodels', controller => 'GeneModel');
  $api->project_resource(url => '/organisms', controller => 'Organism');
  $api->project_resource(url => '/samples', controller => 'Sample');
  $api->project_resource(url => '/tags', controller => 'Tag');

  # auto page fallback
  $r->get('/*tpl', sub {
    my $c = shift;

    $self->log->debug('catchall: '.$c->req->url);
    my ($path, $file, $type) = @_;
    if ($c->req->url =~ m#/?(.*/)?(.+)\.(html|js)#) {
      ($path, $file, $type) = ($1, $2, $3);
    }
    else {
      return $c->reply->not_found;
    }
    $c->render(template => $path.$file, format=>$type);
  });
}

sub setup_projects {
  my $app = shift;
  for my $project ($app->schema->resultset('Project')->search) {
    my %conf = %{$app->config->{plugins}{DBIxClass}{default}};
    my $project_name=$project->name;
    # XXX needs database prefix config option!
    $conf{dsn}=~s/dbname=\w+;/dbname=teardrop_$project_name;/;
    $conf{schema_class}='TearDrop::Model';
    $app->config->{plugins}{DBIxClass}{$project_name}=\%conf;
  }
}

1;
