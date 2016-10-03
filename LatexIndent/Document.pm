package LatexIndent::Document;
use strict;
use warnings;
use Data::Dumper;

# gain access to subroutines in the following modules
use LatexIndent::LogFile qw/logger output_logfile processSwitches is_m_switch_active/;
use LatexIndent::GetYamlSettings qw/readSettings modify_line_breaks_settings get_indentation_settings_for_this_object get_every_or_custom_value get_master_settings get_indentation_information/;
use LatexIndent::BackUpFileProcedure qw/create_back_up_file/;
use LatexIndent::BlankLines qw/protect_blank_lines unprotect_blank_lines condense_blank_lines get_blank_line_token/;
use LatexIndent::ModifyLineBreaks qw/modify_line_breaks_body_and_end pre_print adjust_line_breaks_end_parent/;
use LatexIndent::TrailingComments qw/remove_trailing_comments put_trailing_comments_back_in get_trailing_comment_token get_trailing_comment_regexp add_comment_symbol/;
use LatexIndent::HorizontalWhiteSpace qw/remove_trailing_whitespace remove_leading_space/;
use LatexIndent::Indent qw/indent wrap_up_statement determine_total_indentation indent_body indent_end_statement/;

# code blocks
use LatexIndent::Verbatim qw/put_verbatim_back_in find_verbatim_environments find_noindent_block/;
use LatexIndent::Environment qw/find_environments/;
use LatexIndent::IfElseFi qw/find_ifelsefi/;
use LatexIndent::Arguments qw/find_opt_mand_arguments/;
use LatexIndent::OptionalArgument qw/find_optional_arguments/;
use LatexIndent::MandatoryArgument qw/find_mandatory_arguments/;
use LatexIndent::Item qw/find_items/;

# hiddenChildren can be stored in a global array, it doesn't matter what level they're at
our @hiddenChildren;

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
    # file extension check
    $self->create_back_up_file;
    $self->find_noindent_block;
    $self->remove_trailing_comments;
    $self->find_verbatim_environments;
    $self->protect_blank_lines;
    $self->remove_trailing_whitespace(when=>"before");
    # find filecontents environments
    # find preamble
    $self->remove_leading_space;
    # token check (we use tokens for trailing comments, environments, commands, etc, so check that they're not in the body)
    # find alignment environments
    $self->process_body_of_text;
    # process alignment environments
    # PREVIOUSLY FOUND SETTINGS: need another check, e.g if environment shares same name as (e.g) command
    $self->remove_trailing_whitespace(when=>"after");
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

    # find objects recursively
    $self->logger('Phase 1: finding objects','heading');
    $self->find_objects_recursively;

    # find all hidden child
    $self->logger('Phase 2: finding surrounding indentation','heading');
    $self->find_surrounding_indentation_for_children;

    # indentation recursively
    $self->logger('Phase 3: indenting objects','heading');
    $self->indent_children_recursively;
    return;
}

sub find_objects_recursively{
    my $self = shift;

    # search for environments
    $self->logger('looking for ENVIRONMENTS');
    $self->find_environments;

    # search for ifElseFi blocks
    $self->logger('looking for IFELSEFI');
    $self->find_ifelsefi;

    # if there are no children, return
    if(%{$self}{children}){
        $self->logger("Objects have been found.",'heading');
    } else {
        $self->logger("No objects found.");
        return;
    }

    # logfile information
    $self->logger(Dumper(\%{$self}),'ttrace');
    $self->logger("Operating on: ${$self}{name}",'heading');
    $self->logger("Number of children:",'heading');
    $self->logger(scalar (@{${$self}{children}}));

    # send each child through this routine
    foreach my $child (@{${$self}{children}}){
        $self->logger("Searching ${$child}{name} recursively for objects...",'heading');
        $child->find_objects_recursively;
    }

    # the modify line switch can adjust line breaks, so we need another sweep
    $self->pre_print;
    return;
}

sub find_surrounding_indentation_for_children{
    my $self = shift;

    # find all hidden children
    $self->find_hidden_children;

    # operate on hidden children
    foreach (@hiddenChildren){
        $self->operate_on_hidden_children($_);
    }
    return;
}

sub find_hidden_children{
    my $self = shift;

    # finding hidden children
    foreach my $child (@{${$self}{children}}){
        if(${$self}{body} !~ m/${$child}{id}/){
            $self->logger("child not found, ${$child}{id}",'ttrace');
            ${$child}{hiddenChildYesNo} = 1;
            push(@hiddenChildren,\%{$child});
        } else {
            $self->logger("child found, ${$child}{id} within ${$self}{name}",'ttrace');
        }

        # recursively find other hidden children
        $child->find_hidden_children;
    }

}

