package LatexIndent::Document;
use strict;
use warnings;
use Data::Dumper;

# gain access to subroutines in the following modules
use LatexIndent::LogFile qw/logger output_logfile processSwitches get_switches/;
use LatexIndent::GetYamlSettings qw/masterYamlSettings readSettings modify_line_breaks_settings get_indentation_settings_for_this_object get_every_or_custom_value/;
use LatexIndent::BackUpFileProcedure qw/create_back_up_file/;
use LatexIndent::BlankLines qw/protect_blank_lines unprotect_blank_lines condense_blank_lines/;
use LatexIndent::ModifyLineBreaks qw/modify_line_breaks_body_and_end pre_print/;
use LatexIndent::TrailingComments qw/remove_trailing_comments put_trailing_comments_back_in/;
use LatexIndent::HorizontalWhiteSpace qw/remove_trailing_whitespace remove_leading_space/;
use LatexIndent::Indent qw/indent wrap_up_statement determine_total_indentation indent_body indent_end_statement/;

# code blocks
use LatexIndent::Verbatim qw/put_verbatim_back_in find_verbatim_environments find_noindent_block/;
use LatexIndent::Environment qw/find_environments/;
use LatexIndent::IfElseFi qw/find_ifelsefi/;

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

sub operate_on_file{
    my $self = shift;
    $self->masterYamlSettings;
    # file extension check
    $self->create_back_up_file;
    $self->find_noindent_block;
    $self->remove_trailing_comments;
    $self->find_verbatim_environments;
    #$self->protect_blank_lines;
    # find filecontents environments
    # find preamble
    $self->remove_leading_space;
    # token check (we use tokens for trailing comments, environments, commands, etc, so check that they're not in the body)
    # find alignment environments
    $self->process_body_of_text;
    # process alignment environments
    # PREVIOUSLY FOUND SETTINGS: need another check, e.g if environment shares same name as (e.g) command
    $self->remove_trailing_whitespace;
    #$self->condense_blank_lines;
    #$self->unprotect_blank_lines;
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

    # find objects recursively
    $self->find_objects_recursively;

    $self->indent_children;
    return;
}

sub find_objects_recursively{
    my $self = shift;

    # search for environments
    $self->logger('looking for ENVIRONMENTS','heading');
    $self->find_environments;

    # search for ifElseFi blocks
    $self->logger('looking for IFELSEFI','heading');
    $self->find_ifelsefi;

    # if there are no children, return
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
    return;
}

sub indent_children{
    my $self = shift;

    $self->logger('Pre-processed body:','heading.trace');
    $self->logger(${$self}{body},'trace');

    unless(defined ${$self}{children}){
        $self->logger("No child objects");
        return;
    }

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
                    my $BeginStringLogFile = ${$child}{aliases}{everyBeginStartsOnOwnLine}||"everyBeginStartsOnOwnLine";
                    if(${$child}{BeginStartsOnOwnLine}==1 and !$IDFirstNonWhiteSpaceCharacter){
                        $self->logger("Adding a linebreak at the beginning of ${$child}{begin} (see $BeginStringLogFile)");
                        ${$child}{begin} = "\n".${$child}{begin};
                        ${$child}{begin} =~ s/^(\h*)?/$surroundingIndentation/mg;  # add indentation
                    } elsif (${$child}{BeginStartsOnOwnLine}==0 and $IDFirstNonWhiteSpaceCharacter){
                        $self->logger("Removing linebreak before ${$child}{begin} (see $BeginStringLogFile in ${$child}{modifyLineBreaksYamlName} YAML)");
                        ${$self}{body} =~ s/(\R*|\h*)+${$child}{id}/${$child}{id}/s;
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

}

sub tasks_common_to_each_object{
    my $self = shift;

    # in what follows, $self can be an environment, ifElseFi, etc

    # count linebreaks in body
    my $bodyLineBreaks = 0;
    $bodyLineBreaks++ while(${$self}{body} =~ m/\R/sxg);
    ${$self}{bodyLineBreaks} = $bodyLineBreaks;

    # get settings for this object
    $self->get_indentation_settings_for_this_object;

    # give unique id
    $self->create_unique_id;

    # the replacement text can be just the ID, but the ID might have a line break at the end of it
    ${$self}{replacementText} = ${$self}{id};

    # the above regexp, when used below, will remove the trailing linebreak in ${$self}{linebreaksAtEnd}{end}
    # so we compensate for it here
    ${$self}{replacementText} .= "\n" if(${$self}{linebreaksAtEnd}{end});

    # modify line breaks on body and end statements
    $self->modify_line_breaks_body_and_end;

    return;
}

1;
