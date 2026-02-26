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
#	Chris Hughes, 2017-2025
#
#	For all communication, please visit: https://github.com/cmhughes/latexindent.pl
use strict;
use warnings;
use Data::Dumper;
use File::Basename;    # to get the filename and directory path

use open ':std', ':encoding(UTF-8)';
use Encode qw/decode/;

# gain access to subroutines in the following modules
use LatexIndent::Switches
    qw/store_switches %switches $is_m_switch_active $is_t_switch_active $is_tt_switch_active $is_r_switch_active $is_rr_switch_active $is_rv_switch_active $is_check_switch_active/;
use LatexIndent::LogFile     qw/process_switches $logger/;
use LatexIndent::Logger      qw/@logFileLines/;
use LatexIndent::Check       qw/simple_diff/;
use LatexIndent::Lines       qw/lines_body_selected_lines lines_verbatim_create_line_block/;
use LatexIndent::Replacement qw/make_replacements/;
use LatexIndent::GetYamlSettings
    qw/yaml_obsolete_checks yaml_read_settings yaml_modify_line_breaks_settings yaml_get_indentation_settings_for_this_object yaml_poly_switch_get_every_or_custom_value yaml_get_indentation_information yaml_get_object_attribute_for_indentation_settings yaml_alignment_at_ampersand_settings %mainSettings yaml_get_alignment_at_ampersand_from_parent/;
use LatexIndent::FileExtension       qw/file_extension_check/;
use LatexIndent::BackUpFileProcedure qw/create_back_up_file check_if_different/;
use LatexIndent::BlankLines          qw/protect_blank_lines unprotect_blank_lines condense_blank_lines/;
use LatexIndent::ModifyLineBreaks
    qw/_mlb_line_break_token_adjust _mlb_file_starts_with_line_break _mlb_begin_starts_on_own_line _mlb_body_starts_on_own_line _mlb_end_starts_on_own_line _mlb_end_finishes_with_line_break adjust_line_breaks_end_parent _mlb_verbatim _mlb_after_indentation_token_adjust mlb_PRE_indent_sentence_and_text_wrap mlb_POST_indent_sentence_and_text_wrap/;
use LatexIndent::Sentence qw/one_sentence_per_line mlb_one_sentence_per_line_indent one_sentence_per_line_store /;
use LatexIndent::Wrap     qw/text_wrap text_wrap_comment_blocks/;
use LatexIndent::TrailingComments
    qw/remove_trailing_comments put_trailing_comments_back_in add_comment_symbol construct_trailing_comment_regexp $alignMarkUpBlockPresent/;
use LatexIndent::HorizontalWhiteSpace qw/remove_trailing_whitespace remove_leading_space max_indentation_check/;
use LatexIndent::Tokens qw/token_check %tokens/;
use LatexIndent::AlignmentAtAmpersand
    qw/align_at_ampersand _align_mark_down_block double_back_slash_else main_formatting individual_padding multicolumn_padding multicolumn_pre_check  multicolumn_post_check dont_measure hidden_child_cell_row_width hidden_child_row_width /;
use LatexIndent::DoubleBackSlash qw/dodge_double_backslash un_dodge_double_backslash/;

# code blocks
use LatexIndent::Verbatim
    qw/put_verbatim_back_in find_verbatim_environments find_noindent_block find_verbatim_commands  find_verbatim_special verbatim_common_tasks %verbatimStorage/;
use LatexIndent::Environment;
use LatexIndent::IfElseFi;
use LatexIndent::Arguments;
use LatexIndent::OptionalArgument;
use LatexIndent::MandatoryArgument;
use LatexIndent::Blocks                qw/$braceBracketRegExpBasic _find_all_code_blocks _construct_code_blocks_regex/;
use LatexIndent::Command;
use LatexIndent::KeyEqualsValuesBraces;
use LatexIndent::NamedGroupingBracesBrackets;
use LatexIndent::UnNamedGroupingBracesBrackets;
use LatexIndent::Special;
use LatexIndent::Heading      qw/find_heading construct_headings_levels $allHeadingsRegexp after_heading_indentation/;
use LatexIndent::FileContents qw/find_file_contents_environments_and_preamble/;

use LatexIndent::UTF8CmdLineArgsFileOperation
    qw/copy_with_encode exist_with_encode open_with_encode  zero_with_encode read_yaml_with_encode/;
use utf8;

