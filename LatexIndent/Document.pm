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
use LatexIndent::LogFile qw/processSwitches $logger/;
use LatexIndent::GetYamlSettings qw/yaml_read_settings yaml_modify_line_breaks_settings yaml_get_indentation_settings_for_this_object yaml_poly_switch_get_every_or_custom_value yaml_get_indentation_information yaml_get_object_attribute_for_indentation_settings yaml_alignment_at_ampersand_settings yaml_get_textwrap_removeparagraphline_breaks %masterSettings yaml_get_columns/;
use LatexIndent::FileExtension qw/file_extension_check/;
use LatexIndent::BackUpFileProcedure qw/create_back_up_file/;
use LatexIndent::BlankLines qw/protect_blank_lines unprotect_blank_lines condense_blank_lines/;
use LatexIndent::ModifyLineBreaks qw/modify_line_breaks_body modify_line_breaks_end remove_line_breaks_begin adjust_line_breaks_end_parent text_wrap remove_paragraph_line_breaks construct_paragraph_reg_exp text_wrap_remove_paragraph_line_breaks/;
use LatexIndent::Sentence qw/one_sentence_per_line/;
use LatexIndent::TrailingComments qw/remove_trailing_comments put_trailing_comments_back_in add_comment_symbol construct_trailing_comment_regexp/;
use LatexIndent::HorizontalWhiteSpace qw/remove_trailing_whitespace remove_leading_space/;
use LatexIndent::Indent qw/indent wrap_up_statement determine_total_indentation indent_begin indent_body indent_end_statement final_indentation_check  get_surrounding_indentation indent_children_recursively check_for_blank_lines_at_beginning put_blank_lines_back_in_at_beginning add_surrounding_indentation_to_begin_statement post_indentation_check/;
use LatexIndent::Tokens qw/token_check %tokens/;
use LatexIndent::HiddenChildren qw/find_surrounding_indentation_for_children update_family_tree get_family_tree check_for_hidden_children/;
use LatexIndent::AlignmentAtAmpersand qw/align_at_ampersand find_aligned_block/;
use LatexIndent::DoubleBackSlash qw/dodge_double_backslash un_dodge_double_backslash/;

# code blocks
use LatexIndent::Verbatim qw/put_verbatim_back_in find_verbatim_environments find_noindent_block find_verbatim_commands  put_verbatim_commands_back_in find_verbatim_special/;
use LatexIndent::Environment qw/find_environments $environmentBasicRegExp/;
use LatexIndent::IfElseFi qw/find_ifelsefi construct_ifelsefi_regexp $ifElseFiBasicRegExp/;
use LatexIndent::Else qw/check_for_else_statement/;
use LatexIndent::Arguments qw/get_arguments_regexp find_opt_mand_arguments get_numbered_arg_regexp construct_arguments_regexp/;
use LatexIndent::OptionalArgument qw/find_optional_arguments/;
use LatexIndent::MandatoryArgument qw/find_mandatory_arguments get_mand_arg_reg_exp/;
use LatexIndent::RoundBrackets qw/find_round_brackets/;
use LatexIndent::Item qw/find_items construct_list_of_items/;
use LatexIndent::Braces qw/find_commands_or_key_equals_values_braces $braceBracketRegExpBasic/;
use LatexIndent::Command qw/construct_command_regexp/;
use LatexIndent::KeyEqualsValuesBraces qw/construct_key_equals_values_regexp/;
use LatexIndent::NamedGroupingBracesBrackets qw/construct_grouping_braces_brackets_regexp/;
use LatexIndent::UnNamedGroupingBracesBrackets qw/construct_unnamed_grouping_braces_brackets_regexp/;
use LatexIndent::Special qw/find_special construct_special_begin $specialBeginAndBracesBracketsBasicRegExp $specialBeginBasicRegExp/;
use LatexIndent::Heading qw/find_heading construct_headings_levels $allHeadingsRegexp/;
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
    $logger->trace(${$masterSettings{logFilePreferences}}{showDecorationStartCodeBlockTrace}) if ${$masterSettings{logFilePreferences}}{showDecorationStartCodeBlockTrace};
    bless ($self,$class);
    return $self;
}

sub latexindent{
    my $self = shift;
    $self->storeSwitches;
    $self->processSwitches;
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
    $self->find_verbatim_special;
    $self->text_wrap if ($is_m_switch_active and !${$masterSettings{modifyLineBreaks}{textWrapOptions}}{perCodeBlockBasis} and ${$masterSettings{modifyLineBreaks}{textWrapOptions}}{columns}>1);
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
    return
}

