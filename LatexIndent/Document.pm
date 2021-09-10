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
use LatexIndent::Switches qw/store_switches %switches $is_m_switch_active $is_t_switch_active $is_tt_switch_active $is_r_switch_active $is_rr_switch_active $is_rv_switch_active $is_check_switch_active/;
use LatexIndent::LogFile qw/process_switches $logger/;
use LatexIndent::Logger qw/@logFileLines/;
use LatexIndent::Check qw/simple_diff/;
use LatexIndent::Lines qw/lines_body_selected_lines lines_verbatim_create_line_block/;
use LatexIndent::Replacement qw/make_replacements/;
use LatexIndent::GetYamlSettings qw/yaml_read_settings yaml_modify_line_breaks_settings yaml_get_indentation_settings_for_this_object yaml_poly_switch_get_every_or_custom_value yaml_get_indentation_information yaml_get_object_attribute_for_indentation_settings yaml_alignment_at_ampersand_settings yaml_get_textwrap_removeparagraphline_breaks %mainSettings yaml_get_columns/;
use LatexIndent::FileExtension qw/file_extension_check/;
use LatexIndent::BackUpFileProcedure qw/create_back_up_file/;
use LatexIndent::BlankLines qw/protect_blank_lines unprotect_blank_lines condense_blank_lines/;
use LatexIndent::ModifyLineBreaks qw/modify_line_breaks_body modify_line_breaks_end modify_line_breaks_end_after remove_line_breaks_begin adjust_line_breaks_end_parent text_wrap remove_paragraph_line_breaks construct_paragraph_reg_exp text_wrap_remove_paragraph_line_breaks verbatim_modify_line_breaks/;
use LatexIndent::Sentence qw/one_sentence_per_line/;
use LatexIndent::TrailingComments qw/remove_trailing_comments put_trailing_comments_back_in add_comment_symbol construct_trailing_comment_regexp/;
use LatexIndent::HorizontalWhiteSpace qw/remove_trailing_whitespace remove_leading_space/;
use LatexIndent::Indent qw/indent wrap_up_statement determine_total_indentation indent_begin indent_body indent_end_statement final_indentation_check  get_surrounding_indentation indent_children_recursively check_for_blank_lines_at_beginning put_blank_lines_back_in_at_beginning add_surrounding_indentation_to_begin_statement post_indentation_check/;
use LatexIndent::Tokens qw/token_check %tokens/;
use LatexIndent::HiddenChildren qw/find_surrounding_indentation_for_children update_family_tree get_family_tree check_for_hidden_children hidden_children_preparation_for_alignment unpack_children_into_body/;
use LatexIndent::AlignmentAtAmpersand qw/align_at_ampersand find_aligned_block double_back_slash_else main_formatting individual_padding multicolumn_padding multicolumn_pre_check  multicolumn_post_check dont_measure hidden_child_cell_row_width hidden_child_row_width /;
use LatexIndent::DoubleBackSlash qw/dodge_double_backslash un_dodge_double_backslash/;

# code blocks
use LatexIndent::Verbatim qw/put_verbatim_back_in find_verbatim_environments find_noindent_block find_verbatim_commands  find_verbatim_special verbatim_common_tasks %verbatimStorage/;
use LatexIndent::Environment qw/find_environments $environmentBasicRegExp construct_environments_regexp/;
use LatexIndent::IfElseFi qw/find_ifelsefi construct_ifelsefi_regexp $ifElseFiBasicRegExp/;
use LatexIndent::Else qw/check_for_else_statement/;
use LatexIndent::Arguments qw/get_arguments_regexp find_opt_mand_arguments construct_arguments_regexp comma_else/;
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
    $logger->trace(${$mainSettings{logFilePreferences}}{showDecorationStartCodeBlockTrace}) if ${$mainSettings{logFilePreferences}}{showDecorationStartCodeBlockTrace};
    bless ($self,$class);
    return $self;
}

sub latexindent{
    my $self = shift;
    $self->store_switches;
    $self->process_switches;
    $self->yaml_read_settings;
    $self->file_extension_check;
    $self->operate_on_file;

    # check switch active, and file changed, gives different exit code
    if ($is_check_switch_active and ${$self}{originalBody} ne ${$self}{body}){
        exit(1);
    }
}

