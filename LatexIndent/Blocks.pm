package LatexIndent::Blocks;

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
use LatexIndent::TrailingComments qw/$trailingCommentRegExp/;
use LatexIndent::GetYamlSettings
    qw/%mainSettings %previouslyFoundSettings $commaPolySwitchExists $equalsPolySwitchExists/;
use LatexIndent::Switches         qw/$is_t_switch_active $is_tt_switch_active $is_m_switch_active/;
use LatexIndent::LogFile          qw/$logger/;
use LatexIndent::Tokens           qw/%tokens/;
use LatexIndent::ModifyLineBreaks qw/_mlb_line_break_token_adjust/;
use Data::Dumper;
use Exporter qw/import/;
our @ISA                     = "LatexIndent::Document";    # class inheritance, Programming Perl, pg 321
our @EXPORT_OK               = qw/$braceBracketRegExpBasic _find_all_code_blocks _construct_code_blocks_regex/;
our $braceBracketRegExpBasic = qr/\{|\[/;

our $allCodeBlocks;

our $allArgumentRegEx;
our $argumentBodyRegEx;
our $argumentsBetween;

our $environmentRegEx;

our $ifElseFiRegEx;

our $specialRegEx            = q();
our $specialBeginRegEx       = q();
our $specialEndRegEx         = q();
our $specialRegExNested      = q();
our $specialBeginRegExNested = q();
our $specialEndRegExNested   = q();
our %specialLookUpName;

our $codeBlockLookFor = q();

our $mSwitchOnlyTrailing            = q();
our $mlbCommaSimpleArgBodyRegEx     = qr();
our $mlbCommaSimpleAllArgumentRegEx = qr{};
our $mlbArgBodyWithCommasRegEx      = q();

sub _construct_code_blocks_regex {

    $allArgumentRegEx = _construct_args_with_between();
    my $commandName         = qr/${${$mainSettings{fineTuning}}{commands}}{name}/;
    my $namedBracesBrackets = qr/${${$mainSettings{fineTuning}}{namedGroupingBracesBrackets}}{name}/;
    my $keyEqVal            = qr/${${$mainSettings{fineTuning}}{keyEqualsValuesBracesBrackets}}{name}
                       (?:\s|$trailingCommentRegExp|$tokens{blanklines})*=/x;
    my $unNamed = qr//;
    $mSwitchOnlyTrailing = (
        $is_m_switch_active
        ? qr{(?<TRAILINGHSPACE>\h*)?(?<TRAILINGCOMMENT>$trailingCommentRegExp)?(?<TRAILINGLINEBREAK>\R\s*)?}
        : q{}
    );

    #
    # environment regex
    #
    my $environmentName = qr/${${$mainSettings{fineTuning}}{environments}}{name}/;
    $environmentRegEx = qr{
        (?<ENVBEGIN>                                  # 
           \\begin\{(?<ENVNAME>$environmentName)\}    # \begin{<ENVNAME>}
        )                                             # 
        (?<ENVARGS>                                   # *possible* arguments
          $allArgumentRegEx*                          # 
          $mSwitchOnlyTrailing 
        )                                             # 
        (?<ENVBODY>                                   # body
          (?>                                         # 
              (??{ $environmentRegEx })               # 
              |                                       # 
              (?!                                     # 
                  (?:\\end\{)                         # 
              ).                                      # 
          )*                                          # 
        )                                             # 
        (?<ENVEND>                                    # \end{<ENVNAME>}
           \\end\{\g{ENVNAME}\}                       # 
        )                                             # 
     }xs;

    #
    # ifElseFi regex
    #
    my $ifElseFiNameRegExp = qr/${${$mainSettings{fineTuning}}{ifElseFi}}{name}/;
    $ifElseFiRegEx = qr{
                (?<IFELSEFIBEGIN>
                    (?<!\\newif)\\(?<IFELSEFINAME>
                      $ifElseFiNameRegExp
                    )         # begin statement, e.g \ifnum, \ifodd
                )                         
                (?<IFELSEFIBODY>                    
                  (?>                               
                      (??{ $ifElseFiRegEx })     
                      |
                      (?!                           
                          (?:\\fi)                  
                      ).                            
                  )*                                
                )
                (?<IFELSEFIEND>                    
                    \\fi(?![a-zA-Z])                    # \fi statement 
                )
     }xs;

    #
    # specials regex, separated into 2 cases:
    #
    #   1. NOT nested
    #   2. YES nested
    #

    #
    # specials NOT nested
    #
    $specialBeginRegEx = q();
    $specialEndRegEx   = q();
    foreach ( @{ $mainSettings{specialBeginEnd} } ) {
        next if !${$_}{lookForThis};
        next if ${$_}{lookForThis} eq 'verbatim';
        next if ${$_}{nested};

        $specialBeginRegEx .= ( $specialBeginRegEx eq "" ? q() : "|" ) . ${$_}{begin};
        $specialEndRegEx   .= ( $specialEndRegEx eq ""   ? q() : "|" ) . ${$_}{end};
    }

    $specialBeginRegEx = qr{$specialBeginRegEx}x;
    $specialEndRegEx   = qr{$specialEndRegEx}x;

    $specialRegEx = qr{
                (?<SPECIALBEGIN>
                    $specialBeginRegEx
                )                         
                (?<SPECIALBODY>                    
                  (?>                               
                      (?!                           
                          (?:$specialEndRegEx)                  
                      ).                            
                  )*                                
                )
                (?<SPECIALEND>                    
                    $specialEndRegEx
                )
                $mSwitchOnlyTrailing 
     }xs;

    #
    # specials YES nested
    #
    $specialBeginRegExNested = q();
    $specialEndRegExNested   = q();
    foreach ( @{ $mainSettings{specialBeginEnd} } ) {
        next if !${$_}{lookForThis};
        next if ${$_}{lookForThis} eq 'verbatim';
        next if !${$_}{nested};

        $specialBeginRegExNested .= ( $specialBeginRegExNested eq "" ? q() : "|" ) . ${$_}{begin};
        $specialEndRegExNested   .= ( $specialEndRegExNested eq ""   ? q() : "|" ) . ${$_}{end};
    }

    #
    # specials YES nested
    #
    if ( $specialBeginRegExNested ne '' ) {

        $specialBeginRegExNested = qr{$specialBeginRegExNested}x;
        $specialEndRegExNested   = qr{$specialEndRegExNested}x;

        $specialRegExNested = qr{
                   (?<SPECIALBEGIN>
                       $specialBeginRegExNested
                   )                         
                   (?<SPECIALBODY>                    
                     (?>                               
                         (??{ $specialRegExNested })     
                         |                          
                         (?!                           
                             (?:$specialEndRegExNested)                  
                         ).                            
                     )*                                
                   )
                   (?<SPECIALEND>                    
                       $specialEndRegExNested
                   )
                   $mSwitchOnlyTrailing 
        }xs;
        $codeBlockLookFor = qr/[{[]|$specialBeginRegEx|$specialBeginRegExNested|\\if/s;
    }
    else {
        $codeBlockLookFor = qr/[{[]|$specialBeginRegEx|\\if/s;
    }

    #
    # (commands, named, key=value, unnamed) <ARGUMENTS> regex
    #
    if ( $specialRegExNested ne '' ) {
        $allCodeBlocks = qr{
            (\s*)                                                 # $1 leading space
            (?:
               (                                                  # $2 <thing><arguments>
                  (?>                                             #    prevent backtracking
                    (                                             # $3 name
                      (\\                                         # $4 command
                        ((?!(?:begin|end))$commandName)           # $5 command name
                      )                                           #
                      |                                           #
                      ($keyEqVal)                                 # $6 key=value name
                      |                                           #
                      ((?<!\\)(?<![a-zA-Z])$namedBracesBrackets)  # $7 named braces name
                      |                                           #
                      (?<![a-zA-Z])$unNamed                       #    unnamed braces or brackets
                    )                                             #
                  )
                  (                                               # $8 arguments
                   (?:                                            #
                    $allArgumentRegEx                             #
                   )+                                             #
                   $mSwitchOnlyTrailing 
                  )
               )
               |
               (?<ENVIRONMENT>
                   $environmentRegEx 
               )
               |
               (?<IFELSEFI>
                   $ifElseFiRegEx 
               )
               |
               (?<SPECIAL>
                   $specialRegEx 
               )
               |
               (?<SPECIALNESTED>
                   $specialRegExNested 
               )
            )
         }x;
    }
    else {
        $allCodeBlocks = qr{
            (\s*)                                                 # $1 leading space
            (?:
               (                                                  # $2 <thing><arguments>
                  (?>                                             #    prevent backtracking
                    (                                             # $3 name
                      (\\                                         # $4 command
                        ((?!(?:begin|end))$commandName)           # $5 command name
                      )                                           #
                      |                                           #
                      ($keyEqVal)                                 # $6 key=value name
                      |                                           #
                      ((?<!\\)(?<![a-zA-Z])$namedBracesBrackets)  # $7 named braces name
                      |                                           #
                      (?<![a-zA-Z])$unNamed                       #    unnamed braces or brackets
                    )                                             #
                  )
                  (                                               # $8 arguments
                   (?:                                            #
                    $allArgumentRegEx                             #
                   )+                                             #
                   $mSwitchOnlyTrailing 
                  )
               )
               |
               (?<ENVIRONMENT>
                   $environmentRegEx 
               )
               |
               (?<IFELSEFI>
                   $ifElseFiRegEx 
               )
               |
               (?<SPECIAL>
                   $specialRegEx 
               )
            )
         }x;
    }

    #
    # m switch only, for the following poly-switches
    #
    #      CommaStartsOnOwnLine
    #      CommaFinishesWithLineBreak
    #
    # goal:
    #      - use a stripped down regex for arguments
    #      - use this stripped regex in matching commas
    #
    if ($is_m_switch_active) {
        $mlbCommaSimpleArgBodyRegEx = qr{
                (?>            # 
                  (?:
                    \\[{}\[\]] # \{, \}, \[, \] OK
                  )
                  |            #  
                  [^{}\[\]]    # anything except {, }, [, ]
                )              # 
        }x;

        $mlbCommaSimpleAllArgumentRegEx = qr{};

        $mlbCommaSimpleAllArgumentRegEx = qr{
             (?:
               (?:
                 (?<MANDARGBEGIN>
                  (?:\s|$trailingCommentRegExp|$tokens{blanklines}|$argumentsBetween)*
                  (?<!\\)
                  \{
                 )
                 (?<MANDARGBODY>
                  (?:
                    (?: $mlbCommaSimpleArgBodyRegEx )             # argument body 
                    |
                    (??{ $mlbCommaSimpleAllArgumentRegEx })
                  )*
                 )
                 (?<MANDARGEND>
                  (?<!\\)
                  \}
                 )
               )
               |
               (?:
                 (?<OPTARGBEGIN>
                  (?:\s|$trailingCommentRegExp|$tokens{blanklines}|$argumentsBetween)*
                  (?<!\\)
                  \[
                 )
                 (?<OPTARGBODY>
                  (?:
                    (?: $mlbCommaSimpleArgBodyRegEx )             # argument body 
                    |
                    (??{ $mlbCommaSimpleAllArgumentRegEx })
                  )*
                 )
                 (?<OPTARGEND>
                  (?<!\\)
                  \]
                 )
               )
             )
             }x;

        # used when either of the following poly-switches are active
        #
        #      CommaStartsOnOwnLine
        #      CommaFinishesWithLineBreak
        #
        $mlbArgBodyWithCommasRegEx = qr{
         (\s*)
         (?:
           (?<comma>
             ,
             $mSwitchOnlyTrailing 
           )
           |
           (?<arguments>
              $mlbCommaSimpleAllArgumentRegEx 
           )
         )
        }xs;

    }
}

sub _construct_args_with_between {

    $argumentsBetween = qr/${${$mainSettings{fineTuning}}{arguments}}{between}/;
    my $mSwitchOnlyTrailing = qr{};
    $mSwitchOnlyTrailing = qr{(\h*)?($trailingCommentRegExp)?(\R)?} if $is_m_switch_active;
    my $environmentName = qr/${${$mainSettings{fineTuning}}{environments}}{name}/;

    $argumentBodyRegEx = qr{
            (?>            # 
              \\(?:begin|end)\{$environmentName\}
              |
              (?:
                \\[{}\[\]] # \{, \}, \[, \] OK
              )
              |            #  
              [^{}\[\]]    # anything except {, }, [, ]
            )              # 
    }x;

    my $allArgumentRegEx = qr{
     (?:
       (?:
         (?<MANDARGBEGIN>
          (?:\s|$trailingCommentRegExp|$tokens{blanklines}|$argumentsBetween)*
          (?<!\\)
          \{
         )
         (?<MANDARGBODY>
          (?:
            (?: $argumentBodyRegEx )             # argument body 
            |
            (??{ $allCodeBlocks })
          )*
         )
         (?<MANDARGEND>
          (?<!\\)
          \}
         )
       )
       |
       (?:
         (?<OPTARGBEGIN>
          (?:\s|$trailingCommentRegExp|$tokens{blanklines}|$argumentsBetween)*
          (?<!\\)
          \[
         )
         (?<OPTARGBODY>
          (?:
            (?: $argumentBodyRegEx )             # argument body 
            |
            (??{ $allCodeBlocks })
          )*
         )
         (?<OPTARGEND>
          (?<!\\)
          \]
         )
       )
     )
     }x;

    return $allArgumentRegEx;
}

sub _find_all_code_blocks {

    my $body = shift;

    # empty body check
    return q() if not defined $body;

    my $currentIndentation = shift;

    $body =~ s/$allCodeBlocks/
       
       my $name;
       my $begin = $1;
       my $body;
       my $end;
       my $modifyLineBreaksName;
       my $codeBlockObj;
       my $addedIndentation;
       
       #
       # environment
       #
       if ($+{ENVIRONMENT}){
             $begin = $1.$+{ENVBEGIN};
             $body = $+{ENVBODY};
             $end = $+{ENVEND};
             $name = $+{ENVNAME};
             $modifyLineBreaksName = "environments";
             my $linebreaksAtEndBegin;

             if (!$previouslyFoundSettings{$name.$modifyLineBreaksName} or $is_m_switch_active){
                $codeBlockObj = LatexIndent::Environment->new(name=>$name,
                                                    begin=>$begin,
                                                    body=>$body, 
                                                    end=>$end,
                                                    modifyLineBreaksYamlName=>$modifyLineBreaksName,
                                                    arguments=> ($+{ENVARGS}?1:0),
                                                    type=>"environment",
                );
             }

             $logger->trace("*found: $name \t type: $modifyLineBreaksName")         if $is_t_switch_active;
             
             # store settings for future use
             if (!$previouslyFoundSettings{$name.$modifyLineBreaksName}){
                $codeBlockObj->yaml_get_indentation_settings_for_this_object;
             }
             
             # argument indentation
             my $argBody = q();
             if ($+{ENVARGS}){
                $argBody = _indent_all_args($name, $modifyLineBreaksName, $+{ENVARGS} ,$currentIndentation);
             }
          
             # ***
             # find nested things
             # ***
             $body = _find_all_code_blocks($body,$currentIndentation) if $body =~ m^$codeBlockLookFor^s;

             $addedIndentation = ${$previouslyFoundSettings{$name.$modifyLineBreaksName}}{indentation};

             #
             # m switch linebreak adjustment
             #
             if ($is_m_switch_active){

                   # argument trailing space goes to the *body* of the environment
                   $argBody =~ s@(\s*)$@@s;
                   $body = $1.$body;

                   # <arguments> appended to begin{<env>}
                   ${$codeBlockObj}{begin} = ${$codeBlockObj}{begin}.$argBody;

                   # get the *updated* environment body from above nested code blocks routine
                   ${$codeBlockObj}{body} = $body;

                   # final argument can request a line break removal
                   if ($argBody =~ m^$tokens{mAfterEndRemove}$^s){
                      ${${$codeBlockObj}{linebreaksAtEnd} }{begin} = 0;
                      ${$codeBlockObj}{body} =~ s@^\s*@@s;
                   }

                   # poly-switch work
                   ${$codeBlockObj}{BodyStartsOnOwnLine} = $previouslyFoundSettings{$name.$modifyLineBreaksName}{BodyStartsOnOwnLine};
                   ${$codeBlockObj}{EndStartsOnOwnLine} = $previouslyFoundSettings{$name.$modifyLineBreaksName}{EndStartsOnOwnLine};

                   $logger->trace("*-m switch poly-switch line break adjustment ($name ($modifyLineBreaksName))") if $is_t_switch_active;

                   $codeBlockObj->_mlb_body_starts_on_own_line if ${$codeBlockObj}{BodyStartsOnOwnLine} != 0;  

                   $codeBlockObj->_mlb_end_starts_on_own_line if ${$codeBlockObj}{EndStartsOnOwnLine} != 0;

                   # get updated begin, body, end
                   $begin = ${$codeBlockObj}{begin};
                   $body = ${$codeBlockObj}{body};
                   $end = ${$codeBlockObj}{end};

                   # delete arg body for future as we don't want to duplicate them later on
                   $argBody = q();

                   $linebreaksAtEndBegin = ${${$codeBlockObj}{linebreaksAtEnd}}{begin};
                   
                   # add indentation to BEGIN statement
                   $begin =~ s"^"$addedIndentation"mg;
                   $begin =~ s"^$addedIndentation(\h*\\begin\{)"$1"m;
             } else {
                   $linebreaksAtEndBegin = ($body =~ m@^\h*\R@ ? 1 : 0);
             }

             # environment BODY indentation, possibly
             if ($addedIndentation ne ''){

                # prepend argument body (when m switch not active)
                $body = $argBody.$body;

                # add indentation
                $body =~ s"^"$addedIndentation"mg if ($body !~ m@^\s*$@s);
                $body =~ s"^$addedIndentation""s if (!$linebreaksAtEndBegin or $argBody);
             }
       } elsif ($+{IFELSEFI}){
             $begin = $1.$+{IFELSEFIBEGIN};
             $body = $+{IFELSEFIBODY};
             $end = $+{IFELSEFIEND};
             $name = $+{IFELSEFINAME};
             $modifyLineBreaksName = "ifElseFi";

             if (!$previouslyFoundSettings{$name.$modifyLineBreaksName} or $is_m_switch_active){
                $codeBlockObj = LatexIndent::IfElseFi->new(name=>$name,
                                                    begin=>$begin,
                                                    modifyLineBreaksYamlName=>$modifyLineBreaksName,
                                                    arguments=> 0,
                                                    type=>"ifelsefi",
                );
             }

             $logger->trace("*found: $name \t type: $modifyLineBreaksName")         if $is_t_switch_active;
             
             # store settings for future use
             if (!$previouslyFoundSettings{$name.$modifyLineBreaksName}){
                $codeBlockObj->yaml_get_indentation_settings_for_this_object;
             }
             
             # ***
             # find nested things
             # ***
             $body = _find_all_code_blocks($body ,$currentIndentation) if $body =~ m^$codeBlockLookFor^s;

             # ifElseFi BODY indentation, possibly
             if (${$previouslyFoundSettings{$name.$modifyLineBreaksName}}{indentation} ne ''){
                $addedIndentation = ${$previouslyFoundSettings{$name.$modifyLineBreaksName}}{indentation};

                # add indentation
                $body =~ s"^"$addedIndentation"mg;
                $body =~ s"^$addedIndentation""s;

                # \else statement gets special treatment; not that checking for \\fi ensures we're at the inner most block
                $body =~ s"$addedIndentation(\\else)"$1"s if $body !~ m|\\fi|s ;
             }
       } elsif ($+{SPECIAL} or $+{SPECIALNESTED}){
             my $lookupBegin = $+{SPECIALBEGIN};
             $begin = $1.$+{SPECIALBEGIN};
             $body = $+{SPECIALBODY};
             $end = $+{SPECIALEND};
             $modifyLineBreaksName = "specialBeginEnd";
             my $linebreaksAtEndBegin;
             
             # storage before finding nested things
             my $horizontalTrailingSpace=($+{TRAILINGHSPACE}?$+{TRAILINGHSPACE}:q());
             my $trailingComment=($+{TRAILINGCOMMENT}?$+{TRAILINGCOMMENT}:q());
             my $linebreaksAtEnd=($+{TRAILINGCOMMENT} ? q() : ( $+{TRAILINGLINEBREAK} ? $+{TRAILINGLINEBREAK} : q()));

             # get the name of special
             if (not defined $specialLookUpName{$lookupBegin}){
                foreach ( @{ $mainSettings{specialBeginEnd} } ) {
                   if($lookupBegin =~m^${$_}{begin}^s){
                     $specialLookUpName{$lookupBegin} = ${$_}{name};
                     last;
                   }
                }
             }
             $name = $specialLookUpName{$lookupBegin};

             if (!$previouslyFoundSettings{$name.$modifyLineBreaksName} or $is_m_switch_active){
                $codeBlockObj = LatexIndent::Special->new(name=>$name,
                                                    begin=>$begin,
                                                    body=>$body,
                                                    end=>$end,
                                                    modifyLineBreaksYamlName=>$modifyLineBreaksName,
                                                    arguments=> 0,
                                                    type=>"special",
                                                    aliases=>{
                                                       BeginStartsOnOwnLine=>"SpecialBeginStartsOnOwnLine",
                                                       BodyStartsOnOwnLine=>"SpecialBodyStartsOnOwnLine",
                                                       EndStartsOnOwnLine=>"SpecialEndStartsOnOwnLine",
                                                       EndFinishesWithLineBreak=>"SpecialEndFinishesWithLineBreak",
                                                    },
                                                    horizontalTrailingSpace=>$horizontalTrailingSpace,
                                                    trailingComment=>$trailingComment,
                                                    linebreaksAtEnd=>{
                                                          end=>$linebreaksAtEnd,
                                                    },
                );
             }

             $logger->trace("*found: $name \t type: $modifyLineBreaksName")         if $is_t_switch_active;
             
             # store settings for future use
             if (!$previouslyFoundSettings{$name.$modifyLineBreaksName}){
                $codeBlockObj->yaml_get_indentation_settings_for_this_object;
             }
             
             # ***
             # find nested things
             # ***
             $body = _find_all_code_blocks($body ,$currentIndentation) if $body =~ m^$codeBlockLookFor^s;

             #
             # m switch linebreak adjustment
             #
             if ($is_m_switch_active){
                   # get the *updated* environment body from above nested code blocks routine
                   ${$codeBlockObj}{body} = $body;

                   # poly-switch work
                   ${$codeBlockObj}{BeginStartsOnOwnLine} = $previouslyFoundSettings{$name.$modifyLineBreaksName}{BeginStartsOnOwnLine};
                   ${$codeBlockObj}{BodyStartsOnOwnLine} = $previouslyFoundSettings{$name.$modifyLineBreaksName}{BodyStartsOnOwnLine};
                   ${$codeBlockObj}{EndStartsOnOwnLine} = $previouslyFoundSettings{$name.$modifyLineBreaksName}{EndStartsOnOwnLine};

                   $logger->trace("*-m switch poly-switch line break adjustment ($name ($modifyLineBreaksName))") if $is_t_switch_active;

                   $codeBlockObj->_mlb_begin_starts_on_own_line if ${$codeBlockObj}{BeginStartsOnOwnLine} != 0;  

                   $codeBlockObj->_mlb_body_starts_on_own_line if ${$codeBlockObj}{BodyStartsOnOwnLine} != 0;  

                   $codeBlockObj->_mlb_end_starts_on_own_line if ${$codeBlockObj}{EndStartsOnOwnLine} != 0;

                   $codeBlockObj->_mlb_end_finishes_with_line_break;

                   # get updated begin, body, end
                   $begin = ${$codeBlockObj}{begin};
                   $body = ${$codeBlockObj}{body};
                   $end = ${$codeBlockObj}{end};

                   $linebreaksAtEndBegin = ${$codeBlockObj}{linebreaksAtEnd}{begin};
             } else {
                   $linebreaksAtEndBegin = ($body =~ m@^\h*\R@ ? 1 : 0);
             }

             # special BODY indentation, possibly
             if (${$previouslyFoundSettings{$name.$modifyLineBreaksName}}{indentation} ne ''){
                $addedIndentation = ${$previouslyFoundSettings{$name.$modifyLineBreaksName}}{indentation};

                # add indentation
                $body =~ s"^"$addedIndentation"mg;
                $body =~ s"^$addedIndentation""s if !$linebreaksAtEndBegin;
             }
       } else {
          # argument body is always in $8
          my $argBody = $8;
          my $BeginStartsOnOwnLineAlias;
          my $BodyStartsOnOwnLineAlias = undef;
          my $keyEqualsValue = q();

          #
          # command
          #
          if ($4) {                                                    # 
             $begin = $1.q(\\);                                        # \\
             $name = $5;                                               # <command name>
             $modifyLineBreaksName="commands";                         # 
             $BeginStartsOnOwnLineAlias = "CommandStartsOnOwnLine";    # --------------------------------
          } elsif ($7) {                                               # <name of named braces brackets>
          #                                                            # 
          # named braces or brackets                                   # 
          #                                                            # 
             $begin = $1;                                              # <possible leading space> 
             $name = $7 ;                                              # <name of named braces brackets>
             $modifyLineBreaksName="namedGroupingBracesBrackets";      # 
             $BeginStartsOnOwnLineAlias = "NameStartsOnOwnLine";       # 
             $BodyStartsOnOwnLineAlias = "NameFinishesWithLineBreak";  #
          } elsif($6)  {                                               # -------------------------------- 
          #                                                            # 
          # key = braces or brackets                                   # 
          #                                                            # 
             $name = $6;                                               # <name of key = value braces brackets>
             $name =~ s^((?:\s|$trailingCommentRegExp|$tokens{blanklines})*=)^^s;                                    # 
             $keyEqualsValue = $1;
             $begin = $begin.$name;
             $modifyLineBreaksName="keyEqualsValuesBracesBrackets";    # 
             $BeginStartsOnOwnLineAlias = "KeyStartsOnOwnLine";        # 
          } else {                                                     # -------------------------------- 
          #                                                            # 
          # unnamed braces and brackets                                # 
          #                                                            # 
             $begin = $1;                                              # <possible leading space> 
             $name = q();                                              # 
             $modifyLineBreaksName="UnNamedGroupingBracesBrackets";    # 
             $BeginStartsOnOwnLineAlias = undef;                       # 
          }

          if (!$previouslyFoundSettings{$name.$modifyLineBreaksName} or $is_m_switch_active){
             $codeBlockObj = LatexIndent::Blocks->new(name=>$name,
                                                 begin=>$begin,
                                                 modifyLineBreaksYamlName=>$modifyLineBreaksName,
                                                 arguments=>1,
                                                 type=>"something-with-braces",
                                                 aliases=>{
                                                   # begin statements
                                                   BeginStartsOnOwnLine=>$BeginStartsOnOwnLineAlias,
                                                   BodyStartsOnOwnLine=>$BodyStartsOnOwnLineAlias,
                                                 },
             );
          }

          $logger->trace("*found: $name \t type: $modifyLineBreaksName")         if $is_t_switch_active;

          # store settings for future use
          if (!$previouslyFoundSettings{$name.$modifyLineBreaksName}){
             ${$codeBlockObj}{BeginStartsOnOwnLine} = 0;
             ${$codeBlockObj}{BodyStartsOnOwnLine} = 0;
             $codeBlockObj->yaml_get_indentation_settings_for_this_object;
          }

          # m-switch: command name starts on own line
          if ($is_m_switch_active){

               if ( ${$previouslyFoundSettings{$name.$modifyLineBreaksName}}{BeginStartsOnOwnLine} !=0){
                  ${$codeBlockObj}{BeginStartsOnOwnLine}=${$previouslyFoundSettings{$name.$modifyLineBreaksName}}{BeginStartsOnOwnLine};
                  $codeBlockObj->_mlb_begin_starts_on_own_line;  
                  $begin = ${$codeBlockObj}{begin};
                  $begin =~ s@$tokens{mAfterEndLineBreak}$tokens{mBeforeBeginLineBreakREMOVE}@@sg;
               }

               if (${$previouslyFoundSettings{$name.$modifyLineBreaksName}}{BodyStartsOnOwnLine} !=0){
                   $argBody =~ s"^\s*""s if ${$previouslyFoundSettings{$name.$modifyLineBreaksName}}{BodyStartsOnOwnLine} == -1;
               }
            
               # key = value poly-switches: EqualsStartsOnOwnLine or EqualsFinishesWithLineBreak
               if ( $modifyLineBreaksName eq "keyEqualsValuesBracesBrackets" and $equalsPolySwitchExists){
                   my $EqualsStartsOnOwnLine= 
                     (defined ${$previouslyFoundSettings{$name.$modifyLineBreaksName}}{EqualsStartsOnOwnLine}?
                              ${$previouslyFoundSettings{$name.$modifyLineBreaksName}}{EqualsStartsOnOwnLine} : 0);
                   my $EqualsFinishesWithLineBreak= 
                     (defined ${$previouslyFoundSettings{$name.$modifyLineBreaksName}}{EqualsFinishesWithLineBreak}?
                              ${$previouslyFoundSettings{$name.$modifyLineBreaksName}}{EqualsFinishesWithLineBreak} : 0);

                   $keyEqualsValue =~s^=^^s;
                   $argBody =~ s@^$mSwitchOnlyTrailing@@s;
                   my $horizontalTrailingSpace=($+{TRAILINGHSPACE}?$+{TRAILINGHSPACE}:q());
                   my $trailingComment=($+{TRAILINGCOMMENT}?$+{TRAILINGCOMMENT}:q());
                   my $linebreaksAtEnd=($+{TRAILINGCOMMENT} ? q() : ( $+{TRAILINGLINEBREAK} ? $+{TRAILINGLINEBREAK} : q()));

                   my $codeBlockObj = LatexIndent::Special->new(name=>"equals",
                                                     body=>$keyEqualsValue,
                                                     end=>"=",
                                                     modifyLineBreaksYamlName=>"equals",
                                                     type=>"equals",
                                                     EndStartsOnOwnLine=>$EqualsStartsOnOwnLine,
                                                     EndFinishesWithLineBreak=>$EqualsFinishesWithLineBreak,
                                                     horizontalTrailingSpace=>$horizontalTrailingSpace,
                                                     trailingComment=>$trailingComment,
                                                     linebreaksAtEnd=>{
                                                       end=>$linebreaksAtEnd,
                                                     },
                   );

                   $logger->trace("*found: equals in key=value")         if $is_t_switch_active;
                   $codeBlockObj->_mlb_end_starts_on_own_line if ${$codeBlockObj}{EndStartsOnOwnLine} != 0;  
                   $codeBlockObj->_mlb_end_finishes_with_line_break if ${$codeBlockObj}{EndFinishesWithLineBreak} != 0;  

                   ${$codeBlockObj}{body} =  ${$codeBlockObj}{body}.${$codeBlockObj}{end};
                   $codeBlockObj->_mlb_after_indentation_token_adjust; 
                   $keyEqualsValue = ${$codeBlockObj}{body};
               }

               if ( $modifyLineBreaksName eq "keyEqualsValuesBracesBrackets"){
                   $keyEqualsValue =~ s^=(.*)$^=^s;
                   $argBody = $1.$argBody;
               }
          }

          # argument indentation
          $argBody = _indent_all_args($name, $modifyLineBreaksName, $argBody,$currentIndentation);
          
          $argBody = $keyEqualsValue.$argBody if $modifyLineBreaksName eq "keyEqualsValuesBracesBrackets";

          # command BODY indentation, possibly
          if (${$previouslyFoundSettings{$name.$modifyLineBreaksName}}{indentation} ne ''){
             $addedIndentation = ${$previouslyFoundSettings{$name.$modifyLineBreaksName}}{indentation};

             # add indentation
             $argBody =~ s"^"$addedIndentation"mg;
             $argBody =~ s"^$addedIndentation""s;
          }

          # put it all together
          $body = $name;
          
          # key = value is particular
          $body = q() if $modifyLineBreaksName eq "keyEqualsValuesBracesBrackets";
          
          $end = $argBody;
       }

       # ---------------------
       # output indented block
       # ---------------------
       $begin.$body.$end;/sgex;

    # m switch conflicting linebreak addition or removal handled by tokens
    $body = _mlb_line_break_token_adjust($body) if $is_m_switch_active;

    return $body;
}

sub _indent_all_args {

    my ( $name, $modifyLineBreaksName, $body, $indentation ) = @_;

    my $commandStorageName = $name . $modifyLineBreaksName;

    my $mandatoryArgumentsIndentation
        = ${ $previouslyFoundSettings{$commandStorageName} }{mandatoryArgumentsIndentation};
    my $optionalArgumentsIndentation = ${ $previouslyFoundSettings{$commandStorageName} }{optionalArgumentsIndentation};

    $body =~ s|\G$allArgumentRegEx$mSwitchOnlyTrailing|
       # mandatory or optional argument?
       my $mandatoryArgument = ($+{MANDARGBEGIN}?1:0);

       # begin
       my $begin = ($mandatoryArgument ? $+{MANDARGBEGIN}:$+{OPTARGBEGIN});

       # body 
       my $argBody = (defined $+{MANDARGBODY}?$+{MANDARGBODY}:$+{OPTARGBODY});
       
       # end
       my $end = ($+{MANDARGEND}?$+{MANDARGEND}:$+{OPTARGEND});

       # indentation
       my $currentIndentation = ($mandatoryArgument ? $mandatoryArgumentsIndentation : $optionalArgumentsIndentation).$indentation;

       # does arg body start on own line?
       my $argBodyStartsOwnLine;

       # storage before finding nested things
       my $horizontalTrailingSpace=($+{TRAILINGHSPACE}?$+{TRAILINGHSPACE}:q());
       my $trailingComment=($+{TRAILINGCOMMENT}?$+{TRAILINGCOMMENT}:q());
       my $linebreaksAtEnd=( $+{TRAILINGLINEBREAK} ? $+{TRAILINGLINEBREAK} : q());

       # ***
       # find nested things
       # ***
       $argBody = _find_all_code_blocks($argBody,$indentation) if $argBody=~ m^$codeBlockLookFor^s;

       #
       # m switch linebreak adjustment
       #
       if ($is_m_switch_active){

          my $argType = ($mandatoryArgument ? "mand" : "opt");

          # possible comma poly-switch
          if ($commaPolySwitchExists){

             my $CommaStartsOnOwnLine = 
               (defined ${${$previouslyFoundSettings{$commandStorageName}}{$argType}}{CommaStartsOnOwnLine}?
               ${${$previouslyFoundSettings{$commandStorageName}}{$argType}}{CommaStartsOnOwnLine}: 0);

            my $CommaFinishesWithLineBreak = 
              (defined ${${$previouslyFoundSettings{$commandStorageName}}{$argType}}{CommaFinishesWithLineBreak}?
              ${${$previouslyFoundSettings{$commandStorageName}}{$argType}}{CommaFinishesWithLineBreak}: 0);

              $argBody = _mlb_commas_in_arg_body($argBody,$CommaStartsOnOwnLine,$CommaFinishesWithLineBreak);
              $argBody =~ s@\R\h*$tokens{mBeforeBeginLineBreakADD}@\n@sg;
              $argBody =~ s@$tokens{mBeforeBeginLineBreakADD}@\n@sg;
              $argBody =~ s@$tokens{mAfterEndLineBreak}@\n@sg;
          }

          # begin statements
          my $BeginStartsOnOwnLine=${${$previouslyFoundSettings{$commandStorageName}}{mand}}{LCuBStartsOnOwnLine};

          # body statements
          my $BodyStartsOnOwnLine=${${$previouslyFoundSettings{$commandStorageName}}{mand}}{MandArgBodyStartsOnOwnLine};

          # end statements
          my $EndStartsOnOwnLine=${${$previouslyFoundSettings{$commandStorageName}}{mand}}{RCuBStartsOnOwnLine};

          # after end statements
          my $EndFinishesWithLineBreak=${${$previouslyFoundSettings{$commandStorageName}}{mand}}{RCuBFinishesWithLineBreak};

          if (!$mandatoryArgument){
             # begin statements
             $BeginStartsOnOwnLine=${${$previouslyFoundSettings{$commandStorageName}}{opt}}{LSqBStartsOnOwnLine};

             # body statements
             $BodyStartsOnOwnLine=${${$previouslyFoundSettings{$commandStorageName}}{opt}}{OptArgBodyStartsOnOwnLine};

             # end statements
             $EndStartsOnOwnLine=${${$previouslyFoundSettings{$commandStorageName}}{opt}}{RSqBStartsOnOwnLine};

             # after end statements
             $EndFinishesWithLineBreak=${${$previouslyFoundSettings{$commandStorageName}}{opt}}{RSqBFinishesWithLineBreak};

             $argType = "optional";
          }

          my $argument = LatexIndent::MandatoryArgument->new(
                                                begin=>$begin,                                       # begin statement
                                                body=>$argBody,                                      # body  statement
                                                end=>$end,                                           # end   statement
                                                modifyLineBreaksName=>$modifyLineBreaksName,
                                                type=>"argument",
                                                BeginStartsOnOwnLine=>$BeginStartsOnOwnLine,         # begin     poly-switch
                                                BodyStartsOnOwnLine=>$BodyStartsOnOwnLine,           # body      poly-switch
                                                EndStartsOnOwnLine=>$EndStartsOnOwnLine,             # end       poly-switch
                                                EndFinishesWithLineBreak=>$EndFinishesWithLineBreak, # after end poly-switch
                                                horizontalTrailingSpace=>$horizontalTrailingSpace,
                                                trailingComment=>$trailingComment,
                                                linebreaksAtEnd=>{
                                                  end=>$linebreaksAtEnd,
                                                },
                            );

            $logger->trace("*-m switch poly-switch line break adjustment ($commandStorageName, arg-type $argType)") if $is_t_switch_active;

            $argument->_mlb_begin_starts_on_own_line if ${$argument}{BeginStartsOnOwnLine} != 0;  

            $argument->_mlb_body_starts_on_own_line if ${$argument}{BodyStartsOnOwnLine} != 0;  

            $argument->_mlb_end_starts_on_own_line if ${$argument}{EndStartsOnOwnLine} != 0;

            $argument->_mlb_end_finishes_with_line_break;

            # get updated begin, body, end
            $begin = ${$argument}{begin};
            $argBody = ${$argument}{body};
            $end = ${$argument}{end};

            $argBodyStartsOwnLine = ${$argument}{linebreaksAtEnd}{begin};
       } else {
         $argBodyStartsOwnLine = ($argBody =~ m@^\h*\R@ ? 1 : 0);
       }

       my $bodyHasLineBreaks = ($argBody=~m@[\n]@s ? 1 : 0);

       # add indentation
       $argBody =~ s@^@$currentIndentation@mg if ( ($argBodyStartsOwnLine or $bodyHasLineBreaks) and $argBody ne '');

       # if arg body does NOT start on its own line, remove the first indentation added by previous step
       $argBody =~ s@^$currentIndentation@@s if (!$argBodyStartsOwnLine and $bodyHasLineBreaks);

       # put it all together
       $begin.$argBody.$end;|sgex;

    # m switch conflicting linebreak addition or removal handled by tokens
    $body = _mlb_line_break_token_adjust($body) if $is_m_switch_active;
    return $body;
}

sub _mlb_commas_in_arg_body {
    my ( $body, $CommaStartsOnOwnLine, $CommaFinishesWithLineBreak ) = @_;

    $body =~ s/$mlbArgBodyWithCommasRegEx/
                my $begin = $1;
                my $commaOrArgs = q();
                if ($+{comma}){
                  
                  my $horizontalTrailingSpace=($+{TRAILINGHSPACE}?$+{TRAILINGHSPACE}:q());
                  my $trailingComment=($+{TRAILINGCOMMENT}?$+{TRAILINGCOMMENT}:q());
                  my $linebreaksAtEnd=($+{TRAILINGCOMMENT} ? q() : ( $+{TRAILINGLINEBREAK} ? $+{TRAILINGLINEBREAK} : q()));

                  my $codeBlockObj = LatexIndent::Special->new(name=>"comma",
                                                    begin=>$begin.",",
                                                    body=>$horizontalTrailingSpace.$trailingComment.$linebreaksAtEnd,
                                                    end=>q(),
                                                    modifyLineBreaksYamlName=>"comma",
                                                    type=>"comma",
                                                    BeginStartsOnOwnLine=>$CommaStartsOnOwnLine,
                                                    BodyStartsOnOwnLine=>$CommaFinishesWithLineBreak,
                  );

                  $logger->trace("*found: comma within argument")         if $is_t_switch_active;
                  $codeBlockObj->_mlb_begin_starts_on_own_line if ${$codeBlockObj}{BeginStartsOnOwnLine} != 0;  
                  $codeBlockObj->_mlb_body_starts_on_own_line if ${$codeBlockObj}{BodyStartsOnOwnLine} != 0;  

                  $commaOrArgs = ${$codeBlockObj}{begin}.${$codeBlockObj}{body}.${$codeBlockObj}{end}; 
                  } else {
                    $commaOrArgs = $+{arguments};
                  };
                $commaOrArgs;/sgex;
    return $body;
}
1;
