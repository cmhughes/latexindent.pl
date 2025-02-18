package LatexIndent::Braces;

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
use LatexIndent::GetYamlSettings  qw/%mainSettings %previouslyFoundSettings/;
use LatexIndent::Switches qw/$is_t_switch_active $is_tt_switch_active $is_m_switch_active/;
use LatexIndent::LogFile  qw/$logger/;
use LatexIndent::Tokens           qw/%tokens/;
use Data::Dumper;
use Exporter qw/import/;
our @ISA       = "LatexIndent::Document";    # class inheritance, Programming Perl, pg 321
our @EXPORT_OK = qw/$braceBracketRegExpBasic _find_things_with_braces_brackets _construct_commands_with_args_regex/;
our $braceBracketRegExpBasic = qr/\{|\[/;

our $anythingWithArguments;
our $allArgumentRegEx; 

our $argumentBodyRegEx = qr{
        (?>            # 
          (?:
            \\[{}\[\]] # \{, \}, \[, \] OK
          )
          |            #  
          [^{}\[\]]    # anything except {, }, [, ]
        )              # 
}x;

sub _construct_commands_with_args_regex {

     $allArgumentRegEx = _construct_args_with_between( qr/${${$mainSettings{fineTuning}}{arguments}}{between}/ );
     my $commandName = qr/${${$mainSettings{fineTuning}}{commands}}{name}/;
     my $namedBracesBrackets = qr/${${$mainSettings{fineTuning}}{namedGroupingBracesBrackets}}{name}/;
     my $keyEqVal = qr/${${$mainSettings{fineTuning}}{keyEqualsValuesBracesBrackets}}{name}\s*=\s*/;
     my $unNamed = qr//;

     $anythingWithArguments = qr{
        (\s*)                        # $1 leading space
        (?>                          #    prevent backtracking
          (                          # $2 name
            (\\                      # $3 command
              ($commandName)         # $4 command name
            )                        #
            |                        #
            ($namedBracesBrackets)   # $5 named braces name
            |                        #
            ($keyEqVal)              # $6 key=value name
            |                        #
            $unNamed                 #    unnamed braces or brackets
          )                          #
        )
        (                            # $7 arguments
         (?:                         #
          $allArgumentRegEx          #
         )+                          #
        )
     }x;
}

sub _construct_args_with_between{

    my $argumentsBetween = shift;

    my $mSwitchOnlyTrailing = qr{};
    $mSwitchOnlyTrailing = qr{(\h*)?($trailingCommentRegExp)?(\R)?} if $is_m_switch_active;

    my $allArgumentRegEx = qr{
     (?:
       (?:
         (
          (?:\s|$trailingCommentRegExp|$tokens{blanklines}|$argumentsBetween)*
          (?<!\\)
          \{
          \h*
          (\R*)
         )
         (
          (?:
            (?: $argumentBodyRegEx )             # argument body 
            |
            (??{ $anythingWithArguments })
          )*
         )
         (
          (?<!\\)
          \}
         )
       )
       |
       (?:
         (
          (?:\s|$trailingCommentRegExp|$tokens{blanklines}|$argumentsBetween)*
          (?<!\\)
          \[
          \h*
          (\R*)
         )
         (
          (?:
            (?: $argumentBodyRegEx )             # argument body 
            |
            (??{ $anythingWithArguments })
          )*
         )
         (
          (?<!\\)
          \]
         )
       )
     )
     $mSwitchOnlyTrailing 
     }x;

     return $allArgumentRegEx; 
}

sub _find_things_with_braces_brackets {

    my $body = shift;

    # empty body check
    return q() if not defined $body;

    my $currentIndentation = shift;

    $body =~ s/$anythingWithArguments/
       
       my $begin;
       my $bracesBracketsName;
       my $argBody;
       my $modifyLineBreaksName;
       my $BeginStartsOnOwnLineAlias;
       my $bracesBracketsObj; 
       my $keyEqualsValue = q();
       
       # begin is always in $1
       $begin = $1;

       # argument body is always in $7
       $argBody = $7;

       #
       # command
       #
       if ($3) {                                                    # 
          $begin = $1.q(\\);                                        # \\
          $bracesBracketsName = $4;                                 # <command name>
          $modifyLineBreaksName="commands";                         # 
          $BeginStartsOnOwnLineAlias = "CommandStartsOnOwnLine";    # --------------------------------
       } elsif ($5) {                                               # <name of named braces brackets>
       #                                                            # 
       # named braces or brackets                                   # 
       #                                                            # 
          $bracesBracketsName = $5 ;                                # <name of named braces brackets>
          $modifyLineBreaksName="namedGroupingBracesBrackets";      # 
          $BeginStartsOnOwnLineAlias = "NameStartsOnOwnLine";       # 
       } elsif($6)  {                                               # -------------------------------- 
       #                                                            # 
       # key = braces or brackets                                   # 
       #                                                            # 
          $bracesBracketsName = $6;                                 # <name of key = value braces brackets>
          $bracesBracketsName =~ s|(\s*=$)||s;                      # 
          $keyEqualsValue = $1;
          $modifyLineBreaksName="keyEqualsValuesBracesBrackets";    # 
          $BeginStartsOnOwnLineAlias = "KeyStartsOnOwnLine";        # 
       } else {                                                     # -------------------------------- 
       #                                                            # 
       # unnamed braces and brackets                                # 
       #                                                            # 
          $begin = q();                                             # <possible leading space> 
          $bracesBracketsName = q();                                # 
          $modifyLineBreaksName="UnNamedGroupingBracesBrackets";    # 
          $BeginStartsOnOwnLineAlias = undef;                       # 
       }

       if (!$previouslyFoundSettings{$bracesBracketsName.$modifyLineBreaksName} or $is_m_switch_active){
          $bracesBracketsObj = LatexIndent::Braces->new(name=>$bracesBracketsName,
                                              begin=>$begin,
                                              modifyLineBreaksYamlName=>$modifyLineBreaksName,
                                              arguments=>1,
                                              type=>"something-with-braces",
                                              aliases=>{
                                                # begin statements
                                                BeginStartsOnOwnLine=>$BeginStartsOnOwnLineAlias,
                                              },
          );
       }

       $logger->trace("*found: $bracesBracketsName ($modifyLineBreaksName)")         if $is_t_switch_active;

       # store settings for future use
       if (!$previouslyFoundSettings{$bracesBracketsName.$modifyLineBreaksName}){
          $bracesBracketsObj->yaml_get_indentation_settings_for_this_object;
       }

       # m-switch: command name starts on own line
       if ($is_m_switch_active and ${$previouslyFoundSettings{$bracesBracketsName.$modifyLineBreaksName}}{BeginStartsOnOwnLine} !=0){
            ${$bracesBracketsObj}{BeginStartsOnOwnLine}=${$previouslyFoundSettings{$bracesBracketsName.$modifyLineBreaksName}}{BeginStartsOnOwnLine};
            $bracesBracketsObj->modify_line_breaks_before_begin;  
            $begin = ${$bracesBracketsObj}{begin};
            $begin =~ s@$tokens{mAfterEndLineBreak}$tokens{mBeforeBeginLineBreak}@@sg;
            $begin =~ s@$tokens{mBeforeBeginLineBreak}@@sg;
       }

       # argument indentation
       $argBody = _indent_all_args($bracesBracketsName, $modifyLineBreaksName, $argBody,$currentIndentation);
       
       # command BODY indentation, possibly
       if (${$previouslyFoundSettings{$bracesBracketsName.$modifyLineBreaksName}}{indentation} ne ''){
          my $commandIndentation = ${$previouslyFoundSettings{$bracesBracketsName.$modifyLineBreaksName}}{indentation};

          # add indentation
          $argBody =~ s"^"$commandIndentation"mg;
          $argBody =~ s"^$commandIndentation""s;
       }

       # key = value is particular
       $bracesBracketsName = $bracesBracketsName.$keyEqualsValue if $modifyLineBreaksName eq "keyEqualsValuesBracesBrackets";
       
       # put it all together
       $begin.$bracesBracketsName.$argBody;/sgex;

    return $body;
}

sub _indent_all_args {

    my ($bracesBracketsName, $modifyLineBreaksName, $body , $indentation ) = @_;

    my $commandStorageName = $bracesBracketsName.$modifyLineBreaksName;

    my $mandatoryArgumentsIndentation = ${$previouslyFoundSettings{$commandStorageName}}{mandatoryArgumentsIndentation};
    my $optionalArgumentsIndentation  = ${$previouslyFoundSettings{$commandStorageName}}{optionalArgumentsIndentation};

    $body =~ s|\G$allArgumentRegEx|
       # begin
       my $begin = ($1?$1:$5);

       # mandatory or optional
       my $currentIndentation = ($1 ? $mandatoryArgumentsIndentation : $optionalArgumentsIndentation).$indentation;

       # does arg body start on own line?
       my $argBodyStartsOwnLine = ( ($2 or $6) ? 1 : 0 );

       # body 
       my $argBody = (defined $3?$3:$7);
       
       # end
       my $end = ($4?$4:$8);

       # mandatory or optional argument?
       my $mandatoryArgument = ($1?1:0);

       # storage before finding nested things
       my $horizontalTrailingSpace=$9?$9:q();
       my $trailingComment=($10?$10:q());
       my $linebreaksAtEnd=($10?0:($11?1:0));

       # ***
       # find nested things
       # ***
       $argBody = _find_things_with_braces_brackets($argBody,$indentation) if $argBody=~m/[{[]/s;

       #
       # m switch linebreak adjustment
       #
       if ($is_m_switch_active){

          # begin statements
          my $BeginStartsOnOwnLine=${${$previouslyFoundSettings{$commandStorageName}}{mand}}{LCuBStartsOnOwnLine};

          # body statements
          my $BodyStartsOnOwnLine=${${$previouslyFoundSettings{$commandStorageName}}{mand}}{MandArgBodyStartsOnOwnLine};

          # end statements
          my $EndStartsOnOwnLine=${${$previouslyFoundSettings{$commandStorageName}}{mand}}{RCuBStartsOnOwnLine};

          # after end statements
          my $EndFinishesWithLineBreak=${${$previouslyFoundSettings{$commandStorageName}}{mand}}{RCuBFinishesWithLineBreak};

          my $argType = "mandatory";

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

          my $mandatoryArg = LatexIndent::MandatoryArgument->new(
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
                                                  begin=>$argBodyStartsOwnLine,
                                                  end=>$linebreaksAtEnd,
                                                },
                            );

            $logger->trace("*-m switch poly-switch line break adjustment ($commandStorageName, arg-type $argType)") if $is_t_switch_active;

            $mandatoryArg->modify_line_breaks_before_begin if ${$mandatoryArg}{BeginStartsOnOwnLine} != 0;  

            $mandatoryArg->modify_line_breaks_before_body if ${$mandatoryArg}{BodyStartsOnOwnLine} != 0;  

            $mandatoryArg->modify_line_breaks_before_end if ${$mandatoryArg}{EndStartsOnOwnLine} != 0;

            $mandatoryArg->modify_line_breaks_after_end;

            # get updated begin, body, end
            $begin = ${$mandatoryArg}{begin};
            $argBody = ${$mandatoryArg}{body};
            $end = ${$mandatoryArg}{end};

            $argBodyStartsOwnLine = ${$mandatoryArg}{linebreaksAtEnd}{begin};
       }

       # add indentation
       $argBody =~ s@^@$currentIndentation@mg if ( ($argBodyStartsOwnLine or $argBody=~m@[\n]@s) and $argBody ne '');

       # if arg body does NOT start on its own line, remove the first indentation added by previous step
       $argBody =~ s@^$currentIndentation@@s if (!$argBodyStartsOwnLine);

       # put it all together
       $begin.$argBody.$end;|sgex;

       # m switch conflicting linebreak addition/removal handled by tokens
       if ($is_m_switch_active){
          $body =~ s@(?:$tokens{mAfterEndLineBreak})+$tokens{mBeforeBeginLineBreak}@@sg;
          $body =~ s@$tokens{mAfterEndLineBreak}($trailingCommentRegExp)$tokens{mBeforeBeginLineBreak}@\n$1@sg;
          $body =~ s@$tokens{mBeforeBeginLineBreak}@@sg;
          $body =~ s@$tokens{mAfterEndLineBreak}($trailingCommentRegExp)@\n$1\n@sg;
          $body =~ s@$tokens{mAfterEndLineBreak}@\n@sg;
       }

    return $body;
}

1;