sub operate_on_file{
    my $self = shift;

    $self->create_back_up_file;
    $self->token_check unless ($switches{lines}) ;
    $self->make_replacements(when=>"before") if ($is_r_switch_active and !$is_rv_switch_active);
    unless ($is_rr_switch_active){
        $self->construct_regular_expressions;
        $self->find_noindent_block;
        $self->find_verbatim_commands;
        $self->find_aligned_block;
        $self->remove_trailing_comments;
        $self->find_verbatim_environments;
        $self->find_verbatim_special;
        $logger->trace("*Verbatim storage:") if $is_tt_switch_active;
        $logger->trace(Dumper(\%verbatimStorage)) if $is_tt_switch_active;
        $self->verbatim_modify_line_breaks if $is_m_switch_active; 
        $self->make_replacements(when=>"before") if $is_rv_switch_active;
        $self->text_wrap if ($is_m_switch_active and !${$mainSettings{modifyLineBreaks}{textWrapOptions}}{perCodeBlockBasis} and ${$mainSettings{modifyLineBreaks}{textWrapOptions}}{columns}>1);
        $self->protect_blank_lines if $is_m_switch_active;
        $self->remove_trailing_whitespace(when=>"before");
        $self->find_file_contents_environments_and_preamble;
        $self->dodge_double_backslash;
        $self->remove_leading_space;
        $self->process_body_of_text;
        ${$self}{body} =~ s/\r\n/\n/sg if $mainSettings{dos2unixlinebreaks};
        $self->remove_trailing_whitespace(when=>"after");
        $self->condense_blank_lines  if( $is_m_switch_active and ${$mainSettings{modifyLineBreaks}}{condenseMultipleBlankLinesInto} );
        $self->unprotect_blank_lines if( $is_m_switch_active and ${$mainSettings{modifyLineBreaks}}{preserveBlankLines} );
        $self->un_dodge_double_backslash;
        $self->make_replacements(when=>"after") if $is_rv_switch_active;
        $self->put_verbatim_back_in (match=>"everything-except-commands");
        $self->put_trailing_comments_back_in;
        $self->put_verbatim_back_in (match=>"just-commands");
        $self->make_replacements(when=>"after") if ($is_r_switch_active and !$is_rv_switch_active);
        ${$self}{body} =~ s/\r\n/\n/sg if $mainSettings{dos2unixlinebreaks};
    }
    $self->output_indented_text;
    return
}

sub construct_regular_expressions{
    my $self = shift;
    $self->construct_trailing_comment_regexp;
    $self->construct_environments_regexp;
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

    $self->simple_diff() if $is_check_switch_active;

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

    # output the log file information
    $self->output_logfile();

    # output to screen, unless silent mode
    print ${$self}{body} unless $switches{silentMode};

    return;
}

