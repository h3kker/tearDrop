package TearDrop::Logger;

use parent 'Exporter';

@EXPORT = qw/log/;

use Mojo::Log;

my $logger;

sub init {
  if ($TearDrop::config) {
    $logger = Mojo::Log->new(%{$TearDrop::config->{log}});
  }
  else {
    #$logger = bless {}, 'TearDrop::Logger';
    $logger = Mojo::Log->new();
  }
}

sub log {
  init() unless($logger);
  return $logger;
}

sub debug {}
sub info {}
sub warn {}
sub error {}
sub fatal {}

1;
