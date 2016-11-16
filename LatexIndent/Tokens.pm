package LatexIndent::Tokens;
use strict;
use warnings;
use Data::Dumper;
use Exporter qw/import/;
our @EXPORT_OK = qw/get_tokens/;
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
                endOfToken=>"-END",
              );

sub get_tokens{
    return \%tokens; 
}
1;
