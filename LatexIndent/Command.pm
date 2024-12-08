package LatexIndent::Command;

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
use LatexIndent::Tokens           qw/%tokens/;
use LatexIndent::TrailingComments qw/$trailingCommentRegExp/;
use LatexIndent::Switches         qw/$is_t_switch_active $is_tt_switch_active/;
use LatexIndent::GetYamlSettings  qw/%mainSettings/;
use LatexIndent::LogFile          qw/$logger/;
use Data::Dumper;
use Exporter qw/import/;
our @ISA = "LatexIndent::Document";    # class inheritance, Programming Perl, pg 321
our @EXPORT_OK
    = qw/construct_command_regexp $commandRegExp $commandRegExpTrailingComment $optAndMandAndRoundBracketsRegExpLineBreaks/;
our $commandCounter;
our $commandRegExp;
our $commandRegExpTrailingComment;
our $optAndMandAndRoundBracketsRegExp;
our $optAndMandAndRoundBracketsRegExpLineBreaks;

# store the regular expression for matching and replacing
sub construct_command_regexp {
    my $self = shift;

    $optAndMandAndRoundBracketsRegExp = $self->get_arguments_regexp(
        roundBrackets          => ${ $mainSettings{commandCodeBlocks} }{roundParenthesesAllowed},
        stringBetweenArguments => 1
    );

    $optAndMandAndRoundBracketsRegExpLineBreaks = $self->get_arguments_regexp(
        roundBrackets          => ${ $mainSettings{commandCodeBlocks} }{roundParenthesesAllowed},
        mode                   => "lineBreaksAtEnd",
        stringBetweenArguments => 1
    );

    # put together a list of the special command names (this was mostly motivated by the \@ifnextchar[ issue)
    my $commandNameSpecialRegExp = q();
    if ( ref( ${ $mainSettings{commandCodeBlocks} }{commandNameSpecial} ) eq "ARRAY" ) {

        my @commandNameSpecial = @{ ${ $mainSettings{commandCodeBlocks} }{commandNameSpecial} };
        $logger->trace("*Looping through array for commandCodeBlocks->commandNameSpecial")
            if $is_t_switch_active;

        # note that the zero'th element in this array contains the amalgamate switch, which we don't want!
        foreach ( @commandNameSpecial[ 1 .. $#commandNameSpecial ] ) {
            $logger->trace("$_") if $is_t_switch_active;
            $commandNameSpecialRegExp .= ( $commandNameSpecialRegExp eq "" ? q() : "|" ) . $_;
        }

        # turn the above into a regexp
        $commandNameSpecialRegExp = qr/$commandNameSpecialRegExp/;
    }

    # details to log file
    $logger->trace("*The special command names regexp is: $commandNameSpecialRegExp (see commandNameSpecial)")
        if $is_t_switch_active;

    # read from fine tuning
    my $commandNameRegExp = qr/${${$mainSettings{fineTuning}}{commands}}{name}/;

    # construct the command regexp
    $commandRegExp = qr/
              (\\|\\@|@)   
              (
               $commandNameRegExp|$commandNameSpecialRegExp      # lowercase|uppercase letters, @, *, numbers
              )                
              (\h*)
              (\R*)?
              ($optAndMandAndRoundBracketsRegExp)
              (\R)?
            /sx;

    # command regexp with trailing comment
    $commandRegExpTrailingComment = qr/$commandRegExp(\h*)((?:$trailingCommentRegExp\h*)*)/;

}

1;