sub new {

    # Create new objects, with optional key/value pairs
    # passed as initializers.
    #
    # See Programming Perl, pg 319
    my $invocant = shift;
    my $class    = ref($invocant) || $invocant;
    my $self     = {@_};
    $logger->trace( ${ $mainSettings{logFilePreferences} }{showDecorationStartCodeBlockTrace} )
        if ${ $mainSettings{logFilePreferences} }{showDecorationStartCodeBlockTrace};
    bless( $self, $class );
    return $self;
}

sub latexindent {
    my $self      = shift;
    my @fileNames = @{ $_[0] };

    my $check_switch_status_across_files = 0;

    my $file_extension_status_across_files = 0;

    # one-time operations
    $self->store_switches;
    ${$self}{fileName} = $fileNames[0];
    $self->process_switches( \@fileNames );
    $self->yaml_read_settings;

    ${$self}{multipleFiles} = 1 if ( ( scalar(@fileNames) ) > 1 );

    my $fileCount = 0;

    # per-file operations
    foreach (@fileNames) {
        $fileCount++;
        if ( ( scalar(@fileNames) ) > 1 ) {
            $logger->info( "*Filename: $_ (" . $fileCount . " of " . ( scalar(@fileNames) ) . ")" );
        }
        ${$self}{fileName}       = $_;
        ${$self}{cruftDirectory} = $switches{cruftDirectory} || ( dirname ${$self}{fileName} );

        # file existence/extension checks
        my $file_existence = $self->file_extension_check;
        if ( $file_existence > 0 ) {
            $file_extension_status_across_files = $file_existence;
            next;
        }

        # overwrite and overwriteIfDifferent switches, per file
        ${$self}{overwrite}            = $switches{overwrite};
        ${$self}{overwriteIfDifferent} = $switches{overwriteIfDifferent};

        # the main operations
        $self->operate_on_file;

        # keep track of check status across files
        $check_switch_status_across_files = 1
            if ( $is_check_switch_active and ${$self}{originalBody} ne ${$self}{body} );
    }

    # check switch summary across multiple files
    if ( $is_check_switch_active and ( scalar(@fileNames) ) > 1 ) {
        if ($check_switch_status_across_files) {
            $logger->info("*check switch across multiple files: differences to report from at least one file");
        }
        else {
            $logger->info("*check switch across multiple files: no differences to report");
        }
    }

    # logging of existence check
    if ( $file_extension_status_across_files > 2 ) {
        $logger->warn("*at least one of the files you specified does not exist or could not be read");
    }

    # output the log file information
    $self->output_logfile();

    if ( $file_extension_status_across_files > 2 ) {
        exit($file_extension_status_across_files);
    }

    # check switch active, and file changed, gives different exit code
    if ($check_switch_status_across_files) {
        exit(1);
    }
}

sub operate_on_file {
    my $self = shift;

    $self->create_back_up_file;
    $self->token_check unless ( $switches{lines} );
    $self->make_replacements( when => "before" )                if ( $is_r_switch_active and !$is_rv_switch_active );
    $self->_mlb_file_starts_with_line_break( when => "before" ) if $is_m_switch_active;
    unless ($is_rr_switch_active) {
        $self->construct_trailing_comment_regexp;
        $self->_construct_code_blocks_regex;

        # ---------- verbatim -------------------
        $self->find_noindent_block;
        $self->find_verbatim_commands;
        $self->remove_trailing_comments;
        $self->find_verbatim_environments;
        $self->find_verbatim_special;
        $self->_mlb_verbatim( when => "beforeTextWrap" ) if $is_m_switch_active;

        # ---------- END verbatim -------------------
        $self->make_replacements( when => "before" ) if $is_rv_switch_active;
        $self->protect_blank_lines                   if $is_m_switch_active;
        $self->remove_trailing_whitespace( when => "before" );
        $self->find_file_contents_environments_and_preamble;
        $self->dodge_double_backslash;
        $self->remove_leading_space;

        # ---------- one sentence per line, text wrap (BEFORE) -------------------
        $self->mlb_PRE_indent_sentence_and_text_wrap if $is_m_switch_active;

        # ---------- marked-up alignment blocks: %*\begin{tabular}...%*\end{tabular} ----------
        $self->_align_mark_down_block if $alignMarkUpBlockPresent;

        # ---------- main code blocks  -------------------
        ${$self}{body} = _find_all_code_blocks( ${$self}{body}, "" );
        ${$self}{body} =~ s/\r\n/\n/sg             if $mainSettings{dos2unixlinebreaks};
        $self->mlb_one_sentence_per_line_indent    if $is_m_switch_active;
        $self->_mlb_after_indentation_token_adjust if $is_m_switch_active;

        # ---------- headings -------------------
        $self->find_heading;

        $self->condense_blank_lines
            if ( $is_m_switch_active and ${ $mainSettings{modifyLineBreaks} }{condenseMultipleBlankLinesInto} );
            
        # ---------- one sentence per line, text wrap (AFTER) -------------------
        $self->mlb_POST_indent_sentence_and_text_wrap if $is_m_switch_active;

        $self->unprotect_blank_lines
            if ( $is_m_switch_active and ${ $mainSettings{modifyLineBreaks} }{preserveBlankLines} );
        $self->un_dodge_double_backslash;
        $self->max_indentation_check;

        $self->remove_trailing_whitespace( when => "after" );
        $self->make_replacements( when => "after" ) if $is_rv_switch_active;
        $self->put_verbatim_back_in( match => "everything-except-commands" );
        $self->put_trailing_comments_back_in;
        $self->put_verbatim_back_in( match => "just-commands" );
        $self->_mlb_file_starts_with_line_break( when => "after" ) if $is_m_switch_active;
        $self->make_replacements( when => "after" )                if ( $is_r_switch_active and !$is_rv_switch_active );
        ${$self}{body} =~ s/\r\n/\n/sg                             if $mainSettings{dos2unixlinebreaks};
        $self->check_if_different                                  if ${$self}{overwriteIfDifferent};
    }
    $self->output_indented_text;
    return;
}

