package TearDrop::Plugin::DBIxClass;
use warnings;
use strict;

use Mojo::Base 'Mojolicious::Plugin';
use Mojo::Util qw(camelize);
use Module::Load;
use Carp;
use Try::Tiny;

our $VERSION = '0.01';

#some known good defaults
my $COMMON_ATTRIBUTES = {
  RaiseError => 1,
  AutoCommit => 1,
};

has config => sub { {} };
has schemas => sub { {} };

sub register {
my ($self, $app, $config) = @_;
  
  $self->config($config || {});

  my $helper_builder = sub {
    my ($app, $name) = @_;
    $app = $app->can('app') ? $app->app : $app;
    my $cfg=$self->config;
    if (not defined $name) {
      if (keys %$cfg == 1) {
        ($name) = keys %$cfg;
      }
      elsif (keys %$cfg) {
        $name = 'default';
      }
      else {
        croak 'No schemas are configured';
      }
    }

    return $self->schemas->{$name} if $self->schemas->{$name};
    $app->log->debug('loading schema '.$name);
    $app->log->debug("configured schemas: ".join ",", keys %{$self->schemas});

    my $options = $cfg->{$name} or croak "The schema $name is not configured";
    if (my $alias = $options->{alias}) {
      $options = $cfg->{$alias} or croak "The schema alias $alias does not exist in the config";
      return $self->schemas->{$alias} if $self->schemas->{$alias};
    }
    my @conn_info = $options->{connect_info} ? @{$options->{connect_info}}
      : @$options{qw/dsn user password options/};
    # extend connection info hash with some default values
    $conn_info[$#conn_info] =  
      {%$COMMON_ATTRIBUTES, %{$conn_info[$#conn_info]}}, 
    
    my $schema;
    if (my $schema_class = $options->{schema_class}) {
      $schema_class = camelize $schema_class;
      try {
        load $schema_class;
      } catch {
        croak 'Could not load schema_class '.$schema_class.': '.$_;
      };
      if (my $replicated = $options->{replicated}) {
        $schema = $schema_class->clone;
        my %storage_options;
        my @params = qw/balancer_type balancer_args pool_type pool_args/;
        for my $p (@params) {
          my $value = $replicated->{$p};
          $storage_options{$p} = $value if defined $value;
        }
        $schema->storage_type(['::DBI::Replicated', \%storage_options ]);
        $schema->connection(@conn_info);
        $schema->storage->connect_replicants(@{$replicated->{replicants}});
      }
      else {
        $schema = $schema_class->connect(@conn_info);
      }
    }
    else {
      my $dbic_loader = 'DBIx::Class::Schema::Loader';
      try {
        load $dbic_loader;
      } catch {
        croak "You must provide a schema_class option or install $dbic_loader";
      };
      $dbic_loader->naming($options->{schema_loader_naming} || 'v7');
      $schema = DBIx::Class::Schema::Loader->connect(@conn_info);
    }

    return $self->schemas->{$name} = $schema;
  };

  #$app->attr('schema', sub { $app->log->debug('here'); $helper_builder->(@_) });
  $app->helper('schema', $helper_builder);

}

1;

=pod

=encoding utf8

=head1 NAME

Teardrop::Plugin::DBIxClass - use DBIx::Class in your application.

=head1 SYNOPSIS

  #load
  # Mojolicious
  push @{$app->plugins->namespaces}, 'TearDrop::Plugin';
  $self->plugin('DBIxClass', $config);

  $self->schema('default')->resultset('User')->find(1234);
  
  
=head1 DESCRIPTION

Mojolicious::Plugin::DBIxClass is a L<Mojolicious> plugin that helps you
use L<DBIx::Class> in your application.
It also adds a helper (C<$app-E<gt>schema> by default) which is 
a L<DBIx::Class::Schema> instance.

It's a shameless rip-off from L<Dancer::Plugin::DBIC>.

=head1 SEE ALSO

L<Dancer::Plugin::DBIC>, L<DBIx::Class>, L<Mojolicious>, L<Mojolicious::Guides>, L<http://mojolicio.us>.

=cut

