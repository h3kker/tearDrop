package TearDrop::Command::deploy_project;

use 5.12.0;

use Mojo::Base 'Mojolicious::Command';

use Carp;
use Try::Tiny;

use Getopt::Long qw/GetOptionsFromArray :config no_auto_abbrev no_ignore_case/;

has description => 'Deploy Project';
has usage => sub { shift->extract_usage };

sub run {
  my ($self, @args) = @_;

  my %opt = ( project => undef, overwrite => 0, create => 0 );

  GetOptionsFromArray(\@args, \%opt, 'project|p=s', 'create|c', 'overwrite|o', 'status|s=s',
    'title|t=s', 'description|d=s', 'group|g=s', 'help|h') or croak $self->help;

  if ($opt{help}) {
    print $self->help;
    return;
  }

  croak 'need project name!' unless $opt{project};

  my $p;
  if ($opt{create}) {
    croak "need title and group for new project!" unless $opt{title} && $opt{group};

    $p = $self->app->schema->resultset('Project')->create({
      name => $opt{project},
      title => $opt{title},
      description => $opt{description},
      forskalle_group => $opt{group},
      status => 'setup',
    });
    say "Project entry created.";
    $self->app->setup_projects;

  }
  else {
    $p = $self->app->schema->resultset('Project')->find($opt{project}) || croak "No such project: ".$opt{project}."!";
    say "Project read from master.";
  }
  if ($p->status eq 'done' || $p->status eq 'active') {
    croak "Project ".$p->name." is ".$p->status.", won't touch it.";
  }

  if ($opt{status}) {
    $p->status($opt{status});
    $p->update;
    say "Status updated. Ciao!";
    return;
  }
  my $trans_test;
  try {
    $self->app->schema($opt{project})->resultset('Transcript')->first;
    $trans_test=1;
  } catch {
    if ($_ =~ m#DBI connect.*failed#) {
      say "Create database...";
      $self->app->create_project_db(\%opt);
    }
    else {
      croak $_;
    }
  };
  if (!$opt{overwrite} && $trans_test) {
    say "Schema seems to be deployed already, quitting.";
    return;
  }
  say "Create database schema...";
  $self->app->schema($opt{project})->deploy({ add_drop_table => 1 });

  say "Populate tables from templates...";
  for my $tbl (qw/Organism GeneModel DbSource Tag/) {
    $self->app->schema($opt{project})->resultset($tbl)->populate([
      $self->app->schema->resultset($tbl)->search({}, {
        result_class => 'DBIx::Class::ResultClass::HashRefInflator',
      })
    ]);
  }
  $p->status('import');
  $p->update;
}

1;

=pod

=head1 NAME

TearDrop::Command::deploy_project - manage projects

=head1 SYNOPSIS

  Usage: tear_drop deploy_project [OPTIONS]

  Required Options:
  -p, --project [project]
      Name of the project

  Optional:
  -c, --create
      create project in master database
  -o, --overwrite 
      drop tables before creating
  -s, --status [status]
      set project status and quit

  -t, --title [title]
      title (display name) for new project
  -d, --description [description]
      Description text for new project
  -g, --group [group]
      Group name, owner of new project

  -h, --help
      This message

=head1 DESCRIPTION

=cut

