package LatexIndent::ModifyLineBreaks;
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
use Exporter qw/import/;
use Text::Wrap;
use LatexIndent::GetYamlSettings qw/%mainSettings/;
use LatexIndent::Tokens qw/%tokens/;
use LatexIndent::TrailingComments qw/$trailingCommentRegExp/;
use LatexIndent::Switches qw/$is_m_switch_active $is_t_switch_active $is_tt_switch_active/;
use LatexIndent::Item qw/$listOfItems/;
use LatexIndent::LogFile qw/$logger/;
use LatexIndent::Verbatim qw/%verbatimStorage/;
our @EXPORT_OK = qw/modify_line_breaks_body modify_line_breaks_end modify_line_breaks_end_after adjust_line_breaks_end_parent remove_line_breaks_begin text_wrap remove_paragraph_line_breaks construct_paragraph_reg_exp text_wrap_remove_paragraph_line_breaks verbatim_modify_line_breaks/;
our $paragraphRegExp = q();

sub modify_line_breaks_body{
    my $self = shift;
    # 
    # Blank line poly-switch notes (==4)
    #
    # when BodyStartsOnOwnLine=4 we adopt the following approach:
    #   temporarily change BodyStartsOnOwnLine to -1, make adjustments
    #   temporarily change BodyStartsOnOwnLine to 3, make adjustments
    # switch BodyStartsOnOwnLine back to 4
    
    # add a line break after \begin{statement} if appropriate
    my @polySwitchValues = (${$self}{BodyStartsOnOwnLine}==4)?(-1,3):(${$self}{BodyStartsOnOwnLine});
    foreach(@polySwitchValues){
      my $BodyStringLogFile = ${$self}{aliases}{BodyStartsOnOwnLine}||"BodyStartsOnOwnLine";
      if($_>=1 and !${$self}{linebreaksAtEnd}{begin}){
          # if the <begin> statement doesn't finish with a line break, 
          # then we have different actions based upon the value of BodyStartsOnOwnLine:
          #     BodyStartsOnOwnLine == 1 just add a new line
          #     BodyStartsOnOwnLine == 2 add a comment, and then new line
          #     BodyStartsOnOwnLine == 3 add a blank line, and then new line
          if($_==1){
            # modify the begin statement
            $logger->trace("Adding a linebreak at the end of begin statement ${$self}{begin} (see $BodyStringLogFile)") if $is_t_switch_active;
            ${$self}{begin} .= "\n";       
            ${$self}{linebreaksAtEnd}{begin} = 1;
            $logger->trace("Removing leading space from body of ${$self}{name} (see $BodyStringLogFile)") if $is_t_switch_active;
            ${$self}{body} =~ s/^\h*//;       
          } elsif($_==2){
            # by default, assume that no trailing comment token is needed
            my $trailingCommentToken = q();
            if(${$self}{body} !~ m/^\h*$trailingCommentRegExp/s){
                # modify the begin statement
                $logger->trace("Adding a % at the end of begin ${$self}{begin} followed by a linebreak ($BodyStringLogFile == 2)") if $is_t_switch_active;
                $trailingCommentToken = "%".$self->add_comment_symbol;
                ${$self}{begin} =~ s/\h*$//;       
                ${$self}{begin} .= "$trailingCommentToken\n";       
                ${$self}{linebreaksAtEnd}{begin} = 1;
                $logger->trace("Removing leading space from body of ${$self}{name} (see $BodyStringLogFile)") if $is_t_switch_active;
                ${$self}{body} =~ s/^\h*//;       
            } else {
                $logger->trace("Even though $BodyStringLogFile == 2, ${$self}{begin} already finishes with a %, so not adding another.") if $is_t_switch_active;
            }
          } elsif ($_==3){
            my $trailingCharacterToken = q();
            $logger->trace("Adding a blank line at the end of begin ${$self}{begin} followed by a linebreak ($BodyStringLogFile == 3)") if $is_t_switch_active;
            ${$self}{begin} =~ s/\h*$//;       
            ${$self}{begin} .= (${$mainSettings{modifyLineBreaks}}{preserveBlankLines}?$tokens{blanklines}:"\n")."\n";       
            ${$self}{linebreaksAtEnd}{begin} = 1;
            $logger->trace("Removing leading space from body of ${$self}{name} (see $BodyStringLogFile)") if $is_t_switch_active;
            ${$self}{body} =~ s/^\h*//;       
          } 
       } elsif ($_==-1 and ${$self}{linebreaksAtEnd}{begin}){
          # remove line break *after* begin, if appropriate
          $self->remove_line_breaks_begin;
       }
    }
}