sub construct_regular_expressions{
    my $self = shift;
    $self->construct_trailing_comment_regexp;
    $self->construct_ifelsefi_regexp;
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

    $logger->info("*Output routine:");

    # if -overwrite is active then output to original fileName
    if($switches{overwrite}) {
        $logger->info("Overwriting file ${$self}{fileName}");
        open(OUTPUTFILE,">",${$self}{fileName});
        print OUTPUTFILE ${$self}{body};
        close(OUTPUTFILE);
    } elsif($switches{outputToFile}) {
        $logger->info("Outputting to file $switches{outputToFile}");
        open(OUTPUTFILE,">",$switches{outputToFile});
        print OUTPUTFILE ${$self}{body};
        close(OUTPUTFILE);
    } else {
        $logger->info("Not outputting to file; see -w and -o switches for more options.");
    }
    
    # put the final line in the logfile
    $logger->info("${$masterSettings{logFilePreferences}}{endLogFileWith}") if ${$masterSettings{logFilePreferences}}{endLogFileWith};
    
    # github info line
    $logger->info("*Please direct all communication/issues to:\nhttps://github.com/cmhughes/latexindent.pl") if ${$masterSettings{logFilePreferences}}{showGitHubInfoFooter};
    
    # output to screen, unless silent mode
    print ${$self}{body} unless $switches{silentMode};

    return;
}

sub process_body_of_text{
    my $self = shift;

    # find objects recursively
    $logger->info('*Phase 1: searching for objects');
    $self->find_objects;

    # find all hidden child
    $logger->info('*Phase 2: finding surrounding indentation');
    $self->find_surrounding_indentation_for_children;

    # indentation recursively
    $logger->info('*Phase 3: indenting objects');
    $self->indent_children_recursively;

    # final indentation check
    $logger->info('*Phase 4: final indentation check');
    $self->final_indentation_check;

    return;
}

sub find_objects{
    my $self = shift;

    # one sentence per line: sentences are objects, as of V3.5.1
    $self->one_sentence_per_line if ($is_m_switch_active and ${$masterSettings{modifyLineBreaks}{oneSentencePerLine}}{manipulateSentences});

    # search for environments
    $logger->trace('looking for ENVIRONMENTS') if $is_t_switch_active;
    $self->find_environments if ${$self}{body} =~ m/$environmentBasicRegExp/s;

    # search for ifElseFi blocks
    $logger->trace('looking for IFELSEFI') if $is_t_switch_active;
    $self->find_ifelsefi if ${$self}{body} =~ m/$ifElseFiBasicRegExp/s;

    # search for headings (part, chapter, section, setc)
    $logger->trace('looking for HEADINGS (chapter, section, part, etc)') if $is_t_switch_active;
    $self->find_heading if ${$self}{body} =~ m/$allHeadingsRegexp/s;

    # the ordering of finding commands and special code blocks can change
    $self->find_commands_or_key_equals_values_braces_and_special if ${$self}{body} =~ m/$specialBeginAndBracesBracketsBasicRegExp/s;
    
    # documents without preamble need a manual call to the paragraph_one_line routine
    if ($is_m_switch_active and !${$self}{preamblePresent}){
        $self->yaml_get_textwrap_removeparagraphline_breaks;

        # call the remove_paragraph_line_breaks and text_wrap routines
        if(${$masterSettings{modifyLineBreaks}{removeParagraphLineBreaks}}{beforeTextWrap}){
            $self->remove_paragraph_line_breaks if ${$self}{removeParagraphLineBreaks};
            $self->text_wrap if (${$self}{textWrapOptions} and ${$masterSettings{modifyLineBreaks}{textWrapOptions}}{perCodeBlockBasis});
        } else {
            $self->text_wrap if (${$self}{textWrapOptions} and ${$masterSettings{modifyLineBreaks}{textWrapOptions}}{perCodeBlockBasis});
            $self->remove_paragraph_line_breaks if ${$self}{removeParagraphLineBreaks};
        }
    }

    # if there are no children, return
    if(${$self}{children}){
        $logger->trace("*Objects have been found.") if $is_t_switch_active;
    } else {
        $logger->trace("No objects found.");
        return;
    }

    # logfile information
    $logger->trace(Dumper(\%{$self})) if($is_tt_switch_active);

    return;
}

