# AlignmentAtAmpersand.pm
#   contains subroutines for indentation (can be overwritten for each object, if necessary)
package LatexIndent::AlignmentAtAmpersand;
use strict;
use warnings;
use LatexIndent::TrailingComments qw/$trailingCommentRegExp/;
use LatexIndent::Switches qw/$is_t_switch_active $is_tt_switch_active/;
use LatexIndent::GetYamlSettings qw/%masterSettings/;
use LatexIndent::Tokens qw/%tokens/;
use Data::Dumper;
use Exporter qw/import/;
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
                                                                          regexp=>$noIndentRegExp,
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
    my $self = shift;
#    $self->remove_leading_space;
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

        my $numberOfAmpersands = () = $_ =~ /(?<!\\)&/g;
        if($numberOfAmpersands == $maximumNumberOfAmpersands){
            # remove any trailing comments
            my $trailingComments;
            if($_ =~ m/$trailingCommentRegExp/ ){
                $_ =~ s/($trailingCommentRegExp)//;
                $trailingComments = $1; 
            }

            # if the line finishes with an &, then add an empty space,
            # otherwise the column count is off
            $_ .= ($_ =~ m/(?<!\\)&$/ ? " ":q());

            # loop through the columns
            my $columnCount = 0;
            my $strippedRow = '';
            foreach my $column (split(/(?<!\\)&/,$_)){
                # remove leading space
                $column =~ s/^\h*//;

                # remove trailing space
                $column =~ s/\h*$//; 

                # store the column size
                $columnSizes[$columnCount] = length($column) if(length($column)>$columnSizes[$columnCount]);

                # put the row back together, using " " if the column is empty
                $strippedRow .= ($columnCount>0 ? "&" : q() ).(length($column)>0 ? $column: " ");

                # move on to the next column
                $columnCount++;
            }

            # store the information
            push(@formattedBody,{
                                row=>$strippedRow,
                                format=>1,
                                endPiece=>($endPiece ? $endPiece :q() ),
                                trailingComment=>($trailingComments ? $trailingComments :q() )});
        } else {
            # otherwise simply store the row
            push(@formattedBody,{
                                row=>$_.($endPiece ? $endPiece : q() ),
                                format=>0});
        }
    }

    # output some of the info so far to the log file
    $self->logger("Column sizes of horizontally stripped formatted block (${$self}{name}): @columnSizes") if $is_t_switch_active;

    # README: printf( formatting, expression)
    #
    #   formatting has the form %-50s & %-20s & %-19s
    #   (the numbers have been made up for example)
    #       the - symbols mean that each column should be left-aligned
    #       the numbers represent how wide each column is
    #       the s represents string
    #       the & needs to be inserted

    # join up the maximum string lengths using "s %-"
    my $fmtstring = join("s & %-",@columnSizes);

    # add %- to the beginning and an s to the end
    $fmtstring = "%-".$fmtstring."s ";

    # log file info
    $self->logger("Formatting string is: $fmtstring",'heading') if $is_t_switch_active;

    # finally, reformat the body
    foreach(@formattedBody){
        if(${$_}{format} and ${$_}{row} !~ m/^\h*$/){
            # format the row, and put the trailing \\ and trailing comments back into the row
            ${$_}{row} = sprintf($fmtstring,split(/(?<!\\)&/,${$_}{row})).(${$_}{endPiece} ? ${$_}{endPiece} :q() ).(${$_}{trailingComment}? ${$_}{trailingComment} : q() );

            # possibly remove space ahead of \\
            ${$_}{row} =~ s/\h*\\\\/\\\\/ if(!${$self}{alignDoubleBackSlash});

            # possibly insert spaces infront of \\
            if(defined ${$self}{spacesBeforeDoubleBackSlash} and ${$self}{spacesBeforeDoubleBackSlash}>=0 and !${$self}{alignDoubleBackSlash}){
                my $horizontalSpaceToInsert = " "x (${$self}{spacesBeforeDoubleBackSlash});
                ${$_}{row} =~ s/\h*\\\\/$horizontalSpaceToInsert\\\\/;
            }
        }

        # if we have an empty row, it's possible that it originally had an end piece (e.g \\) and/or trailing comments
        if(${$_}{row} =~ m/^\h*$/){
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
