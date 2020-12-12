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
use LatexIndent::Switches qw/storeSwitches %switches $is_m_switch_active $is_t_switch_active $is_tt_switch_active $is_r_switch_active $is_rr_switch_active $is_rv_switch_active/;
use LatexIndent::LogFile qw/processSwitches $logger/;
use LatexIndent::Replacement qw/make_replacements/;
use LatexIndent::GetYamlSettings qw/yaml_read_settings yaml_modify_line_breaks_settings yaml_get_indentation_settings_for_this_object yaml_poly_switch_get_every_or_custom_value yaml_get_indentation_information yaml_get_object_attribute_for_indentation_settings yaml_alignment_at_ampersand_settings yaml_get_textwrap_removeparagraphline_breaks %masterSettings yaml_get_columns/;
use LatexIndent::FileExtension qw/file_extension_check/;
use LatexIndent::BackUpFileProcedure qw/create_back_up_file/;
use LatexIndent::AlignmentAtAmpersand qw/align_at_ampersand find_aligned_block double_back_slash_else main_formatting individual_padding multicolumn_padding multicolumn_pre_check  multicolumn_post_check dont_measure/;
use LatexIndent::HorizontalWhiteSpace qw/remove_trailing_whitespace remove_leading_space/;

# grammar-related 
use LatexIndent::Between;
use LatexIndent::Element;
use LatexIndent::File;
use LatexIndent::Grammar qw/$latex_indent_parser/;
use LatexIndent::Literal;

# code blocks
use LatexIndent::Verbatim qw/put_verbatim_back_in find_verbatim_environments find_noindent_block find_verbatim_commands  find_verbatim_special verbatim_common_tasks/;
use LatexIndent::Arguments;
use LatexIndent::Command;
use LatexIndent::Environment;
use LatexIndent::MandatoryArgument;
use LatexIndent::OptionalArgument;
use LatexIndent::NamedGroupingBracesBrackets;
use LatexIndent::KeyEqualsValuesBraces;
use LatexIndent::Special;
use LatexIndent::GroupOfItems;
use LatexIndent::Item;

# Data::Dumper settings
#   reference: https://stackoverflow.com/questions/7466825/how-do-you-sort-the-output-of-datadumper
$Data::Dumper::Terse = 1;
$Data::Dumper::Indent = 1;
$Data::Dumper::Useqq = 1;
$Data::Dumper::Deparse = 1;
$Data::Dumper::Quotekeys = 0;
$Data::Dumper::Sortkeys = 1;

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
    $self->remove_leading_space;
    $self->{body} =~ $latex_indent_parser;
    print Dumper \%/;
    $/{File}->explain(0);
    print "----------- end of explain --------------\n";
    $self->{body} = $/{File}->indent(0);
    $self->output_indented_text;
    return
}

sub explain {
    my ($self, $level) = @_;
    for my $element (@{$self->{Element}}) {
        $element->explain($level);
    }
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

1;
