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
use Data::Dumper;
use Exporter qw/import/;
use Text::Wrap;
use LatexIndent::GetYamlSettings qw/%masterSettings/;
use LatexIndent::Tokens qw/%tokens/;
use LatexIndent::TrailingComments qw/$trailingCommentRegExp/;
use LatexIndent::Switches qw/$is_m_switch_active $is_t_switch_active $is_tt_switch_active/;
use LatexIndent::Item qw/$listOfItems/;
use LatexIndent::LogFile qw/$logger/;
our @EXPORT_OK = qw/modify_line_breaks_body modify_line_breaks_end adjust_line_breaks_end_parent remove_line_breaks_begin text_wrap remove_paragraph_line_breaks construct_paragraph_reg_exp one_sentence_per_line text_wrap_remove_paragraph_line_breaks/;
our $paragraphRegExp = q();


sub modify_line_breaks_body{
    my $self = shift;
    
    # add a line break after \begin{statement} if appropriate
    if(defined ${$self}{BodyStartsOnOwnLine}){
      my $BodyStringLogFile = ${$self}{aliases}{BodyStartsOnOwnLine}||"BodyStartsOnOwnLine";
      if(${$self}{BodyStartsOnOwnLine}>=1 and !${$self}{linebreaksAtEnd}{begin}){
          # if the <begin> statement doesn't finish with a line break, 
          # then we have different actions based upon the value of BodyStartsOnOwnLine:
          #     BodyStartsOnOwnLine == 1 just add a new line
          #     BodyStartsOnOwnLine == 2 add a comment, and then new line
          #     BodyStartsOnOwnLine == 3 add a blank line, and then new line
          if(${$self}{BodyStartsOnOwnLine}==1){
            # modify the begin statement
            $logger->trace("Adding a linebreak at the end of begin, ${$self}{begin} (see $BodyStringLogFile)") if $is_t_switch_active;
            ${$self}{begin} .= "\n";       
            ${$self}{linebreaksAtEnd}{begin} = 1;
            $logger->trace("Removing leading space from body of ${$self}{name} (see $BodyStringLogFile)") if $is_t_switch_active;
            ${$self}{body} =~ s/^\h*//;       
          } elsif(${$self}{BodyStartsOnOwnLine}==2){
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
          } elsif (${$self}{BodyStartsOnOwnLine}==3){
            my $trailingCharacterToken = q();
            $logger->trace("Adding a blank line at the end of begin ${$self}{begin} followed by a linebreak ($BodyStringLogFile == 3)") if $is_t_switch_active;
            ${$self}{begin} =~ s/\h*$//;       
            ${$self}{begin} .= (${$masterSettings{modifyLineBreaks}}{preserveBlankLines}?$tokens{blanklines}:"\n")."\n";       
            ${$self}{linebreaksAtEnd}{begin} = 1;
            $logger->trace("Removing leading space from body of ${$self}{name} (see $BodyStringLogFile)") if $is_t_switch_active;
            ${$self}{body} =~ s/^\h*//;       
          } 
       } elsif (${$self}{BodyStartsOnOwnLine}==-1 and ${$self}{linebreaksAtEnd}{begin}){
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

    # possibly modify line break *before* \end{statement}
    if(defined ${$self}{EndStartsOnOwnLine}){
          my $EndStringLogFile = ${$self}{aliases}{EndStartsOnOwnLine}||"EndStartsOnOwnLine";
          if(${$self}{EndStartsOnOwnLine}>=1 and !${$self}{linebreaksAtEnd}{body}){
              # if the <body> statement doesn't finish with a line break, 
              # then we have different actions based upon the value of EndStartsOnOwnLine:
              #     EndStartsOnOwnLine == 1 just add a new line
              #     EndStartsOnOwnLine == 2 add a comment, and then new line
              #     EndStartsOnOwnLine == 3 add a blank line, and then new line
              $logger->trace("Adding a linebreak at the end of body (see $EndStringLogFile)") if $is_t_switch_active;

              # by default, assume that no trailing character token is needed
              my $trailingCharacterToken = q();
              if(${$self}{EndStartsOnOwnLine}==2){
                $logger->trace("Adding a % immediately after body of ${$self}{name} ($EndStringLogFile==2)") if $is_t_switch_active;
                $trailingCharacterToken = "%".$self->add_comment_symbol;
                ${$self}{body} =~ s/\h*$//s;
              } elsif (${$self}{EndStartsOnOwnLine}==3) {
                $logger->trace("Adding a blank line immediately after body of ${$self}{name} ($EndStringLogFile==3)") if $is_t_switch_active;
                $trailingCharacterToken = "\n".(${$masterSettings{modifyLineBreaks}}{preserveBlankLines}?$tokens{blanklines}:q());
                ${$self}{body} =~ s/\h*$//s;
              }
              
              # modified end statement
              if(${$self}{body} =~ m/^\h*$/s and ${$self}{BodyStartsOnOwnLine} >=1 ){
                ${$self}{linebreaksAtEnd}{body} = 0;
              } else {
                ${$self}{body} .= "$trailingCharacterToken\n";
                ${$self}{linebreaksAtEnd}{body} = 1;
              }
          } elsif (${$self}{EndStartsOnOwnLine}==-1 and ${$self}{linebreaksAtEnd}{body}){
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

    # possibly modify line break *after* \end{statement}
    if(defined ${$self}{EndFinishesWithLineBreak}
       and ${$self}{EndFinishesWithLineBreak}>=1 
       and !${$self}{linebreaksAtEnd}{end}){
              # if the <end> statement doesn't finish with a line break, 
              # then we have different actions based upon the value of EndFinishesWithLineBreak:
              #     EndFinishesWithLineBreak == 1 just add a new line
              #     EndFinishesWithLineBreak == 2 add a comment, and then new line
              #     EndFinishesWithLineBreak == 3 add a blank line, and then new line
              my $EndStringLogFile = ${$self}{aliases}{EndFinishesWithLineBreak}||"EndFinishesWithLineBreak";
              if(${$self}{EndFinishesWithLineBreak}==1){
                $logger->trace("Adding a linebreak at the end of ${$self}{end} ($EndStringLogFile==1)") if $is_t_switch_active;
                ${$self}{linebreaksAtEnd}{end} = 1;

                # modified end statement
                ${$self}{replacementText} .= "\n";
              } elsif(${$self}{EndFinishesWithLineBreak}==2){
                if(${$self}{endImmediatelyFollowedByComment}){
                  # no need to add a % if one already exists
                  $logger->trace("Even though $EndStringLogFile == 2, ${$self}{end} is immediately followed by a %, so not adding another; not adding line break.") if $is_t_switch_active;
                } else {
                  # otherwise, create a trailing comment, and tack it on 
                  $logger->trace("Adding a % immediately after, ${$self}{end} ($EndStringLogFile==2)") if $is_t_switch_active;
                  my $trailingCommentToken = "%".$self->add_comment_symbol;
                  ${$self}{end} =~ s/\h*$//s;
                  ${$self}{replacementText} .= "$trailingCommentToken\n";
                  ${$self}{linebreaksAtEnd}{end} = 1;
                }
              } elsif(${$self}{EndFinishesWithLineBreak}==3){
                $logger->trace("Adding a blank line at the end of ${$self}{end} ($EndStringLogFile==3)") if $is_t_switch_active;
                ${$self}{linebreaksAtEnd}{end} = 1;

                # modified end statement
                ${$self}{replacementText} .= (${$masterSettings{modifyLineBreaks}}{preserveBlankLines}?$tokens{blanklines}:"\n")."\n";
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

sub text_wrap_remove_paragraph_line_breaks{
    my $self = shift;

    if(${$masterSettings{modifyLineBreaks}{removeParagraphLineBreaks}}{beforeTextWrap}){
        $self->remove_paragraph_line_breaks if ${$self}{removeParagraphLineBreaks};
        $self->text_wrap if (${$self}{textWrapOptions} and ${$masterSettings{modifyLineBreaks}{textWrapOptions}}{perCodeBlockBasis});
    } else {
        $self->text_wrap if (${$self}{textWrapOptions} and ${$masterSettings{modifyLineBreaks}{textWrapOptions}}{perCodeBlockBasis});
    }

}

sub text_wrap{

    my $self = shift;
    
    # alignment at ampersand can take priority
    return if(${$self}{lookForAlignDelims} and ${$masterSettings{modifyLineBreaks}{textWrapOptions}}{alignAtAmpersandTakesPriority});

    # call the text wrapping routine
    my $columns;

    # columns might have been defined by the user
    if(defined ${$self}{columns}){
        $columns = ${$self}{columns};
    } elsif(ref ${$masterSettings{modifyLineBreaks}{textWrapOptions}}{columns} eq "HASH"){
        if(defined ${${$masterSettings{modifyLineBreaks}{textWrapOptions}}{columns}}{default}){
            $columns = ${${$masterSettings{modifyLineBreaks}{textWrapOptions}}{columns}}{default};
        } else {
            $columns = 80;
        }
    } elsif (defined ${$masterSettings{modifyLineBreaks}{textWrapOptions}}{columns}){
        $columns = ${$masterSettings{modifyLineBreaks}{textWrapOptions}}{columns} ;
    } else {
        $columns = 80;
    }

    $Text::Wrap::columns=$columns;
    if(${$masterSettings{modifyLineBreaks}{textWrapOptions}}{separator} ne ''){
        $Text::Wrap::separator=${$masterSettings{modifyLineBreaks}{textWrapOptions}}{separator};
    }
    ${$self}{body} = wrap('','',${$self}{body});
}

sub construct_paragraph_reg_exp{
    my $self = shift;

    $logger->trace("*Constructing the paragraph-stop regexp (see paragraphsStopAt)") if $is_t_switch_active ;
    my $stopAtRegExp = q();
    while( my ($paragraphStopAt,$yesNo)= each %{${$masterSettings{modifyLineBreaks}{removeParagraphLineBreaks}}{paragraphsStopAt}}){
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
    return if(${$self}{lookForAlignDelims} and ${$masterSettings{modifyLineBreaks}{removeParagraphLineBreaks}}{alignAtAmpersandTakesPriority});

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

sub one_sentence_per_line{
    my $self = shift;

    return unless ${$masterSettings{modifyLineBreaks}{oneSentencePerLine}}{manipulateSentences};
    $logger->trace("*One sentence per line regular expression construction: (see oneSentencePerLine: manipulateSentences)") if $is_t_switch_active;

    # sentences FOLLOW
    # sentences FOLLOW
    # sentences FOLLOW
    my $sentencesFollow = q();

    while( my ($sentencesFollowEachPart,$yesNo)= each %{${$masterSettings{modifyLineBreaks}{oneSentencePerLine}}{sentencesFollow}}){
        if($yesNo){
            if($sentencesFollowEachPart eq "par"){
                $sentencesFollowEachPart = qr/\R?\\par/s;
            } elsif ($sentencesFollowEachPart eq "blankLine"){
                $sentencesFollowEachPart = qr/
                        (?:\A(?:$tokens{blanklines}\R)+)     # the order of each of these 
                                |                            # is important, as (like always) the first
                        (?:\G(?:$tokens{blanklines}\R)+)     # thing to be matched will 
                                |                            # be accepted
                        (?:(?:$tokens{blanklines}\h*\R)+)
                                |
                                \R{2,}
                                |
                                \G
                        /sx;
            } elsif ($sentencesFollowEachPart eq "fullStop"){
                $sentencesFollowEachPart = qr/\./s;
            } elsif ($sentencesFollowEachPart eq "exclamationMark"){
                $sentencesFollowEachPart = qr/\!/s;
            } elsif ($sentencesFollowEachPart eq "questionMark"){
                $sentencesFollowEachPart = qr/\?/s;
            } elsif ($sentencesFollowEachPart eq "rightBrace"){
                $sentencesFollowEachPart = qr/\}/s;
            } elsif ($sentencesFollowEachPart eq "commentOnPreviousLine"){
                $sentencesFollowEachPart = qr/$trailingCommentRegExp\h*\R/s;
            } elsif ($sentencesFollowEachPart eq "other"){
                $sentencesFollowEachPart = qr/$yesNo/;
            }
            $sentencesFollow .= ($sentencesFollow eq '' ? q() : "|").qr/$sentencesFollowEachPart/sx;
        }
    }
    # if blankLine is not active from sentencesFollow then we need to set up the 
    # beginning of the string, but make sure that it is *not* followed by a 
    # blank line token, or a blank line
    if(!${${$masterSettings{modifyLineBreaks}{oneSentencePerLine}}{sentencesFollow}}{blankLine}){
            $sentencesFollow .= ($sentencesFollow eq '' ? q() : "|").
                                    qr/
                                        \G
                                        (?!$tokens{blanklines})
                                    /sx;
    }

    if(${${$masterSettings{modifyLineBreaks}{oneSentencePerLine}}{sentencesFollow}}{blankLine}){
        $sentencesFollow = ($sentencesFollow eq '' ? q() : qr/(?:$sentencesFollow)(?:\h|\R)*/sx );
    } else {
        $sentencesFollow = ($sentencesFollow eq '' ? q() : qr/(?:$sentencesFollow)(?:\h*\R?)/sx );
    }


    $logger->trace("Sentences follow regexp:") if $is_tt_switch_active;
    $logger->trace($sentencesFollow) if $is_tt_switch_active;
    
    # sentences BEGIN with
    # sentences BEGIN with
    # sentences BEGIN with
    my $sentencesBeginWith = q();

    while( my ($sentencesBeginWithEachPart,$yesNo)= each %{${$masterSettings{modifyLineBreaks}{oneSentencePerLine}}{sentencesBeginWith}}){
        if($yesNo){
            if($sentencesBeginWithEachPart eq "A-Z"){
                $logger->trace("sentence BEGINS with capital letters (see oneSentencePerLine:sentencesBeginWith:A-Z)") if $is_t_switch_active;
                $sentencesBeginWithEachPart = qr/(?!(?:$tokens{blanklines}|$tokens{verbatim}|$tokens{preamble}))[A-Z]/;
            } elsif ($sentencesBeginWithEachPart eq "a-z"){
                $logger->trace("sentence BEGINS with lower-case letters (see oneSentencePerLine:sentencesBeginWith:a-z)") if $is_t_switch_active;
                $sentencesBeginWithEachPart = qr/[a-z]/;
            } elsif ($sentencesBeginWithEachPart eq "other"){
                $logger->trace("sentence BEGINS with other $yesNo (reg exp) (see oneSentencePerLine:sentencesBeginWith:other)") if $is_t_switch_active;
                $sentencesBeginWithEachPart = qr/$yesNo/;
            }
            $sentencesBeginWith .= ($sentencesBeginWith eq "" ? q(): "|" ).$sentencesBeginWithEachPart;
        }
    }
    $sentencesBeginWith = qr/$sentencesBeginWith/;

    # sentences END with
    # sentences END with
    # sentences END with
    ${${$masterSettings{modifyLineBreaks}{oneSentencePerLine}}{sentencesEndWith}}{basicFullStop} = 0 if ${${$masterSettings{modifyLineBreaks}{oneSentencePerLine}}{sentencesEndWith}}{betterFullStop};
    my $sentencesEndWith = q();

    while( my ($sentencesEndWithEachPart,$yesNo)= each %{${$masterSettings{modifyLineBreaks}{oneSentencePerLine}}{sentencesEndWith}}){
        if($yesNo){
            if($sentencesEndWithEachPart eq "basicFullStop"){
                $logger->trace("sentence ENDS with full stop (see oneSentencePerLine:sentencesEndWith:basicFullStop") if $is_t_switch_active;
                $sentencesEndWithEachPart = qr/\./;
            } elsif($sentencesEndWithEachPart eq "betterFullStop"){
                $logger->trace("sentence ENDS with *better* full stop (see oneSentencePerLine:sentencesEndWith:betterFullStop") if $is_t_switch_active;
                $sentencesEndWithEachPart = qr/(?:\.\)(?!\h*[a-z]))|(?:(?<!(?:(?:e\.g)|(?:i\.e)|(?:etc))))\.(?!(?:[a-z]|[A-Z]|\-|\,|[0-9]))/;
            } elsif ($sentencesEndWithEachPart eq "exclamationMark"){
                $logger->trace("sentence ENDS with exclamation mark (see oneSentencePerLine:sentencesEndWith:exclamationMark)") if $is_t_switch_active;
                $sentencesEndWithEachPart = qr/!/;
            } elsif ($sentencesEndWithEachPart eq "questionMark"){
                $logger->trace("sentence ENDS with question mark (see oneSentencePerLine:sentencesEndWith:questionMark)") if $is_t_switch_active;
                $sentencesEndWithEachPart = qr/\?/;
            } elsif ($sentencesEndWithEachPart eq "other"){
                $logger->trace("sentence ENDS with other $yesNo (reg exp) (see oneSentencePerLine:sentencesEndWith:other)") if $is_t_switch_active;
                $sentencesEndWithEachPart = qr/$yesNo/;
            }
            $sentencesEndWith .= ($sentencesEndWith eq "" ? q(): "|" ).$sentencesEndWithEachPart;
        }
    }
    $sentencesEndWith = qr/$sentencesEndWith/;

    # the OVERALL sentence regexp
    # the OVERALL sentence regexp
    # the OVERALL sentence regexp
    $logger->trace("Overall sentences end with regexp:") if $is_tt_switch_active;
    $logger->trace($sentencesEndWith) if $is_tt_switch_active;

    $logger->trace("Finding sentences...") if $is_t_switch_active;

    my $notWithinSentence = qr/$trailingCommentRegExp/s;

    # if 
    #
    #   modifyLineBreaks
    #       oneSentencePerLine
    #           sentencesFollow
    #               blankLine
    #
    # is set to 0 then we need to *exclude* the $tokens{blanklines} from the sentence routine,
    # otherwise we could begin a sentence with $tokens{blanklines}.
    if(!${${$masterSettings{modifyLineBreaks}{oneSentencePerLine}}{sentencesFollow}}{blankLine}){
        $notWithinSentence .= "|".qr/(?:\h*\R?$tokens{blanklines})/s;
    }

    # similarly for \par
    if(${${$masterSettings{modifyLineBreaks}{oneSentencePerLine}}{sentencesFollow}}{par}){
        $notWithinSentence .= "|".qr/(?:\R?\\par)/s;
    }

    # initiate the sentence counter
    my $sentenceCounter;
    my @sentenceStorage;

    # make the sentence manipulation
    ${$self}{body} =~ s/((?:$sentencesFollow))
                            (\h*)
                            (?!$notWithinSentence) 
                            ((?:$sentencesBeginWith).*?)
                            ($sentencesEndWith)/
                            my $beginning = $1;
                            my $h_space   = ($2?$2:q());
                            my $middle    = $3;
                            my $end       = $4;
                            my $trailingComments = q();
                            # remove trailing comments from within the body of the sentence
                            while($middle =~ m|$trailingCommentRegExp|){
                                $middle =~ s|\h*($trailingCommentRegExp)||s;
                                $trailingComments .= $1;
                            }
                            # remove line breaks from within a sentence
                            $middle =~ s|
                                            (?!\A)      # not at the *beginning* of a match
                                            (\h*)\R     # possible horizontal space, then line break
                                        |$1?$1:" ";|esgx if ${$masterSettings{modifyLineBreaks}{oneSentencePerLine}}{removeSentenceLineBreaks};
                            $middle =~ s|$tokens{blanklines}\h*\R?|$tokens{blanklines}\n|sg;
                            $logger->trace("follows: $beginning") if $is_tt_switch_active;
                            $logger->trace("sentence: $middle") if $is_tt_switch_active;
                            $logger->trace("ends with: $end") if $is_tt_switch_active;
                            # reconstruct the sentence
                            $sentenceCounter++;
                            push(@sentenceStorage,{id=>$tokens{sentence}.$sentenceCounter.$tokens{endOfToken},value=>$middle.$end});
                            $beginning.$h_space.$tokens{sentence}.$sentenceCounter.$tokens{endOfToken}.$trailingComments;
                            /xsge;

    # loop back through the sentenceStorage and replace with the sentence, adjusting line breaks
    # before and after appropriately
    while( my $sentence = pop @sentenceStorage){
      my $sentenceStorageID = ${$sentence}{id};
      my $sentenceStorageValue = ${$sentence}{value};

      # option to text wrap (and option to indent) sentences
      if(${$masterSettings{modifyLineBreaks}{oneSentencePerLine}}{textWrapSentences}){
              my $sentenceObj = LatexIndent::Document->new(body=>$sentenceStorageValue,
                                                    name=>"sentence",
                                                    modifyLineBreaksYamlName=>"sentence",
                                                    );

              # text wrapping
              $sentenceObj->yaml_get_columns;
              $sentenceObj->text_wrap;

              # indentation of sentences
              if(${$sentenceObj}{body} =~ m/
                                  (.*?)      # content of first line
                                  \R         # first line break
                                  (.*$)      # rest of body
                                  /sx){
                  my $bodyFirstLine = $1;
                  my $remainingBody = $2;
                  my $indentation = ${$masterSettings{modifyLineBreaks}{oneSentencePerLine}}{sentenceIndent};
                  $logger->trace("first line of sencent:  $bodyFirstLine") if $is_tt_switch_active;
                  $logger->trace("remaining body (before indentation):\n'$remainingBody'") if($is_tt_switch_active);
    
                  # add the indentation to all the body except first line
                  $remainingBody =~ s/^/$indentation/mg unless($remainingBody eq '');  # add indentation
                  $logger->trace("remaining body (after indentation):\n$remainingBody'") if($is_tt_switch_active);
    
                  # put the body back together
                  ${$sentenceObj}{body} = $bodyFirstLine."\n".$remainingBody; 
              }
              $sentenceStorageValue = ${$sentenceObj}{body};
      };
      # sentence at the very END
      ${$self}{body} =~ s/\h*$sentenceStorageID\h*$/$sentenceStorageValue/s;
      # sentence at the very BEGINNING
      ${$self}{body} =~ s/^$sentenceStorageID\h*\R?/$sentenceStorageValue\n/s;
      # all other sentences
      ${$self}{body} =~ s/\R?\h*$sentenceStorageID\h*\R?/\n$sentenceStorageValue\n/s;
    }

}

1;