sub remove_line_breaks_begin{
    my $self = shift;
    my $BodyStringLogFile = ${$self}{aliases}{BodyStartsOnOwnLine}||"BodyStartsOnOwnLine";
    $logger->trace("Removing linebreak at the end of begin (see $BodyStringLogFile)") if $is_t_switch_active;
    ${$self}{begin} =~ s/\R*$//sx;
    ${$self}{linebreaksAtEnd}{begin} = 0;
}

sub modify_line_breaks_end{
    my $self = shift;

    # 
    # Blank line poly-switch notes (==4)
    #
    # when EndStartsOnOwnLine=4 we adopt the following approach:
    #   temporarily change EndStartsOnOwnLine to -1, make adjustments
    #   temporarily change EndStartsOnOwnLine to 3, make adjustments
    # switch EndStartsOnOwnLine back to 4
    #
    
    my @polySwitchValues =(${$self}{EndStartsOnOwnLine}==4) ?(-1,3):(${$self}{EndStartsOnOwnLine});
    foreach(@polySwitchValues){
        # possibly modify line break *before* \end{statement}
        if(defined ${$self}{EndStartsOnOwnLine}){
              my $EndStringLogFile = ${$self}{aliases}{EndStartsOnOwnLine}||"EndStartsOnOwnLine";
              if($_>=1 and !${$self}{linebreaksAtEnd}{body}){
                  # if the <body> statement doesn't finish with a line break, 
                  # then we have different actions based upon the value of EndStartsOnOwnLine:
                  #     EndStartsOnOwnLine == 1 just add a new line
                  #     EndStartsOnOwnLine == 2 add a comment, and then new line
                  #     EndStartsOnOwnLine == 3 add a blank line, and then new line
                  $logger->trace("Adding a linebreak at the end of body (see $EndStringLogFile)") if $is_t_switch_active;

                  # by default, assume that no trailing character token is needed
                  my $trailingCharacterToken = q();
                  if($_==2){
                    $logger->trace("Adding a % immediately after body of ${$self}{name} ($EndStringLogFile==2)") if $is_t_switch_active;
                    $trailingCharacterToken = "%".$self->add_comment_symbol;
                    ${$self}{body} =~ s/\h*$//s;
                  } elsif ($_==3) {
                    $logger->trace("Adding a blank line immediately after body of ${$self}{name} ($EndStringLogFile==3)") if $is_t_switch_active;
                    $trailingCharacterToken = "\n".(${$mainSettings{modifyLineBreaks}}{preserveBlankLines}?$tokens{blanklines}:q());
                    ${$self}{body} =~ s/\h*$//s;
                  }
                  
                  # modified end statement
                  if(${$self}{body} =~ m/^\h*$/s and (defined ${$self}{BodyStartsOnOwnLine}) and ${$self}{BodyStartsOnOwnLine} >=1 ){
                    ${$self}{linebreaksAtEnd}{body} = 0;
                  } else {
                    ${$self}{body} .= "$trailingCharacterToken\n";
                    ${$self}{linebreaksAtEnd}{body} = 1;
                  }
              } elsif ($_==-1 and ${$self}{linebreaksAtEnd}{body}){
                  # remove line break *after* body, if appropriate

                  # check to see that body does *not* finish with blank-line-token, 
                  # if so, then don't remove that final line break
                  if(${$self}{body} !~ m/$tokens{blanklines}$/s){
                    $logger->trace("Removing linebreak at the end of body (see $EndStringLogFile)") if $is_t_switch_active;
                    ${$self}{body} =~ s/\R*$//sx;
                    ${$self}{linebreaksAtEnd}{body} = 0;
                  } else {
                    $logger->trace("Blank line token found at end of body (${$self}{name}), see preserveBlankLines, not removing line break before ${$self}{end}") if $is_t_switch_active;
                  }
              }
        }
    }

  }

