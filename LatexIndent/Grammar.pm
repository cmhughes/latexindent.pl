package LatexIndent::Grammar;
use strict;
use warnings;
use Exporter qw/import/;
use Regexp::Grammars;
use Data::Dumper;
our @EXPORT_OK = qw/get_latex_indent_parser/;
our $latex_indent_parser; 

# TO DO: eventually these hashes need to live in GetYamlSettings
# TO DO: environment_items and ifelsefi_else to be constructed *ONCE* at time of YAML reading
our %environment_items = (cmh=>({item=>qr/\\item(?:((\h*\R+)|(\h*)))/s }),);
our %ifelsefi_else = (else=>qr/(?:\\else|\\or)(?:(\h*\R)*)/s );
# TO DO: Headings names need constructing
#        and then add a <require> check within the Heading block
# TO DO: filecontents names need reading from YAML
# TO DO: Verbatim token needs to do a document check to ensure it isn't present in the document

# about modifiers, from Chapter 7 (page 212) Mastering Regular Expressions, Friedl
#   
#   mode                        ^ and $ anchors consider target text as         dot
#   -----------------------------------------------------------------------------------------
#   default             /       a single string, without regard to newlines     doesn't match newline 
#   single-line         /s      a single string, without regard to newlines     matches all characters
#   mult-line           /m      multiple logical lines separated by newlines    unchanged from default
#   clean multi-line    /sm     multiple logical lines separated by newlines    matches all characters

