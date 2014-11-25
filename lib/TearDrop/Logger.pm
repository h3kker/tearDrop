package TearDrop::Logger;

use parent 'Exporter';

@EXPORT = qw/logger/;

use TearDrop;
use Mojo::Log;

my $logger_obj;

sub init {
  my $td = TearDrop->new;
  $td->init unless $td->can('worker');
  $logger_obj=$td->log;
}

sub logger {
  init() unless($logger);
  return $logger;
}

1;