sub output_indented_text {
    my $self = shift;

    $self->simple_diff() if $is_check_switch_active;

    $logger->info("*Output routine:");

    # if -overwrite is active then output to original fileName
    if ( ${$self}{overwrite} ) {

        # diacritics in file names (highlighted in https://github.com/cmhughes/latexindent.pl/pull/439)
        ${$self}{fileName} = ${$self}{fileName};

        $logger->info("Overwriting file ${$self}{fileName}");
        my $OUTPUTFILE = open_with_encode( '>:encoding(UTF-8)', ${$self}{fileName} );
        print $OUTPUTFILE ${$self}{body};
        close($OUTPUTFILE);
    }
    elsif ( $switches{outputToFile} ) {
        $logger->info("Outputting to file ${$self}{outputToFile}");
        my $OUTPUTFILE = open_with_encode( '>:encoding(UTF-8)', ${$self}{outputToFile} );
        print $OUTPUTFILE ${$self}{body};
        close($OUTPUTFILE);
    }
    else {
        $logger->info("Not outputting to file; see -w and -o switches for more options.");
    }

    # output to screen, unless silent mode
    print ${$self}{body} unless $switches{silentMode};

    return;
}

sub output_logfile {

    my $self = shift;
    #
    # put the final line in the logfile
    $logger->info("${$mainSettings{logFilePreferences}}{endLogFileWith}")
        if ${ $mainSettings{logFilePreferences} }{endLogFileWith};

    # github info line
    $logger->info("*Please direct all communication/issues to:")
        if ${ $mainSettings{logFilePreferences} }{showGitHubInfoFooter};
    $logger->info("https://github.com/cmhughes/latexindent.pl")
        if ${ $mainSettings{logFilePreferences} }{showGitHubInfoFooter};
    $logger->info("documentation: https://latexindentpl.readthedocs.io/en/latest/")
        if ${ $mainSettings{logFilePreferences} }{showGitHubInfoFooter};

    # open log file
    my $logfileName = $switches{logFileName} || "indent.log";

    my $logfilePath;
    $logfilePath = "${$self}{cruftDirectory}/$logfileName";
    $logfilePath =~ s/\\/\//g;
    $logfilePath =~ s/\/{2,}/\//g;
    if ( $^O eq 'MSWin32' ) {
        $logfilePath =~ s/\//\\/g;
    }

    my $logfile = open_with_encode( '>:encoding(UTF-8)', $logfilePath );

    if ($logfile) {
        foreach my $line ( @{LatexIndent::Logger::logFileLines} ) {
            print $logfile $line, "\n";
        }

        # close log file
        close($logfile);
    }
    else {
        if ( $switches{screenlog} ) {
            print "WARN:  Could not open the logfile $logfilePath \n";
            print "       No logfile will be produced.\n";
        }
    }
}

1;
