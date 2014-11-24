package TearDrop::Controller::Project;
use Mojo::Base 'Mojolicious::Controller';

use warnings;
use strict;

our $VERSION='0.01';

sub list_project {
  my $self = shift;
  $self->render(json => [ $self->app->schema->resultset('Project')->all ]);

}

sub read_project {
  my $self = shift;

  my $p = $self->app->schema->resultset('Project')->find($self->param('projectId'));
  unless($p) {
    return $self->reply->not_found;
  }
  $self->render(json => $p);
}

sub chained {
  my $self = shift;

  my $projects = $self->app->cache->get('projects') || {};
  my $p = $projects->{$self->param('projectId')} ||
    $self->app->schema->resultset('Project')->find($self->param('projectId'));
  unless($p) {
    $self->reply->not_found;
    return 0;
  }
  $projects->{$self->param('projectId')}=$p;
  $self->app->cache->set(projects => $projects);
  $self->stash(project => $p);
  $self->app->log->debug('setting schema '.$p->name);
  my $project_schema = $self->app->schema($p->name);
  $self->app->log->debug($project_schema);
  unless($project_schema) {
    $self->reply->not_found;
    return 0;
  }
  $self->stash(project_schema => $self->app->schema($p->name));
  1;
}

1;
