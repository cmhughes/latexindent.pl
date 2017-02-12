package LatexIndent::Tokens;
use strict;
use warnings;
use Exporter qw/import/;
use LatexIndent::Switches qw/$is_t_switch_active $is_tt_switch_active/;
our @EXPORT_OK = qw/token_check %tokens/;

# each of the tokens begins the same way -- this is exploited during the hidden Children routine
my $beginningToken = "LTXIN-TK-";
my $ifelsefiSpecial = "!-!";

# the %tokens hash is passed around many modules
our %tokens = (
                environment=>$beginningToken."ENVIRONMENT",
                ifelsefiSpecial=>$ifelsefiSpecial,
                ifelsefi=>$ifelsefiSpecial.$beginningToken."IFELSEFI", 
                item=>$beginningToken."ITEMS",
                trailingComment=>"latexindenttrailingcomment", 
                blanklines=>$beginningToken."blank-line",
                arguments=>$beginningToken."ARGUMENTS",
                optionalArgument=>$beginningToken."OPTIONAL-ARGUMENT",
                mandatoryArgument=>$beginningToken."MANDATORY-ARGUMENT",
                roundBracket=>$beginningToken."ROUND-BRACKET",
                verbatim=>$beginningToken."VERBATIM",
                command=>$beginningToken."COMMAND",
                key_equals_values_braces=>$beginningToken."KEY-VALUE-BRACES",
                groupingBraces=>$beginningToken."GROUPING-BRACES",
                unNamedgroupingBraces=>$beginningToken."UN-NAMED-GROUPING-BRACES",
                special=>$beginningToken."SPECIAL",
                heading=>$beginningToken."HEADING",
                filecontents=>$beginningToken."FILECONTENTS",
                preamble=>$beginningToken."preamble",
                beginOfToken=>$beginningToken,
                doubleBackSlash=>$beginningToken."DOUBLEBACKSLASH",
                alignmentBlock=>$beginningToken."ALIGNMENTBLOCK",
                endOfToken=>"-END",
              );

sub token_check{
    my $self = shift;

    $self->logger("Token check",'heading') if $is_t_switch_active;
    # we use tokens for trailing comments, environments, commands, etc, so check that they're not in the body
    foreach( keys %tokens){
        while(${$self}{body} =~ m/$tokens{$_}/si){
            $self->logger("Found $tokens{$_} within body, updating replacement token to $tokens{$_}-LIN") if($is_t_switch_active);
            $tokens{$_} .= "-LIN";
        }
    }
}


1;
