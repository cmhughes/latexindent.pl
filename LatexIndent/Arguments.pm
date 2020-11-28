package LatexIndent::Arguments;
use strict;
use warnings;

sub explain {
    my ($self, $level) = @_;
    ($self->{OptionalArgs} || $self->{MandatoryArgs} || $self->{Between} )->explain($level);
  }

sub indent {
    my $self = shift;
    ($self->{OptionalArgs} || $self->{MandatoryArgs} || $self->{Between} )->indent;
  }
1;
