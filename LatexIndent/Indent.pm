# Indent.pm
#   contains subroutines for indentation (can be overwritten for each object, if necessary)
package LatexIndent::Indent;
use strict;
use warnings;
use Data::Dumper;
use Exporter qw/import/;
our @EXPORT_OK = qw/indent wrap_up_statement determine_total_indentation indent_begin indent_body indent_end_statement final_indentation_check push_family_tree_to_indent get_surrounding_indentation indent_children_recursively/;
our %familyTree;

sub push_family_tree_to_indent{
    my $self = shift;

    %familyTree = %{$self->get_family_tree};
}

sub indent{
    my $self = shift;

    # determine the surrounding and current indentation
    $self->determine_total_indentation;

    # indent the begin statement
    $self->indent_begin;

    # indent the body
    $self->indent_body;

    # indent the end statement
    $self->indent_end_statement;

    # output the completed object to the log file
    $self->logger("Complete indented object (${$self}{name}) after indentation:\n${$self}{begin}${$self}{body}${$self}{end}","trace");

    # wrap-up statement
    $self->wrap_up_statement;
    return $self;
}

sub wrap_up_statement{
    my $self = shift;
    $self->logger("Finished indenting ${$self}{name}",'heading');
    return $self;
  }

sub determine_total_indentation{
    my $self = shift;

    # calculate and grab the surrounding indentation
    $self->get_surrounding_indentation;

    # logfile information
    my $surroundingIndentation = ${$self}{surroundingIndentation};
    $self->logger("indenting object ${$self}{name}",'trace');
    (my $during = $surroundingIndentation) =~ s/\t/TAB/g;
    $self->logger("indentation *surrounding* object: '$during'",'trace');
    ($during = ${$self}{indentation}) =~ s/\t/TAB/g;
    $self->logger("indentation *of* object: '$during'",'trace');
    ($during = $surroundingIndentation.${$self}{indentation}) =~ s/\t/TAB/g;
    $self->logger("*total* indentation to be added: '$during'",'trace');

    # form the total indentation of the object
    ${$self}{indentation} = $surroundingIndentation.${$self}{indentation};

}

sub get_surrounding_indentation{
    my $self = shift;

    my $surroundingIndentation = q();

    if($familyTree{${$self}{id}}){
        $self->logger("Adopted ancestors found!");
        foreach(@{${$familyTree{${$self}{id}}}{ancestors}}){
            if(${$_}{type} eq "adopted"){
                my $newAncestorId = ${$_}{ancestorID};
                $self->logger("ancestor ID: $newAncestorId, adding indentation of $newAncestorId to surroundingIndentation of ${$self}{id}",'trace');
                $surroundingIndentation .= ref(${$_}{ancestorIndentation}) eq 'SCALAR'
                                                    ?
                                            (${${$_}{ancestorIndentation}}?${${$_}{ancestorIndentation}}:q())
                                                    :
                                            (${$_}{ancestorIndentation}?${$_}{ancestorIndentation}:q());
            }
        }
    }
    ${$self}{surroundingIndentation} = $surroundingIndentation;

}

sub indent_begin{
    # for most objects, the begin statement is just one line, but there are exceptions, e.g KeyEqualsValuesBraces
    return;
}

sub indent_body{
    my $self = shift;

    # grab the indentation of the object
    my $indentation = ${$self}{indentation};

    # output to the logfile
    $self->logger("Body (${$self}{name}) before indentation:\n${$self}{body}","trace");

    # last minute check for modified bodyLineBreaks
    $self->count_body_line_breaks if $self->is_m_switch_active;

    # body indendation
    if(${$self}{linebreaksAtEnd}{begin}==1){
        if(${$self}{body} =~ m/^\h*$/s){
            $self->logger("Body of ${$self}{name} is empty, not applying indentation","trace");
        } else {
            # put any existing horizontal space after the current indentation
            $self->logger("Entire body of ${$self}{name} receives indendentation","trace");
            ${$self}{body} =~ s/^(\h*)/$indentation$1/mg;  # add indentation
        }
    } elsif(${$self}{linebreaksAtEnd}{begin}==0 and ${$self}{bodyLineBreaks}>0) {
        if(${$self}{body} =~ m/
                            (.*?)      # content of first line
                            \R         # first line break
                            (.*$)      # rest of body
                            /sx){
            my $bodyFirstLine = $1;
            my $remainingBody = $2;
            $self->logger("first line of body: $bodyFirstLine",'heading.trace');
            $self->logger("remaining body (before indentation): '$remainingBody'",'trace');
    
            # add the indentation to all the body except first line
            $remainingBody =~ s/^/$indentation/mg unless($remainingBody eq '');  # add indentation
            $self->logger("remaining body (after indentation): '$remainingBody'",'trace');
    
            # put the body back together
            ${$self}{body} = $bodyFirstLine."\n".$remainingBody; 
        }
    }

    # the final linebreak can be modified by a child object; see test-cases/commands/figureValign-mod5.tex, for example
    if($self->is_m_switch_active and defined ${$self}{linebreaksAtEnd}{body} and ${$self}{linebreaksAtEnd}{body}==1 and ${$self}{body} !~ m/\R$/){
        $self->logger("Updating body for ${$self}{name} to contain a linebreak at the end (linebreaksAtEnd is 1, but there isn't currently a linebreak)",'trace');
        ${$self}{body} .= "\n";
    }

    # output to the logfile
    $self->logger("Body (${$self}{name}) after indentation:\n${$self}{body}","trace");
    return $self;
}

