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
        <Command> | <Literal>

    <objrule: LatexIndent::Command=Command>    
        <begin=(\\)>
        <name=([^][\$&%#_{}~^\s]+)>
        <[Arguments]>*
        <linebreaksAtEndEnd=(\R*)> 

    <objrule: LatexIndent::Arguments=Arguments> 
        (?:<OptionalArgs>|<MandatoryArgs>|<Between>)

    <objrule: LatexIndent::OptionalArgument=OptionalArgs> 
        <begin=(\[)> 
        <leadingHorizontalSpace=(\h*)>
        <linebreaksAtEndBegin=(\R*)> 
        <[Element]>* 
        <linebreaksAtEndBody=(\R*)> 
        <end=(\])> 

    <objrule: LatexIndent::MandatoryArgument=MandatoryArgs> 
        <begin=(\{)> 
        <leadingHorizontalSpace=(\h*)>
        <linebreaksAtEndBegin=(\R*)> 
        <[Element]>* 
        <linebreaksAtEndBody=(\R*)> 
        <end=(\})> 


    <objrule: LatexIndent::Literal=Literal>    
        <body=([^][\\$&%#_{}~^]+)>

    # to fix
    # to fix
    # to fix
    <rule: Between>                      [*_]
}xms;

1;
