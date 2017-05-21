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
our @EXPORT_OK = qw/modify_line_breaks_body modify_line_breaks_end adjust_line_breaks_end_parent remove_line_breaks_begin max_char_per_line paragraphs_on_one_line construct_paragraph_reg_exp/;
our $paragraphRegExp = q();


sub modify_line_breaks_body{
    my $self = shift;

    # add a line break after \begin{statement} if appropriate
    if(defined ${$self}{BodyStartsOnOwnLine}){
      my $BodyStringLogFile = ${$self}{aliases}{BodyStartsOnOwnLine}||"BodyStartsOnOwnLine";
      if(${$self}{BodyStartsOnOwnLine}>=1 and !${$self}{linebreaksAtEnd}{begin}){
          if(${$self}{BodyStartsOnOwnLine}==1){
            # modify the begin statement
            $self->logger("Adding a linebreak at the end of begin, ${$self}{begin} (see $BodyStringLogFile)") if $is_t_switch_active;
            ${$self}{begin} .= "\n";       
            ${$self}{linebreaksAtEnd}{begin} = 1;
            $self->logger("Removing leading space from body of ${$self}{name} (see $BodyStringLogFile)") if $is_t_switch_active;
            ${$self}{body} =~ s/^\h*//;       
          } elsif(${$self}{BodyStartsOnOwnLine}==2){
            # by default, assume that no trailing comment token is needed
            my $trailingCommentToken = q();
            if(${$self}{body} !~ m/^\h*$trailingCommentRegExp/s){
                # modify the begin statement
                $self->logger("Adding a % at the end of begin, ${$self}{begin}, followed by a linebreak ($BodyStringLogFile == 2)") if $is_t_switch_active;
                $trailingCommentToken = "%".$self->add_comment_symbol;
                ${$self}{begin} =~ s/\h*$//;       
                ${$self}{begin} .= "$trailingCommentToken\n";       
                ${$self}{linebreaksAtEnd}{begin} = 1;
                $self->logger("Removing leading space from body of ${$self}{name} (see $BodyStringLogFile)") if $is_t_switch_active;
                ${$self}{body} =~ s/^\h*//;       
            } else {
                $self->logger("Even though $BodyStringLogFile == 2, ${$self}{begin} already finishes with a %, so not adding another.") if $is_t_switch_active;
            }
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
    $self->logger("Removing linebreak at the end of begin (see $BodyStringLogFile)") if $is_t_switch_active;
    ${$self}{begin} =~ s/\R*$//sx;
    ${$self}{linebreaksAtEnd}{begin} = 0;
}

sub modify_line_breaks_end{
    my $self = shift;

    # possibly modify line break *before* \end{statement}
    if(defined ${$self}{EndStartsOnOwnLine}){
          my $EndStringLogFile = ${$self}{aliases}{EndStartsOnOwnLine}||"EndStartsOnOwnLine";
          if(${$self}{EndStartsOnOwnLine}>=1 and !${$self}{linebreaksAtEnd}{body}){
              # add a line break after body, if appropriate
              $self->logger("Adding a linebreak at the end of body (see $EndStringLogFile)") if $is_t_switch_active;

              # by default, assume that no trailing comment token is needed
              my $trailingCommentToken = q();
              if(${$self}{EndStartsOnOwnLine}==2){
                $self->logger("Adding a % immediately after body of ${$self}{name} ($EndStringLogFile==2)") if $is_t_switch_active;
                $trailingCommentToken = "%".$self->add_comment_symbol;
                ${$self}{body} =~ s/\h*$//s;
              }
              
              # modified end statement
              if(${$self}{body} =~ m/^\h*$/s and ${$self}{BodyStartsOnOwnLine} >=1 ){
                ${$self}{linebreaksAtEnd}{body} = 0;
              } else {
                ${$self}{body} .= "$trailingCommentToken\n";
                ${$self}{linebreaksAtEnd}{body} = 1;
              }
          } elsif (${$self}{EndStartsOnOwnLine}==-1 and ${$self}{linebreaksAtEnd}{body}){
              # remove line break *after* body, if appropriate

              # check to see that body does *not* finish with blank-line-token, 
              # if so, then don't remove that final line break
              if(${$self}{body} !~ m/$tokens{blanklines}$/s){
                $self->logger("Removing linebreak at the end of body (see $EndStringLogFile)") if $is_t_switch_active;
                ${$self}{body} =~ s/\R*$//sx;
                ${$self}{linebreaksAtEnd}{body} = 0;
              } else {
                $self->logger("Blank line token found at end of body (${$self}{name}), see preserveBlankLines, not removing line break before ${$self}{end}") if $is_t_switch_active;
              }
          }
    }

    # possibly modify line break *after* \end{statement}
    if(defined ${$self}{EndFinishesWithLineBreak}
       and ${$self}{EndFinishesWithLineBreak}>=1 
       and !${$self}{linebreaksAtEnd}{end}){
              my $EndStringLogFile = ${$self}{aliases}{EndFinishesWithLineBreak}||"EndFinishesWithLineBreak";
              if(${$self}{EndFinishesWithLineBreak}==1){
                $self->logger("Adding a linebreak at the end of ${$self}{end} (see $EndStringLogFile)") if $is_t_switch_active;
                ${$self}{linebreaksAtEnd}{end} = 1;

                # modified end statement
                ${$self}{replacementText} .= "\n";
              } elsif(${$self}{EndFinishesWithLineBreak}==2){
                if(${$self}{endImmediatelyFollowedByComment}){
                  # no need to add a % if one already exists
                  $self->logger("Even though $EndStringLogFile == 2, ${$self}{end} is immediately followed by a %, so not adding another; not adding line break.") if $is_t_switch_active;
                } else {
                  # otherwise, create a trailing comment, and tack it on 
                  $self->logger("Adding a % immediately after, ${$self}{end} ($EndStringLogFile==2)") if $is_t_switch_active;
                  my $trailingCommentToken = "%".$self->add_comment_symbol;
                  ${$self}{end} =~ s/\h*$//s;
                  ${$self}{replacementText} .= "$trailingCommentToken\n";
                  ${$self}{linebreaksAtEnd}{end} = 1;
                }
              }
    }

}

sub adjust_line_breaks_end_parent{
    # when a parent object contains a child object, the line break
    # at the end of the parent object can become messy
    return unless $is_m_switch_active;

    my $self = shift;

    # most recent child object
    my $child = @{${$self}{children}}[-1];

    # adjust parent linebreaks information
    if(${$child}{linebreaksAtEnd}{end} and ${$self}{body} =~ m/${$child}{replacementText}\h*\R*$/s and !${$self}{linebreaksAtEnd}{body}){
        $self->logger("ID: ${$child}{id}") if($is_t_switch_active);
        $self->logger("${$child}{begin}...${$child}{end} is found at the END of body of parent, ${$self}{name}, avoiding a double line break:") if($is_t_switch_active);
        $self->logger("adjusting ${$self}{name} linebreaksAtEnd{body} to be 1") if($is_t_switch_active);
        ${$self}{linebreaksAtEnd}{body}=1;
      }

    # the modify line switch can adjust line breaks, so we need another check, 
    # see for example, test-cases/environments/environments-remove-line-breaks-trailing-comments.tex
    if(defined ${$child}{linebreaksAtEnd}{body} 
        and !${$child}{linebreaksAtEnd}{body} 
        and ${$child}{body} =~ m/\R(?:$trailingCommentRegExp\h*)?$/s ){
        # log file information
        $self->logger("Undisclosed line break at the end of body of ${$child}{name}: '${$child}{end}'") if($is_t_switch_active);
        $self->logger("Adding a linebreak at the end of body for ${$child}{id}") if($is_t_switch_active);
        
        # make the adjustments
        ${$child}{body} .= "\n";
        ${$child}{linebreaksAtEnd}{body}=1;
    }

}

sub max_char_per_line{
    return unless $is_m_switch_active;

    my $self = shift;
    return unless ${$masterSettings{modifyLineBreaks}{textWrapOptions}}{columns}>1;

    # call the text wrapping routine
    $Text::Wrap::columns=${$masterSettings{modifyLineBreaks}{textWrapOptions}}{columns};
    if(${$masterSettings{modifyLineBreaks}{textWrapOptions}}{separator} ne ''){
        $Text::Wrap::separator=${$masterSettings{modifyLineBreaks}{textWrapOptions}}{separator};
    }
    ${$self}{body} = wrap('','',${$self}{body});
}

sub construct_paragraph_reg_exp{
    my $self = shift;

    my $stopAtRegExp = q();
    while( my ($paragraphStopAt,$yesNo)= each %{${$masterSettings{modifyLineBreaks}{removeParagraphLineBreaks}}{paragraphsStopAt}}){
        if($yesNo){
            # the headings (chapter, section, etc) need a slightly special treatment
            $paragraphStopAt = "afterHeading" if($paragraphStopAt eq "heading");

            # the comment need a slightly special treatment
            $paragraphStopAt = "trailingComment" if($paragraphStopAt eq "comments");

            # output to log file
            $self->logger("The paragraph-stop regexp WILL include $tokens{$paragraphStopAt} (see paragraphsStopAt)",'heading') if $is_t_switch_active ;

            # update the regexp
            if($paragraphStopAt eq "items"){
                $stopAtRegExp .= "|(?:\\\\(?:".$listOfItems."))";
            } else {
                $stopAtRegExp .= "|(?:".($paragraphStopAt eq "trailingComment" ? "%" : q() ).$tokens{$paragraphStopAt}."\\d+)";
            }
        } else {
            $self->logger("The paragraph-stop regexp won't include $tokens{$paragraphStopAt} (see paragraphsStopAt)",'heading') if $is_t_switch_active ;
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

    $self->logger("The paragraph-stop-regexp is:",'heading') if $is_tt_switch_active ;
    $self->logger($paragraphRegExp) if $is_tt_switch_active ;
}

sub paragraphs_on_one_line{
    my $self = shift;
    return unless ${$self}{removeParagraphLineBreaks};

    # alignment at ampersand can take priority
    return if(${$self}{lookForAlignDelims} and ${$masterSettings{modifyLineBreaks}{removeParagraphLineBreaks}}{alignAtAmpersandTakesPriority});

    $self->logger("Checking ${$self}{name} for paragraphs (see removeParagraphLineBreaks)") if $is_t_switch_active;

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
