package LatexIndent::HorizontalWhiteSpace;
use strict;
use warnings;
use Exporter qw/import/;
our @EXPORT_OK = qw/remove_trailing_whitespace remove_leading_space/;

sub remove_trailing_whitespace{
    my $self = shift;
    my %input = @_;

    # grab the settings
    my %masterSettings = %{$self->get_master_settings};

    # this method can be called before the indendation, and after, depending upon the input
    if($input{when} eq "before"){
        return unless(${$masterSettings{removeTrailingWhitespace}}{beforeProcessing});
        $self->logger("Removing trailing white space *before* the document is processed (see removeTrailingWhitespace: beforeProcessing)",'heading');
    } elsif($input{when} eq "after"){
        return unless(${$masterSettings{removeTrailingWhitespace}}{afterProcessing});
        $self->logger("Removing trailing white space *after* the document is processed (see removeTrailingWhitespace: afterProcessing)",'heading');
    } else {
        return;
    }

    ${$self}{body} =~ s/
                       \h+  # followed by possible horizontal space
                       $    # up to the end of a line
                       //xsmg;

    $self->logger("Processed body, *$input{when}* indentation (${$self}{name}):",'trace');
    $self->logger(${$self}{body},'trace');

}

sub remove_leading_space{
    my $self = shift;
    $self->logger("Removing leading space from ${$self}{name} (verbatim/noindentblock already accounted for)",'heading');
    ${$self}{body} =~ s/
                        (   
                            ^           # beginning of the line
                            \h*         # with 0 or more horizontal spaces
                        )?              # possibly
                        //mxg;
    return;
}


1;
