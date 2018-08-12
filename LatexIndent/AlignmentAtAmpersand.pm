package LatexIndent::AlignmentAtAmpersand;
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
use utf8;
use Unicode::GCString;
use Data::Dumper;
use Exporter qw/import/;
use List::Util qw(max);
use LatexIndent::TrailingComments qw/$trailingCommentRegExp/;
use LatexIndent::Switches qw/$is_t_switch_active $is_tt_switch_active/;
use LatexIndent::GetYamlSettings qw/%masterSettings/;
use LatexIndent::Tokens qw/%tokens/;
use LatexIndent::LogFile qw/$logger/;
our @ISA = "LatexIndent::Document"; # class inheritance, Programming Perl, pg 321
our @EXPORT_OK = qw/align_at_ampersand find_aligned_block/;
our $alignmentBlockCounter;

sub find_aligned_block{
    my $self = shift;

    return unless (${$self}{body} =~ m/(?!<\\)%\*\h*\\begin\{/s);

    # aligned block
	#      %* \begin{tabular}
	#         1 & 2 & 3 & 4 \\
	#         5 &   & 6 &   \\
	#        %* \end{tabular}
    $logger->trace('*Searching for ALIGNED blocks marked by comments')if($is_t_switch_active);
    $logger->trace(Dumper(\%{$masterSettings{lookForAlignDelims}})) if($is_tt_switch_active);
    while( my ($alignmentBlock,$yesno)= each %{$masterSettings{lookForAlignDelims}}){
        if(ref $yesno eq "HASH"){
              $yesno = (defined ${$yesno}{delims} ) ? ${$yesno}{delims} : 1;
            }
        if($yesno){
            $logger->trace("looking for %*\\begin\{$alignmentBlock\} environments");

            my $alignmentRegExp = qr/
                            (
                                (?!<\\)
                                %
                                \*
                                \h*                     # possible horizontal spaces
                                \\begin\{
                                        $alignmentBlock  # environment name captured into $2
                                       \}               # %* \begin{alignmentBlock} statement
                            )
                            (
                                .*?
                            )
                            \R
                            \h*
                            (
                                (?!<\\)
                                %\*                     # %
                                \h*                     # possible horizontal spaces
                                \\end\{$alignmentBlock\} # \end{alignmentBlock}
                            )                           # %* \end{<something>} statement
                            #\R
                        /sx;

            while( ${$self}{body} =~ m/$alignmentRegExp/sx){

              ${$self}{body} =~ s/
                                    $alignmentRegExp
                                /
                                    # create a new Environment object
                                    my $alignmentBlockObj = LatexIndent::AlignmentAtAmpersand->new( begin=>$1,
                                                                          body=>$2,
                                                                          end=>$3,
                                                                          name=>$alignmentBlock,
                                                                          modifyLineBreaksYamlName=>"environments",
                                                                          linebreaksAtEnd=>{
                                                                            begin=>1,
                                                                            body=>1,
                                                                            end=>0,
                                                                          },
                                                                          );
            
                                    # log file output
                                    $logger->trace("*Alignment block found: %*\\begin\{$alignmentBlock\}") if $is_t_switch_active;

                                    # the settings and storage of most objects has a lot in common
                                    $self->get_settings_and_store_new_object($alignmentBlockObj);
                                    
                                    ${@{${$self}{children}}[-1]}{replacementText};
                              /xseg;
            } 
      } else {
            $logger->trace("*not* looking for $alignmentBlock as $alignmentBlock:$yesno");
      }
    }
    return;
}

sub yaml_modify_line_breaks_settings{
    return;
}

sub tasks_particular_to_each_object{
    return;
}

sub create_unique_id{
    my $self = shift;

    $alignmentBlockCounter++;
    ${$self}{id} = "$tokens{alignmentBlock}$alignmentBlockCounter";
    return;
}

sub align_at_ampersand{
    my $self = shift;
    return if(${$self}{bodyLineBreaks}==0);

    # calculate the maximum number of ampersands in a row in the body
    my $maximumNumberOfAmpersands = 0;
    foreach(split("\n",${$self}{body})){
        my $numberOfAmpersands = () = $_ =~ /(?<!\\)&/g;
        $maximumNumberOfAmpersands = $numberOfAmpersands if($numberOfAmpersands>$maximumNumberOfAmpersands);
    }

    # create an array of zeros
    my @maximumColumnWidth = (0) x ($maximumNumberOfAmpersands+1); 
    my @maximumColumnWidthMC = (0) x ($maximumNumberOfAmpersands+1); 

    # array for the new body
    my @formattedBody;

    # now loop back through the body, and store the maximum column size
    foreach(split("\n",${$self}{body})){
        # remove \\ and anything following it
        my $endPiece;
        if($_ =~ m/(\\\\.*)/){
            $_ =~ s/(\\\\.*)//;
            $endPiece = $1;
        }

        # remove any trailing comments
        my $trailingComments;
        if($_ =~ m/$trailingCommentRegExp/ ){
            $_ =~ s/($trailingCommentRegExp)//;
            $trailingComments = $1; 
        }

        # count the number of ampersands in the current row
        my $numberOfAmpersands = () = $_ =~ /(?<!\\)&/g;

        # switch for multiColumGrouping
        my $multiColumnGrouping = ($_ =~ m/\\multicolumn/ and ${$self}{multiColumnGrouping});
        my $alignRowsWithoutMaxDelims = ${$self}{alignRowsWithoutMaxDelims};

        # by default, the stripped row is simply the current row
        my $strippedRow = $_;

        # loop through the columns
        my $columnCount = 0;

        # format switch off by default
        my $formatRow = 0;

        # store the column sizes for measuring and comparison purposes
        my @columnSizes = ();

        # we will store the columns in each row
        my @columns;

        # need to have at least one ampersand, or contain a \multicolumn command
        if( ($_ =~ m/(?<!\\)&/ and ( ($numberOfAmpersands == $maximumNumberOfAmpersands)||$multiColumnGrouping||$alignRowsWithoutMaxDelims ) )
                                                or
                            ($multiColumnGrouping and $alignRowsWithoutMaxDelims) ){
            # remove space at the beginning of a row, surrounding &, and at the end of the row
            $_ =~ s/(?<!\\)\h*(?<!\\)&\h*/&/g;
            $_ =~ s/^\h*//g;
            $_ =~ s/\h*$//g;

            # if the line finishes with an &, then add an empty space,
            # otherwise the column count is off
            $_ .= ($_ =~ m/(?<!\\)&$/ ? " ":q());

            # store the columns, which are either split by & 
            # or otherwise simply the current line, if for example, the current line simply
            # contains \multicolumn{8}... \\  (see test-cases/texexchange/366841-zarko.tex, for example)
            @columns = ($_ =~ m/(?<!\\)&/ ? split(/(?<!\\)&/,$_) : $_);

            # empty the white-space-stripped row
            $strippedRow = '';
            foreach my $column (@columns){
                # if a column has finished with a \ then we need to add a trailing space, 
                # otherwise the \ can be put next to &. See test-cases/texexchange/112343-gonzalo for example
                $column .= ($column =~ m/\\$/ ? " ": q());

                # store the column size
                # reference: http://www.perl.com/pub/2012/05/perlunicook-unicode-column-width-for-printing.html
                my $gcs  = Unicode::GCString->new($column);
                my $columnWidth = $gcs->columns();

                # multicolumn cells need a bit of special care
                if($multiColumnGrouping and $column =~ m/\\multicolumn\{(\d+)\}/ and $1>1){
                    $maximumColumnWidthMC[$columnCount] = $columnWidth if( defined $maximumColumnWidthMC[$columnCount] and ($columnWidth > $maximumColumnWidthMC[$columnCount]) );
                    $columnWidth = 1 if($multiColumnGrouping and ($column =~ m/\\multicolumn\{(\d+)\}/));
                }

                # store the maximum column width
                $maximumColumnWidth[$columnCount] = $columnWidth if( defined $maximumColumnWidth[$columnCount] and ($columnWidth > $maximumColumnWidth[$columnCount]) );

                # put the row back together, using " " if the column is empty
                $strippedRow .= ($columnCount>0 ? "&" : q() ).($columnWidth > 0 ? $column: " ");

                # store the column width
                $columnSizes[$columnCount] = $columnWidth; 

                # move on to the next column
                if($multiColumnGrouping and ($column =~ m/\\multicolumn\{(\d+)\}/)){
                    # columns that are within the multiCol statement receive a width of -1
                    for my $i (($columnCount+1)..($columnCount+$1)){
                        $columnSizes[$i] = -1; 
                    }
                    # update the columnCount to account for the multiColSpan
                    $columnCount += $1; 
                } else {
                    $columnCount++;
                }
            }

            # toggle the formatting switch
            $formatRow = 1;
        } elsif($endPiece and ${$self}{alignDoubleBackSlash}){
            # otherwise a row could contain no ampersands, but would still desire
            # the \\ to be aligned, see test-cases/alignment/multicol-no-ampersands.tex
            @columns = $_;
            $formatRow = 1;
        }

        # store the information
        push(@formattedBody,{
                            row=>$strippedRow,
                            format=>$formatRow,
                            multiColumnGrouping=>$multiColumnGrouping,
                            columnSizes=>\@columnSizes,
                            columns=>\@columns,
                            endPiece=>($endPiece ? $endPiece :q() ),
                            trailingComment=>($trailingComments ? $trailingComments :q() )});
    }

    # output some of the info so far to the log file
    $logger->trace("*Alignment at ampersand routine") if $is_t_switch_active;
    $logger->trace("Maximum column sizes of horizontally stripped formatted block (${$self}{name}): @maximumColumnWidth") if $is_t_switch_active;
    $logger->trace("align at ampersand: ${$self}{lookForAlignDelims}") if $is_t_switch_active;
    $logger->trace("align at \\\\: ${$self}{alignDoubleBackSlash}") if $is_t_switch_active;
    $logger->trace("spaces before \\\\: ${$self}{spacesBeforeDoubleBackSlash}") if $is_t_switch_active;
    $logger->trace("multi column grouping: ${$self}{multiColumnGrouping}") if $is_t_switch_active;
    $logger->trace("align rows without maximum delimeters: ${$self}{alignRowsWithoutMaxDelims}") if $is_t_switch_active;
    $logger->trace("spaces before ampersand: ${$self}{spacesBeforeAmpersand}") if $is_t_switch_active;
    $logger->trace("spaces after ampersand: ${$self}{spacesAfterAmpersand}") if $is_t_switch_active;
    $logger->trace("justification: ${$self}{justification}") if $is_t_switch_active;

    # acount for multicolumn grouping, if the appropriate switch is set
    if(${$self}{multiColumnGrouping}){
        foreach(@formattedBody){
            if(${$_}{format} and ${$_}{row} !~ m/^\h*$/){

                # set a columnCount, which will vary depending on multiColumnGrouping settings or not
                my $columnCount=0;

                # loop through the columns
                foreach my $column (@{${$_}{columns}}){
                    # calculate the width of the current column 
                    my $gcs  = Unicode::GCString->new($column);
                    my $columnWidth = $gcs->columns();

                    # check for multiColumnGrouping
                    if(${$_}{multiColumnGrouping} and $column =~ m/\\multicolumn\{(\d+)\}/ and $1>1){
                        my $multiColSpan = $1;

                        # for example, \multicolumn{3}{c}{<stuff>} spans 3 columns, so 
                        # the maximum column needs to account for this (subtract 1 because of 0 index in perl arrays)
                        my $columnMax = $columnCount+$multiColSpan-1;

                        # groupingWidth contains the total width of column sizes grouped 
                        # underneath the \multicolumn{} statement
                        my $groupingWidth = 0;
                        my $maxGroupingWidth = 0;
                        foreach (@formattedBody){
                           $groupingWidth = 0;

                            # loop through the columns covered by the multicolumn statement
                            foreach my $j ($columnCount..$columnMax){
                                if(  defined @{${$_}{columnSizes}}[$j] 
                                             and 
                                     @{${$_}{columnSizes}}[$j] >= 0
                                             and
                                         ${$_}{format} 
                                          ){
                                    $groupingWidth += (defined $maximumColumnWidth[$j] ? $maximumColumnWidth[$j] : 0); 
                                } else {
                                    $groupingWidth = 0;
                                }
                            }

                            # update the maximum grouping width
                            $maxGroupingWidth = $groupingWidth if($groupingWidth > $maxGroupingWidth);

                            # the cells that receive multicolumn grouping need extra padding; in particular
                            # if the justification is *left*:
                            #       the *last* cell of the multicol group receives the padding
                            # if the justification is *right*:
                            #       the *first* cell of the multicol group receives the padding
                            #
                            # this motivates the introduction of $columnOffset, which is 
                            #       0 if justification is left
                            #       $multiColSpan if justification is right
                            my $columnOffset = (${$self}{justification} eq "left") ? $columnMax : $columnCount;
                            if(defined @{${$_}{columnSizes}}[$columnMax] and ($columnWidth > ($groupingWidth+(${$self}{spacesBeforeAmpersand}+1+${$self}{spacesAfterAmpersand})*($multiColSpan-1)) ) and @{${$_}{columnSizes}}[$columnMax] >= 0){
                                my $multiColPadding = $columnWidth-$groupingWidth-(${$self}{spacesBeforeAmpersand}+1+${$self}{spacesAfterAmpersand})*($multiColSpan-1);

                                # it's possible that multiColPadding might already be assigned; in which case, 
                                # we need to check that the current value of $multiColPadding is greater than the existing one
                                if(defined @{${$_}{multiColPadding}}[$columnOffset]){
                                    @{${$_}{multiColPadding}}[$columnOffset] = max($multiColPadding,@{${$_}{multiColPadding}}[$columnOffset]);
                                } else {
                                    @{${$_}{multiColPadding}}[$columnOffset] = $multiColPadding;
                                }

                                # also need to account for maximum column width *including* other multicolumn statements
                                if($maximumColumnWidthMC[$columnCount]>$columnWidth and $column !~ m/\\multicolumn\{(\d+)\}/){
                                    @{${$_}{multiColPadding}}[$columnOffset] += ($maximumColumnWidthMC[$columnCount]-$columnWidth); 
                                }
                            }
                        }
                        # update it to account for the ampersands and the spacing either side of ampersands
                        $maxGroupingWidth += ($multiColSpan-1)*(${$self}{spacesBeforeAmpersand}+1+${$self}{spacesAfterAmpersand});

                        # store the maxGroupingWidth for use in the next loop
                        @{${$_}{maxGroupingWidth}}[$columnCount] = $maxGroupingWidth; 

                        # update the columnCount to account for the multiColSpan
                        $columnCount += $multiColSpan - 1;
                    } 

                    # increase the column count
                    $columnCount++;
                }
            } 
        }
    }

    # the maximum row width will be used in aligning (or not) the \\
    my $maximumRowWidth = 0;

    # now that the multicolumn widths have been accounted for, loop through the body
    foreach(@formattedBody){
        if(${$_}{format} and ${$_}{row} !~ m/^\h*$/){

            # set a columnCount, which will vary depending on multiColumnGrouping settings or not
            my $columnCount=0;
            my $tmpRow = q();

            # loop through the columns
            foreach my $column (@{${$_}{columns}}){
                # calculate the width of the current column 
                my $gcs  = Unicode::GCString->new($column);
                my $columnWidth = $gcs->columns();

                # reset the column padding
                my $padding = q();

                # check for multiColumnGrouping
                if(${$_}{multiColumnGrouping} and $column =~ m/\\multicolumn\{(\d+)\}/ and $1>1){
                    my $multiColSpan = $1;

                    # groupingWidth contains the total width of column sizes grouped 
                    # underneath the \multicolumn{} statement
                    my $maxGroupingWidth = ${${$_}{maxGroupingWidth}}[$columnCount];

                    # it's possible to have situations such as
                    #
	                # \multicolumn{3}{l}{one} & \multicolumn{3}{l}{two} & \\ 
	                # \multicolumn{6}{l}{one}                           & \\
                    #
                    # in which case we need to loop through the @maximumColumnWidthMC
                    my $groupingWidthMC = 0;
                    my $multicolsEncountered =0;
                    for ($columnCount..($columnCount + ($multiColSpan-1))){
                        if(defined $maximumColumnWidthMC[$_]){
                            $groupingWidthMC += $maximumColumnWidthMC[$_];
                            $multicolsEncountered++ if $maximumColumnWidthMC[$_]>0;
                        }
                    }

                    # need to account for (spacesBeforeAmpersands) + length of ampersands (which is 1) + (spacesAfterAmpersands)
                    $groupingWidthMC += ($multicolsEncountered-1)*(${$self}{spacesBeforeAmpersand}+1+${$self}{spacesAfterAmpersand});
                    
                    # set the padding; we need
                    #       maximum( $maxGroupingWidth, $maximumColumnWidthMC[$columnCount] )
                    my $maxValueToUse = 0;
                    if(defined $maximumColumnWidthMC[$columnCount]){
                        $maxValueToUse = max($maxGroupingWidth,$maximumColumnWidthMC[$columnCount],$groupingWidthMC);
                    } else {
                        $maxValueToUse = $maxGroupingWidth;
                    }

                    # calculate the padding
                    $padding = " " x ( $maxValueToUse  >= $columnWidth ? $maxValueToUse  - $columnWidth : 0 );

                    # to the log file
                    if($is_tt_switch_active){    
                        $logger->trace("*---------column-------------");
                        $logger->trace($column);
                        $logger->trace("multiColSpan: $multiColSpan");
                        $logger->trace("groupingWidthMC: $groupingWidthMC");
                        $logger->trace("padding length: ",$maxValueToUse  - $columnWidth);
                        $logger->trace("multicolsEncountered: $multicolsEncountered");
                        $logger->trace("maxValueToUse: $maxValueToUse");
                        $logger->trace("maximumColumnWidth: ",join(",",@maximumColumnWidth));
                        $logger->trace("maximumColumnWidthMC: ",join(",",@maximumColumnWidthMC));
                    }

                    # update the columnCount to account for the multiColSpan
                    $columnCount += $multiColSpan - 1;
                } else {
                    # compare the *current* column width with the *maximum* column width
                    $padding = " " x (defined $maximumColumnWidth[$columnCount] and $maximumColumnWidth[$columnCount] >= $columnWidth ? $maximumColumnWidth[$columnCount] - $columnWidth : 0);
                }

                # either way, the row is formed of "COLUMN + PADDING"
                if(${$self}{justification} eq "left"){
                    $tmpRow .= $column.$padding.(defined @{${$_}{multiColPadding}}[$columnCount] ? " " x @{${$_}{multiColPadding}}[$columnCount]: q()).(" " x ${$self}{spacesBeforeAmpersand})."&".(" " x ${$self}{spacesAfterAmpersand});
                } else {
                    $tmpRow .= $padding.(defined @{${$_}{multiColPadding}}[$columnCount] ? " " x @{${$_}{multiColPadding}}[$columnCount]: q()).$column.(" " x ${$self}{spacesBeforeAmpersand})."&".(" " x ${$self}{spacesAfterAmpersand});
                }
                $columnCount++;
            }

            # remove the final &
            $tmpRow =~ s/\h*&\h*$/ /;
            my $finalSpacing = q();
            $finalSpacing = " " x (${$self}{spacesBeforeDoubleBackSlash}) if ${$self}{spacesBeforeDoubleBackSlash}>=1;
            $tmpRow =~ s/\h*$/$finalSpacing/;

            # replace the row with the formatted row
            ${$_}{row} = $tmpRow;

            # update the maximum row width
            my $gcs  = Unicode::GCString->new($tmpRow);
            ${$_}{rowWidth} = $gcs->columns();
            $maximumRowWidth = ${$_}{rowWidth} if(${$_}{rowWidth} >  $maximumRowWidth);
        } 
    }

    # final loop through to get \\ aligned
    foreach (@formattedBody){
        # reset the padding
        my $padding = q();

        # possibly adjust the padding
        if(${$_}{format} and ${$_}{row} !~ m/^\h*$/){
            # remove trailing horizontal space if ${$self}{alignDoubleBackSlash} is set to 0
            ${$_}{row} =~ s/\h*$// if (!${$self}{alignDoubleBackSlash});
            
            # format spacing infront of \\
            if(defined ${$self}{spacesBeforeDoubleBackSlash} and ${$self}{spacesBeforeDoubleBackSlash}<0 and !${$self}{alignDoubleBackSlash}){
                # zero spaces (possibly resulting in un-aligned \\)
                $padding = q();
            } elsif(defined ${$self}{spacesBeforeDoubleBackSlash} and ${$self}{spacesBeforeDoubleBackSlash}>=0 and !${$self}{alignDoubleBackSlash}){
                # specified number of spaces (possibly resulting in un-aligned \\)
                $padding = " " x (${$self}{spacesBeforeDoubleBackSlash});
            } else {
                # aligned \\
                $padding = " " x ($maximumRowWidth - ${$_}{rowWidth});
            }
        }

        # format the row, and put the trailing \\ and trailing comments back into the row
        ${$_}{row} .= $padding.(${$_}{endPiece} ? ${$_}{endPiece} :q() ).(${$_}{trailingComment}? ${$_}{trailingComment} : q() );
    }

    # to the log file
    if($is_tt_switch_active){    
        $logger->trace(${$_}{row}) for @formattedBody;
    }

    # delete the original body
    ${$self}{body} = q();

    # update the body
    ${$self}{body} .= ${$_}{row}."\n" for @formattedBody;

    # if the \end{} statement didn't originally have a line break before it, we need to remove the final 
    # line break added by the above
    ${$self}{body} =~ s/\h*\R$//s if !${$self}{linebreaksAtEnd}{body};
}

1;
