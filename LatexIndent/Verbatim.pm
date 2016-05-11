# Verbatim.pm
#   creates a class for the Verbatim objects
#   which are a subclass of the Document object.
package LatexIndent::Verbatim;
use strict;
use warnings;
our @ISA = "LatexIndent::Document"; # class inheritance, Programming Perl, pg 321

sub indent{
    my $self = shift;
    $self->logger("in verbatim environment ${$self}{name}, not indenting");
    return;
}

1;