sub indent_end_statement{
    my $self = shift;
    my $surroundingIndentation = (${$self}{surroundingIndentation} and ${$self}{hiddenChildYesNo})
                                            ?
                                 (ref(${$self}{surroundingIndentation}) eq 'SCALAR'?${${$self}{surroundingIndentation}}:${$self}{surroundingIndentation})
                                            :q();

    # end{statement} indentation, e.g \end{environment}, \fi, }, etc
    if(${$self}{linebreaksAtEnd}{body}){
        ${$self}{end} =~ s/^\h*/$surroundingIndentation/mg;  # add indentation
        $self->logger("Adding surrounding indentation to ${$self}{end} (${$self}{name}: '$surroundingIndentation')");
     }
    return $self;
}

sub final_indentation_check{
    # problem:
    #       if a tab is appended to spaces, it will look different 
    #       from spaces appended to tabs (see test-cases/items/spaces-and-tabs.tex)
    # solution:
    #       move all of the tabs to the beginning of ${$self}{indentation}
    # notes;
    #       this came to light when studying test-cases/items/items1.tex

    my $self = shift;

    my $indentationCounter;
    my @indentationTokens;

    while(${$self}{body} =~ m/^((\h*|\t*)((\h+)(\t+))+)(.*)/mg){
        # replace offending indentation with a token
        $indentationCounter++;
        my $indentationToken = "${$self->get_tokens}{indentation}$indentationCounter${$self->get_tokens}{endOfToken}";
        my $lineDetails = $6;
        ${$self}{body} =~ s/^((\h*|\t*)((\h+)(\t+))+)/$indentationToken/m;

        $self->logger("Final indentation check: tabs found after spaces -- rearranging so that spaces follow tabs",'trace');

        # fix the indentation
        my $indentation = $1;

        # log the before
        (my $before = $indentation) =~ s/\t/TAB/g;
        $self->logger("Indentation before: '$before'",'trace');

        # move tabs to the beginning
        while($indentation =~ m/(\h+[^\t])(\t+)/ and $indentation !~ m/^\t*$/  and $1 ne '' and $1 ne "\t"){
            $indentation =~ s/(\h+)(\t+)/$2$1/;

            # log the during
            (my $during = $indentation) =~ s/\t/TAB/g;
            $self->logger("Indentation during: '$during'",'trace');
        }

        # log the after
        (my $after = $indentation) =~ s/\t/TAB/g;
        $self->logger("Indentation after: '$after'",'trace');

        # store it
        push(@indentationTokens,{id=>$indentationToken,value=>$indentation});
    }

    # loop back through the body and replace tokens with updated values
    foreach (@indentationTokens){
        ${$self}{body} =~ s/${$_}{id}/${$_}{value}/;
    }

}

