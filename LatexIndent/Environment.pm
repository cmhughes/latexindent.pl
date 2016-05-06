# Environment.pm
#   creates a class for the Environment objects
#   which are a subclass of the Document object.
package LatexIndent::Environment;
use strict;
use warnings;
our @ISA = "LatexIndent::Document"; # class inheritance, Programming Perl, pg 321

sub indent{
    my $self = shift;
    my $previousIndent = shift;
    print "indenting ENVIRONMENT ${$self}{name}\n";
    print "indentation of object: '",${$self}{indent},"'\n";
    print "indentation before object: '",$previousIndent,"'\n";
    print "total indentation to be added: '",$previousIndent.${$self}{indent},"'\n";
    my $indent = $previousIndent.${$self}{indent};
    #print "begin:\n",${$self}{begin},"\n";
    #print "end:\n",${$self}{end},"\n";

    # ${$self}{body} =~ s/\R*$//;        # remove line break(s) at end of body
    ${$self}{body} =~ s/(^)/$indent/mg;  # add indentation
    ${$self}{end} =~ s/(^)/$previousIndent/mg;  # add indentation
    #print "body:\n",${$self}{body},"\n";
    # ${$self}{begin} =~ s/\R*$//;       # remove line break(s) before body
    # ${$self}{body} =~ s/\R*//mg;       # remove line break(s) from body
    return $self;
}

1;