sub modify_line_breaks_end_after{
    my $self = shift;
    # 
    # Blank line poly-switch notes (==4)
    #
    # when EndFinishesWithLineBreak=4 we adopt the following approach:
    #   temporarily change EndFinishesWithLineBreak to -1, make adjustments
    #   temporarily change EndFinishesWithLineBreak to 3, make adjustments
    # switch EndFinishesWithLineBreak back to 4
    #
    my @polySwitchValues =(${$self}{EndFinishesWithLineBreak}==4) ?(-1,3):(${$self}{EndFinishesWithLineBreak});
    foreach(@polySwitchValues){
        last if !(defined $_);
        ${$self}{linebreaksAtEnd}{end} = 0 if($_==3 and (defined ${$self}{EndFinishesWithLineBreak} and ${$self}{EndFinishesWithLineBreak}==4));

        # possibly modify line break *after* \end{statement}
        if(defined $_ and $_>=1 
           and !${$self}{linebreaksAtEnd}{end} and ${$self}{end} ne ''){
                  # if the <end> statement doesn't finish with a line break, 
                  # then we have different actions based upon the value of EndFinishesWithLineBreak:
                  #     EndFinishesWithLineBreak == 1 just add a new line
                  #     EndFinishesWithLineBreak == 2 add a comment, and then new line
                  #     EndFinishesWithLineBreak == 3 add a blank line, and then new line
                  my $EndStringLogFile = ${$self}{aliases}{EndFinishesWithLineBreak}||"EndFinishesWithLineBreak";
                  if($_==1){
                    $logger->trace("Adding a linebreak at the end of ${$self}{end} ($EndStringLogFile==1)") if $is_t_switch_active;
                    ${$self}{linebreaksAtEnd}{end} = 1;

                    # modified end statement
                    ${$self}{replacementText} .= "\n";
                  } elsif($_==2){
                    if(${$self}{endImmediatelyFollowedByComment}){
                      # no need to add a % if one already exists
                      $logger->trace("Even though $EndStringLogFile == 2, ${$self}{end} is immediately followed by a %, so not adding another; not adding line break.") if $is_t_switch_active;
                    } else {
                      # otherwise, create a trailing comment, and tack it on 
                      $logger->trace("Adding a % immediately after ${$self}{end} ($EndStringLogFile==2)") if $is_t_switch_active;
                      my $trailingCommentToken = "%".$self->add_comment_symbol;
                      ${$self}{end} =~ s/\h*$//s;
                      ${$self}{replacementText} .= "$trailingCommentToken\n";
                      ${$self}{linebreaksAtEnd}{end} = 1;
                    }
                  } elsif($_==3){
                    $logger->trace("Adding a blank line at the end of ${$self}{end} ($EndStringLogFile==3)") if $is_t_switch_active;
                    ${$self}{linebreaksAtEnd}{end} = 1;

                    # modified end statement
                    ${$self}{replacementText} .= (${$mainSettings{modifyLineBreaks}}{preserveBlankLines}?$tokens{blanklines}:"\n")."\n";
                  } 
        }
    }

}

