package LatexIndent::Document;
use strict;
use warnings;
use Data::Dumper;

# gain access to subroutines in the following modules
use LatexIndent::Switches qw/storeSwitches %switches $is_m_switch_active $is_t_switch_active $is_tt_switch_active/;
use LatexIndent::LogFile qw/logger output_logfile processSwitches/;
use LatexIndent::GetYamlSettings qw/readSettings modify_line_breaks_settings get_indentation_settings_for_this_object get_every_or_custom_value get_indentation_information get_object_attribute_for_indentation_settings alignment_at_ampersand_settings/;
use LatexIndent::FileExtension qw/file_extension_check/;
use LatexIndent::BackUpFileProcedure qw/create_back_up_file/;
use LatexIndent::BlankLines qw/protect_blank_lines unprotect_blank_lines condense_blank_lines/;
use LatexIndent::ModifyLineBreaks qw/modify_line_breaks_body_and_end pre_print pre_print_entire_body adjust_line_breaks_end_parent/;
use LatexIndent::TrailingComments qw/remove_trailing_comments put_trailing_comments_back_in add_comment_symbol/;
use LatexIndent::HorizontalWhiteSpace qw/remove_trailing_whitespace remove_leading_space/;
use LatexIndent::Indent qw/indent wrap_up_statement determine_total_indentation indent_begin indent_body indent_end_statement final_indentation_check  get_surrounding_indentation indent_children_recursively check_for_blank_lines_at_beginning put_blank_lines_back_in_at_beginning add_surrounding_indentation_to_begin_statement/;
use LatexIndent::Tokens qw/token_check %tokens/;
use LatexIndent::HiddenChildren qw/find_surrounding_indentation_for_children update_family_tree get_family_tree update_child_id_reg_exp check_for_hidden_children/;
use LatexIndent::AlignmentAtAmpersand qw/align_at_ampersand/;

# code blocks
use LatexIndent::Verbatim qw/put_verbatim_back_in find_verbatim_environments find_noindent_block find_verbatim_commands/;
use LatexIndent::Environment qw/find_environments/;
use LatexIndent::IfElseFi qw/find_ifelsefi/;
use LatexIndent::Arguments qw/get_arguments_regexp find_opt_mand_arguments get_numbered_arg_regexp construct_arguments_regexp/;
use LatexIndent::OptionalArgument qw/find_optional_arguments/;
use LatexIndent::MandatoryArgument qw/find_mandatory_arguments get_mand_arg_reg_exp/;
use LatexIndent::Item qw/find_items construct_list_of_items/;
use LatexIndent::Braces qw/find_commands_or_key_equals_values_braces/;
use LatexIndent::Command qw/construct_command_regexp/;
use LatexIndent::KeyEqualsValuesBraces qw/construct_key_equals_values_regexp/;
use LatexIndent::NamedGroupingBracesBrackets qw/construct_grouping_braces_brackets_regexp/;
use LatexIndent::UnNamedGroupingBracesBrackets qw/construct_unnamed_grouping_braces_brackets_regexp/;
use LatexIndent::Special qw/find_special construct_special_begin/;
use LatexIndent::Heading qw/find_heading construct_headings_levels/;
use LatexIndent::FileContents qw/find_file_contents_environments_and_preamble/;
use LatexIndent::Preamble;

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
    $self->construct_regular_expressions;
    $self->find_noindent_block;
    $self->remove_trailing_comments;
    $self->find_verbatim_environments;
    $self->find_verbatim_commands;
    $self->protect_blank_lines;
    $self->remove_trailing_whitespace(when=>"before");
    $self->find_file_contents_environments_and_preamble;
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

sub construct_regular_expressions{
    my $self = shift;
    $self->construct_list_of_items;
    $self->construct_special_begin;
    $self->construct_headings_levels;
    $self->construct_arguments_regexp;
    $self->construct_command_regexp;
    $self->construct_key_equals_values_regexp;
    $self->construct_grouping_braces_brackets_regexp;
    $self->construct_unnamed_grouping_braces_brackets_regexp;

}

