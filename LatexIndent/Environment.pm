# Environment.pm
#   creates a class for the Environment objects
#   which are a subclass of the Document object.
package LatexIndent::Environment;
use strict;
use warnings;
our @ISA = "LatexIndent::Document"; # class inheritance, Programming Perl, pg 321

sub indent{
    my $self = shift;
    # ${$self}{body} =~ s/\R*$//;        # remove line break(s) at end of body
    ${$self}{body} =~ s/^/****/mg;  # add indentation
    # ${$self}{begin} =~ s/\R*$//;       # remove line break(s) before body
    # ${$self}{body} =~ s/\R*//mg;       # remove line break(s) from body
    return $self;
}

1;
