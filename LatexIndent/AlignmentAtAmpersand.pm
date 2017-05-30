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
use LatexIndent::TrailingComments qw/$trailingCommentRegExp/;
use LatexIndent::Switches qw/$is_t_switch_active $is_tt_switch_active/;
use LatexIndent::GetYamlSettings qw/%masterSettings/;
use LatexIndent::Tokens qw/%tokens/;
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
    $self->logger('looking for ALIGNED blocks marked by comments','heading')if($is_t_switch_active);
    $self->logger(Dumper(\%{$masterSettings{lookForAlignDelims}})) if($is_t_switch_active);
    while( my ($alignmentBlock,$yesno)= each %{$masterSettings{lookForAlignDelims}}){
        if(ref $yesno eq "HASH"){
              $yesno = (defined ${$yesno}{delims} ) ? ${$yesno}{delims} : 1;
            }
        if($yesno){
            $self->logger("looking for $alignmentBlock:$yesno environments");

            my $noIndentRegExp = qr/
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

            while( ${$self}{body} =~ m/$noIndentRegExp/sx){

              ${$self}{body} =~ s/
                                    $noIndentRegExp
                                /
                                    # create a new Environment object
                                    my $alignmentBlock = LatexIndent::AlignmentAtAmpersand->new( begin=>$1,
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
            
                                    # the settings and storage of most objects has a lot in common
                                    $self->get_settings_and_store_new_object($alignmentBlock);
                                    ${@{${$self}{children}}[-1]}{replacementText};
                              /xseg;
            } 
      } else {
            $self->logger("*not* looking for $alignmentBlock as $alignmentBlock:$yesno");
      }
    }
    return;
}

