package LatexIndent::HorizontalWhiteSpace;
#	This program is free software: you can redistribute it and/or modify
#	it under the terms of the GNU General Public License as published by
#	the Free Software Foundation, either version 3 of the License, or
#	(at your option) any later version.
#
#	This program is distributed in the hope that it will be useful,
#	but WITHOUT ANY WARRANTY; without even the implied warranty of
#	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#	GNU General Public License for more details.
#
#	See http://www.gnu.org/licenses/.
#
#	Chris Hughes, 2017
#
#	For all communication, please visit: https://github.com/cmhughes/latexindent.pl
use strict;
use warnings;
use LatexIndent::GetYamlSettings qw/%masterSettings/;
use LatexIndent::Switches qw/$is_t_switch_active $is_tt_switch_active/;
use Exporter qw/import/;
our @EXPORT_OK = qw/remove_trailing_whitespace remove_leading_space/;

sub remove_trailing_whitespace{
    my $self = shift;
    my %input = @_;

    # this method can be called before the indendation, and after, depending upon the input
    if($input{when} eq "before"){
        return unless(${$masterSettings{removeTrailingWhitespace}}{beforeProcessing});
        $self->logger("Removing trailing white space *before* the document is processed (see removeTrailingWhitespace: beforeProcessing)",'heading') if $is_t_switch_active;
    } elsif($input{when} eq "after"){
        return unless(${$masterSettings{removeTrailingWhitespace}}{afterProcessing});
        $self->logger("Removing trailing white space *after* the document is processed (see removeTrailingWhitespace: afterProcessing)",'heading') if $is_t_switch_active;
    } else {
        return;
    }

    ${$self}{body} =~ s/
                       \h+  # followed by possible horizontal space
                       $    # up to the end of a line
                       //xsmg;

    $self->logger("Processed body, *$input{when}* indentation (${$self}{name}):") if($is_t_switch_active);
    $self->logger(${$self}{body}) if($is_t_switch_active);

}

sub remove_leading_space{
    my $self = shift;
    $self->logger("Removing leading space from ${$self}{name} (verbatim/noindentblock already accounted for)",'heading') if $is_t_switch_active;
    ${$self}{body} =~ s/
                        (   
                            ^           # beginning of the line
                            \h*         # with 0 or more horizontal spaces
                        )?              # possibly
                        //mxg;
    return;
}


1;
