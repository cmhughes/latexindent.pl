package LatexIndent::Braces;

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
use LatexIndent::TrailingComments qw/$trailingCommentRegExp/;
use LatexIndent::Command qw/$commandRegExp $commandRegExpTrailingComment $optAndMandAndRoundBracketsRegExpLineBreaks/;
use LatexIndent::KeyEqualsValuesBraces
    qw/$key_equals_values_bracesRegExp $key_equals_values_bracesRegExpTrailingComment/;
use LatexIndent::NamedGroupingBracesBrackets qw/$grouping_braces_regexp $grouping_braces_regexpTrailingComment/;
use LatexIndent::UnNamedGroupingBracesBrackets
    qw/$un_named_grouping_braces_RegExp $un_named_grouping_braces_RegExp_trailing_comment/;
use LatexIndent::GetYamlSettings qw/%previouslyFoundSettings/;
use LatexIndent::Switches qw/$is_t_switch_active $is_tt_switch_active/;
use LatexIndent::LogFile  qw/$logger/;
use Data::Dumper;
use Exporter qw/import/;
our @ISA       = "LatexIndent::Document";    # class inheritance, Programming Perl, pg 321
our @EXPORT_OK = qw/find_commands_or_key_equals_values_braces $braceBracketRegExpBasic find_things_with_braces_brackets/;
our $commandCounter;
our $braceBracketRegExpBasic = qr/\{|\[/;

our $latexCommand;
our $argumentBodyRegEx = qr{
        (?>              # 
          \\             #  \   backslash
            (?>          # 
              \{         #  \\\{  means \{
              |          # 
              \}         #  \\\}  means \}
              |          # 
              \[         #  \\\[  means \[
              |          # 
              \]         #  \\\]  means \]
            )            # 
            |            #  OR
            [^{}\[\]]    #   anything except {, }, [, ]
        )+               # 
}x;
our $allArgumentRegEx = qr{
     (?:
       (
        \s*
        (?<!\\)
        \{
        \h*
        (\R?)
       )
       (
        (?:
          (?: $argumentBodyRegEx ) # argument body 
          |
          (??{ $latexCommand })    # command regex, RECURSIVE
        )*
       )
       (
        (?<!\\)
        \}
       )
     )
     |
     (?:
       (
        (?<!\\)
        \[
        \h*
        (\R?)
       )
       (
        (?:
          (?: $argumentBodyRegEx ) # argument body 
          |
          (??{ $latexCommand })    # command regex, RECURSIVE
        )*
       )
       (
        (?<!\\)
        \]
       )
     )
}x;

$latexCommand = qr{
   \\
   ([a-zA-Z]+?)
   (
    (?:
     $allArgumentRegEx 
    )+
   )
   }x;

sub find_things_with_braces_brackets {

    my $body = shift;
    my $currentIndentation = shift;

    $body =~ s/$latexCommand/
       my $commandName = $1;
       my $argBody = $2;
       if (!$previouslyFoundSettings{$commandName."commands"}){
          my $commandObj = LatexIndent::Braces->new(name=>$commandName,
                                              modifyLineBreaksYamlName=>"commands",
                                              arguments=>1,
                                                );
          $commandObj->yaml_get_indentation_settings_for_this_object;
       }
       $argBody = &indent_all_args($commandName."commands", $argBody,$currentIndentation);
       "\\".$commandName.$argBody;/sgex;

    return $body;
}

sub indent_all_args {

    my $commandStorageName = shift;
    my $body = shift;
    my $indentation = shift;

    my $mandatoryArgumentsIndentation = ${$previouslyFoundSettings{$commandStorageName}}{mandatoryArgumentsIndentation};
    my $optionalArgumentsIndentation  = ${$previouslyFoundSettings{$commandStorageName}}{optionalArgumentsIndentation};

    my $all_args;
    $all_args = qr{
       \G
       (?:
         (                                                          #
          \s*
          (?<!\\)
          \{                                                        #
          \h*                                                       # $1
          (?:$trailingCommentRegExp)*                               # 
          (\R?)                                                     # $2
         )                                                          #
         (                                                          # $3
          (?:                                                       #
            (?: $argumentBodyRegEx ) # argument body 
            |                                                       #
            (??{ $latexCommand }) # Group with matching braces {}   #
          )*                                                        #
         )                                                          #
         (                                                          # $4
          (?<!\\)
          \}                                                        #
         )                                                          #
       )                                                            #
       |                                                            #
       (?:                                                          #
         (                                                          # $5
          (?<!\\)
          \[                                                        #
          \h*                                                       #
           (?:$trailingCommentRegExp)*                              # 
          (\R?)                                                     # $6
         )                                                          #
         (                                                          # $7
          (?:                                                       #
            (?: $argumentBodyRegEx ) # argument body 
            |                                                       #
            (??{ $latexCommand }) # Group with matching braces {}   #
          )*                                                        #
         )                                                          #
         (                                                          # $8
          (?<!\\)
          \]                                                        #
         )                                                          #
       )
       }x;

    $body =~ s/$all_args/
       my $begin = ($1?$1:$5);
       my $currentIndentation = q();
       if ($2) {
          $currentIndentation = $mandatoryArgumentsIndentation;
       } elsif ($6){
          $currentIndentation = $optionalArgumentsIndentation;
       }
       $currentIndentation = $currentIndentation.$indentation;
       my $argBody = ($3?$3:$7);
       my $end = ($4?$4:$8);
       $argBody = &find_things_with_braces_brackets($argBody,$indentation);
       $argBody =~ s@^@$currentIndentation@mg;
       $begin.$argBody.$end;/sgex;
    return $body;
}

1;
