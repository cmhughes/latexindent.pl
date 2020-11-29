package LatexIndent::Grammar;
use strict;
use warnings;
use Exporter qw/import/;
use Regexp::Grammars;
our @EXPORT_OK = qw/$latex_indent_parser/;
our $latex_indent_parser; 

$latex_indent_parser = qr{
    # starting point:
    #   https://perl-begin.org/uses/text-parsing/
    #   https://metacpan.org/pod/Regexp::Grammars#Subrule-results
    
    # helpful
    #   https://stackoverflow.com/questions/1352657/regex-for-matching-custom-syntax
    
    # https://metacpan.org/pod/Regexp::Grammars#Debugging1
    # <logfile: indent.log >

    # https://metacpan.org/pod/Regexp::Grammars#Subrule-results
    <nocontext:>

    <File>

    <objrule: LatexIndent::File=File>          
        <[Element]>*

    <objrule: LatexIndent::Element=Element>    
        <Environment> | <Command> | <Literal>

    <objrule: LatexIndent::Command=Command>    
        <begin=(\\)>
        <name=([^][\$&%#_{}~^\s]+)>
        <[Arguments]>+
        <linebreaksAtEndEnd=(\R*)> 

    # Environments
    #   \begin{<name>}
    #       body ...
    #       body ...
    #   \end{<name>}
    <objrule: LatexIndent::Environment=Environment>    
        <begin=(\\begin\{)>
        <name=([a-zA-Z0-9]+)>\}
        <leadingHorizontalSpace=(\h*)>
        <linebreaksAtEndBegin=(\R*)> 
        #<[Arguments]>*
        <[Element]>*?
        <end=(\\end\{(??{quotemeta $MATCH{name}})\})>
        <linebreaksAtEndEnd=(\R*)> 

    # Combination of arguments
    #   e.g. \[...\] \{...\} ... \[ \]
    <objrule: LatexIndent::Arguments=Arguments> 
        <OptionalArgs>|<MandatoryArgs>|<Between>

    # Optional Arguments
    #   \[ .... \]
    <objrule: LatexIndent::OptionalArgument=OptionalArgs> 
        <begin=(\[)> 
        <leadingHorizontalSpace=(\h*)>
        <linebreaksAtEndBegin=(\R*)> 
        <[Element]>* 
        <linebreaksAtEndBody=(\R*)> 
        <end=(\])> 

    # Mandatory Arguments
    #   \{ .... \}
    <objrule: LatexIndent::MandatoryArgument=MandatoryArgs> 
        <begin=(\{)> 
        <leadingHorizontalSpace=(\h*)>
        <linebreaksAtEndBegin=(\R*)> 
        <[Element]>*? 
        <linebreaksAtEndBody=(\R*)> 
        <end=(\})> 

    # Between arguments
    <objrule: LatexIndent::Between=Between>                      
        <body=([*_^])>

    <objrule: LatexIndent::Literal=Literal>    
        <body=((?:[a-zA-Z0-9&]|\h|\R|\\\\)*)>
}xms;

1;
