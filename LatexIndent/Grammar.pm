package LatexIndent::Grammar;
use strict;
use warnings;
use Exporter qw/import/;
use Regexp::Grammars;
use Data::Dumper;
our @EXPORT_OK = qw/$latex_indent_parser/;
our $latex_indent_parser; 

our %environment_items = (cmh=>({item=>qr/\\item(?:(\h|\R)*)/s }),);
our %ifelsefi_else = (else=>qr/\\else(?:(\h|\R)*)/s );

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
      | <IfElseFi>
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
        <Between>?(<OptionalArg>|<MandatoryArg>)

    # Optional Arguments
    #   \[ .... \]
    <objrule: LatexIndent::OptionalArgument=OptionalArg> 
        <begin=(\[)>                        # [
        <leadingHorizontalSpace=(\h*)>      #
        <linebreaksAtEndBegin=(\R*)>        #   ANYTHING
        <[Element]>*                        #   ANYTHING
        <linebreaksAtEndBody=(\R*)>         #
        <end=(\])>                          # ]
        <linebreaksAtEndEnd=(\R*)> 

    # Mandatory Arguments
    #   \{ .... \}
    <objrule: LatexIndent::MandatoryArgument=MandatoryArg> 
        <begin=(\{)>                        # {
        <leadingHorizontalSpace=(\h*)>      #
        <linebreaksAtEndBegin=(\R*)>        #   ANYTHING
        <[Element]>*?                       #   ANYTHING
        <linebreaksAtEndBody=(\R*)>         #
        <end=(\})>                          # } 
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
        <type=(?{'Environment'})>
        <leadingHorizontalSpace=(\h*)>
        <linebreaksAtEndBegin=(\R*)> 
        <[Arguments]>*?
        <GroupOfItems(:name,:type)>?                  
        <end=(\\end\{(??{ quotemeta $MATCH{name} })\})>
        <linebreaksAtEndEnd=(\R*)> 
        
    <objrule: LatexIndent::GroupOfItems=GroupOfItems>    
        <name=(?{ $ARG{name} })>                 # store the name
        <type=(?{ $ARG{type} })>                 # store the type
        <[Item]>+ % <[itemHeading(:name,:type)]> # pass it to the item heading

    <objrule: LatexIndent::Item=Item>    
        <[Element]>+?

    <token: itemHeading>
        (??{
            return $ifelsefi_else{else}
                if $ARG{type} eq 'IfElseFi';

            return ${ $environment_items{ $ARG{name} } }{item}
                if ${ $environment_items{ $ARG{name} } }{item};

            return q{(\\\\item(?:(\h|\R)*))}; 
        })

    # ifElseFi
    #   \if
    #       body ...
    #       body ...
    #   \fi
    <objrule: LatexIndent::IfElseFi=IfElseFi>    
        <begin=(\\if)>
        <type=(?{'IfElseFi'})>
        <leadingHorizontalSpace=(\h*)>
        <linebreaksAtEndBegin=(\R*)> 
        <GroupOfItems(:name,:type)>?
        <end=(\\fi)>
        <horizontalTrailingSpace=(\h*)> 
        <linebreaksAtEndEnd=(\R*)> 

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