sub adjust_line_breaks_end_parent{
    # when a parent object contains a child object, the line break
    # at the end of the parent object can become messy

    my $self = shift;

    # most recent child object
    my $child = @{${$self}{children}}[-1];

    # adjust parent linebreaks information
    if(${$child}{linebreaksAtEnd}{end} and ${$self}{body} =~ m/${$child}{replacementText}\h*\R*$/s and !${$self}{linebreaksAtEnd}{body}){
        $logger->trace("ID: ${$child}{id}") if($is_t_switch_active);
        $logger->trace("${$child}{begin}...${$child}{end} is found at the END of body of parent, ${$self}{name}, avoiding a double line break:") if($is_t_switch_active);
        $logger->trace("adjusting ${$self}{name} linebreaksAtEnd{body} to be 1") if($is_t_switch_active);
        ${$self}{linebreaksAtEnd}{body}=1;
      }

    # the modify line switch can adjust line breaks, so we need another check, 
    # see for example, test-cases/environments/environments-remove-line-breaks-trailing-comments.tex
    if(defined ${$child}{linebreaksAtEnd}{body} 
        and !${$child}{linebreaksAtEnd}{body} 
        and ${$child}{body} =~ m/\R(?:$trailingCommentRegExp\h*)?$/s ){
        # log file information
        $logger->trace("Undisclosed line break at the end of body of ${$child}{name}: '${$child}{end}'") if($is_t_switch_active);
        $logger->trace("Adding a linebreak at the end of body for ${$child}{id}") if($is_t_switch_active);
        
        # make the adjustments
        ${$child}{body} .= "\n";
        ${$child}{linebreaksAtEnd}{body}=1;
    }

}

sub verbatim_modify_line_breaks{
    # verbatim modify line breaks are a bit special, as they happen before 
    # any of the main processes have been done
    my $self = shift;
    while ( my ($key,$child)= each %verbatimStorage){
      if(defined ${$child}{BeginStartsOnOwnLine}){
        my $BeginStringLogFile = ${$child}{aliases}{BeginStartsOnOwnLine};
        $logger->trace("*$BeginStringLogFile is ${$child}{BeginStartsOnOwnLine} for ${$child}{name}") if $is_t_switch_active ;
        if (${$child}{BeginStartsOnOwnLine}==-1){
            # VerbatimStartsOnOwnLine = -1
            if(${$self}{body}=~m/^\h*${$child}{id}/m){
                $logger->trace("${$child}{name} begins on its own line, removing leading line break") if $is_t_switch_active ;
                ${$self}{body} =~ s/(\R|\h)*${$child}{id}/${$child}{id}/s;
            }
        } elsif (${$child}{BeginStartsOnOwnLine}>=1 and ${$self}{body}!~m/^\h*${$child}{id}/m){
            # VerbatimStartsOnOwnLine = 1, 2 or 3
            my $trailingCharacterToken = q();
            if(${$child}{BeginStartsOnOwnLine}==1){
                $logger->trace("Adding a linebreak at the beginning of ${$child}{begin} (see $BeginStringLogFile)") if $is_t_switch_active;
            } elsif (${$child}{BeginStartsOnOwnLine}==2){
                $logger->trace("Adding a % at the end of the line that ${$child}{begin} is on, then a linebreak ($BeginStringLogFile == 2)") if $is_t_switch_active;
                $trailingCharacterToken = "%".$self->add_comment_symbol;
            } elsif (${$child}{BeginStartsOnOwnLine}==3){
                $logger->trace("Adding a blank line at the end of the line that ${$child}{begin} is on, then a linebreak ($BeginStringLogFile == 3)") if $is_t_switch_active;
                $trailingCharacterToken = "\n";
            }
            ${$self}{body} =~ s/\h*${$child}{id}/$trailingCharacterToken\n${$child}{id}/s;
        }
      }
    }
}

sub text_wrap_remove_paragraph_line_breaks{
    my $self = shift;

    if(${$mainSettings{modifyLineBreaks}{removeParagraphLineBreaks}}{beforeTextWrap}){
        $self->remove_paragraph_line_breaks if ${$self}{removeParagraphLineBreaks};
        $self->text_wrap if (${$self}{textWrapOptions} and ${$mainSettings{modifyLineBreaks}{textWrapOptions}}{perCodeBlockBasis});
    } else {
        $self->text_wrap if (${$self}{textWrapOptions} and ${$mainSettings{modifyLineBreaks}{textWrapOptions}}{perCodeBlockBasis});
    }

}

