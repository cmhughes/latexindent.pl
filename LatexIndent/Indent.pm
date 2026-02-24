package LatexIndent::Indent;

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
use LatexIndent::Tokens          qw/%tokens/;
use LatexIndent::Switches        qw/$is_m_switch_active $is_t_switch_active $is_tt_switch_active/;
use LatexIndent::GetYamlSettings qw/%mainSettings/;
use LatexIndent::LogFile         qw/$logger/;
use Text::Tabs;
use Data::Dumper;
use Exporter qw/import/;
our @EXPORT_OK
    = qw/final_indentation_check/;

sub final_indentation_check {

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
