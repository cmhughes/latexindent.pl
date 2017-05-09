package LatexIndent::Indent;
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
use LatexIndent::Tokens qw/%tokens/;
use LatexIndent::Switches qw/$is_m_switch_active $is_t_switch_active $is_tt_switch_active/;
use LatexIndent::HiddenChildren qw/%familyTree/;
use Data::Dumper;
use Exporter qw/import/;
our @EXPORT_OK = qw/indent wrap_up_statement determine_total_indentation indent_begin indent_body indent_end_statement final_indentation_check push_family_tree_to_indent get_surrounding_indentation indent_children_recursively check_for_blank_lines_at_beginning put_blank_lines_back_in_at_beginning add_surrounding_indentation_to_begin_statement/;
our %familyTree;

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
    $self->logger("Complete indented object (${$self}{name}) after indentation:\n${$self}{begin}${$self}{body}${$self}{end}") if $is_t_switch_active;

    # wrap-up statement
    $self->wrap_up_statement;
    return $self;
}

sub wrap_up_statement{
    my $self = shift;
    $self->logger("Finished indenting ${$self}{name}",'heading') if $is_t_switch_active;
    return $self;
  }

sub determine_total_indentation{
    my $self = shift;

    # calculate and grab the surrounding indentation
    $self->get_surrounding_indentation;

    # logfile information
    my $surroundingIndentation = ${$self}{surroundingIndentation};
    $self->logger("indenting object ${$self}{name}") if($is_t_switch_active);
    (my $during = $surroundingIndentation) =~ s/\t/TAB/g;
    $self->logger("indentation *surrounding* object: '$during'") if($is_t_switch_active);
    ($during = ${$self}{indentation}) =~ s/\t/TAB/g;
    $self->logger("indentation *of* object: '$during'") if($is_t_switch_active);
    ($during = $surroundingIndentation.${$self}{indentation}) =~ s/\t/TAB/g;
    $self->logger("*total* indentation to be added: '$during'") if($is_t_switch_active);

    # form the total indentation of the object
    ${$self}{indentation} = $surroundingIndentation.${$self}{indentation};

}

