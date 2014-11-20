package TearDrop::Util::Pod::Markdown;

use strict;
use warnings;

use Pod::Markdown;

use Moo;
extends 'Pod::Markdown';


before format_perldoc_url => sub {
  my ($self, $name, $section) = @_;
  $self->_private->{orig_perldoc_url_prefix}||=$self->perldoc_url_prefix;

  if ($name && $name=~m#^TearDrop#) {
    $_[1]=~s#::#/#g;
    $_[1].='.md';
    $self->_private->{perldoc_url_prefix}='https://github.com/h3kker/tearDrop/blob/master/doc/pod/';
  }
  else {
    $self->_private->{perldoc_url_prefix}=$self->_private->{orig_perldoc_url_prefix};
  }
};

1;