sub modify_line_breaks_settings{
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
    my @columnSizes = (0) x ($maximumNumberOfAmpersands+1); 

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

        # need to have at least one ampersand
        if($_ =~ m/(?<!\\)&/ and ( ($numberOfAmpersands == $maximumNumberOfAmpersands)||$multiColumnGrouping||$alignRowsWithoutMaxDelims ) ){
            # remove space at the beginning of a row, surrounding &, and at the end of the row
            $_ =~ s/(?<!\\)\h*(?<!\\)&\h*/&/g;
            $_ =~ s/^\h*//g;
            $_ =~ s/\h*$//g;

            # if the line finishes with an &, then add an empty space,
            # otherwise the column count is off
            $_ .= ($_ =~ m/(?<!\\)&$/ ? " ":q());

            $strippedRow = '';
            foreach my $column (split(/(?<!\\)&/,$_)){
                # if a column has finished with a \ then we need to add a trailing space, 
                # otherwise the \ can be put next to &. See test-cases/texexchange/112343-gonzalo for example
                $column .= ($column =~ m/\\$/ ? " ": q());

                # store the column size
                # reference: http://www.perl.com/pub/2012/05/perlunicook-unicode-column-width-for-printing.html
                my $gcs  = Unicode::GCString->new($column);
                my $columnWidth = $gcs->columns();
                $columnWidth = 1 if($multiColumnGrouping and ($column =~ m/\\multicolumn\{(\d+)\}/));
                $columnSizes[$columnCount] = $columnWidth if($columnWidth > $columnSizes[$columnCount]);

                # put the row back together, using " " if the column is empty
                $strippedRow .= ($columnCount>0 ? "&" : q() ).($columnWidth > 0 ? $column: " ");

                # move on to the next column
                if($multiColumnGrouping and ($column =~ m/\\multicolumn\{(\d+)\}/)){
                    # update the columnCount to account for the multiColSpan
                    # subtract 1 because of 0 array index in perl
                    $columnCount += $1 - 1; 
                } else {
                    $columnCount++;
                }
            }

            # toggle the formatting switch
            $formatRow = 1;
        }

        # store the information
        push(@formattedBody,{
                            row=>$strippedRow,
                            format=>$formatRow,
                            multiColumnGrouping=>$multiColumnGrouping,
                            endPiece=>($endPiece ? $endPiece :q() ),
                            trailingComment=>($trailingComments ? $trailingComments :q() )});
    }

    # output some of the info so far to the log file
    $self->logger("Column sizes of horizontally stripped formatted block (${$self}{name}): @columnSizes") if $is_t_switch_active;

    # finally, reformat the body
    foreach(@formattedBody){
        if(${$_}{format} and ${$_}{row} !~ m/^\h*$/){

            # set a columnCount, which will vary depending on multiColumnGrouping settings or not
            my $columnCount=0;
            my $tmpRow = q();

            # loop through the columns
            foreach my $column (split(/(?<!\\)&/,${$_}{row})){
                # calculate the width of the current column 
                my $gcs  = Unicode::GCString->new($column);
                my $columnWidth = $gcs->columns();

                # reset the column padding
                my $padding = q();

                # check for multiColumnGrouping
                if(${$_}{multiColumnGrouping} and $column =~ m/\\multicolumn\{(\d+)\}/){
                    my $multiColSpan = $1;

                    # for example, \multicolumn{3}{c}{<stuff>} spans 3 columns, so 
                    # the maximum column needs to account for this (subtract 1 because of 0 index in perl arrays)
                    my $columnMax = $columnCount+$multiColSpan-1;

                    # groupingWidth contains the total width of column sizes grouped 
                    # underneath the \multicolumn{} statement
                    my $groupingWidth = 0;
                    foreach ($columnCount..$columnMax){
                        $groupingWidth += $columnSizes[$_];
                    }

                    # update it to account for the ampersands and 1 space either side of ampersands (total of 3)
                    $groupingWidth += ($multiColSpan-1)*3;

                    # set the padding
                    if($columnWidth  <= $groupingWidth){
                       $padding = " " x ($groupingWidth - $columnWidth);
                    } else {
                       $columnSizes[$columnMax] += ($columnWidth - $groupingWidth);
                    }

                    # update the columnCount to account for the multiColSpan
                    $columnCount += $multiColSpan - 1;
                } else {
                    # compare the *current* column width with the *maximum* column width
                    if($columnWidth  <= $columnSizes[$columnCount]){
                       $padding = " " x ($columnSizes[$columnCount] - $columnWidth);
                    } else {
                       # columns from a row in which there's not the $maximumNumberOfAmpersands 
                       # should be accounted for at this stage
                       $columnSizes[$columnCount] = $columnWidth;
                       $padding = " " x ($columnSizes[$columnCount] - $columnWidth);
                    }

                }

                # either way, the row is formed of "COLUMN + PADDING"
                $tmpRow .= $column.$padding." & ";
                $columnCount++;
            }

            # remove the final &
            $tmpRow =~ s/\s&\s$/ /;

            # replace the row with the formatted row
            ${$_}{row} = $tmpRow;

            # format the row, and put the trailing \\ and trailing comments back into the row
            ${$_}{row} .= (${$_}{endPiece} ? ${$_}{endPiece} :q() ).(${$_}{trailingComment}? ${$_}{trailingComment} : q() );

            # possibly remove space ahead of \\
            ${$_}{row} =~ s/\h*\\\\/\\\\/ if(!${$self}{alignDoubleBackSlash});

            # possibly insert spaces infront of \\
            if(defined ${$self}{spacesBeforeDoubleBackSlash} and ${$self}{spacesBeforeDoubleBackSlash}>=0 and !${$self}{alignDoubleBackSlash}){
                my $horizontalSpaceToInsert = " "x (${$self}{spacesBeforeDoubleBackSlash});
                ${$_}{row} =~ s/\h*\\\\/$horizontalSpaceToInsert\\\\/;
            }
        } else{
            # otherwise, it's possible that the row originally had an end piece (e.g \\) and/or trailing comments
            ${$_}{row} .= (${$_}{endPiece} ? ${$_}{endPiece} :q() ).(${$_}{trailingComment}? ${$_}{trailingComment} : q() );
        } 
    }

    # to the log file
    if($is_tt_switch_active){    
        $self->logger(${$_}{row},'ttrace') for @formattedBody;
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
