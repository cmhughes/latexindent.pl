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
our $specialAllRegEx = q();

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

    # for environment arguments
    my $mSwitchOnlyTrailingNoCapture = (
        $is_m_switch_active
        ? qr{(?:\h*)?(?:$trailingCommentRegExp)?(?:\R\s*)?}
        : q{}
    );

    # default environment regex
    $environmentRegEx = qr{
        (?<ENVBEGIN>                                  # 
           \\begin\{(?<ENVNAME>$environmentName)\}    # \begin{<ENVNAME>}
        )                                             # 
        (?<ENVARGS>                                   # *possible* arguments
          $allArgumentRegEx*                          # 
          $mSwitchOnlyTrailingNoCapture
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
        $mSwitchOnlyTrailing 
     }xs;

    # non-default environment regex
    if (    defined ${ ${ $mainSettings{fineTuning} }{environments} }{begin}
        and defined ${ ${ $mainSettings{fineTuning} }{environments} }{end} )
    {
        $logger->info("*environment regex changed from default using fineTuning");
        $environmentRegEx = qr{
        (?<ENVBEGIN>                                  # 
           ${${$mainSettings{fineTuning}}{environments}}{begin}
        )                                             # 
        (?<ENVARGS>                                   # *possible* arguments
          $allArgumentRegEx*                          # 
          $mSwitchOnlyTrailingNoCapture
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
           ${${$mainSettings{fineTuning}}{environments}}{end} 
        )                                             # 
        $mSwitchOnlyTrailing 
     }xs;
    }

    #
    # ifElseFi regex
    #
    my $ifElseFiNameRegExp = qr/${${$mainSettings{fineTuning}}{ifElseFi}}{name}/;
    $ifElseFiRegEx = qr{
                (?<IFELSEFIBEGIN>                  # \ifnum, \ifodd
                    (?<!\\newif)\\(?<IFELSEFINAME>
                      $ifElseFiNameRegExp
                    )         
                )                         
                (?<IFELSEFIBODY>                    
                  (?>                               
                      (??{ $ifElseFiRegEx })     
                      |
                      (?!                           
                          (?:\\fi(?![a-zA-Z]))                  
                      ).                            
                  )*                                
                )
                (?<IFELSEFIEND>                    # \fi statement 
                    \\fi(?![a-zA-Z])                 
                )
                $mSwitchOnlyTrailing 
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

    #
    # specials NOT nested, account for possibility of special being empty
    #
    if ( $specialBeginRegEx ne '' ) {
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
    }

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
    # specialBeginEnd regex
    #
    if ( $specialRegEx ne '' and $specialRegExNested ne '' ) {

        # YES nested
        # YES not nested
        $specialAllRegEx = qr{
               (?<SPECIAL>
                   $specialRegEx 
               )
               |
               (?<SPECIALNESTED>
                   $specialRegExNested 
               )
               }x;
    }
    elsif ( $specialRegEx ne '' ) {

        # NO nested
        # YES not nested
        $specialAllRegEx = qr{
               (?<SPECIAL>
                   $specialRegEx 
               )
               }x;
    }
    elsif ( $specialRegExNested ne '' ) {

        # YES nested
        # no not nested
        $specialAllRegEx = qr{
               (?<SPECIALNESTED>
                   $specialRegExNested 
               )
               }x;
    }

    #
    # (commands, named, key=value, unnamed) <ARGUMENTS> regex
    #
    if ( $specialAllRegEx ne '' ) {
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
               $specialAllRegEx 
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

             # storage before finding nested things
             my $horizontalTrailingSpace=($+{TRAILINGHSPACE}?$+{TRAILINGHSPACE}:q());
             my $trailingComment=($+{TRAILINGCOMMENT}?$+{TRAILINGCOMMENT}:q());
             my $linebreaksAtEnd=( $+{TRAILINGLINEBREAK} ? $+{TRAILINGLINEBREAK} : q());

             if (!$previouslyFoundSettings{$name.$modifyLineBreaksName} or $is_m_switch_active){
                $codeBlockObj = LatexIndent::Environment->new(name=>$name,
                                                    begin=>$begin,
                                                    body=>$body, 
                                                    end=>$end,
                                                    modifyLineBreaksYamlName=>$modifyLineBreaksName,
                                                    arguments=> ($+{ENVARGS}?1:0),
                                                    type=>"environment",
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
             
             # argument indentation
             my $argBody = q();
             if ($+{ENVARGS}){
                $argBody = $+{ENVARGS};
                if ($argBody =~ m@^\s*$trailingCommentRegExp\s*$@s){
                  $body = $argBody.$body;
                  $argBody = q();
                  $logger->trace("arguments for $name environment is ONLY a comment, pre-pending it to body")         if $is_t_switch_active;
                } else {
                  $argBody = _indent_all_args($name, $modifyLineBreaksName, $argBody, $currentIndentation);
                }
             } else {
                $logger->trace("no arguments for $name environment")         if $is_t_switch_active;
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
                   $logger->trace("*-m switch poly-switch line break adjustment ($name ($modifyLineBreaksName))") if $is_t_switch_active;

                   ${$codeBlockObj}{BeginStartsOnOwnLine} = $previouslyFoundSettings{$name.$modifyLineBreaksName}{BeginStartsOnOwnLine};
                   ${$codeBlockObj}{BodyStartsOnOwnLine} = $previouslyFoundSettings{$name.$modifyLineBreaksName}{BodyStartsOnOwnLine};
                   ${$codeBlockObj}{EndStartsOnOwnLine} = $previouslyFoundSettings{$name.$modifyLineBreaksName}{EndStartsOnOwnLine};
                   ${$codeBlockObj}{EndFinishesWithLineBreak} = $previouslyFoundSettings{$name.$modifyLineBreaksName}{EndFinishesWithLineBreak};

                   $codeBlockObj->_mlb_begin_starts_on_own_line if ${$codeBlockObj}{BeginStartsOnOwnLine} != 0;  
                   $codeBlockObj->_mlb_body_starts_on_own_line if ${$codeBlockObj}{BodyStartsOnOwnLine} != 0;  
                   $codeBlockObj->_mlb_end_starts_on_own_line if ${$codeBlockObj}{EndStartsOnOwnLine} != 0;
                   $codeBlockObj->_mlb_end_finishes_with_line_break;

                   # get updated begin, body, end
                   $begin = ${$codeBlockObj}{begin};
                   $body = ${$codeBlockObj}{body};
                   $end = ${$codeBlockObj}{end};

                   # add indentation to BEGIN statement
                   if ($argBody and $addedIndentation ne ''){
                      $argBody = $begin;

                      # remove \begin{<name>} from arguments
                      $argBody =~ s@(.*?\\begin\{[^}]+\})@@s;

                      # store \begin{<name>} 
                      $begin = $1;

                      # operate on argument body
                      $argBody =~ s"^"$addedIndentation"mg;
                      $argBody =~ s"^$addedIndentation""s;

                      # put begin back together
                      $begin = $begin.$argBody;
                   }

                   # delete arg body for future as we don't want to duplicate them later on
                   $argBody = q();

                   $linebreaksAtEndBegin = ${${$codeBlockObj}{linebreaksAtEnd}}{begin};
                   
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
             my $linebreaksAtEndBegin;
             
             # storage before finding nested things
             my $horizontalTrailingSpace=($+{TRAILINGHSPACE}?$+{TRAILINGHSPACE}:q());
             my $trailingComment=($+{TRAILINGCOMMENT}?$+{TRAILINGCOMMENT}:q());
             my $linebreaksAtEnd=( $+{TRAILINGLINEBREAK} ? $+{TRAILINGLINEBREAK} : q());
             my $elseExists;

             if (!$previouslyFoundSettings{$name.$modifyLineBreaksName} or $is_m_switch_active){
                $codeBlockObj = LatexIndent::IfElseFi->new(name=>$name,
                                                    begin=>$begin,
                                                    body=>$body,
                                                    end=>$end,
                                                    modifyLineBreaksYamlName=>$modifyLineBreaksName,
                                                    arguments=> 0,
                                                    type=>"ifelsefi",
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

             # look for else, or
             ($body, $elseExists) = _find_ifelsefi_else_or($body, $name, $modifyLineBreaksName);

             #
             # m switch linebreak adjustment
             #
             if ($is_m_switch_active){
                   # middle can add line break tokens to the specialBeginEnd body
                   $body =~ s@\R\h*$tokens{mBeforeBeginLineBreakADD}($tokens{blanklines})?@\n@sg;
                   $body =~ s@$tokens{mBeforeBeginLineBreakADD}@\n@sg;
                   $body =~ s@([a-zA-Z0-9])$tokens{mElseTrailingSpace}([^\\])@$1 $2@sg;
                   $body =~ s@$tokens{mElseTrailingSpace}@@sg;


                   # get the *updated* environment body from above nested code blocks routine
                   ${$codeBlockObj}{body} = $body;

                   # poly-switch work
                   $logger->trace("*-m switch poly-switch line break adjustment ($name ($modifyLineBreaksName))") if $is_t_switch_active;
                   ${$codeBlockObj}{BeginStartsOnOwnLine} = $previouslyFoundSettings{$name.$modifyLineBreaksName}{BeginStartsOnOwnLine};
                   ${$codeBlockObj}{BodyStartsOnOwnLine} = $previouslyFoundSettings{$name.$modifyLineBreaksName}{BodyStartsOnOwnLine};
                   ${$codeBlockObj}{EndStartsOnOwnLine} = $previouslyFoundSettings{$name.$modifyLineBreaksName}{EndStartsOnOwnLine};
                   ${$codeBlockObj}{EndFinishesWithLineBreak} = $previouslyFoundSettings{$name.$modifyLineBreaksName}{EndFinishesWithLineBreak};

                   $codeBlockObj->_mlb_begin_starts_on_own_line if ${$codeBlockObj}{BeginStartsOnOwnLine} != 0;  
                   $codeBlockObj->_mlb_body_starts_on_own_line if ${$codeBlockObj}{BodyStartsOnOwnLine} != 0;  
                   $codeBlockObj->_mlb_end_starts_on_own_line if ${$codeBlockObj}{EndStartsOnOwnLine} != 0;
                    
                   if (${$codeBlockObj}{BodyStartsOnOwnLine} == -1 
                           and ${$codeBlockObj}{body} !~m@^\h@s 
                           and ${$codeBlockObj}{body} =~m@^[^\\]@s 
                           and ${$codeBlockObj}{body} !~m@^($tokens{specialBeginEndMiddle})?$tokens{mBeforeBeginLineBreakREMOVE}\\@s ){
                      ${$codeBlockObj}{begin} .= ' ';
                      $logger->trace("adding single space ' ' *after* begin for $name (BodyStartsOnOwnLine == -1)")         if $is_t_switch_active;
                   }

                   # \fi needs particular attention when FiFinishesWithLineBreak is -1, see
                   #    ifelsefi-first-mod-E -s -m -l=ifelsefi-all-on,ifelsefi-mod-lines12 -o=+-mod12
                   if (${$codeBlockObj}{EndFinishesWithLineBreak} == -1 and $horizontalTrailingSpace eq ''){
                        ${$codeBlockObj}{horizontalTrailingSpace} = ' ';
                        $logger->trace("adding single space ' ' *after* end for $name (EndFinishesWithLineBreak == -1)")         if $is_t_switch_active;
                   }
                   $codeBlockObj->_mlb_end_finishes_with_line_break;

                   # \fi needs particular attention when FiFinishesWithLineBreak is 2, see
                   #   ifelsefi-one-line-mk1 -m -l=ifelsefi-add-comments-all -o=+-all-comments
                   # in particular, this can result in 
                   #    \fimSwitchComment
                   # which then *breaks* the ifElseFi regex
                   #
                   # solution: *add* a space so that we get
                   #    \fi mSwitchComment
                   # and then *remove* it in the adjust routine
                   if (${$codeBlockObj}{EndFinishesWithLineBreak} == 2 and ${$codeBlockObj}{end} =~ m@^\\fi$tokens{mSwitchComment}@s ){
                       $logger->trace("adding single space ' ' temporarily *after* end for $name (EndFinishesWithLineBreak == 2)")         if $is_t_switch_active;
                       ${$codeBlockObj}{end} =~ s@^(\\fi)$tokens{mSwitchComment}@$1 $tokens{mSwitchCommentFi}@s;
                   }

                   # get updated begin, body, end
                   $begin = ${$codeBlockObj}{begin};
                   $body = ${$codeBlockObj}{body};
                   $end = ${$codeBlockObj}{end};

                   $linebreaksAtEndBegin = ${$codeBlockObj}{linebreaksAtEnd}{begin};
             } else {
                   $linebreaksAtEndBegin = ($body =~ m@^\h*\R@ ? 1 : 0);
             }

             # ifElseFi BODY indentation, possibly
             if (${$previouslyFoundSettings{$name.$modifyLineBreaksName}}{indentation} ne '' or $elseExists){
                $addedIndentation = ${$previouslyFoundSettings{$name.$modifyLineBreaksName}}{indentation};

                # add indentation
                $body =~ s"^(\h*)$tokens{mSwitchComment}\s*($tokens{specialBeginEndMiddle})"$1$2"mg if $is_m_switch_active;
                $body =~ s"^"$addedIndentation"mg;
                $body =~ s"^$addedIndentation""s if !$linebreaksAtEndBegin;

                # \else statement gets special treatment
                if ($elseExists){
                   $body =~ s"$addedIndentation$tokens{specialBeginEndMiddle}""mg;
                   $body =~ s"$tokens{specialBeginEndMiddle}""sg;
                }

                # \if needs particular attention when BodyStartsOnOwnLine is -1, see
                #    ifelsefi-nested-blank-lines -s -m -l=ifelsefi-all-on,ifelsefi-mod-lines18,removeTWS-before
                if ($is_m_switch_active 
                        and ${$codeBlockObj}{BodyStartsOnOwnLine} == -1 
                        and ${$codeBlockObj}{begin} =~m@[a-zA-Z0-9]$@s 
                        and ${$codeBlockObj}{body} =~m@^[a-zA-Z0-9]@s){
                    ${$codeBlockObj}{body} = ' '.${$codeBlockObj}{body};
                }

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
             my $linebreaksAtEnd=( $+{TRAILINGLINEBREAK} ? $+{TRAILINGLINEBREAK} : q());

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

             # look for middle, if it is defined
             $body = _find_special_middle($body, $name, $modifyLineBreaksName) if defined ${$mainSettings{specialLookUpMiddle}}{$name};

             #
             # m switch linebreak adjustment
             #
             if ($is_m_switch_active){
                   # middle can add line break tokens to the specialBeginEnd body
                   $body =~ s@\R\h*$tokens{mBeforeBeginLineBreakADD}($tokens{blanklines})?@\n@sg;
                   $body =~ s@$tokens{mBeforeBeginLineBreakADD}@\n@sg;

                   # get the *updated* environment body from above nested code blocks routine
                   ${$codeBlockObj}{body} = $body;

                   # poly-switch work
                   $logger->trace("*-m switch poly-switch line break adjustment ($name ($modifyLineBreaksName))") if $is_t_switch_active;
                   ${$codeBlockObj}{BeginStartsOnOwnLine} = $previouslyFoundSettings{$name.$modifyLineBreaksName}{BeginStartsOnOwnLine};
                   ${$codeBlockObj}{BodyStartsOnOwnLine} = $previouslyFoundSettings{$name.$modifyLineBreaksName}{BodyStartsOnOwnLine};
                   ${$codeBlockObj}{EndStartsOnOwnLine} = $previouslyFoundSettings{$name.$modifyLineBreaksName}{EndStartsOnOwnLine};
                   ${$codeBlockObj}{EndFinishesWithLineBreak} = $previouslyFoundSettings{$name.$modifyLineBreaksName}{EndFinishesWithLineBreak};

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
                $body =~ s"^(\h)*$tokens{mSwitchComment}\s*($tokens{specialBeginEndMiddle})"$1$2"mg if defined ${$mainSettings{specialLookUpMiddle}}{$name};
                $body =~ s"^"$addedIndentation"mg;
                $body =~ s"^$addedIndentation""s if !$linebreaksAtEndBegin;
                
                if (defined ${$mainSettings{specialLookUpMiddle}}{$name}){
                   $body =~ s"$addedIndentation$tokens{specialBeginEndMiddle}""mg;
                   $body =~ s"$tokens{specialBeginEndMiddle}""g;
                }
             }
       } else {
          # argument body is always in $8
          my $argBody = $8;
          my $keyEqualsValue = q();

          #
          # command
          #
          if ($4) {                                                    # 
             $begin = $1.q(\\);                                        # \\
             $name = $5;                                               # <command name>
             $modifyLineBreaksName="commands";                         # 
          } elsif ($7) {                                               # <name of named braces brackets>
          #                                                            # 
          # named braces or brackets                                   # 
          #                                                            # 
             $begin = $1;                                              # <possible leading space> 
             $name = $7 ;                                              # <name of named braces brackets>
             $modifyLineBreaksName="namedGroupingBracesBrackets";      # 
          } elsif($6)  {                                               # -------------------------------- 
          #                                                            # 
          # key = braces or brackets                                   # 
          #                                                            # 
             $name = $6;                                               # <name of key = value braces brackets>
             $name =~ s^((?:\s|$trailingCommentRegExp|$tokens{blanklines})*=)^^s;                                    # 
             $keyEqualsValue = $1;
             $begin = $begin.$name;
             $modifyLineBreaksName="keyEqualsValuesBracesBrackets";    # 
          } else {                                                     # -------------------------------- 
          #                                                            # 
          # unnamed braces and brackets                                # 
          #                                                            # 
             $begin = $1;                                              # <possible leading space> 
             $name = q();                                              # 
             $modifyLineBreaksName="UnNamedGroupingBracesBrackets";    # 
          }

          if (!$previouslyFoundSettings{$name.$modifyLineBreaksName} or $is_m_switch_active){
             $codeBlockObj = LatexIndent::Blocks->new(name=>$name,
                                                 begin=>$begin,
                                                 modifyLineBreaksYamlName=>$modifyLineBreaksName,
                                                 arguments=>1,
                                                 type=>"something-with-braces",
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

#
# specialBeginEnd that have middle
#
sub _find_special_middle {
    my ( $body, $name, $modifyLineBreaksName ) = @_;
    $logger->trace("looking for special MIDDLE for $name")         if $is_t_switch_active;
    $logger->trace("${$mainSettings{specialLookUpMiddle}}{$name}") if $is_t_switch_active;

    my $specialMiddleRegEx = qr{
         (\s*)
         (?:
           (?<SPECIALMIDDLE>
             (?<SPECIALMIDDLESTATEMENT>
               ${$mainSettings{specialLookUpMiddle}}{$name}
             )
             $mSwitchOnlyTrailing 
           )
           |
           (?<SPECIALALL>
             $specialAllRegEx            
           )
         )
        }xs;

    # m-switch notes
    #   don't usually mix poly-switch work like this, but
    #   the middle statements need finding regardless of
    #   whether the m-switch is active
    #
    my $commandStorageName           = $name . $modifyLineBreaksName;
    my $SpecialMiddleStartsOnOwnLine = (
        defined ${ $previouslyFoundSettings{$commandStorageName} }{SpecialMiddleStartsOnOwnLine}
        ? ${ $previouslyFoundSettings{$commandStorageName} }{SpecialMiddleStartsOnOwnLine}
        : 0
    );

    my $SpecialMiddleFinishesWithLineBreak = (
        defined ${ $previouslyFoundSettings{$commandStorageName} }{SpecialMiddleFinishesWithLineBreak}
        ? ${ $previouslyFoundSettings{$commandStorageName} }{SpecialMiddleFinishesWithLineBreak}
        : 0
    );

    $body =~ s/$specialMiddleRegEx/
                    my $begin = $1;
                    my $middleOrSpecial = q();
                    if ($+{SPECIALMIDDLE}){
                        my $horizontalTrailingSpace=($+{TRAILINGHSPACE}?$+{TRAILINGHSPACE}:q());
                        my $trailingComment=($+{TRAILINGCOMMENT}?$+{TRAILINGCOMMENT}:q());
                        my $linebreaksAtEnd=($+{TRAILINGCOMMENT} ? q() : ( $+{TRAILINGLINEBREAK} ? $+{TRAILINGLINEBREAK} : q()));

                        my $codeBlockObj = LatexIndent::Special->new(name=>"specialMiddle",
                                                          begin=>$begin.$+{SPECIALMIDDLESTATEMENT},
                                                          body=>$horizontalTrailingSpace.$trailingComment.$linebreaksAtEnd,
                                                          end=>q(),
                                                          modifyLineBreaksYamlName=>"middle",
                                                          type=>"middle",
                                                          BeginStartsOnOwnLine=>$SpecialMiddleStartsOnOwnLine,
                                                          BodyStartsOnOwnLine=>$SpecialMiddleFinishesWithLineBreak,
                        );


                        $logger->trace("*found: $+{SPECIALMIDDLESTATEMENT}\t type: specialBeginEnd MIDDLE")         if $is_t_switch_active;

                        # poly-switch work
                        if ($is_m_switch_active){
                            $codeBlockObj->_mlb_begin_starts_on_own_line if ${$codeBlockObj}{BeginStartsOnOwnLine} != 0;  
                            $codeBlockObj->_mlb_body_starts_on_own_line if ${$codeBlockObj}{BodyStartsOnOwnLine} != 0;  
                            $middleOrSpecial = ${$codeBlockObj}{begin}.${$codeBlockObj}{body}.${$codeBlockObj}{end}; 

                            # poly-switch token adjustment
                            $middleOrSpecial =~ s@^(\s*)@$1$tokens{specialBeginEndMiddle}@s;
                            $middleOrSpecial =~ s@($tokens{specialBeginEndMiddle}\s*)($tokens{mSwitchComment}|$tokens{blanklines})(\s*)@$2$3$1@s;
                            $middleOrSpecial =~ s@($tokens{specialBeginEndMiddle}\s*)($tokens{mBeforeBeginLineBreakADD}(?:$tokens{blanklines})?)(\s*)@$2$3$1@s;
                        } else {
                            $middleOrSpecial = $begin.$tokens{specialBeginEndMiddle}.$+{SPECIALMIDDLE};
                        }
                      } else {
                        $middleOrSpecial = $begin.$+{SPECIALALL};
                      };
                      $middleOrSpecial;/sgex;
    return $body;
}

#
# ifelsefi find else, or
#
sub _find_ifelsefi_else_or {
    my ( $body, $name, $modifyLineBreaksName ) = @_;
    $logger->trace("looking for ifelsefi ELSE for $name")                        if $is_t_switch_active;
    $logger->trace( ${ ${ $mainSettings{fineTuning} }{ifElseFi} }{elseOrRegEx} ) if $is_t_switch_active;

    my $ifelsefiElseOrRegEx = qr{
         (\s*)
         (?:
           (?<IFELSEFIELSE>
             (?<IFELSEFIELSESTATEMENT>
               ${${$mainSettings{fineTuning}}{ifElseFi}}{elseOrRegEx}
             )
             $mSwitchOnlyTrailing 
           )
           |
           (?<IFELSEFIALL>
             $ifElseFiRegEx 
           )
         )
        }xs;

    # m-switch notes
    #   don't usually mix poly-switch work like this, but
    #   the ELSE/OR statements need finding regardless of
    #   whether the m-switch is active
    #
    my $commandStorageName           = $name . $modifyLineBreaksName;
    my $SpecialMiddleStartsOnOwnLine = (
        defined ${ $previouslyFoundSettings{$commandStorageName} }{ElseStartsOnOwnLine}
        ? ${ $previouslyFoundSettings{$commandStorageName} }{ElseStartsOnOwnLine}
        : 0
    );

    my $SpecialMiddleFinishesWithLineBreak = (
        defined ${ $previouslyFoundSettings{$commandStorageName} }{ElseFinishesWithLineBreak}
        ? ${ $previouslyFoundSettings{$commandStorageName} }{ElseFinishesWithLineBreak}
        : 0
    );

    my $elseExists = 0;

    $body =~ s/$ifelsefiElseOrRegEx/
                    my $begin = $1;
                    my $middleOrSpecial = q();
                    if ($+{IFELSEFIELSE}){
                        $elseExists = 1;
                        my $ifElseFiStatment = $+{IFELSEFIELSESTATEMENT};
                        my $horizontalTrailingSpace=($+{TRAILINGHSPACE}?$+{TRAILINGHSPACE}:q());
                        my $trailingComment=($+{TRAILINGCOMMENT}?$+{TRAILINGCOMMENT}:q());
                        my $linebreaksAtEnd=($+{TRAILINGCOMMENT} ? q() : ( $+{TRAILINGLINEBREAK} ? $+{TRAILINGLINEBREAK} : q()));

                        my $codeBlockObj = LatexIndent::Special->new(name=>"ifElseFiElse",
                                                          begin=>$begin.$ifElseFiStatment,
                                                          body=>$horizontalTrailingSpace.$trailingComment.$linebreaksAtEnd,
                                                          end=>q(),
                                                          modifyLineBreaksYamlName=>"middle",
                                                          type=>"middle",
                                                          BeginStartsOnOwnLine=>$SpecialMiddleStartsOnOwnLine,
                                                          BodyStartsOnOwnLine=>$SpecialMiddleFinishesWithLineBreak,
                        );

                        $logger->trace("*found: $ifElseFiStatment in $name \t type: ifElseFi ELSE")         if $is_t_switch_active;

                        # poly-switch work
                        if ($is_m_switch_active){
                            #
                            # update for OR statement poly-switch 
                            #
                            if ($ifElseFiStatment =~ m@\\or@s ){
                               ${$codeBlockObj}{BeginStartsOnOwnLine} = (
                                       defined ${ $previouslyFoundSettings{$commandStorageName} }{OrStartsOnOwnLine}
                                       ? ${ $previouslyFoundSettings{$commandStorageName} }{OrStartsOnOwnLine}
                                       : 0
                               );
                               ${$codeBlockObj}{BodyStartsOnOwnLine} = (
                                       defined ${ $previouslyFoundSettings{$commandStorageName} }{OrFinishesWithLineBreak}
                                       ? ${ $previouslyFoundSettings{$commandStorageName} }{OrFinishesWithLineBreak}
                                       : 0
                               );
                            }

                            $codeBlockObj->_mlb_begin_starts_on_own_line if ${$codeBlockObj}{BeginStartsOnOwnLine} != 0;  

                            # else, OR require care when no trailing space is present
                            my $elseRequiresTrailingSpace = 0;
                            if (${$codeBlockObj}{BodyStartsOnOwnLine} == -1 and $horizontalTrailingSpace eq ''){
                                 $elseRequiresTrailingSpace = 1;
                                 $logger->trace("adding trailing space ' ' *after* $ifElseFiStatment as body empty and BodyStartsOnOwnLine == -1");
                            }
                            $codeBlockObj->_mlb_body_starts_on_own_line if ${$codeBlockObj}{BodyStartsOnOwnLine} != 0;  
                            $middleOrSpecial = ${$codeBlockObj}{begin}
                                              .($elseRequiresTrailingSpace ? $tokens{mElseTrailingSpace} : q() )
                                              .${$codeBlockObj}{body}
                                              .${$codeBlockObj}{end}; 

                            # poly-switch token adjustment
                            $middleOrSpecial =~ s@^(\s*)@$1$tokens{specialBeginEndMiddle}@s;
                            $middleOrSpecial =~ s@($tokens{specialBeginEndMiddle}\s*)($tokens{mSwitchComment}|$tokens{blanklines})(\s*)@$2$3$1@s;
                            $middleOrSpecial =~ s@($tokens{specialBeginEndMiddle}\s*)($tokens{mBeforeBeginLineBreakADD}(?:$tokens{blanklines})?)(\s*)@$2$3$1@s;
                        } else {
                            $middleOrSpecial = $begin.$tokens{specialBeginEndMiddle}.$+{IFELSEFIELSE};
                        }
                      } else {
                        $middleOrSpecial = $begin.$+{IFELSEFIALL};
                      };
                      $middleOrSpecial;/sgex;
    return ( $body, $elseExists );
}
1;