sub text_wrap{

    my $self = shift;
    
    # alignment at ampersand can take priority
    return if(${$self}{lookForAlignDelims} and ${$mainSettings{modifyLineBreaks}{textWrapOptions}}{alignAtAmpersandTakesPriority});

    # goal: get an accurate measurement of verbatim objects;
    # 
    # example: 
    #       Lorem \verb!x+y! ipsum dolor sit amet
    # 
    # is represented as 
    #
    #       Lorem LTXIN-TK-VERBATIM1-END ipsum dolor sit amet
    #
    # so we *measure* the verbatim token and replace it with 
    # an appropriate-length string
    #
    #       Lorem a2A41233rt ipsum dolor sit amet
    #
    # and then put the body back to 
    #
    #       Lorem LTXIN-TK-VERBATIM1-END ipsum dolor sit amet
    # 
    # following the text wrapping
    my @putVerbatimBackIn;

    # check body for verbatim and get measurements
    if (${$self}{body} =~ m/$tokens{verbatim}/s and ${$mainSettings{modifyLineBreaks}{textWrapOptions}}{huge} eq "overflow"){

      # reference: https://stackoverflow.com/questions/10336660/in-perl-how-can-i-generate-random-strings-consisting-of-eight-hex-digits
      my @set = ('0' ..'9', 'A' .. 'Z', 'a' .. 'z');

      # loop through verbatim objects
      while( my ($verbatimID,$child)= each %verbatimStorage){
        my $verbatimThing = ${$child}{begin}.${$child}{body}.${$child}{end};

        # if the object has line breaks, don't measure it
        next if $verbatimThing =~ m/\R/s;

        if(${$self}{body} =~m/$verbatimID/s){

          # measure length
          my $verbatimLength = Unicode::GCString->new($verbatimThing)->columns();

          # create temporary ID, and check that it is not contained in the body
          my $verbatimTmpID = join '' => map $set[rand @set], 1 .. $verbatimLength;
          while(${$self}{body} =~m/$verbatimTmpID/s){
             $verbatimTmpID = join '' => map $set[rand @set], 1 .. $verbatimLength;
          }

          # store for use after the text wrapping
          push(@putVerbatimBackIn,{origVerbatimID=>$verbatimID,tmpVerbatimID=>$verbatimTmpID});

          # make the substitution
          ${$self}{body} =~ s/$verbatimID/$verbatimTmpID/s;
        }
      }
    }

    # call the text wrapping routine
    my $columns;

    # columns might have been defined by the user
    if(defined ${$self}{columns}){
        $columns = ${$self}{columns};
    } elsif(ref ${$mainSettings{modifyLineBreaks}{textWrapOptions}}{columns} eq "HASH"){
        if(defined ${${$mainSettings{modifyLineBreaks}{textWrapOptions}}{columns}}{default}){
            $columns = ${${$mainSettings{modifyLineBreaks}{textWrapOptions}}{columns}}{default};
        } else {
            $columns = 80;
        }
    } elsif (defined ${$mainSettings{modifyLineBreaks}{textWrapOptions}}{columns}){
        $columns = ${$mainSettings{modifyLineBreaks}{textWrapOptions}}{columns} ;
    } else {
        $columns = 80;
    }

    # vital Text::Wrap options
    $Text::Wrap::columns=$columns;
    $Text::Wrap::huge = ${$mainSettings{modifyLineBreaks}{textWrapOptions}}{huge};

    # all other Text::Wrap options not usually needed/helpful, but available
    $Text::Wrap::separator=${$mainSettings{modifyLineBreaks}{textWrapOptions}}{separator} if(${$mainSettings{modifyLineBreaks}{textWrapOptions}}{separator} ne '');
    $Text::Wrap::break = ${$mainSettings{modifyLineBreaks}{textWrapOptions}}{break} if ${$mainSettings{modifyLineBreaks}{textWrapOptions}}{break};
    $Text::Wrap::unexpand = ${$mainSettings{modifyLineBreaks}{textWrapOptions}}{unexpand} if ${$mainSettings{modifyLineBreaks}{textWrapOptions}}{unexpand};
    $Text::Wrap::tabstop = ${$mainSettings{modifyLineBreaks}{textWrapOptions}}{tabstop} if ${$mainSettings{modifyLineBreaks}{textWrapOptions}}{tabstop};

    # perform the text wrapping
    ${$self}{body} = wrap('','',${$self}{body});

    ${$self}{body} =~ s/${$_}{tmpVerbatimID}/${$_}{origVerbatimID}/s foreach (@putVerbatimBackIn);
}

