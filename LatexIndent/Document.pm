package LatexIndent::Document;
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
use utf8;
use open ':std', ':encoding(UTF-8)';

# gain access to subroutines in the following modules
use LatexIndent::Switches qw/storeSwitches %switches $is_m_switch_active $is_t_switch_active $is_tt_switch_active/;
use LatexIndent::LogFile qw/logger output_logfile processSwitches/;
use LatexIndent::GetYamlSettings qw/readSettings modify_line_breaks_settings get_indentation_settings_for_this_object get_every_or_custom_value get_indentation_information get_object_attribute_for_indentation_settings alignment_at_ampersand_settings %masterSettings/;
use LatexIndent::FileExtension qw/file_extension_check/;
use LatexIndent::BackUpFileProcedure qw/create_back_up_file/;
use LatexIndent::BlankLines qw/protect_blank_lines unprotect_blank_lines condense_blank_lines/;
use LatexIndent::ModifyLineBreaks qw/modify_line_breaks_body modify_line_breaks_end remove_line_breaks_begin adjust_line_breaks_end_parent max_char_per_line paragraphs_on_one_line construct_paragraph_reg_exp/;
use LatexIndent::TrailingComments qw/remove_trailing_comments put_trailing_comments_back_in add_comment_symbol construct_trailing_comment_regexp/;
use LatexIndent::HorizontalWhiteSpace qw/remove_trailing_whitespace remove_leading_space/;
use LatexIndent::Indent qw/indent wrap_up_statement determine_total_indentation indent_begin indent_body indent_end_statement final_indentation_check  get_surrounding_indentation indent_children_recursively check_for_blank_lines_at_beginning put_blank_lines_back_in_at_beginning add_surrounding_indentation_to_begin_statement/;
use LatexIndent::Tokens qw/token_check %tokens/;
use LatexIndent::HiddenChildren qw/find_surrounding_indentation_for_children update_family_tree get_family_tree check_for_hidden_children/;
use LatexIndent::AlignmentAtAmpersand qw/align_at_ampersand find_aligned_block/;
use LatexIndent::DoubleBackSlash qw/dodge_double_backslash un_dodge_double_backslash/;

# code blocks
use LatexIndent::Verbatim qw/put_verbatim_back_in find_verbatim_environments find_noindent_block find_verbatim_commands  put_verbatim_commands_back_in/;
use LatexIndent::Environment qw/find_environments/;
use LatexIndent::IfElseFi qw/find_ifelsefi/;
use LatexIndent::Arguments qw/get_arguments_regexp find_opt_mand_arguments get_numbered_arg_regexp construct_arguments_regexp/;
use LatexIndent::OptionalArgument qw/find_optional_arguments/;
use LatexIndent::MandatoryArgument qw/find_mandatory_arguments get_mand_arg_reg_exp/;
use LatexIndent::RoundBrackets qw/find_round_brackets/;
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

sub latexindent{
    my $self = shift;
    $self->storeSwitches;
    $self->processSwitches;
    $self->readSettings;
    $self->file_extension_check;
    $self->operate_on_file;
}

sub operate_on_file{
    my $self = shift;

    $self->create_back_up_file;
    $self->token_check;
    $self->construct_regular_expressions;
    $self->find_noindent_block;
    $self->find_verbatim_commands;
    $self->find_aligned_block;
    $self->remove_trailing_comments;
    $self->find_verbatim_environments;
    $self->max_char_per_line;
    $self->protect_blank_lines;
    $self->remove_trailing_whitespace(when=>"before");
    $self->find_file_contents_environments_and_preamble;
    $self->dodge_double_backslash;
    $self->remove_leading_space;
    $self->process_body_of_text;
    $self->remove_trailing_whitespace(when=>"after");
    $self->condense_blank_lines;
    $self->unprotect_blank_lines;
    $self->un_dodge_double_backslash;
    $self->put_verbatim_back_in;
    $self->put_trailing_comments_back_in;
    $self->put_verbatim_commands_back_in;
    $self->output_indented_text;
    $self->output_logfile;
    return
}

