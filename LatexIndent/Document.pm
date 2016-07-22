package LatexIndent::Document;
use strict;
use warnings;
use Data::Dumper;
use Data::UUID;

# gain access to subroutines in the following modules
use LatexIndent::Logfile qw/logger output_logfile processSwitches get_switches/;
use LatexIndent::GetYamlSettings qw/masterYamlSettings readSettings/;
use LatexIndent::Verbatim qw/put_verbatim_back_in find_verbatim_environments find_noindent_block/;
use LatexIndent::BackUpFileProcedure qw/create_back_up_file/;
use LatexIndent::BlankLines qw/protect_blank_lines unprotect_blank_lines condense_blank_lines/;
use LatexIndent::Environment qw/find_environments/;

our $environmentCounter;

sub new{
    # Create new objects, with optional key/value pairs
    # passed as initializers.
    #
    # See Programming Perl, pg 319
    my $invocant = shift;
    my $class = ref($invocant) || $invocant;
    my $self = {@_};
    bless ($self,$class);
    return $self;
}

sub remove_leading_space{
    my $self = shift;
    $self->logger("Removing leading space from entire document (verbatim/noindentblock already accounted for)",'heading');
    ${$self}{body} =~ s/
                        (   
                            ^           # beginning of the line
                            \h*         # with 0 or more horizontal spaces
                        )?              # possibly
                        //mxg;
    return;
}

sub operate_on_file{
    my $self = shift;
    $self->masterYamlSettings;
    # file extension check
    $self->create_back_up_file;
    $self->find_noindent_block;
    $self->remove_trailing_comments;
    $self->find_verbatim_environments;
    $self->protect_blank_lines;
    # find filecontents environments
    # find preamble
    $self->remove_leading_space;
    # token check (we use tokens for trailing comments, environments, commands, etc, so check that they're not in the body)
    # find alignment environments
    $self->process_body_of_text;
    # process alignment environments
    $self->remove_trailing_whitespace;
    $self->condense_blank_lines;
    $self->unprotect_blank_lines;
    $self->put_verbatim_back_in;
    $self->put_trailing_comments_back_in;
    $self->output_indented_text;
    $self->output_logfile;
    return
}

sub output_indented_text{
    my $self = shift;

    # output to screen, unless silent mode
    print ${$self}{body} unless ${%{$self}{switches}}{silentMode};

    $self->logger("Output routine",'heading');

    # if -overwrite is active then output to original fileName
    if(${%{$self}{switches}}{overwrite}) {
        $self->logger("Overwriting file ${$self}{fileName}");
        open(OUTPUTFILE,">",${$self}{fileName});
        print OUTPUTFILE ${$self}{body};
        close(OUTPUTFILE);
    } elsif(${%{$self}{switches}}{outputToFile}) {
        $self->logger("Outputting to file ${%{$self}{switches}}{outputToFile}");
        open(OUTPUTFILE,">",${%{$self}{switches}}{outputToFile});
        print OUTPUTFILE ${$self}{body};
        close(OUTPUTFILE);
    } else {
        $self->logger("Not outputting to file; see -w and -o switches for more options.");
    }
    return;
}