sub construct_paragraph_reg_exp{
    my $self = shift;

    $logger->trace("*Constructing the paragraph-stop regexp (see paragraphsStopAt)") if $is_t_switch_active ;
    my $stopAtRegExp = q();
    while( my ($paragraphStopAt,$yesNo)= each %{${$mainSettings{modifyLineBreaks}{removeParagraphLineBreaks}}{paragraphsStopAt}}){
        if($yesNo){
            # the headings (chapter, section, etc) need a slightly special treatment
            $paragraphStopAt = "afterHeading" if($paragraphStopAt eq "heading");

            # the comment need a slightly special treatment
            $paragraphStopAt = "trailingComment" if($paragraphStopAt eq "comments");

            # output to log file
            $logger->trace("The paragraph-stop regexp WILL include $tokens{$paragraphStopAt} (see paragraphsStopAt)") if $is_t_switch_active ;

            # update the regexp
            if($paragraphStopAt eq "items"){
                $stopAtRegExp .= "|(?:\\\\(?:".$listOfItems."))";
            } else {
                $stopAtRegExp .= "|(?:".($paragraphStopAt eq "trailingComment" ? "%" : q() ).$tokens{$paragraphStopAt}."\\d+)";
            }
        } else {
            $logger->trace("The paragraph-stop regexp won't include $tokens{$paragraphStopAt} (see paragraphsStopAt)") if ($tokens{$paragraphStopAt} and $is_t_switch_active);
        }
    }

    $paragraphRegExp = qr/
                        ^
                        (?!$tokens{beginOfToken})
                        (\w
                            (?:
                                (?!
                                    (?:$tokens{blanklines}|\\par) 
                                ).
                            )*?
                         )
                         (
                            (?:
                                ^(?:(\h*\R)|\\par|$tokens{blanklines}$stopAtRegExp)
                            )
                            |
                            \z      # end of string
                         )/sxm;

    $logger->trace("The paragraph-stop-regexp is:") if $is_tt_switch_active ;
    $logger->trace($paragraphRegExp) if $is_tt_switch_active ;
}

sub remove_paragraph_line_breaks{
    my $self = shift;
    return unless ${$self}{removeParagraphLineBreaks};

    # alignment at ampersand can take priority
    return if(${$self}{lookForAlignDelims} and ${$mainSettings{modifyLineBreaks}{removeParagraphLineBreaks}}{alignAtAmpersandTakesPriority});

    $logger->trace("Checking ${$self}{name} for paragraphs (see removeParagraphLineBreaks)") if $is_t_switch_active;

    my $paragraphCounter;
    my @paragraphStorage;

    ${$self}{body} =~ s/$paragraphRegExp/
                            $paragraphCounter++;
                            push(@paragraphStorage,{id=>$tokens{paragraph}.$paragraphCounter.$tokens{endOfToken},value=>$1});

                            # replace comment with dummy text
                            $tokens{paragraph}.$paragraphCounter.$tokens{endOfToken}.$2;
                        /xsmeg;

    while( my $paragraph = pop @paragraphStorage){
      # remove all line breaks from paragraph, except for any at the very end
      ${$paragraph}{value} =~ s/\R(?!\z)/ /sg; 
      ${$self}{body} =~ s/${$paragraph}{id}/${$paragraph}{value}/; 
    }
}


1;
