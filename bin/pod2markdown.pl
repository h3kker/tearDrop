#!/usr/bin/env perl

use warnings;
use strict;

use Dancer ':script';
use TearDrop::Util::Pod::Markdown;
use File::Find;
use File::Path 'make_path';
use File::Basename;
use Cwd;
use File::Spec;

my $markdown;

my $curwd=cwd;
my $base = File::Spec->catdir('doc','pod');

find(sub {
  return unless m#\.pm$#;
  my $out_name = $File::Find::name;
  $out_name =~ s#^lib(\b)#$base$1#;
  $out_name =~ s#\.pm$#.md#;
  $out_name = File::Spec->catfile($curwd,$out_name);
  my $markdown;
  my $parser = TearDrop::Util::Pod::Markdown->new;
  $parser->output_string($markdown);
  $parser->parse_file($_);
  warn length($markdown);
  if ($markdown && $markdown !~ m#^\s+$#m) {
    make_path(dirname $out_name);
    open POD, ">$out_name" || die "open $out_name: $!";
    print POD $markdown;
    close POD;
  }

}, 'lib/');