sub process_body_of_text{
    my $self = shift;

    # search for environments
    $self->logger('looking for ENVIRONMENTS','heading');
    $self->find_environments;

    # if there are no verbatim children, return
    if(%{$self}{children}){
        $self->logger("Objects have been found.",'heading');
    } else {
        $self->logger("No objects found.",'heading');
        return;
    }

    # logfile information
    $self->logger(Dumper(\%{$self}),'ttrace');
    $self->logger("Operating on: $self",'heading');
    $self->logger("Number of children:",'heading');
    $self->logger(scalar keys %{%{$self}{children}});

    $self->logger("searching for hidden children",'ttrace');
    # finding hidden children
    while( my ($key,$child)= each %{%{$self}{children}}){
        if(${$self}{body} !~ m/${$child}{id}/){
            $self->logger("child not found, ${$child}{id}",'ttrace');
            ${$self}{hiddenChildren}{${$child}{id}} = \%{$child};
        } else {
            $self->logger("child found, ${$child}{id}",'ttrace');
        }
    }

    # operate on hiddenChildren, if any
    if(%{$self}{hiddenChildren}){
        $self->logger("Hidden children: ",'heading.ttrace');
        $self->logger(Dumper(\%{%{$self}{hiddenChildren}}),'ttrace');

        # surrounding indentation
        $self->logger("Adding surrounding indentation");

        # loop through hidden children
        while( my ($key,$hiddenChild)= each %{%{$self}{hiddenChildren}}){
            $self->logger("Searching sibblings for ${$hiddenChild}{id} (${$hiddenChild}{name})",'heading.ttrace');

            # try to find in one of the other children
            while( my ($key,$child)= each %{%{$self}{children}}){
               if(${$child}{body} =~ m/${$hiddenChild}{id}/){
                    $self->logger("Hidden child found! ${$hiddenChild}{name} within ${$child}{name}",'ttrace');
                    ${${$self}{children}{${$hiddenChild}{id}}}{surroundingIndentation} = \${$child}{indentation};
                    $self->logger(Dumper(\%{${$self}{children}{${$hiddenChild}{id}}}),'ttrace');
               }
            }
        }
    }

    # the modify line switch can adjust line breaks, so we need another sweep
    $self->pre_print;

    $self->logger('Pre-processed body:','heading');
    $self->logger(${$self}{body});
    $self->logger("Indenting children objects:",'heading');

    # loop through document children hash
    while( (scalar keys %{%{$self}{children}})>0 ){
          while( my ($key,$child)= each %{%{$self}{children}}){
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
                my $surroundingIndentation = ${$child}{surroundingIndentation}?${${$child}{surroundingIndentation}}:q();

                # log file info
                $self->logger("Indenting  ${$child}{name} (id: ${$child}{id})",'heading');
                $self->logger("current indentation: '$surroundingIndentation'");
                $self->logger("looking up indentation scheme for ${$child}{name}");

                # line break checks before \begin{statement}
                if(defined ${$child}{BeginStartsOnOwnLine}){
                    if(${$child}{BeginStartsOnOwnLine}==1 and !$IDFirstNonWhiteSpaceCharacter){
                        $self->logger("Adding a linebreak at the beginning of ${$child}{begin} (see BeginStartsOnOwnLine)");
                        ${$child}{begin} = "\n".${$child}{begin};
                        ${$child}{begin} =~ s/^(\h*)?/$surroundingIndentation/mg;  # add indentation
                    } elsif (${$child}{BeginStartsOnOwnLine}==0 and $IDFirstNonWhiteSpaceCharacter){
                        $self->logger("Removing linebreak before ${$child}{begin} (see BeginStartsOnOwnLine)",'heading');
                        ${$self}{body} =~ s/\R*(\h*)?${$child}{id}/${$child}{id}/s;
                    }
                }

                # line break checks *after* \end{statement}
                if (defined ${$child}{EndFinishesWithLineBreak}
                    and ${$child}{EndFinishesWithLineBreak}==0 
                    and $IDFollowedImmediatelyByLineBreak) {
                    # remove line break *after* \end{statement}, if appropriate
                    $self->logger("Removing linebreak after ${$child}{end} (see EndFinishesWithLineBreak)");
                    ${$self}{body} =~ s/${$child}{id}(\h*)?\R*\h*/${$child}{id}$1/s;
                    ${$child}{linebreaksAtEnd}{end} = 0;
                }

                # perform indentation
                $child->indent;
                $self->logger(Dumper(\%{$child}),'ttrace');

                # replace ids with body
                ${$self}{body} =~ s/${$child}{id}/${$child}{begin}${$child}{body}${$child}{end}/;

                # log file info
                $self->logger('Body now looks like:','heading.trace');
                $self->logger(${$self}{body},'trace');

                # delete the hash so it won't be operated upon again
                delete ${$self}{children}{${$child}{id}};
                $self->logger("deleted key");
              }
            }
    }

    # logfile info
    $self->logger("Number of children:",'heading');
    $self->logger(scalar keys %{%{$self}{children}});
    $self->logger('Post-processed body:','trace');
    $self->logger(${$self}{body},'trace');
    return;
}