sub get_latex_indent_parser{

    $latex_indent_parser = qr{
    
    
        # starting point:
        #   https://perl-begin.org/uses/text-parsing/
        #   https://metacpan.org/pod/Regexp::Grammars#Subrule-results
        
        # helpful
        #   https://stackoverflow.com/questions/1352657/regex-for-matching-custom-syntax
        
        # https://metacpan.org/pod/Regexp::Grammars#Debugging1
        #<logfile: cmh.log >
        # <debug: match>
    
        # https://metacpan.org/pod/Regexp::Grammars#Subrule-results
        <nocontext:>
    
        # FILE is the top-level element, everything else follows from it
        <File>
    
        # WHITE SPACE: 
        #   it is *vital* to re-define the whitespace <ws> element in order
        #   to keep track of blank lines
        #
        #   reference: https://metacpan.org/pod/Regexp::Grammars#Tokens-vs-rules-(whitespace-handling)
        #
        <token: ws>
            (?:\h*)
    
        <objrule: LatexIndent::File=File>          
            <headinglevel=(?{1})> 
            <[Element(:headinglevel)]>*
    
        # each of the different CODE BLOCKS and COMMENTS and LINE BREAKS
        # are all ELEMENTS to latexindent.pl
        #
        <objrule: LatexIndent::Element=Element>    
            <NoIndentBlock> 
            | <BeginsWithBackSlash>
            | (?: 
                  <headinglevel=(?{ $ARG{headinglevel}//=0; 
                                    $ARG{incrementHeadingLevel}//=0; 
                                    $ARG{headinglevel} + $ARG{incrementHeadingLevel}; })>
                  <Heading(:headinglevel)>
              )
            | <Command> 
            | <KeyEqualsValuesBraces> 
            | <NamedGroupingBracesBrackets> 
            | <Special> 
            | <TrailingComment> 
            | <BlankLine>
            | <Literal>
            
        # Begins With Backslash
        <objrule: LatexIndent::Element=BeginsWithBackSlash>    
            <begin=(\\)>
            ( <PreambleVerbatim>
                | <Preamble>
                | <EnvironmentStructure> 
                | <IfElseFi> )

        # Environment structure
        <objrule: LatexIndent::Element=EnvironmentStructure>    
            <begin=(begin\{)>
            (<Verbatim> | <FileContents> | <Environment>)
            
        # NoIndentBlock 
        #
        # Note: this is just a Verbatim block
        <objrule: LatexIndent::Verbatim=NoIndentBlock>    
            <begin=((?<!\\)\%\h*\\begin\{)>                              # \begin{
            <name=(noindent)>\}                                          #   name
            <type=(?{'Verbatim'})>                                       # }
            <[VerbatimLiteral]>*?                                        # body
            <end=((?<!\\)\%\h*\\end\{(??{ quotemeta $MATCH{name} })\})>  # \end{name}
            <trailingHorizontalSpace=(\h*)>  
            <linebreaksAtEndEnd> 
    
        # Verbatim 
        <objrule: LatexIndent::Verbatim=Verbatim>    
            # REDEFINE whitespace
            #   important for space infront of \end{verbatim}
            <ws: ((?<!^)\h)*>
            <begin=(?{"\\begin\{"})>                # \begin{
            <name=(verbatim|lstlistings|minted)>\}          #   name
            <type=(?{'Verbatim'})>                          # }
            <[VerbatimLiteral]>*?                           # body
            <end=EnvironmentEnd(:name)>                     # \end{name}
            <trailingHorizontalSpace=(\h*)>  
            <linebreaksAtEndEnd> 
            
        <objrule: LatexIndent::Literal=VerbatimLiteral>    
           <lead=(^\h+)>?<body=([^\n]+|\R)>
    
        <token: EnvironmentEnd>
            (\h*\\end\{(??{ quotemeta $ARG{name} })\}) # \end{name}
            
        # Preamble
        #   \documentclass...
        #       ...
        #       ...
        #   \begin{document}
        #
        # rule for INDENTING preamble
        <objrule: LatexIndent::Preamble=Preamble>    
            <require: (?{$LatexIndent::GetYamlSettings::masterSettings{indentPreamble};})>
            <begin=(?{"\\documentclass"})>
            documentclass
            <[Arguments]>+
            (<!beginDocument><[Element]>)*
    
        # rule for **NOT** indenting preamble
        <objrule: LatexIndent::Verbatim=PreambleVerbatim>    
            <require: (?{!$LatexIndent::GetYamlSettings::masterSettings{indentPreamble};})>
            <begin=(?{"\\documentclass"})>
            documentclass
            <type=(?{'Preamble: verbatim'})>
            <name=(?{'Preamble'})>
            (<!beginDocument><[PreambleVerbatimBody]>)*
            
        <objrule: LatexIndent::Element=PreambleVerbatimBody>
           <lead=(^\h+)>?(<FileContentsVerbatim>|<VerbatimLiteral>)

        <token: beginDocument>
            \h*\\begin\{document\}
    
        # FileContents
        #   \begin{<name>}
        #       body ...
        #       body ...
        #   \end{<name>}
        <objrule: LatexIndent::FileContents=FileContents>    
            <begin=(?{"\\begin\{"})>                # \begin{
            <name=(filecontents)>\}             #   name
            <type=(?{'FileContents'})>          # }
            <leadingHorizontalSpace=(\h*)>      #
            <linebreaksAtEndBegin=(\R*)>        #
            <[Element]>*?                       # body
            <end=EnvironmentEnd(:name)>         # \end{name}
            <trailingHorizontalSpace=(\h*)>  
            <linebreaksAtEndEnd> 
    
        # FileContents VERBATIM 
        <objrule: LatexIndent::Verbatim=FileContentsVerbatim>    
            # REDEFINE whitespace
            #   important for space infront of \end{verbatim}
            <ws: ((?<!^)\h)*>
            <begin=(\h*\\begin\{)>              # \begin{
            <name=(filecontents)>\}             #   name
            <type=(?{'FileContentsVerbatim'})>  # }
            <[VerbatimLiteral]>*?               # body
            <end=EnvironmentEnd(:name)>         # \end{name}
            <trailingHorizontalSpace=(\h*)>  
            <linebreaksAtEndEnd> 

        # Headings
        #
        #   \part, \chapter, \section etc
        #
        <objrule: LatexIndent::Heading=Heading>    
            <headinglevel=(?{  $ARG{headinglevel}  })>
            <incrementHeadingLevel=(?{1})>
            <begin=(\\)>
            <name=headingText(:headinglevel)>
            <[Arguments]>+
            <linebreaksAtEndEnd> 
            (<!Heading(:headinglevel)><[Element(:headinglevel,:incrementHeadingLevel)]>)*
    
        <token: headingText>
            (??{
                $ARG{headinglevel} //= 0;
                return "section|paragraph" if $ARG{headinglevel} == 0;
    
                # level 1 headings
                return 'chapter|section' if $ARG{headinglevel} == 1;
    
                # level 2 headings need BOTH 
                #   - level 1 headings
                #   AND
                #   - level 2 headings
                return 'chapter|section|subsection' if $ARG{headinglevel} == 2;
                
                # level 3 headings need 
                #   - level 1 headings
                #   AND
                #   - level 2 headings
                #   AND
                #   - level 3 headings
                return 'chapter|section|subsection|paragraph' if $ARG{headinglevel} == 3;
            })
    
        # Commands
        #   \<name> <arguments>
        <objrule: LatexIndent::Command=Command>    
            <begin=(\\)>
            <name=([a-zA-Z0-9*]+)>
            <[Arguments]>+
            <linebreaksAtEndEnd> 
    
        # key = value braces/brackets
        #   key = <arguments>
        <objrule: LatexIndent::KeyEqualsValuesBraces=KeyEqualsValuesBraces>    
            <name=([a-zA-Z@\*0-9_\/.\h\{\}:\#-]++)>
            <equals=((?:\h|\R)*=(\h|\R)*)>
            <[Arguments]>+
            <linebreaksAtEndEnd> 
    
        # NamedGroupingBracesBrackets
        #   <name> <arguments>
        <objrule: LatexIndent::NamedGroupingBracesBrackets=NamedGroupingBracesBrackets>    
            <name=([a-zA-Z0-9*]++)>
            <[Arguments]>+
            <linebreaksAtEndEnd> 
    
        # Combination of arguments
        #   e.g. \[...\] \{...\} ... \[ \]
        <objrule: LatexIndent::Arguments=Arguments> 
            <[Between]>*?(<OptionalArg>|<MandatoryArg>)
    
        # Optional Arguments
        #   \[ .... \]
        <objrule: LatexIndent::OptionalArgument=OptionalArg> 
            <begin=(\[)>                        # [
            <leadingHorizontalSpace=(\h*)>      #
            <linebreaksAtEndBegin=(\R*)>        #   ANYTHING
            <[Element]>*?                       #   ANYTHING
            <linebreaksAtEndBody=(\R*)>         #
            <.ws>
            <end=(\])>                          # ]
            <trailingHorizontalSpace=(\h*)>  
            <linebreaksAtEndEnd> 
    
        # Mandatory Arguments
        #   \{ .... \}
        <objrule: LatexIndent::MandatoryArgument=MandatoryArg> 
            <begin=(\{)>                        # {
            <leadingHorizontalSpace=(\h*)>      #
            <linebreaksAtEndBegin=(\R*)>        #   ANYTHING
            <[Element]>*?                       #   ANYTHING
            <linebreaksAtEndBody=(\R*)>         #
            \h*
            <end=(\})>                          # } 
            <trailingHorizontalSpace=(\h*)>  
            <linebreaksAtEndEnd> 
    
        # Between arguments
        <objrule: LatexIndent::Between=Between>                      
            <body=((?:\h|\R|[*_^])*)>|<TrailingComment>
            
        # Environments
        #   \begin{<name>}<Arguments>
        #       body ...
        #       body ...
        #   \end{<name>}
        <objrule: LatexIndent::Environment=Environment>    
            <begin=(?{"\\begin\{"})>                # \begin{
            <name=([a-zA-Z0-9]+)>\}                 #   name
            <type=(?{'Environment'})>               # }
            <leadingHorizontalSpace=(\h*)>          #
            <linebreaksAtEndBegin=(\R*)>            #
            <[Arguments]>*?                         # possible arguments
            <GroupOfItems(:name,:type,:begin)>?     #   ANYTHING
            <end=EnvironmentEnd(:name)>             # \end{name}
            <trailingHorizontalSpace=(\h*)>  
            <linebreaksAtEndEnd> 
    
        # ifElseFi
        #   \if
        #       body ...
        #       body ...
        #   \fi
        <objrule: LatexIndent::IfElseFi=IfElseFi>    
            <begin=(?{"\\if"})>              # \if
            if
            <type=(?{'IfElseFi'})>           # 
            <leadingHorizontalSpace=(\h*)>   #  ANYTHING
            <linebreaksAtEndBegin=(\R*)>     # 
            <GroupOfItems(:name,:type)>?     #  
            <end=(\\fi)>                     # \fi
            <trailingHorizontalSpace=(\h*)>  # 
            <linebreaksAtEndEnd> 
    
        # Special
        #   USER specified
        #
        #   default: 
        #       $ ... $
        #       \[ ... \]
        <objrule: LatexIndent::Special=Special>    
            <begin=((??{$LatexIndent::Special::special_begin_reg_ex}))>
            <type=(?{'Special'})>
            <leadingHorizontalSpace=(\h*)>
            <linebreaksAtEndBegin=(\R*)> 
            <GroupOfItems(:type,:begin)>?                  
            <end=end_special(:begin)>
            <trailingHorizontalSpace=(\h*)> 
            <linebreaksAtEndEnd> 
    
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
            
        # GroupOfItems
        # Item
        # itemHeading
        #
        #       this set of OBJECTS and TOKENS is used
        #       across a few of the different grammars,
        #       which include
        #           
        #           Environments
        #           IfElseFi
        #           Special
        #
        #       the idea is that GroupOfItems captures (or Groups) 
        #       the list of items, and then each individual
        #       item is operated upon
        #
        #       the 'item' itself is stored within itemHeading
        #
        <objrule: LatexIndent::GroupOfItems=GroupOfItems>    
            <name= (?{ $ARG{name}  })>                      # store the name
            <type= (?{ $ARG{type}  })>                      # store the type
            <begin=(?{ $ARG{begin} })>                      # store the begin
            <[Item]>+ % <[itemHeading(:name,:type,:begin)]> # pass them to the item heading
    
        <objrule: LatexIndent::Item=Item>    
            <[Element]>+?
    
        <token: itemHeading>
            (??{
                # IfElseFi
                return $ifelsefi_else{else}
                    if $ARG{type} eq 'IfElseFi';
    
                # Environment
                return ${ $environment_items{ $ARG{name} } }{item}
                    if ($ARG{type} eq 'Environment' and ${ $environment_items{ $ARG{name} } }{item});
    
                # Special
                if ($ARG{type} eq 'Special'){
                    return $LatexIndent::Special::special_middle_look_up_hash{ $ARG{begin} } 
                        if $LatexIndent::Special::special_middle_look_up_hash{ $ARG{begin} }; 
    
                    while( my ($key,$value)= each %LatexIndent::Special::special_look_up_hash){
                        if ($ARG{begin} =~ ${$value}{begin} ){
                            if( defined ${$value}{middle} ){
                                $LatexIndent::Special::special_middle_look_up_hash{ $ARG{begin} } = ${$value}{middle};
                            }
                        }
                    }
                    return $LatexIndent::Special::special_middle_look_up_hash{ $ARG{begin} }
                        if defined $LatexIndent::Special::special_middle_look_up_hash{ $ARG{begin} };
                };
                return q{(\\\\item(?:((\h*\R+)|(\h*))))}; 
            })
          
        # linebreaksAtEndEnd, used across code blocks
        <token: linebreaksAtEndEnd>
            (?<!^)\h*\R?
    
        # Comment
        <objrule: LatexIndent::TrailingComment=TrailingComment>    
            <begin=((?<!\\)\%)>
            <body=([^\n]*\R)>
            
        # BlankLine
        #   matches at least one blank line and
        #   stores into an array
        #
        <objrule: LatexIndent::BlankLine=BlankLine>    
            <[body=blanklinetoken]>+
    
        <token: blanklinetoken>
            ^\h*\R
    
        # anything else
        <objrule: LatexIndent::Literal=Literal>    
            <body=((?:[a-zA-Z0-9&^()']|((?<!^)\h)|((?<!^)\R)|\\\\)+)>
    
    }xms;

    return $latex_indent_parser; 
}

1;
