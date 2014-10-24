package TearDrop;
use Dancer ':syntax';

use Dancer::Plugin::DBIC qw(schema resultset);

our $VERSION = '0.1';

get '/' => sub {
  schema->resultset('Sample');
  template 'index';
};

true;