sub pre_print{
    my $self = shift;
    return unless ${%{$self}{switches}}{modifyLineBreaks};

    $self->logger('Checking amalgamated line breaks (-m switch active):','heading.trace');

    $self->logger('children to process:','trace');
    $self->logger(scalar keys %{%{$self}{children}},'trace');

    my $processedChildren = 0;
    my $totalChildren = scalar keys %{%{$self}{children}};
    my $body = ${$self}{body};

    # loop through document children hash, remove comments, 
    # produce a pre-print of the document so that line breaks can be checked
    while($processedChildren != $totalChildren){
            foreach my $child (values %{%{$self}{children}}) { 
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
    $self->logger("Expanded body, no comments (just to check linebreaks)","heading.ttrace");
    $self->logger($body,'ttrace');

    # reset counter
    $processedChildren = 0;

    # sweep back through, check linebreaks
    while($processedChildren != $totalChildren){
            foreach my $child (values %{%{$self}{children}}) { 
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
    return;
}

sub create_unique_id{
    my $self = shift;

    # generate a unique ID (http://stackoverflow.com/questions/18628244/how-we-can-create-a-unique-id-in-perl)
    my $uuid1 = Data::UUID->new->create_str();

    # allocate id to the object
    ${$self}{id} = $uuid1;

    $environmentCounter++;
    ${$self}{id} = "LATEX-INDENT-ENVIRONMENT$environmentCounter";
    return;
}

sub remove_trailing_comments{
    my $self = shift;
    $self->logger("Storing trailing comments",'heading');
    my $commentCounter = 0;
    ${$self}{body} =~ s/
                            (?<!\\)  # not preceeded by a \
                            %        # % 
                            (
                                \h*? # followed by possible horizontal space
                                .*?  # and anything else
                            )
                            $        # up to the end of a line
                        /   
                            # increment comment counter and store comment
                            $commentCounter++;
                            ${${$self}{trailingcomments}}{"latexindenttrailingcomment$commentCounter"}= $1;

                            # replace comment with dummy text
                            "% latexindenttrailingcomment".$commentCounter;
                       /xsmeg;
    if(%{$self}{trailingcomments}){
        $self->logger("Trailing comments stored in:",'trace');
        $self->logger(Dumper(\%{%{$self}{trailingcomments}}),'trace');
    } else {
        $self->logger("No trailing comments found",'trace');
    }
    return;
}

sub put_trailing_comments_back_in{
    my $self = shift;
    return unless(%{$self}{trailingcomments});

    $self->logger("Returning trailing comments to body",'heading');
    while( my ($trailingcommentID,$trailingcommentValue)= each %{%{$self}{trailingcomments}}){
        if(${$self}{body} =~ m/%\h$trailingcommentID
                                (
                                    (?!          # not immediately preceeded by 
                                        (?<!\\)  # \
                                        %        # %
                                    ).*?
                                )                # captured into $1
                                (\h*)?$                
                            /mx and $1 ne ''){
            $self->logger("Comment not at end of line $trailingcommentID, moving it to end of line");
            ${$self}{body} =~ s/%\h$trailingcommentID(.*)$/$1%$trailingcommentValue/m;
        } else {
            ${$self}{body} =~ s/%\h$trailingcommentID/%$trailingcommentValue/;
        }
        $self->logger("replace $trailingcommentID with $trailingcommentValue",'trace');
    }
    return;
}

sub remove_trailing_whitespace{
    my $self = shift;
    return unless(${%{$self}{settings}}{removeTrailingWhitespace});

    $self->logger("Removing trailing white space");
    ${$self}{body} =~ s/
                       \h+  # followed by possible horizontal space
                       $    # up to the end of a line
                       //xsmg;

}

1;
