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
use LatexIndent::GetYamlSettings  qw/%previouslyFoundSettings/;
use LatexIndent::Switches qw/$is_t_switch_active $is_tt_switch_active $is_m_switch_active/;
use LatexIndent::LogFile  qw/$logger/;
use LatexIndent::Tokens           qw/%tokens/;
use Data::Dumper;
use Exporter qw/import/;
our @ISA       = "LatexIndent::Document";    # class inheritance, Programming Perl, pg 321
our @EXPORT_OK = qw/$braceBracketRegExpBasic find_things_with_braces_brackets construct_commands_with_args_regex/;
our $braceBracketRegExpBasic = qr/\{|\[/;

our $latexCommand;
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

sub construct_commands_with_args_regex {

    my $mSwitchOnlyTrailing = qr{};
    $mSwitchOnlyTrailing = qr{(\h*)?($trailingCommentRegExp)?(\R)?} if $is_m_switch_active;

    $allArgumentRegEx = qr{
     (?:
     (?:
       (
        (?:\s|$trailingCommentRegExp|$tokens{blanklines})*
        (?<!\\)
        \{
        \h*
        (\R?)
       )
       (
        (?:
          (?: $argumentBodyRegEx ) # argument body 
          |
          (??{ $latexCommand })    # command regex, RECURSIVE
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
        (?:\s|$trailingCommentRegExp|$tokens{blanklines})*
        (?<!\\)
        \[
        \h*
        (\R?)
       )
       (
        (?:
          (?: $argumentBodyRegEx ) # argument body 
          |
          (??{ $latexCommand })    # command regex, RECURSIVE
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

     $latexCommand = qr{
        \\
        ([a-zA-Z]+?)
        (
         (?:
          $allArgumentRegEx 
         )+
        )
        }x;
}

sub find_things_with_braces_brackets {

    my $body = shift;
    my $currentIndentation = shift;

    $body =~ s/$latexCommand/
       my $commandName = $1;
       my $argBody = $2;
       if (!$previouslyFoundSettings{$commandName."commands"}){
          my $commandObj = LatexIndent::Braces->new(name=>$commandName,
                                              modifyLineBreaksYamlName=>"commands",
                                              arguments=>1,
                                                );
          $commandObj->yaml_get_indentation_settings_for_this_object;
       }
       $argBody = &indent_all_args($commandName."commands", $argBody,$currentIndentation);
       
       # command BODY indentation, possibly
       if (${$previouslyFoundSettings{$commandName."commands"}}{indentation} ne ''){
          my $commandIndentation = ${$previouslyFoundSettings{$commandName."commands"}}{indentation};

          # add indentation
          $argBody =~ s"^"$commandIndentation"mg;
          $argBody =~ s"^$commandIndentation""s;
       }

       # put it all together
       "\\".$commandName.$argBody;/sgex;

    return $body;
}

sub indent_all_args {

    my $commandStorageName = shift;
    my $body = shift;
    my $indentation = shift;

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
       my $argBody = ($3?$3:$7);
       
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
       $argBody = &find_things_with_braces_brackets($argBody,$indentation);

       #
       # m switch linebreak adjustment
       #
       if ($is_m_switch_active){

          # begin statements
          my $BeginStartsOnOwnLine=${$previouslyFoundSettings{$commandStorageName}}{LCuBStartsOnOwnLine};

          # body statements
          my $BodyStartsOnOwnLine=${$previouslyFoundSettings{$commandStorageName}}{MandArgBodyStartsOnOwnLine};

          # end statements
          my $EndStartsOnOwnLine=${$previouslyFoundSettings{$commandStorageName}}{RCuBStartsOnOwnLine};

          # after end statements
          my $EndFinishesWithLineBreak=${$previouslyFoundSettings{$commandStorageName}}{RCuBFinishesWithLineBreak};

          if (!$mandatoryArgument){
             # begin statements
             $BeginStartsOnOwnLine=${$previouslyFoundSettings{$commandStorageName}}{LSqBStartsOnOwnLine};

             # body statements
             $BodyStartsOnOwnLine=${$previouslyFoundSettings{$commandStorageName}}{OptArgBodyStartsOnOwnLine};

             # end statements
             $EndStartsOnOwnLine=${$previouslyFoundSettings{$commandStorageName}}{RSqBStartsOnOwnLine};

             # after end statements
             $EndFinishesWithLineBreak=${$previouslyFoundSettings{$commandStorageName}}{RSqBFinishesWithLineBreak};
          }

          my $mandatoryArg = LatexIndent::MandatoryArgument->new(
                                                begin=>$begin,
                                                body=>$argBody, 
                                                end=>$end,
                                                # begin statements
                                                BeginStartsOnOwnLine=>$BeginStartsOnOwnLine,
                                                # body statements
                                                BodyStartsOnOwnLine=>$BodyStartsOnOwnLine,
                                                # end statements
                                                EndStartsOnOwnLine=>$EndStartsOnOwnLine,
                                                # after end statements
                                                EndFinishesWithLineBreak=>$EndFinishesWithLineBreak,
                                                horizontalTrailingSpace=>$horizontalTrailingSpace,
                                                trailingComment=>$trailingComment,
                                                linebreaksAtEnd=>{
                                                  begin=>$argBodyStartsOwnLine,
                                                  end=>$linebreaksAtEnd,
                                                },
                            );

            $mandatoryArg->modify_line_breaks_begin if ${$mandatoryArg}{BeginStartsOnOwnLine} != 0;  

            $mandatoryArg->modify_line_breaks_body if ${$mandatoryArg}{BodyStartsOnOwnLine} != 0;  

            $mandatoryArg->modify_line_breaks_end if ${$mandatoryArg}{EndStartsOnOwnLine} != 0;

            $mandatoryArg->modify_line_breaks_end_after if ${$mandatoryArg}{EndFinishesWithLineBreak} != 0;

            # get updated begin, body, end
            $begin = ${$mandatoryArg}{begin};
            $argBody = ${$mandatoryArg}{body};
            $end = ${$mandatoryArg}{end};

            $argBodyStartsOwnLine = ${$mandatoryArg}{linebreaksAtEnd}{begin};
       }

       # add indentation
       $argBody =~ s@^@$currentIndentation@mg;

       # if arg body does NOT start on its own line, remove the first indentation added by previous step
       $argBody =~ s@^$currentIndentation@@s if (!$argBodyStartsOwnLine);

       # put it all together
       $begin.$argBody.$end;|sgex;

       # m switch conflicting linebreak addition/removal handled by tokens
       if ($is_m_switch_active){
          $body =~ s@$tokens{mAfterEndLineBreak}$tokens{mBeforeBeginLineBreak}@@sg;
          $body =~ s@$tokens{mBeforeBeginLineBreak}@@sg;
          $body =~ s@$tokens{mAfterEndLineBreak}@\n@sg;
       }

    return $body;
}

1;