sub operate_on_hidden_children{
    my $self = shift;

    # the hidden child is the argument
    my $hiddenChild = $_[0];

    # if the hidden child is found in the current body, take action
    if(${$self}{body} =~ m/${$hiddenChild}{id}/){
        $self->logger("hiddenChild found, ${$hiddenChild}{id} within ${$self}{name} (${$self}{id})",'ttrace');
        $self->logger("updating surrounding indentation of ${$hiddenChild}{id} '${$self}{indentation}'",'ttrace');
        ${$hiddenChild}{surroundingIndentation} = \${$self}{indentation};

        # check if the current object has ancestors, and if so, update the hidden child
        #   note: test-cases/items/items1.5.tex and items2.tex first highlighted the need for this
        if(${$self}{ancestors}){
            $self->logger("Adding the ancestors of ${$self}{id} to ${$hiddenChild}{id}",'ttrace');
            ${$hiddenChild}{ancestors} = ${$self}{ancestors};
            $self->logger(Dumper(@{${$hiddenChild}{ancestors}}),'ttrace');
        }
    } else {
        # call this subroutine recursively for the children
        foreach my $child (@{${$self}{children}}){
            $self->logger("Searching children of ${$child}{name} for ${$hiddenChild}{id}",'ttrace');
            $child->operate_on_hidden_children(\%{$hiddenChild});
        }
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
                my $surroundingIndentation = (${$child}{surroundingIndentation} and ${$child}{hiddenChildYesNo})
                                                        ?
                                             (ref(${$child}{surroundingIndentation}) eq 'SCALAR'?${${$child}{surroundingIndentation}}:${$child}{surroundingIndentation})
                                                        :q();

                # log file info
                $self->logger("${$child}{id} found!",'trace');
                $self->logger("Indenting  ${$child}{name} (id: ${$child}{id})",'heading');
                $self->logger("current indentation: '$surroundingIndentation'");
                $self->logger("looking up indentation scheme for ${$child}{name}");

                # line break checks before \begin{statement}
                if(defined ${$child}{BeginStartsOnOwnLine}){
                    my $BeginStringLogFile = ${$child}{aliases}{BeginStartsOnOwnLine}||"BeginStartsOnOwnLine";
                    if(${$child}{BeginStartsOnOwnLine}>=1 and !$IDFirstNonWhiteSpaceCharacter){
                        # by default, assume that no trailing comment token is needed
                        my $trailingCommentToken = q();
                        if(${$child}{BeginStartsOnOwnLine}==2){
                            $self->logger("Adding a % at the end of the line that ${$child}{begin} is on, then a linebreak ($BeginStringLogFile == 2)");
                            $trailingCommentToken = "%".$self->add_comment_symbol;
                        } else {
                            $self->logger("Adding a linebreak at the beginning of ${$child}{begin} (see $BeginStringLogFile)");
                        }

                        # the trailing comment/linebreak magic
                        ${$child}{begin} = "$trailingCommentToken\n".${$child}{begin};
                        ${$child}{begin} =~ s/^(\h*)?/$surroundingIndentation/mg;  # add indentation
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

                # line break checks *after* \end{statement}
                if (defined ${$child}{EndFinishesWithLineBreak}
                    and ${$child}{EndFinishesWithLineBreak}==0 
                    and $IDFollowedImmediatelyByLineBreak) {
                    # remove line break *after* \end{statement}, if appropriate
                    my $EndStringLogFile = ${$child}{aliases}{EndFinishesWithLineBreak}||"EndFinishesWithLineBreak";
                    $self->logger("Removing linebreak after ${$child}{end} (see $EndStringLogFile)");
                    ${$self}{body} =~ s/${$child}{id}(\h*)?\R*\h*/${$child}{id}$1/s;
                    ${$child}{linebreaksAtEnd}{end} = 0;
                }

                # perform indentation
                $child->indent;
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

sub tasks_common_to_each_object{
    my $self = shift;

    # grab the parent information
    my %parent = @_;

    # update/create the ancestor information
    if($parent{ancestors}){
      $self->logger("Ancestors *have* been found for ${$self}{name}",'trace');
      push(@{${$self}{ancestors}},@{$parent{ancestors}});
    } else {
      $self->logger("No ancestors found for ${$self}{name}",'trace');
      if(defined $parent{id} and $parent{id} ne ''){
        $self->logger("Creating ancestors with $parent{id} as the first one",'trace');
        push(@{${$self}{ancestors}},{ancestorID=>$parent{id},ancestorIndentation=>$parent{indentation}});
      }
    }

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

sub wrap_up_tasks{
    my $self = shift;

    # most recent child object
    my $child = @{${$self}{children}}[-1];

    # remove the environment block, and replace with unique ID
    ${$self}{body} =~ s/${$child}{regexp}/${$child}{replacementText}/;

    # check if the last object was the last thing in the body, and if it has adjusted linebreaks
    $self->adjust_line_breaks_end_parent;

    $self->logger(Dumper(\%{$child}),'trace');
    $self->logger("replaced with ID: ${$child}{id}");

}

1;
