package LatexIndent::Arguments;
use strict;
use warnings;

sub explain {
    my ($self, $level) = @_;
    ($self->{OptionalArgs} || $self->{MandatoryArgs})->explain($level);
  }

sub indent {
    my $self = shift;
    ($self->{OptionalArgs} || $self->{MandatoryArgs})->indent;
  }
1;