sub indent_children_recursively{
    my $self = shift;

    $self->logger('Pre-processed body:','heading.trace');
    $self->logger(${$self}{body},'trace');

    unless(defined ${$self}{children}){
        $self->logger("No child objects (${$self}{name})");
        return;
    }

    # send the children through this indentation routine recursively
    if(defined ${$self}{children}){
        foreach my $child (@{${$self}{children}}){
            $self->logger("Indenting child objects on ${$child}{name}");
            $child->indent_children_recursively;
        }
    }

    $self->logger("Replacing ids with begin, body, and end statements:",'heading');

    # loop through document children hash
    while( scalar (@{${$self}{children}}) > 0 ){
          # we work through the array *in order*
          foreach my $child (@{${$self}{children}}){
            $self->logger("Searching ${$self}{name} for ${$child}{id}...",'heading.trace');
            if(${$self}{body} =~ m/
                        (   
                            ^           # beginning of the line
                            \h*         # with 0 or more horizontal spaces
                        )?              # possibly
                                        #
                        (.*?)?          # any other character
                        ${$child}{id}   # the ID
                        (\h*)?          # possibly followed by horizontal space
                        (\R*)?          # then line breaks
                        /mx){
                my $IDFirstNonWhiteSpaceCharacter = $2?0:1;
                my $IDFollowedImmediatelyByLineBreak = $4?1:0;

                # log file info
                $self->logger("${$child}{id} found!",'trace');
                $self->logger("Indenting  ${$child}{name} (id: ${$child}{id})",'heading');
                $self->logger("looking up indentation scheme for ${$child}{name}");

                # line break checks *after* <end statement>
                if (defined ${$child}{EndFinishesWithLineBreak}
                    and ${$child}{EndFinishesWithLineBreak}==0 
                    and $IDFollowedImmediatelyByLineBreak) {
                    # remove line break *after* <end statement>, if appropriate
                    my $EndStringLogFile = ${$child}{aliases}{EndFinishesWithLineBreak}||"EndFinishesWithLineBreak";
                    $self->logger("Removing linebreak after ${$child}{end} (see $EndStringLogFile)");
                    ${$self}{body} =~ s/${$child}{id}(\h*)?(\R|\h)*/${$child}{id}$1/s;
                    ${$child}{linebreaksAtEnd}{end} = 0;
                }

                # perform indentation
                $child->indent;

                # surrounding indentation is now up to date
                my $surroundingIndentation = (${$child}{surroundingIndentation} and ${$child}{hiddenChildYesNo})
                                                        ?
                                             (ref(${$child}{surroundingIndentation}) eq 'SCALAR'?${${$child}{surroundingIndentation}}:${$child}{surroundingIndentation})
                                                        :q();

                # line break checks before <begin statement>
                if(defined ${$child}{BeginStartsOnOwnLine}){
                    my $BeginStringLogFile = ${$child}{aliases}{BeginStartsOnOwnLine}||"BeginStartsOnOwnLine";
                    if(${$child}{BeginStartsOnOwnLine}>=1 and !$IDFirstNonWhiteSpaceCharacter){
                        # by default, assume that no trailing comment token is needed
                        my $trailingCommentToken = q();
                        if(${$child}{BeginStartsOnOwnLine}==2){
                            $self->logger("Removing space immediately before ${$child}{id}, in preparation for adding % ($BeginStringLogFile == 2)");
                            ${$self}{body} =~ s/\h*${$child}{id}/${$child}{id}/s;
                            $self->logger("Adding a % at the end of the line that ${$child}{begin} is on, then a linebreak ($BeginStringLogFile == 2)");
                            $trailingCommentToken = "%".$self->add_comment_symbol;
                        } else {
                            $self->logger("Adding a linebreak at the beginning of ${$child}{begin} (see $BeginStringLogFile)");
                        }

                        # the trailing comment/linebreak magic
                        ${$child}{begin} = "$trailingCommentToken\n".${$child}{begin};
                        ${$child}{begin} =~ s/^(\h*)?/$surroundingIndentation/mg;  # add indentation

                        # remove surrounding indentation ahead of %
                        ${$child}{begin} =~ s/^(\h*)%/%/ if(${$child}{BeginStartsOnOwnLine}==2);
                    } elsif (${$child}{BeginStartsOnOwnLine}==0 and $IDFirstNonWhiteSpaceCharacter){
                        # important to check we don't move the begin statement next to a blank-line-token
                        my $blankLineToken = $self->get_blank_line_token;
                        if(${$self}{body} !~ m/$blankLineToken\R*\h*${$child}{id}/s){
                            $self->logger("Removing linebreak before ${$child}{begin} (see $BeginStringLogFile in ${$child}{modifyLineBreaksYamlName} YAML)");
                            ${$self}{body} =~ s/(\R*|\h*)+${$child}{id}/${$child}{id}/s;
                        } else {
                            $self->logger("Not removing linebreak ahead of ${$child}{begin}, as blank-line-token present (see preserveBlankLines)");
                        }
                    }
                }

                $self->logger(Dumper(\%{$child}),'ttrace');

                # replace ids with body
                ${$self}{body} =~ s/${$child}{id}/${$child}{begin}${$child}{body}${$child}{end}/;

                # log file info
                $self->logger("Body (${$self}{name}) now looks like:",'heading.trace');
                $self->logger(${$self}{body},'trace');

                # remove element from array: http://stackoverflow.com/questions/174292/what-is-the-best-way-to-delete-a-value-from-an-array-in-perl
                my $index = 0;
                $index++ until ${${$self}{children}[$index]}{id} eq ${$child}{id};
                splice(@{${$self}{children}}, $index, 1);

                # output to the log file
                $self->logger("deleted child key ${$child}{name} (parent is: ${$self}{name})");

                # restart the loop, as the size of the array has changed
                last;
              } else {
                $self->logger("${$child}{id} not found",'trace');
              }
            }
    }

    # logfile info
    $self->logger("${$self}{name} has this many children:",'heading');
    $self->logger(scalar @{${$self}{children}});
    $self->logger("Post-processed body (${$self}{name}):",'trace');
    $self->logger(${$self}{body},'trace');

}


1;
