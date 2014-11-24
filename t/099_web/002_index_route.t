use Mojo::Base -strict;
use Test::More;

use Test::Mojo;

### XXX read base_uri from config!
my $t = Test::Mojo->new('TearDrop');
$t->get_ok('/teardrop')->status_is(200)->content_like(qr/TearDrop/i);
done_testing();
