package TearDrop::Cmd;

use warnings;
use strict;

use Getopt::Long;

BEGIN {
  Getopt::Long::Configure('pass_through');
}

use Dancer ':script';

use TearDrop; # initialize

1;
