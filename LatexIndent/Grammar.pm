package LatexIndent::Grammar;
use strict;
use warnings;
use Exporter qw/import/;
use Regexp::Grammars;
use Data::Dumper;
our @EXPORT_OK = qw/$latex_indent_parser/;
our $latex_indent_parser; 


$latex_indent_parser = qr{
    # starting point:
    #   https://perl-begin.org/uses/text-parsing/
    #   https://metacpan.org/pod/Regexp::Grammars#Subrule-results
    
    # helpful
    #   https://stackoverflow.com/questions/1352657/regex-for-matching-custom-syntax
    
    # https://metacpan.org/pod/Regexp::Grammars#Debugging1
    <logfile: cmh.log >

    # https://metacpan.org/pod/Regexp::Grammars#Subrule-results
    <nocontext:>

    <File>

    <objrule: LatexIndent::File=File>          
        <[Element]>*

    <objrule: LatexIndent::Element=Element>    
        <Environment> 
      | <Command> 
      | <KeyEqualsValuesBraces> 
      | <NamedGroupingBracesBrackets> 
      | <Special> 
      | <Literal>
      
    # Commands
    #   \<name> <arguments>
    <objrule: LatexIndent::Command=Command>    
        <begin=(\\)>
        <name=([a-zA-Z0-9*]+)>
        <[Arguments]>+
        <linebreaksAtEndEnd=(\R*)> 

    # key = value braces/brackets
    #   key = <arguments>
    <objrule: LatexIndent::KeyEqualsValuesBraces=KeyEqualsValuesBraces>    
        <name=([a-zA-Z@\*0-9_\/.\h\{\}:\#-]+?)>
        <equals=((?:\h|\R)*=(\h|\R)*)>
        <[Arguments]>+
        <linebreaksAtEndEnd=(\R*)> 

    # NamedGroupingBracesBrackets
    #   <name> <arguments>
    <objrule: LatexIndent::NamedGroupingBracesBrackets=NamedGroupingBracesBrackets>    
        <name=([a-zA-Z0-9*]+)>
        <[Arguments]>+
        <linebreaksAtEndEnd=(\R*)> 

    # Combination of arguments
    #   e.g. \[...\] \{...\} ... \[ \]
    <objrule: LatexIndent::Arguments=Arguments> 
        <Between>?(<OptionalArgs>|<MandatoryArgs>)

    # Optional Arguments
    #   \[ .... \]
    <objrule: LatexIndent::OptionalArgument=OptionalArgs> 
        <begin=(\[)> 
        <leadingHorizontalSpace=(\h*)>
        <linebreaksAtEndBegin=(\R*)> 
        <[Element]>* 
        <linebreaksAtEndBody=(\R*)> 
        <end=(\])> 
        <linebreaksAtEndEnd=(\R*)> 

    # Mandatory Arguments
    #   \{ .... \}
    <objrule: LatexIndent::MandatoryArgument=MandatoryArgs> 
        <begin=(\{)> 
        <leadingHorizontalSpace=(\h*)>
        <linebreaksAtEndBegin=(\R*)> 
        <[Element]>*? 
        <linebreaksAtEndBody=(\R*)> 
        <end=(\})> 
        <linebreaksAtEndEnd=(\R*)> 

    # Between arguments
    <objrule: LatexIndent::Between=Between>                      
        <body=((\h|\R)*[*_^])>
        
    # Environments
    #   \begin{<name>}<Arguments>
    #       body ...
    #       body ...
    #   \end{<name>}
    <objrule: LatexIndent::Environment=Environment>    
        <begin=(\\begin\{)>
        <name=([a-zA-Z0-9]+)>\}
        <leadingHorizontalSpace=(\h*)>
        <linebreaksAtEndBegin=(\R*)> 
        <[Arguments]>*?
        <[GroupOfItems]>?
        <end=(\\end\{(??{quotemeta $MATCH{name}})\})>
        <linebreaksAtEndEnd=(\R*)> 
        
    <objrule: LatexIndent::GroupOfItems=GroupOfItems>    
        <[Item]>+ % <[itemHeading]>

    <objrule: LatexIndent::Item=Item>    
        <[Element]>+?

    <token: itemHeading>
        (\\item(?:(\h|\R)*))

    # Special
    #   USER specified
    #
    #   default: 
    #       $ ... $
    #       \[ ... \]
    <objrule: LatexIndent::Special=Special>    
        <begin=((??{$LatexIndent::Special::special_begin_reg_ex}))>
        <leadingHorizontalSpace=(\h*)>
        <linebreaksAtEndBegin=(\R*)> 
        <[Element]>*?
        <end=end_special(:begin)>
        <horizontalTrailingSpace=(\h*)> 
        <linebreaksAtEndEnd=(\R*)> 

    <token: end_special>
        (??{
            return $LatexIndent::Special::special_end_look_up_hash{ $ARG{begin} } 
                if $LatexIndent::Special::special_end_look_up_hash{ $ARG{begin} }; 

            while( my ($key,$value)= each %LatexIndent::Special::special_look_up_hash){
                if ($ARG{begin} =~ ${$value}{begin} ){
                    $LatexIndent::Special::special_end_look_up_hash{ $ARG{begin} } = ${$value}{end};
                }
            }
            return $LatexIndent::Special::special_end_look_up_hash{ $ARG{begin} };
           })

    # anything else
    <objrule: LatexIndent::Literal=Literal>    
        <body=((?:[a-zA-Z0-9&^()']|\h|\R|\\\\)*)>
}xs;

1;