sub find_commands_or_key_equals_values_braces_and_special{
    my $self = shift;

    # the order in which we search for specialBeginEnd and commands/key/braces
    # can change depending upon specialBeforeCommand
    if(${$masterSettings{specialBeginEnd}}{specialBeforeCommand}){
        # search for special begin/end
        $logger->trace('looking for SPECIAL begin/end *before* looking for commands (see specialBeforeCommand)') if $is_t_switch_active;
        $self->find_special if ${$self}{body} =~ m/$specialBeginBasicRegExp/s;

        # search for commands with arguments
        $logger->trace('looking for COMMANDS and key = {value}') if $is_t_switch_active;
        $self->find_commands_or_key_equals_values_braces if ${$self}{body} =~ m/$braceBracketRegExpBasic/s;
    } else {
        # search for commands with arguments
        $logger->trace('looking for COMMANDS and key = {value}') if $is_t_switch_active;
        $self->find_commands_or_key_equals_values_braces if ${$self}{body} =~ m/$braceBracketRegExpBasic/s;

        # search for special begin/end
        $logger->trace('looking for SPECIAL begin/end') if $is_t_switch_active;
        $self->find_special if ${$self}{body} =~ m/$specialBeginBasicRegExp/s;
    }
    return;
}

sub tasks_particular_to_each_object{
    my $self = shift;
    $logger->trace("There are no tasks particular to ${$self}{name}") if $is_t_switch_active;
}

sub get_settings_and_store_new_object{
    my $self = shift;

    # grab the object to be operated upon
    my ($latexIndentObject) = @_;

    # there are a number of tasks common to each object
    $latexIndentObject->tasks_common_to_each_object(%{$self});
      
    # tasks particular to each object
    $latexIndentObject->tasks_particular_to_each_object;
    
    # removeParagraphLineBreaks and textWrapping fun!
    $latexIndentObject->text_wrap_remove_paragraph_line_breaks if($is_m_switch_active);

    # store children in special hash
    push(@{${$self}{children}},$latexIndentObject);

    # possible decoration in log file 
    $logger->trace(${$masterSettings{logFilePreferences}}{showDecorationFinishCodeBlockTrace}) if ${$masterSettings{logFilePreferences}}{showDecorationFinishCodeBlockTrace};
}

sub tasks_common_to_each_object{
    my $self = shift;

    # grab the parent information
    my %parent = @_;

    # update/create the ancestor information
    if($parent{ancestors}){
      $logger->trace("Ancestors *have* been found for ${$self}{name}") if($is_t_switch_active);
      push(@{${$self}{ancestors}},@{$parent{ancestors}});
    } else {
      $logger->trace("No ancestors found for ${$self}{name}") if($is_t_switch_active);
      if(defined $parent{id} and $parent{id} ne ''){
        $logger->trace("Creating ancestors with $parent{id} as the first one") if($is_t_switch_active);
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
    $self->yaml_get_indentation_settings_for_this_object;

    # give unique id
    $self->create_unique_id;

    # add trailing text to the id to stop, e.g LATEX-INDENT-ENVIRONMENT1 matching LATEX-INDENT-ENVIRONMENT10
    ${$self}{id} .= $tokens{endOfToken};

    # text wrapping can make the ID split across lines
    ${$self}{idRegExp} = ${$self}{id};

    if($is_m_switch_active){
        my $IDwithLineBreaks = join("\\R?\\h*",split(//,${$self}{id}));
        ${$self}{idRegExp} = qr/$IDwithLineBreaks/s;  
    }

    # the replacement text can be just the ID, but the ID might have a line break at the end of it
    $self->get_replacement_text;

    # the above regexp, when used below, will remove the trailing linebreak in ${$self}{linebreaksAtEnd}{end}
    # so we compensate for it here
    $self->adjust_replacement_text_line_breaks_at_end;

    # modify line breaks on body and end statements
    $self->modify_line_breaks_body if $is_m_switch_active;

    # modify line breaks end statements
    $self->modify_line_breaks_end if $is_m_switch_active;

    # check the body for current children
    $self->check_for_hidden_children if ${$self}{body} =~ m/$tokens{beginOfToken}/;

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
    $logger->trace("Putting linebreak after replacementText for ${$self}{name}") if($is_t_switch_active);
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
    $logger->trace("bodyLineBreaks ${$self}{bodyLineBreaks}")  if((${$self}{bodyLineBreaks} != $oldBodyLineBreaks) and  $is_t_switch_active);
}

sub wrap_up_tasks{
    my $self = shift;

    # most recent child object
    my $child = @{${$self}{children}}[-1];

    # check if the last object was the last thing in the body, and if it has adjusted linebreaks
    $self->adjust_line_breaks_end_parent if $is_m_switch_active;

    $logger->trace(Dumper(\%{$child})) if($is_tt_switch_active);
    $logger->trace("replaced with ID: ${$child}{id}") if $is_t_switch_active;

}

1;
