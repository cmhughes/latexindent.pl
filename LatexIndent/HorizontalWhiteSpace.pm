package LatexIndent::HorizontalWhiteSpace;
use strict;
use warnings;
use Exporter qw/import/;
our @EXPORT_OK = qw/remove_trailing_whitespace remove_leading_space/;

sub remove_trailing_whitespace{
    my $self = shift;
    return unless(${%{$self}{settings}}{removeTrailingWhitespace});

    $self->logger("Removing trailing white space");
    ${$self}{body} =~ s/
                       \h+  # followed by possible horizontal space
                       $    # up to the end of a line
                       //xsmg;

}

sub remove_leading_space{
    my $self = shift;
    $self->logger("Removing leading space from entire document (verbatim/noindentblock already accounted for)",'heading');
    ${$self}{body} =~ s/
                        (   
                            ^           # beginning of the line
                            \h*         # with 0 or more horizontal spaces
                        )?              # possibly
                        //mxg;
    return;
}


1;
