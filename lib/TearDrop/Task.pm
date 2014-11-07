package TearDrop::Task;

use warnings;
use strict;

use Dancer qw/:moose !status/;
use Mouse;

use File::Temp ();

has 'result' => ( is => 'rw', isa => 'ArrayRef | Undef' );
has 'pid' => ( is => 'rw', isa => 'Int | Undef' );
has 'status' => ( is => 'rw', isa => 'Str | Undef' );

has tmpfile => ( is => 'rw', isa => 'File::Temp', default => sub {
  File::Temp->new;
});

1;
