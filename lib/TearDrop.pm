package TearDrop;
use Mojo::Base 'Mojolicious';

use Mojo::Cache;
use Mojo::Asset::File;
use File::Spec;
use Text::Markdown 'markdown';

# This method will run once at server start
sub startup {
  my $self = shift;

  push @{$self->plugins->namespaces}, 'TearDrop::Plugin';

  $self->plugin('YamlConfig' => {
    file => 'config.yml',
    class => 'YAML',
  });
  #$self->helper(config => sub { state $config = $self->stash('config') });
  $self->helper(cache => sub { state $cache = Mojo::Cache->new(max_keys => 50) });
  $self->secrets([$self->config->{session_name}]);

  $self->plugin('DBIxClass' => $self->config->{plugins}{DBIxClass});
  $self->setup_projects;

  $self->hook('before_render' => sub {
    my ($c, $args)=@_;
    return unless my $template = $args->{template};
    return unless $template eq 'exception' || $template eq 'not_found';
    #$self->log->error($self->dumper($c->stash('exception')));
    $args->{json} = {error => 'muh', exception => $c->stash('exception')};
      #if $c->accepts('json');
  });
  $self->hook('before_dispatch' => sub {
    my $c = shift;
    return unless $c->can('resultset');
    $c->stash(filters => {}, sort => []);
    my $o = $c->app->project_schema->resultset($c->resultset)->result_class->new;
    return unless $o->can('comparisons');
    my $comparisons = $o->comparisons;
    for my $field (keys %$comparisons) {
      my $fname = 'filter.'.$field;
      if (defined $c->param($fname)) {
        my $col = $comparisons->{$field}{column};
        if ($comparisons->{$field}{cmp} eq 'like') {
          $c->param($fname)='%'.lc($c->param($fname)).'%';
          $col=sprintf 'LOWER(%s)' => $col;
        }
        if ($comparisons->{$field}{cmp} eq 'IN') {
          $c->stash('filters')->{$col} = $c->every_param($fname);
        }
        else {
          $c->stash('filters')->{$col} = { $comparisons->{$field}{cmp} => $c->param($fname) };
        }
      }
      for my $k ($c->req->params) {
        if ($k =~ m/sort-(\d+)-(.+)/) {
          my ($w, $f) = ($1, $2);
          $c->stash('sort')->[$w]={ '-'.$c->param($k) => $f =~ m#\.# ? $f : 'me.'.$f };
        }
      }
    }
    if (defined $c->param('filter.log2_foldchange')) {
      $c->stash('filters')->{'log2_foldchange'} = [
        { '<', $c->param('filter.log2_foldchange')*-1 },
        { '>', $c->param('filter.log2_foldchange') },
      ];
    }
    $c->log->debug($c->dumper($c->stash('filters')));
    $c->log->debug($c->dumper($c->stash('sort')));
  });

  # angular used POST instead of PUT for updates
  $self->plugin('REST' => { prefix => 'api', htt2crud => {
      collection => { get => 'list', post => 'create' },
      resource => { 'get' => 'read', post => 'update', delete => 'delete' },
    }, hook => 0
  });

  # Router
  my $base = $self->routes;
  $base->get('/', sub { my $c = shift; $c->render; } => 'index' );
  my $r = $base->under($self->config->{base_uri});

  # Normal route to controller
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

  $r->rest_routes(name => 'Project');

  $r->rest_routes(name => 'DeRun', under => 'Project');
  $r->rest_routes(name => 'Contrast', under => 'DeRun');
  $r->rest_routes(name => 'Result', under => 'Contrast');
  $r->rest_routes(name => 'Gene', under => 'Project');
  $r->rest_routes(name => 'Transcript', under => 'Project');

  $r->rest_routes(name => 'Alignment', under => 'Project');
  $r->rest_routes(name => 'Assembly', under => 'Project');
  $r->rest_routes(name => 'Condition', under => 'Project');
  $r->rest_routes(name => 'DbSource', under => 'Project');
  $r->rest_routes(name => 'GeneModel', under => 'Project');
  $r->rest_routes(name => 'Organism', under => 'Project');
  $r->rest_routes(name => 'Sample', under => 'Project');
  $r->rest_routes(name => 'Tag', under => 'Project');

  # auto page fallback
  $r->get('/*tpl', sub {
    my $c = shift;

    $self->log->debug($c->req->url);
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
