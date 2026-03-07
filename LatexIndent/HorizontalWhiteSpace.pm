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
#	Chris Hughes, 2017-2025
#
#	For all communication, please visit: https://github.com/cmhughes/latexindent.pl
use strict;
use warnings;
use LatexIndent::GetYamlSettings qw/%mainSettings/;
use LatexIndent::Switches        qw/$is_t_switch_active $is_tt_switch_active/;
use LatexIndent::LogFile         qw/$logger/;
use Text::Tabs;
use Exporter qw/import/;
use Data::Dumper;
our @EXPORT_OK = qw/remove_trailing_whitespace remove_leading_space max_indentation_check /;

sub remove_trailing_whitespace {
    my $self  = shift;
    my %input = @_;

    # removeTrailingWhitespace can be either a hash or a scalar, but if
    # it's a scalar, we need to fix it
    if ( ref( $mainSettings{removeTrailingWhitespace} ) ne 'HASH' ) {
        $logger->trace("removeTrailingWhitespace specified as scalar, will update it to be a hash")
            if $is_t_switch_active;

        # grab the value
        my $removeTWS = $mainSettings{removeTrailingWhitespace};

        # delete the scalar
        delete $mainSettings{removeTrailingWhitespace};

        # redefine it as a hash
        ${ $mainSettings{removeTrailingWhitespace} }{beforeProcessing} = $removeTWS;
        ${ $mainSettings{removeTrailingWhitespace} }{afterProcessing}  = $removeTWS;

        $logger->trace("*removeTrailingWhitespace setting defaults routine")           if $is_t_switch_active;
        $logger->trace("removeTrailingWhitespace: beforeProcessing is now $removeTWS") if $is_t_switch_active;
        $logger->trace("removeTrailingWhitespace: afterProcessing is now $removeTWS")  if $is_t_switch_active;
    }

    # this method can be called before the indentation, and after, depending upon the input
    if ( $input{when} eq "before" ) {
        return unless ( ${ $mainSettings{removeTrailingWhitespace} }{beforeProcessing} );
        $logger->trace(
            "*Removing trailing white space *before* the document is processed (removeTrailingWhitespace: beforeProcessing == 1)"
        ) if $is_t_switch_active;
    }
    elsif ( $input{when} eq "after" ) {
        return unless ( ${ $mainSettings{removeTrailingWhitespace} }{afterProcessing} );
        if ($is_t_switch_active) {
            $logger->trace(
                "*Removing trailing white space *after* the document is processed (removeTrailingWhitespace: afterProcessing == 1)"
            );
            $logger->trace( Dumper( \%{ $mainSettings{removeTrailingWhitespace} } ) );
        }
    }
    else {
        return;
    }

    ${$self}{body} =~ s/
                       \h+  # followed by possible horizontal space
                       $    # up to the end of a line
                       //xsmg;

}

sub remove_leading_space {
    my $self = shift;
    $logger->trace("*Removing leading space from ${$self}{name} (verbatim/noindentblock already accounted for)")
        if $is_t_switch_active;
    ${$self}{body} =~ s/
                        (   
                            ^           # beginning of the line
                            \h*         # with 0 or more horizontal spaces
                        )?              # possibly
                        //mxg;
    return;
}

sub max_indentation_check {

    # problem:
    #       if a tab is appended to spaces, it will look different
    #       from spaces appended to tabs (see test-cases/items/spaces-and-tabs.tex)
    # solution:
    #       move all of the tabs to the beginning of ${$self}{indentation}
    # notes;
    #       this came to light when studying test-cases/items/items1.tex

    my $self = shift;

    my $indentation;
    my $numberOfTABS;
    my $after;
    $logger->trace("*Tab indentation work") if ($is_tt_switch_active);
    ${$self}{body} =~ s/
                        ^((\h*|\t*)((\h+)(\t+))+)
                        /   
                        # fix the indentation
                        $indentation = $1;

                        # count the number of tabs
                        $numberOfTABS = () = $indentation=~ \/\t\/g;
                        $logger->trace("Number of tabs: $numberOfTABS") if($is_tt_switch_active);

                        # log the after
                        ($after = $indentation) =~ s|\t||g;
                        $after = "TAB"x$numberOfTABS.$after;
                        $logger->trace("Indentation after: '$after'") if($is_tt_switch_active);
                        ($indentation = $after) =~s|TAB|\t|g;

                        $indentation;
                       /xsmeg;

    return unless ( $mainSettings{maximumIndentation} =~ m/^\h+$/ );

    # maximum indentation check
    $logger->trace("*Maximum indentation check") if ($is_t_switch_active);

    # replace any leading tabs with spaces, and update the body
    my @expanded_lines = expand( ${$self}{body} );
    ${$self}{body} = join( "", @expanded_lines );

    # grab the maximum indentation
    my $maximumIndentation       = $mainSettings{maximumIndentation};
    my $maximumIndentationLength = length($maximumIndentation) + 1;

    # replace any leading space that is greater than the
    # specified maximum indentation with the maximum indentation
    ${$self}{body} =~ s/^\h{$maximumIndentationLength,}/$maximumIndentation/smg;
}
1;