sub output_indented_text{
    my $self = shift;

    # output to screen, unless silent mode
    print ${$self}{body} unless $switches{silentMode};

    $self->logger("Output routine",'heading');

    # if -overwrite is active then output to original fileName
    if($switches{overwrite}) {
        $self->logger("Overwriting file ${$self}{fileName}");
        open(OUTPUTFILE,">",${$self}{fileName});
        print OUTPUTFILE ${$self}{body};
        close(OUTPUTFILE);
    } elsif($switches{outputToFile}) {
        $self->logger("Outputting to file $switches{outputToFile}");
        open(OUTPUTFILE,">",$switches{outputToFile});
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
    $self->logger('Phase 1: searching for objects','heading');
    $self->find_objects;

    # find all hidden child
    $self->logger('Phase 2: finding surrounding indentation','heading');
    $self->find_surrounding_indentation_for_children;

    # the modify line switch can adjust line breaks, so we need another sweep
    my $phase3text = $is_m_switch_active?"pre-print process for undisclosed linebreaks":"-m not active";
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

sub find_objects{
    my $self = shift;

    # search for environments
    $self->logger('looking for ENVIRONMENTS');
    $self->find_environments;

    # search for ifElseFi blocks
    $self->logger('looking for IFELSEFI');
    $self->find_ifelsefi;

    # search for headings (part, chapter, section, setc)
    $self->logger('looking for HEADINGS (chapter, section, part, etc)');
    $self->find_heading;
    
    # search for commands with arguments
    $self->logger('looking for COMMANDS and key = {value}');
    $self->find_commands_or_key_equals_values_braces;

    # search for special begin/end
    $self->logger('looking for SPECIAL begin/end');
    $self->find_special;

    # if there are no children, return
    if(%{$self}{children}){
        $self->logger("Objects have been found.",'heading');
    } else {
        $self->logger("No objects found.");
        return;
    }

    # logfile information
    $self->logger(Dumper(\%{$self}),'ttrace') if($is_tt_switch_active);
    $self->logger("Operating on: ${$self}{name}",'heading');
    $self->logger("Number of children:",'heading');
    $self->logger(scalar (@{${$self}{children}}));

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
      $self->logger("Ancestors *have* been found for ${$self}{name}",'trace') if($is_t_switch_active);
      push(@{${$self}{ancestors}},@{$parent{ancestors}});
    } else {
      $self->logger("No ancestors found for ${$self}{name}",'trace') if($is_t_switch_active);
      if(defined $parent{id} and $parent{id} ne ''){
        $self->logger("Creating ancestors with $parent{id} as the first one",'trace') if($is_t_switch_active);
        push(@{${$self}{ancestors}},{ancestorID=>$parent{id},ancestorIndentation=>\$parent{indentation},type=>"natural",name=>${$self}{name}});
      }
    }

    # natural ancestors
    ${$self}{naturalAncestors} = q();
    if(${$self}{ancestors}){
      ${$self}{naturalAncestors} .= "---".${$_}{ancestorID}."\n" for @{${$self}{ancestors}};
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
    ${$self}{id} .= $tokens{endOfToken};

    # the replacement text can be just the ID, but the ID might have a line break at the end of it
    $self->get_replacement_text;

    # the above regexp, when used below, will remove the trailing linebreak in ${$self}{linebreaksAtEnd}{end}
    # so we compensate for it here
    $self->adjust_replacement_text_line_breaks_at_end;

    # modify line breaks on body and end statements
    $self->modify_line_breaks_body_and_end;

    # check the body for current children
    $self->check_for_hidden_children;

    # store child ID in $allChildrenIDRegExp 
    $self->update_child_id_reg_exp;

    return;
}

sub get_replacement_text{
    my $self = shift;

    # the replacement text can be just the ID, but the ID might have a line break at the end of it
    ${$self}{replacementText} = ${$self}{id};
    return;
}

sub adjust_replacement_text_line_breaks_at_end{
    my $self = shift;

    # the above regexp, when used below, will remove the trailing linebreak in ${$self}{linebreaksAtEnd}{end}
    # so we compensate for it here
    $self->logger("Putting linebreak after replacementText for ${$self}{name}",'trace') if($is_t_switch_active);
    ${$self}{replacementText} .= "\n" if(${$self}{linebreaksAtEnd}{end});

}

sub count_body_line_breaks{
    my $self = shift;

    my $oldBodyLineBreaks = (defined ${$self}{bodyLineBreaks})? ${$self}{bodyLineBreaks} : 0;

    # count linebreaks in body
    my $bodyLineBreaks = 0;
    $bodyLineBreaks++ while(${$self}{body} =~ m/\R/sxg);
    ${$self}{bodyLineBreaks} = $bodyLineBreaks;
    $self->logger("bodyLineBreaks ${$self}{bodyLineBreaks}",'trace')  if(${$self}{bodyLineBreaks} != $oldBodyLineBreaks);
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

    $self->logger(Dumper(\%{$child}),'trace') if($is_t_switch_active);
    $self->logger("replaced with ID: ${$child}{id}");

}

1;