sub get_surrounding_indentation{
    my $self = shift;

    my $surroundingIndentation = q();

    if($familyTree{${$self}{id}}){
        $self->logger("Adopted ancestors found!") if($is_t_switch_active);
        foreach(@{${$familyTree{${$self}{id}}}{ancestors}}){
            if(${$_}{type} eq "adopted"){
                my $newAncestorId = ${$_}{ancestorID};
                $self->logger("ancestor ID: $newAncestorId, adding indentation of $newAncestorId to surroundingIndentation of ${$self}{id}") if($is_t_switch_active);
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
    $self->logger("Body (${$self}{name}) before indentation:\n${$self}{body}") if $is_t_switch_active;

    # last minute check for modified bodyLineBreaks
    $self->count_body_line_breaks if $is_m_switch_active;

    # some objects need to check for blank line tokens at the beginning
    $self->check_for_blank_lines_at_beginning if $is_m_switch_active; 

    # some objects can format their body to align at the & character
    $self->align_at_ampersand if ${$self}{lookForAlignDelims};

    # possibly remove paragraph line breaks
    $self->paragraphs_on_one_line if $is_m_switch_active;

    # body indendation
    if(${$self}{linebreaksAtEnd}{begin}==1){
        if(${$self}{body} =~ m/^\h*$/s){
            $self->logger("Body of ${$self}{name} is empty, not applying indentation") if $is_t_switch_active;
        } else {
            # put any existing horizontal space after the current indentation
            $self->logger("Entire body of ${$self}{name} receives indendentation") if $is_t_switch_active;
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
            $self->logger("first line of body: $bodyFirstLine",'heading') if $is_t_switch_active;
            $self->logger("remaining body (before indentation):\n'$remainingBody'") if($is_t_switch_active);
    
            # add the indentation to all the body except first line
            $remainingBody =~ s/^/$indentation/mg unless($remainingBody eq '');  # add indentation
            $self->logger("remaining body (after indentation):\n$remainingBody'") if($is_t_switch_active);
    
            # put the body back together
            ${$self}{body} = $bodyFirstLine."\n".$remainingBody; 
        }
    }

    # if the routine check_for_blank_lines_at_beginning has been called, then the following routine
    # puts blank line tokens back in 
    $self->put_blank_lines_back_in_at_beginning if $is_m_switch_active; 

    # the final linebreak can be modified by a child object; see test-cases/commands/figureValign-mod5.tex, for example
    if($is_m_switch_active and defined ${$self}{linebreaksAtEnd}{body} and ${$self}{linebreaksAtEnd}{body}==1 and ${$self}{body} !~ m/\R$/){
        $self->logger("Updating body for ${$self}{name} to contain a linebreak at the end (linebreaksAtEnd is 1, but there isn't currently a linebreak)") if($is_t_switch_active);
        ${$self}{body} .= "\n";
    }

    # output to the logfile
    $self->logger("Body (${$self}{name}) after indentation:\n${$self}{body}") if $is_t_switch_active;
    return $self;
}

sub check_for_blank_lines_at_beginning{
    # some objects need this routine
    return;
}

sub put_blank_lines_back_in_at_beginning{
    # some objects need this routine
    return;
}

sub indent_end_statement{
    my $self = shift;
    my $surroundingIndentation = (${$self}{surroundingIndentation} and $familyTree{${$self}{id}})
                                            ?
                                 (ref(${$self}{surroundingIndentation}) eq 'SCALAR'?${${$self}{surroundingIndentation}}:${$self}{surroundingIndentation})
                                            :q();

    # end{statement} indentation, e.g \end{environment}, \fi, }, etc
    if(${$self}{linebreaksAtEnd}{body}){
        ${$self}{end} =~ s/^\h*/$surroundingIndentation/mg;  # add indentation
        $self->logger("Adding surrounding indentation to ${$self}{end} (${$self}{name}: '$surroundingIndentation')") if($is_t_switch_active);
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

    my $indentation;
    my $numberOfTABS; 
    my $after;
    ${$self}{body} =~ s/
                        ^((\h*|\t*)((\h+)(\t+))+)
                        /   
                        # fix the indentation
                        $indentation = $1;

                        # count the number of tabs
                        $numberOfTABS = () = $indentation=~ \/\t\/g;
                        $self->logger("Number of tabs: $numberOfTABS") if($is_t_switch_active);

                        # log the after
                        ($after = $indentation) =~ s|\t||g;
                        $after = "TAB"x$numberOfTABS.$after;
                        $self->logger("Indentation after: '$after'") if($is_t_switch_active);
                        ($indentation = $after) =~s|TAB|\t|g;
                        $indentation;
                       /xsmeg;

}

sub indent_children_recursively{
    my $self = shift;

    unless(defined ${$self}{children}) {
        $self->logger("No child objects (${$self}{name})") if $is_t_switch_active;
        return;
    }

    $self->logger('Pre-processed body:','heading') if $is_t_switch_active;
    $self->logger(${$self}{body}) if($is_t_switch_active);

    # send the children through this indentation routine recursively
    if(defined ${$self}{children}){
        foreach my $child (@{${$self}{children}}){
            $self->logger("Indenting child objects on ${$child}{name}") if $is_t_switch_active;
            $child->indent_children_recursively;
        }
    } 

    $self->logger("Replacing ids with begin, body, and end statements:",'heading') if $is_t_switch_active;

    # loop through document children hash
    while( scalar (@{${$self}{children}}) > 0 ){
          my $index = 0;
          # we work through the array *in order*
          foreach my $child (@{${$self}{children}}){
            $self->logger("Searching ${$self}{name} for ${$child}{id}...",'heading') if $is_t_switch_active;
            if(${$self}{body} =~ m/${$child}{id}/s){
                # we only care if id is first non-white space character 
                # and if followed by line break 
                # if m switch is active 
                my $IDFirstNonWhiteSpaceCharacter = 0;
                my $IDFollowedImmediatelyByLineBreak = 0;

                # update the above two, if necessary
                if ($is_m_switch_active){
                    $IDFirstNonWhiteSpaceCharacter = (${$self}{body} =~ m/^${$child}{id}/m 
                                                            or 
                                                         ${$self}{body} =~ m/^\h\h*${$child}{id}/m
                                                        ) ?1:0;
                    $IDFollowedImmediatelyByLineBreak = (${$self}{body} =~ m/${$child}{id}\h*\R*/m) ?1:0;
               }

                # log file info
                $self->logger("${$child}{id} found!") if($is_t_switch_active);
                $self->logger("Indenting  ${$child}{name} (id: ${$child}{id})",'heading') if $is_t_switch_active;
                $self->logger("looking up indentation scheme for ${$child}{name}") if($is_t_switch_active);

                # line break checks *after* <end statement>
                if (defined ${$child}{EndFinishesWithLineBreak}
                    and ${$child}{EndFinishesWithLineBreak}==-1 
                    and $IDFollowedImmediatelyByLineBreak) {
                    # remove line break *after* <end statement>, if appropriate
                    my $EndStringLogFile = ${$child}{aliases}{EndFinishesWithLineBreak}||"EndFinishesWithLineBreak";
                    $self->logger("Removing linebreak after ${$child}{end} (see $EndStringLogFile)") if $is_t_switch_active;
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
                            $self->logger("Removing space immediately before ${$child}{id}, in preparation for adding % ($BeginStringLogFile == 2)") if $is_t_switch_active;
                            ${$self}{body} =~ s/\h*${$child}{id}/${$child}{id}/s;
                            $self->logger("Adding a % at the end of the line that ${$child}{begin} is on, then a linebreak ($BeginStringLogFile == 2)") if $is_t_switch_active;
                            $trailingCommentToken = "%".$self->add_comment_symbol;
                        } else {
                            $self->logger("Adding a linebreak at the beginning of ${$child}{begin} (see $BeginStringLogFile)") if $is_t_switch_active;
                        }

                        # the trailing comment/linebreak magic
                        ${$child}{begin} = "$trailingCommentToken\n".${$child}{begin};
                        $child->add_surrounding_indentation_to_begin_statement;

                        # remove surrounding indentation ahead of %
                        ${$child}{begin} =~ s/^(\h*)%/%/ if(${$child}{BeginStartsOnOwnLine}==2);
                    } elsif (${$child}{BeginStartsOnOwnLine}==-1 and $IDFirstNonWhiteSpaceCharacter){
                        # important to check we don't move the begin statement next to a blank-line-token
                        my $blankLineToken = $tokens{blanklines};
                        if(${$self}{body} !~ m/$blankLineToken\R*\h*${$child}{id}/s){
                            $self->logger("Removing linebreak before ${$child}{begin} (see $BeginStringLogFile in ${$child}{modifyLineBreaksYamlName} YAML)") if $is_t_switch_active;
                            ${$self}{body} =~ s/(\h*)(?:\R*|\h*)+${$child}{id}/$1${$child}{id}/s;
                        } else {
                            $self->logger("Not removing linebreak ahead of ${$child}{begin}, as blank-line-token present (see preserveBlankLines)") if $is_t_switch_active;
                        }
                    }
                }

                $self->logger(Dumper(\%{$child}),'ttrace') if($is_tt_switch_active);

                # replace ids with body
                ${$self}{body} =~ s/${$child}{id}/${$child}{begin}${$child}{body}${$child}{end}/;

                # log file info
                $self->logger("Body (${$self}{name}) now looks like:",'heading') if $is_t_switch_active;
                $self->logger(${$self}{body}) if($is_t_switch_active);

                # remove element from array: http://stackoverflow.com/questions/174292/what-is-the-best-way-to-delete-a-value-from-an-array-in-perl
                splice(@{${$self}{children}}, $index, 1);

                # output to the log file
                $self->logger("deleted child key ${$child}{name} (parent is: ${$self}{name})") if $is_t_switch_active;

                # restart the loop, as the size of the array has changed
                last;
              } else {
                $self->logger("${$child}{id} not found") if($is_t_switch_active);
              }

              # increment the loop counter
              $index++;
            }
    }

    # logfile info
    $self->logger("${$self}{name} has this many children:",'heading') if $is_t_switch_active;
    $self->logger(scalar @{${$self}{children}}) if $is_t_switch_active;
    $self->logger("Post-processed body (${$self}{name}):") if($is_t_switch_active);
    $self->logger(${$self}{body}) if($is_t_switch_active);

}

sub add_surrounding_indentation_to_begin_statement{
    # almost all of the objects add surrounding indentation to the 'begin' statements, 
    # but some (e.g HEADING) have their own method
    my $self = shift;

    my $surroundingIndentation = ${$self}{surroundingIndentation};
    ${$self}{begin} =~ s/^(\h*)?/$surroundingIndentation/mg;  # add indentation

}

1;