sub output_logfile{
  
    my $self = shift;
    #
    # put the final line in the logfile
    $logger->info("${$mainSettings{logFilePreferences}}{endLogFileWith}") if ${$mainSettings{logFilePreferences}}{endLogFileWith};
    
    # github info line
    $logger->info("*Please direct all communication/issues to:\nhttps://github.com/cmhughes/latexindent.pl") if ${$mainSettings{logFilePreferences}}{showGitHubInfoFooter};

    # open log file
    my $logfileName = $switches{logFileName}||"indent.log";
    my $logfile;
    my $logfilePossible = 1;
    open($logfile,">","${$self}{cruftDirectory}/$logfileName") or $logfilePossible =0;

    if($logfilePossible){ 
        foreach my $line (@{LatexIndent::Logger::logFileLines}){
            print $logfile $line,"\n";
        }

        # close log file
        close($logfile);
    } 

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
    $self->one_sentence_per_line if ($is_m_switch_active and ${$mainSettings{modifyLineBreaks}{oneSentencePerLine}}{manipulateSentences});

    if ($is_m_switch_active and !${$self}{preamblePresent}){
        $self->yaml_get_textwrap_removeparagraphline_breaks;
    }

    if( $is_m_switch_active and ${$mainSettings{modifyLineBreaks}{textWrapOptions}}{beforeFindingChildCodeBlocks} == 1){ 
        # call the remove_paragraph_line_breaks and text_wrap routines
        if(${$mainSettings{modifyLineBreaks}{removeParagraphLineBreaks}}{beforeTextWrap}){
            $self->remove_paragraph_line_breaks if ${$self}{removeParagraphLineBreaks};
            $self->text_wrap if (${$self}{textWrapOptions} and ${$mainSettings{modifyLineBreaks}{textWrapOptions}}{perCodeBlockBasis});
        } else {
            $self->text_wrap if (${$self}{textWrapOptions} and ${$mainSettings{modifyLineBreaks}{textWrapOptions}}{perCodeBlockBasis});
            $self->remove_paragraph_line_breaks if ${$self}{removeParagraphLineBreaks};
        }
    }

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
    if ($is_m_switch_active and ${$mainSettings{modifyLineBreaks}{textWrapOptions}}{beforeFindingChildCodeBlocks} == 0 ){ 
       # call the remove_paragraph_line_breaks and text_wrap routines
       if(${$mainSettings{modifyLineBreaks}{removeParagraphLineBreaks}}{beforeTextWrap}){
           $self->remove_paragraph_line_breaks if ${$self}{removeParagraphLineBreaks};
           $self->text_wrap if (${$self}{textWrapOptions} and ${$mainSettings{modifyLineBreaks}{textWrapOptions}}{perCodeBlockBasis});
       } else {
           $self->text_wrap if (${$self}{textWrapOptions} and ${$mainSettings{modifyLineBreaks}{textWrapOptions}}{perCodeBlockBasis});
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
    if(${$mainSettings{specialBeginEnd}}{specialBeforeCommand}){
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
    
    # removeParagraphLineBreaks and textWrapping fun!
    $latexIndentObject->text_wrap_remove_paragraph_line_breaks if( $is_m_switch_active and ${$mainSettings{modifyLineBreaks}{textWrapOptions}}{beforeFindingChildCodeBlocks} );
      
    # tasks particular to each object
    $latexIndentObject->tasks_particular_to_each_object;
    
    # removeParagraphLineBreaks and textWrapping fun!
    $latexIndentObject->text_wrap_remove_paragraph_line_breaks if($is_m_switch_active and !${$mainSettings{modifyLineBreaks}{textWrapOptions}}{beforeFindingChildCodeBlocks} );

    # store children in special hash
    push(@{${$self}{children}},$latexIndentObject);

    # possible alignment preparation for hidden children
    $self->hidden_children_preparation_for_alignment($latexIndentObject) if(${$latexIndentObject}{lookForAlignDelims} and ${$latexIndentObject}{measureHiddenChildren});

    # possible decoration in log file 
    $logger->trace(${$mainSettings{logFilePreferences}}{showDecorationFinishCodeBlockTrace}) if ${$mainSettings{logFilePreferences}}{showDecorationFinishCodeBlockTrace};
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

    if($is_m_switch_active
        and ${$mainSettings{modifyLineBreaks}{textWrapOptions}}{huge} ne "overflow"){
        my $IDwithLineBreaks = join("\\R?\\h*",split(//,${$self}{id}));
        ${$self}{idRegExp} = qr/$IDwithLineBreaks/s;  
    }

    # the replacement text can be just the ID, but the ID might have a line break at the end of it
    $self->get_replacement_text;

    # the above regexp, when used below, will remove the trailing linebreak in ${$self}{linebreaksAtEnd}{end}
    # so we compensate for it here
    $self->adjust_replacement_text_line_breaks_at_end;

    # modify line breaks on body and end statements
    $self->modify_line_breaks_body if ($is_m_switch_active and defined ${$self}{BodyStartsOnOwnLine} and ${$self}{BodyStartsOnOwnLine}!=0);

    # modify line breaks end statements
    $self->modify_line_breaks_end if ($is_m_switch_active and defined ${$self}{EndStartsOnOwnLine} and ${$self}{EndStartsOnOwnLine}!=0);
    $self->modify_line_breaks_end_after if ($is_m_switch_active and defined ${$self}{EndFinishesWithLineBreak} and ${$self}{EndFinishesWithLineBreak}!=0);

    # check the body for current children
    $self->check_for_hidden_children if ${$self}{body} =~ m/$tokens{beginOfToken}/;

    # double back slash poly-switch check
    $self->double_back_slash_else if ($is_m_switch_active and ${$self}{lookForAlignDelims});
    
    # some objects can format their body to align at the & character
    $self->align_at_ampersand if (${$self}{lookForAlignDelims} and !${$self}{measureHiddenChildren});

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
