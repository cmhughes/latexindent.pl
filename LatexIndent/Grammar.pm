package LatexIndent::Grammar;
use strict;
use warnings;
use Exporter qw/import/;
use Regexp::Grammars;
use Data::Dumper;
our @EXPORT_OK = qw/$latex_indent_parser find_special_end/;
our $latex_indent_parser; 

my $special_begin_reg_ex = qr/\$|\\\[/s;

my %special_look_up_hash = (displayMath=>({
                                            begin=>qr/\\\[/s,
                                            end=>qr/\\\]/s
                                          }),
                            inlineMath=>({
                                            begin=>qr/\$/s,
                                            end=>qr/\$/s
                                         }),
                 );

my %special_end_look_up_hash;

# my $test_begin = '$';
# while( my ($key,$value)= each %special_look_up_hash){
#     if ($test_begin =~ ${$value}{begin} ){
#         print "match found: ",$key,"\n";
#         print "corresponding end: ",${$value}{end},"\n";
#     }
# }
# 
# print "================\n";
# 
# print Dumper \%special_look_up_hash; 


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
        
    # Special
    #   USER specified
    #
    #   default: 
    #       $ ... $
    #       \[ ... \]
    <objrule: LatexIndent::Special=Special>    
        <begin=((??{$special_begin_reg_ex}))>
        <leadingHorizontalSpace=(\h*)>
        <linebreaksAtEndBegin=(\R*)> 
        <[Element]>*?
        <end=end_special(:begin)>
        <horizontalTrailingSpace=(\h*)> 
        <linebreaksAtEndEnd=(\R*)> 

    <token: end_special>
        (??{
            return $special_end_look_up_hash{ $ARG{begin} } 
                if $special_end_look_up_hash{ $ARG{begin} }; 

            my $special_end = q();
            while( my ($key,$value)= each %special_look_up_hash){
                if ($ARG{begin} =~ ${$value}{begin} ){
                    $special_end = ${$value}{end};
                    $special_end_look_up_hash{ $ARG{begin} } = ${$value}{end};
                }
            }
            return $special_end;
           })

    # anything else
    <objrule: LatexIndent::Literal=Literal>    
        <body=((?:[a-zA-Z0-9&^()]|\h|\R|\\\\)*)>
}xms;

1;
