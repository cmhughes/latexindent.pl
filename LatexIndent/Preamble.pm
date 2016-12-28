# Preamble.pm
#   creates a class for the Preamble objects
#   which are a subclass of the Document object.
package LatexIndent::Preamble;
use strict;
use warnings;
our @ISA = "LatexIndent::Document"; # class inheritance, Programming Perl, pg 321
our $preambleCounter;

sub create_unique_id{
    my $self = shift;

    $preambleCounter++;
    ${$self}{id} = "${$self->get_tokens}{preamble}$preambleCounter${$self->get_tokens}{endOfToken}";
    return;
}

sub get_replacement_text{
    my $self = shift;

    # the replacement text for preamble needs to put the \\begin{document} back in
    $self->logger("Custom replacement text routine for preamble ${$self}{name}");
    ${$self}{replacementText} = ${$self}{id}.${$self}{afterbit};
    delete ${$self}{afterbit};
}

sub indent{
    # preamble doesn't receive any additional indentation
    return;
}

1;
