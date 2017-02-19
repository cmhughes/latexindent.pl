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
use LatexIndent::Tokens qw/%tokens/;
use LatexIndent::TrailingComments qw/$trailingCommentRegExp/;
use LatexIndent::Switches qw/$is_m_switch_active $is_t_switch_active $is_tt_switch_active/;
our @EXPORT_OK = qw/modify_line_breaks_body_and_end adjust_line_breaks_end_parent/;
our @allObjects;

sub modify_line_breaks_body_and_end{
    my $self = shift;

    # add a line break after \begin{statement} if appropriate
    if(defined ${$self}{BodyStartsOnOwnLine}){
      my $BodyStringLogFile = ${$self}{aliases}{BodyStartsOnOwnLine}||"BodyStartsOnOwnLine";
      if(${$self}{BodyStartsOnOwnLine}>=1 and !${$self}{linebreaksAtEnd}{begin}){
          if(${$self}{BodyStartsOnOwnLine}==1){
            # modify the begin statement
            $self->logger("Adding a linebreak at the end of begin, ${$self}{begin} (see $BodyStringLogFile)");
            ${$self}{begin} .= "\n";       
            ${$self}{linebreaksAtEnd}{begin} = 1;
            $self->logger("Removing leading space from body of ${$self}{name} (see $BodyStringLogFile)");
            ${$self}{body} =~ s/^\h*//;       
          } elsif(${$self}{BodyStartsOnOwnLine}==2){
            # by default, assume that no trailing comment token is needed
            my $trailingCommentToken = q();
            if(${$self}{body} !~ m/^\h*$trailingCommentRegExp/s){
                # modify the begin statement
                $self->logger("Adding a % at the end of begin, ${$self}{begin}, followed by a linebreak ($BodyStringLogFile == 2)");
                $trailingCommentToken = "%".$self->add_comment_symbol;
                ${$self}{begin} =~ s/\h*$//;       
                ${$self}{begin} .= "$trailingCommentToken\n";       
                ${$self}{linebreaksAtEnd}{begin} = 1;
                $self->logger("Removing leading space from body of ${$self}{name} (see $BodyStringLogFile)");
                ${$self}{body} =~ s/^\h*//;       
            } else {
                $self->logger("Even though $BodyStringLogFile == 2, ${$self}{begin} already finishes with a %, so not adding another.");
            }
          } 
       } elsif (${$self}{BodyStartsOnOwnLine}==-1 and ${$self}{linebreaksAtEnd}{begin}){
          # remove line break *after* begin, if appropriate
          $self->logger("Removing linebreak at the end of begin (see $BodyStringLogFile)");
          ${$self}{begin} =~ s/\R*$//sx;
          ${$self}{linebreaksAtEnd}{begin} = 0;
       }
    }

    # possibly modify line break *before* \end{statement}
    if(defined ${$self}{EndStartsOnOwnLine}){
          my $EndStringLogFile = ${$self}{aliases}{EndStartsOnOwnLine}||"EndStartsOnOwnLine";
          if(${$self}{EndStartsOnOwnLine}>=1 and !${$self}{linebreaksAtEnd}{body}){
              # add a line break after body, if appropriate
              $self->logger("Adding a linebreak at the end of body (see $EndStringLogFile)");

              # by default, assume that no trailing comment token is needed
              my $trailingCommentToken = q();
              if(${$self}{EndStartsOnOwnLine}==2){
                $self->logger("Adding a % immediately after body of ${$self}{name} ($EndStringLogFile==2)");
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
                $self->logger("Removing linebreak at the end of body (see $EndStringLogFile)");
                ${$self}{body} =~ s/\R*$//sx;
                ${$self}{linebreaksAtEnd}{body} = 0;
              } else {
                $self->logger("Blank line token found at end of body (${$self}{name}), see preserveBlankLines, not removing line break before ${$self}{end}");
              }
          }
    }

    # possibly modify line break *after* \end{statement}
    if(defined ${$self}{EndFinishesWithLineBreak}
       and ${$self}{EndFinishesWithLineBreak}>=1 
       and !${$self}{linebreaksAtEnd}{end}){
              my $EndStringLogFile = ${$self}{aliases}{EndFinishesWithLineBreak}||"EndFinishesWithLineBreak";
              if(${$self}{EndFinishesWithLineBreak}==1){
                $self->logger("Adding a linebreak at the end of ${$self}{end} (see $EndStringLogFile)");
                ${$self}{linebreaksAtEnd}{end} = 1;

                # modified end statement
                ${$self}{replacementText} .= "\n";
              } elsif(${$self}{EndFinishesWithLineBreak}==2){
                if(${$self}{endImmediatelyFollowedByComment}){
                  # no need to add a % if one already exists
                  $self->logger("Even though $EndStringLogFile == 2, ${$self}{end} is immediately followed by a %, so not adding another; not adding line break.");
                } else {
                  # otherwise, create a trailing comment, and tack it on 
                  $self->logger("Adding a % immediately after, ${$self}{end} ($EndStringLogFile==2)");
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

1;
