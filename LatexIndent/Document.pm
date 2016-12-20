package LatexIndent::Document;
use strict;
use warnings;
use Data::Dumper;

# gain access to subroutines in the following modules
use LatexIndent::LogFile qw/logger output_logfile processSwitches is_m_switch_active/;
use LatexIndent::GetYamlSettings qw/readSettings modify_line_breaks_settings get_indentation_settings_for_this_object get_every_or_custom_value get_master_settings get_indentation_information/;
use LatexIndent::FileExtension qw/file_extension_check/;
use LatexIndent::BackUpFileProcedure qw/create_back_up_file/;
use LatexIndent::BlankLines qw/protect_blank_lines unprotect_blank_lines condense_blank_lines get_blank_line_token/;
use LatexIndent::ModifyLineBreaks qw/modify_line_breaks_body_and_end pre_print pre_print_entire_body adjust_line_breaks_end_parent/;
use LatexIndent::TrailingComments qw/remove_trailing_comments put_trailing_comments_back_in get_trailing_comment_token get_trailing_comment_regexp add_comment_symbol/;
use LatexIndent::HorizontalWhiteSpace qw/remove_trailing_whitespace remove_leading_space/;
use LatexIndent::Indent qw/indent wrap_up_statement determine_total_indentation indent_begin indent_body indent_end_statement final_indentation_check  push_family_tree_to_indent get_surrounding_indentation indent_children_recursively/;
use LatexIndent::Tokens qw/get_tokens token_check/;
use LatexIndent::HiddenChildren qw/find_surrounding_indentation_for_children update_family_tree get_family_tree find_hidden_children operate_on_hidden_children/;

# code blocks
use LatexIndent::Verbatim qw/put_verbatim_back_in find_verbatim_environments find_noindent_block find_verbatim_commands/;
use LatexIndent::Environment qw/find_environments/;
use LatexIndent::IfElseFi qw/find_ifelsefi/;
use LatexIndent::Arguments qw/find_opt_mand_arguments get_arguments_regexp/;
use LatexIndent::OptionalArgument qw/find_optional_arguments/;
use LatexIndent::MandatoryArgument qw/find_mandatory_arguments get_mand_arg_reg_exp/;
use LatexIndent::Item qw/find_items/;
use LatexIndent::Braces qw/find_commands_or_key_equals_values_braces/;
use LatexIndent::Command qw/get_command_regexp/;
use LatexIndent::KeyEqualsValuesBraces qw/get_key_equals_values_regexp/;
use LatexIndent::NamedGroupingBracesBrackets qw/get_grouping_braces_brackets_regexp/;

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

    $self->create_back_up_file;
    $self->token_check;
    $self->find_noindent_block;
    $self->remove_trailing_comments;
    $self->find_verbatim_environments;
    $self->find_verbatim_commands;
    $self->protect_blank_lines;
    $self->remove_trailing_whitespace(when=>"before");
    # find filecontents environments
    # find preamble
    $self->remove_leading_space;
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

    # the modify line switch can adjust line breaks, so we need another sweep
    my $phase3text = $self->is_m_switch_active?"pre-print process for undisclosed linebreaks":"-m not active";
    $self->logger("Phase 3: $phase3text",'heading');
    $self->pre_print_entire_body;

    # indentation recursively
    $self->logger('Phase 4: indenting objects','heading');
    $self->indent_children_recursively;

    # final indentation check
    $self->logger('Phase 5: final indentation check','heading');
    $self->final_indentation_check;

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
    
    # search for commands with arguments
    $self->logger('looking for COMMANDS and key = {value}');
    $self->find_commands_or_key_equals_values_braces;

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

    return;
}

sub tasks_particular_to_each_object{
    my $self = shift;
    $self->logger("There are no tasks particular to ${$self}{name}");
}

sub get_settings_and_store_new_object{
    my $self = shift;

    # grab the object to be operated upon
    my ($latexIndentObject) = @_;

    # there are a number of tasks common to each object
    $latexIndentObject->tasks_common_to_each_object(%{$self});
      
    # tasks particular to each object
    $latexIndentObject->tasks_particular_to_each_object;

    # store children in special hash
    push(@{${$self}{children}},$latexIndentObject);

    # wrap_up_tasks
    $self->wrap_up_tasks;
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
        push(@{${$self}{ancestors}},{ancestorID=>$parent{id},ancestorIndentation=>\$parent{indentation},type=>"natural",name=>${$self}{name}});
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

    # add trailing text to the id to stop, e.g LATEX-INDENT-ENVIRONMENT1 matching LATEX-INDENT-ENVIRONMENT10
    ${$self}{id} .= ${$self->get_tokens}{endOfToken};

    # the replacement text can be just the ID, but the ID might have a line break at the end of it
    $self->get_replacement_text;

    # the above regexp, when used below, will remove the trailing linebreak in ${$self}{linebreaksAtEnd}{end}
    # so we compensate for it here
    $self->logger("Putting linebreak after replacementText for ${$self}{name}",'trace');
    ${$self}{replacementText} .= "\n" if(${$self}{linebreaksAtEnd}{end});

    # modify line breaks on body and end statements
    $self->modify_line_breaks_body_and_end;

    return;
}

sub get_replacement_text{
    my $self = shift;

    # the replacement text can be just the ID, but the ID might have a line break at the end of it
    ${$self}{replacementText} = ${$self}{id};

}

sub count_body_line_breaks{
    my $self = shift;

    my $oldBodyLineBreaks = (defined ${$self}{bodyLineBreaks})? ${$self}{bodyLineBreaks} : 0;

    # count linebreaks in body
    my $bodyLineBreaks = 0;
    $bodyLineBreaks++ while(${$self}{body} =~ m/\R/sxg);
    ${$self}{bodyLineBreaks} = $bodyLineBreaks;
    $self->logger("bodyLineBreaks ${$self}{bodyLineBreaks}",'trace') if(${$self}{bodyLineBreaks} != $oldBodyLineBreaks);
}

sub wrap_up_tasks{
    my $self = shift;

    # most recent child object
    my $child = @{${$self}{children}}[-1];

    # remove the environment block, and replace with unique ID
    ${$self}{body} =~ s/${$child}{regexp}/${$child}{replacementText}/;

    # there's no need to store the regexp, and it makes the logfile unnecessarily big
    delete ${${${$self}{children}}[-1]}{regexp};

    # check if the last object was the last thing in the body, and if it has adjusted linebreaks
    $self->adjust_line_breaks_end_parent;

    $self->logger(Dumper(\%{$child}),'trace');
    $self->logger("replaced with ID: ${$child}{id}");

}

1;
