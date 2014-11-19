use Dancer::Test;
use Test::More tests => 2;
use strict;
use warnings;

use TearDrop;

### XXX read base_uri from config!
route_exists [GET => '/teardrop'], 'a route handler is defined for /';
response_status_is ['GET' => '/teardrop'], 200, 'response status is 200 for /';
