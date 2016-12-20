package LatexIndent::Tokens;
use strict;
use warnings;
use Exporter qw/import/;
our @EXPORT_OK = qw/get_tokens token_check/;
our %tokens = (
                environment=>"LATEX-INDENT-ENVIRONMENT",
                ifelsefi=>"!-!LATEX-INDENT-IFELSEFI", 
                item=>"LATEX-INDENT-ITEMS",
                trailingComment=>"latexindenttrailingcomment", 
                blanklines=>"latex-indent-blank-line",
                arguments=>"LATEX-INDENT-ARGUMENTS",
                optionalArgument=>"LATEX-INDENT-OPTIONAL-ARGUMENT",
                mandatoryArgument=>"LATEX-INDENT-MANDATORY-ARGUMENT",
                verbatim=>"LATEX-INDENT-VERBATIM",
                indentation=>"LATEX-INDENT-INDENTATION",
                command=>"LATEX-INDENT-COMMAND",
                key_equals_values_braces=>"LATEX-INDENT-KEY-VALUE-BRACES",
                groupingBraces=>"LATEX-INDENT-GROUPING-BRACES",
                unNamedgroupingBraces=>"LATEX-INDENT-UN-NAMED-GROUPING-BRACES",
                endOfToken=>"-END",
              );

sub token_check{
    my $self = shift;

    $self->logger("Token check",'heading.trace');
    # we use tokens for trailing comments, environments, commands, etc, so check that they're not in the body
    foreach( keys %tokens){
        while(${$self}{body} =~ m/$tokens{$_}/si){
            $self->logger("Found $tokens{$_} within body, updating replacement token to $tokens{$_}-LIN",'trace');
            $tokens{$_} .= "-LIN";
        }
    }
}


sub get_tokens{
    return \%tokens; 
}
1;