sub construct_regular_expressions{
    my $self = shift;
    $self->construct_trailing_comment_regexp;
    $self->construct_list_of_items;
    $self->construct_special_begin;
    $self->construct_headings_levels;
    $self->construct_arguments_regexp;
    $self->construct_command_regexp;
    $self->construct_key_equals_values_regexp;
    $self->construct_grouping_braces_brackets_regexp;
    $self->construct_unnamed_grouping_braces_brackets_regexp;
    $self->construct_paragraph_reg_exp if $is_m_switch_active;
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

    # indentation recursively
    $self->logger('Phase 3: indenting objects','heading');
    $self->indent_children_recursively;

    # final indentation check
    $self->logger('Phase 4: final indentation check','heading');
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

    # documents without preamble need a manual call to the paragraph_one_line routine
    if ($is_m_switch_active and !${$self}{preamblePresent}){
        ${$self}{removeParagraphLineBreaks} = ${$masterSettings{modifyLineBreaks}{removeParagraphLineBreaks}}{all}||${$masterSettings{modifyLineBreaks}{removeParagraphLineBreaks}}{masterDocument}||0;
        $self->paragraphs_on_one_line ; 
    }

    # if there are no children, return
    if(${$self}{children}){
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
    $self->logger("There are no tasks particular to ${$self}{name}") if $is_t_switch_active;
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

}

sub tasks_common_to_each_object{
    my $self = shift;

    # grab the parent information
    my %parent = @_;

    # update/create the ancestor information
    if($parent{ancestors}){
      $self->logger("Ancestors *have* been found for ${$self}{name}") if($is_t_switch_active);
      push(@{${$self}{ancestors}},@{$parent{ancestors}});
    } else {
      $self->logger("No ancestors found for ${$self}{name}") if($is_t_switch_active);
      if(defined $parent{id} and $parent{id} ne ''){
        $self->logger("Creating ancestors with $parent{id} as the first one") if($is_t_switch_active);
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
    $self->modify_line_breaks_body;

    # modify line breaks end statements
    $self->modify_line_breaks_end;

    # check the body for current children
    $self->check_for_hidden_children;

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
    $self->logger("Putting linebreak after replacementText for ${$self}{name}") if($is_t_switch_active);
    if(defined ${$self}{horizontalTrailingSpace}){
        ${$self}{replacementText} .= ${$self}{horizontalTrailingSpace} unless(!${$self}{endImmediatelyFollowedByComment} and defined ${$self}{EndFinishesWithLineBreak} and ${$self}{EndFinishesWithLineBreak}==2);
    }
    ${$self}{replacementText} .= "\n" if(${$self}{linebreaksAtEnd}{end});

}

sub count_body_line_breaks{
    my $self = shift;

    my $oldBodyLineBreaks = (defined ${$self}{bodyLineBreaks})? ${$self}{bodyLineBreaks} : 0;

    # count linebreaks in body
    my $bodyLineBreaks = 0;
    $bodyLineBreaks++ while(${$self}{body} =~ m/\R/sxg);
    ${$self}{bodyLineBreaks} = $bodyLineBreaks;
    $self->logger("bodyLineBreaks ${$self}{bodyLineBreaks}")  if((${$self}{bodyLineBreaks} != $oldBodyLineBreaks) and  $is_t_switch_active);
}

sub wrap_up_tasks{
    my $self = shift;

    # most recent child object
    my $child = @{${$self}{children}}[-1];

    # check if the last object was the last thing in the body, and if it has adjusted linebreaks
    $self->adjust_line_breaks_end_parent;

    $self->logger(Dumper(\%{$child})) if($is_tt_switch_active);
    $self->logger("replaced with ID: ${$child}{id}") if $is_t_switch_active;

}

1;
