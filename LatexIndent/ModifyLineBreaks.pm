package LatexIndent::ModifyLineBreaks;
use strict;
use warnings;
use Exporter qw/import/;
our @EXPORT_OK = qw/modify_line_breaks_body_and_end pre_print/;

sub pre_print{
    my $self = shift;
    return unless ${%{$self}{switches}}{modifyLineBreaks};

    $self->logger('Checking amalgamated line breaks (-m switch active):','heading.trace');

    $self->logger('children to process:','trace');
    $self->logger(scalar @{%{$self}{children}},'trace');

    my $processedChildren = 0;
    my $totalChildren = scalar @{%{$self}{children}};
    my $body = ${$self}{body};

    # loop through document children hash, remove comments, 
    # produce a pre-print of the document so that line breaks can be checked
    while($processedChildren != $totalChildren){
            foreach my $child (@{${$self}{children}}){
                if(index($body,${$child}{id}) != -1){
                    # make a copy of the begin, body and end statements
                    ${${$child}{noComments}}{begin} = "begin".reverse ${$child}{id};
                    ${${$child}{noComments}}{begin} .= "\n" if(${$child}{linebreaksAtEnd}{begin});
                    ${${$child}{noComments}}{body} = ${$child}{body};
                    ${${$child}{noComments}}{end} = "end".reverse ${$child}{id};
                    ${${$child}{noComments}}{end} .= "\n" if(${$child}{linebreaksAtEnd}{end});

                    # remove all trailing comments from the copied begin, body and end statements
                    ${${$child}{noComments}}{begin} =~ s/%\hlatexindenttrailingcomment\d+//mg;
                    ${${$child}{noComments}}{body} =~ s/%\hlatexindenttrailingcomment\d+//mg;
                    ${${$child}{noComments}}{end} =~ s/%\hlatexindenttrailingcomment\d+//mg;

                    # replace ids with body
                    $body =~ s/${$child}{id}/${${$child}{noComments}}{begin}${${$child}{noComments}}{body}${${$child}{noComments}}{end}/;

                    # increment the processed children counter
                    $processedChildren++;
                  }
             }
    }

    # remove any remaining comments
    $body =~ s/%\hlatexindenttrailingcomment\d+//mg;
    
    # output the body to the log file
    $self->logger("Expanded body (before sweep), no comments (just to check linebreaks)","heading.ttrace");
    $self->logger($body,'ttrace');

    # reset counter
    $processedChildren = 0;

    # sweep back through, check linebreaks
    while($processedChildren != $totalChildren){
            foreach my $child (@{${$self}{children}}){
                if(index($body,${${$child}{noComments}}{begin}.${${$child}{noComments}}{body}.${${$child}{noComments}}{end})!=-1){
                      # check for an undisclosed line break
                      if(${${$child}{noComments}}{body} =~ m/\R$/m and !${$child}{linebreaksAtEnd}{body}){
                          $self->logger("Undisclosed line break for ${$child}{end}",'trace');
                          ${$child}{body} .= "\n";
                          ${$child}{linebreaksAtEnd}{body}=1;
                      }

                      # replace block with ID
                      $body =~ s/\Q${${$child}{noComments}}{begin}${${$child}{noComments}}{body}${${$child}{noComments}}{end}\E/${$child}{id}/;

                      # increment the processed children counter
                      $processedChildren++;
                }
             }
    }

    $self->logger('Processed line breaks','heading.trace');
    $self->logger("Expanded body (after sweep), no comments (just to check linebreaks)","heading.ttrace");
    $self->logger($body,'ttrace');
    return;
}

sub modify_line_breaks_body_and_end{
    my $self = shift;

    # add a line break after \begin{statement} if appropriate
    if(defined ${$self}{BodyStartsOnOwnLine}){
      if(${$self}{BodyStartsOnOwnLine}==1 and !${$self}{linebreaksAtEnd}{begin}){
          $self->logger("Adding a linebreak at the end of begin, ${$self}{begin} (see BodyStartsOnOwnLine)");
          ${$self}{begin} .= "\n";       
          ${$self}{linebreaksAtEnd}{begin} = 1;
       } elsif (${$self}{BodyStartsOnOwnLine}==0 and ${$self}{linebreaksAtEnd}{begin}){
          # remove line break *after* begin, if appropriate
          $self->logger("Removing linebreak at the end of begin (see BodyStartsOnOwnLine)");
          ${$self}{begin} =~ s/\R*$//sx;
          ${$self}{linebreaksAtEnd}{begin} = 0;
       }
    }

    # possibly modify line break *before* \end{statement}
    if(defined ${$self}{EndStartsOnOwnLine}){
          if(${$self}{EndStartsOnOwnLine}==1 and !${$self}{linebreaksAtEnd}{body}){
              # add a line break after body, if appropriate
              $self->logger("Adding a linebreak at the end of body (see EndStartsOnOwnLine)");
              ${$self}{body} .= "\n";
              ${$self}{linebreaksAtEnd}{body} = 1;
          } elsif (${$self}{EndStartsOnOwnLine}==0 and ${$self}{linebreaksAtEnd}{body}){
              # remove line break *after* body, if appropriate
              $self->logger("Removing linebreak at the end of body (see EndStartsOnOwnLine)");
              ${$self}{body} =~ s/\R*$//sx;
              ${$self}{linebreaksAtEnd}{body} = 0;
          }
    }

    # possibly modify line break *after* \end{statement}
    if(defined ${$self}{EndFinishesWithLineBreak}
       and ${$self}{EndFinishesWithLineBreak}==1 
       and !${$self}{linebreaksAtEnd}{end}){
              $self->logger("Adding a linebreak at the end of ${$self}{end} (see EndFinishesWithLineBreak)",'heading');
              ${$self}{linebreaksAtEnd}{end} = 1;
              ${$self}{replacementText} .= "\n";
    }

}



1;
