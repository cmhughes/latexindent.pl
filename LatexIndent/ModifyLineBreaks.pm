package LatexIndent::ModifyLineBreaks;
use strict;
use warnings;
use Exporter qw/import/;
our @EXPORT_OK = qw/modify_line_breaks_body_and_end pre_print pre_print_entire_body adjust_line_breaks_end_parent/;
our @allObjects;

sub pre_print_entire_body{
    my $self = shift;

    return unless $self->is_m_switch_active;

    # pre print the entire document, strip comments
    $self->pre_print;

    # search for undisclosed linebreaks, no need to do this recursively as @allObjects is flat (one-dimensional)
    my $pre_print_body = ${$self}{body};
    my $trailingCommentsRegExp = $self->get_trailing_comment_regexp;
    $pre_print_body =~ s/$trailingCommentsRegExp//mg;

    # replace all of the IDs with their associated (no-comments) begin, body, end statements
    while(scalar @allObjects>0){
        foreach my $child (@allObjects){
            ${$child}{test} = "cmh";
            if($pre_print_body =~ m/${$child}{id}/){
                $pre_print_body =~ s/${$child}{id}/${${$child}{noComments}}{begin}${${$child}{noComments}}{body}${${$child}{noComments}}{end}/;
                # check for an undisclosed line break
                if(${${$child}{noComments}}{body} =~ m/\R$/m and !${$child}{linebreaksAtEnd}{body}){
                    $self->logger("Undisclosed line break at the end of body of ${$child}{name}: '${$child}{end}'",'trace');
                    $self->logger("Adding a linebreak at the end of body for ${$child}{id}",'trace');
                    ${$child}{body} .= "\n";
                    ${$child}{linebreaksAtEnd}{body}=1;
                }
                my $index = 0;
                $index++ until ${$allObjects[$index]}{id} eq ${$child}{id};
                splice(@allObjects, $index, 1);
            }
        }
    }

    # output the body to the log file
    $self->logger("Pre-print body (after sweep), no comments (just to check linebreaks)","heading.ttrace");
    $self->logger($pre_print_body,'ttrace');

}

sub pre_print{
    my $self = shift;

    return unless $self->is_m_switch_active;

    my $trailingCommentsRegExp = $self->get_trailing_comment_regexp;

    # send the children through this routine recursively
    foreach my $child (@{${$self}{children}}){
        $child->pre_print;
        ${${$child}{noComments}}{begin} = "begin".reverse ${$child}{id};
        ${${$child}{noComments}}{begin} .= "\n" if(${$child}{linebreaksAtEnd}{begin});
        ${${$child}{noComments}}{body} = ${$child}{body};
        ${${$child}{noComments}}{end} = "end".reverse ${$child}{id};
        ${${$child}{noComments}}{end} .= "\n" if(${$child}{linebreaksAtEnd}{end});

        # remove all trailing comments from the copied begin, body and end statements
        ${${$child}{noComments}}{begin} =~ s/$trailingCommentsRegExp//mg;
        ${${$child}{noComments}}{body} =~ s/$trailingCommentsRegExp//mg;
        ${${$child}{noComments}}{end} =~ s/$trailingCommentsRegExp//mg;
        push(@allObjects,$child);
    }

}

sub modify_line_breaks_body_and_end{
    my $self = shift;
    my $trailingCommentRegExp = $self->get_trailing_comment_regexp;

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
       } elsif (${$self}{BodyStartsOnOwnLine}==0 and ${$self}{linebreaksAtEnd}{begin}){
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
              ${$self}{body} .= "$trailingCommentToken\n";
              ${$self}{linebreaksAtEnd}{body} = 1;
          } elsif (${$self}{EndStartsOnOwnLine}==0 and ${$self}{linebreaksAtEnd}{body}){
              # remove line break *after* body, if appropriate

              # check to see that body does *not* finish with blank-line-token, 
              # if so, then don't remove that final line break
              my $blankLineToken = $self->get_blank_line_token;
              if(${$self}{body} !~ m/$blankLineToken$/s){
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

    my $self = shift;

    return unless $self->is_m_switch_active;

    # most recent child object
    my $child = @{${$self}{children}}[-1];

    # adjust parent linebreaks information
    if(${$child}{linebreaksAtEnd}{end} and ${$self}{body} =~ m/${$child}{replacementText}\h*\R*$/s and !${$self}{linebreaksAtEnd}{body}){
        $self->logger("ID: ${$child}{id}",'trace');
        $self->logger("${$child}{begin}...${$child}{end} is found at the END of body of parent, ${$self}{name}, avoiding a double line break:",'trace');
        $self->logger("adjusting ${$self}{name} linebreaksAtEnd{body} to be 1",'trace');
        ${$self}{linebreaksAtEnd}{body}=1;
      }
}

1;
