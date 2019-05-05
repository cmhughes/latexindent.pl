package LatexIndent::Verbatim;
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
use Data::Dumper;
use Exporter qw/import/;
use LatexIndent::Tokens qw/%tokens/;
use LatexIndent::GetYamlSettings qw/%masterSettings/;
use LatexIndent::Switches qw/$is_t_switch_active $is_tt_switch_active $is_m_switch_active/;
use LatexIndent::LogFile qw/$logger/;
our @EXPORT_OK = qw/put_verbatim_back_in find_verbatim_environments find_noindent_block find_verbatim_commands find_verbatim_special verbatim_common_tasks/;
our @ISA = "LatexIndent::Document"; # class inheritance, Programming Perl, pg 321
our $verbatimCounter;

sub find_noindent_block{
    my $self = shift;

    # noindent block
    $logger->trace('*Searching for NOINDENTBLOCk environments (see noIndentBlock)') if $is_t_switch_active;
    $logger->trace(Dumper(\%{$masterSettings{noIndentBlock}})) if($is_tt_switch_active);
    while( my ($noIndentBlock,$yesno)= each %{$masterSettings{noIndentBlock}}){
        if($yesno){
            $logger->trace("looking for $noIndentBlock:$yesno environments") if $is_t_switch_active;

            (my $noIndentBlockSpec = $noIndentBlock) =~ s/\*/\\*/sg;
            my $noIndentRegExp = qr/
                            (
                                (?!<\\)
                                %
                                \h*                         # possible horizontal spaces
                                \\begin\{
                                        $noIndentBlockSpec  # environment name captured into $2
                                       \}                   # % \begin{noindentblock} statement
                            )
                            (
                                .*?
                            )                               # non-greedy match (body)
                            (
                                (?!<\\)
                                %                           # %
                                \h*                         # possible horizontal spaces
                                \\end\{$noIndentBlockSpec\} # \end{noindentblock}
                            )                               # % \end{<something>} statement
                        /sx;

            while( ${$self}{body} =~ m/$noIndentRegExp/sx){

              # create a new Verbatim object
              my $noIndentBlockObj = LatexIndent::Verbatim->new( begin=>$1,
                                                    body=>$2,
                                                    end=>$3,
                                                    name=>$noIndentBlock,
                                                    type=>"noindentblock",
                                                    modifyLineBreaksYamlName=>"verbatim",
                                                    );
            
              # give unique id
              $noIndentBlockObj->create_unique_id;

              # verbatim children go in special hash
              ${$self}{verbatim}{${$noIndentBlockObj}{id}}=$noIndentBlockObj;

              # log file output
              $logger->trace("*NOINDENTBLOCK environment found: $noIndentBlock") if $is_t_switch_active;

              # remove the environment block, and replace with unique ID
              ${$self}{body} =~ s/$noIndentRegExp/${$noIndentBlockObj}{id}/sx;

              $logger->trace("replaced with ID: ${$noIndentBlockObj}{id}") if $is_t_switch_active;
              
              # possible decoration in log file 
              $logger->trace(${$masterSettings{logFilePreferences}}{showDecorationFinishCodeBlockTrace}) if ${$masterSettings{logFilePreferences}}{showDecorationFinishCodeBlockTrace};
            } 
      } else {
            $logger->trace("*not* looking for $noIndentBlock as $noIndentBlock:$yesno") if $is_t_switch_active;
      }
    }
    return;
}

sub find_verbatim_environments{
    my $self = shift;

    # verbatim environments
    $logger->trace('*Searching for VERBATIM environments (see verbatimEnvironments)') if $is_t_switch_active;
    $logger->trace(Dumper(\%{$masterSettings{verbatimEnvironments}})) if($is_tt_switch_active);
    while( my ($verbEnv,$yesno)= each %{$masterSettings{verbatimEnvironments}}){
        if($yesno){
            $logger->trace("looking for $verbEnv:$yesno environments") if $is_t_switch_active;

            (my $verbEnvSpec = $verbEnv) =~ s/\*/\\*/sg;
            my $verbatimRegExp = qr/
                            (
                            \\begin\{
                                    $verbEnvSpec      # environment name captured into $1
                                   \}                 # \begin{<something>} statement
                            )
                            (
                                .*?
                            )                         # any character, but not \\begin
                            (
                                \\end\{$verbEnvSpec\} # \end{<something>} statement
                            )                    
                            (\h*)?                    # possibly followed by horizontal space
                            (\R)?                     # possibly followed by a line break 
                        /sx;

            while( ${$self}{body} =~ m/$verbatimRegExp/sx){

              # create a new Verbatim object
              my $verbatimBlock = LatexIndent::Verbatim->new( begin=>$1,
                                                    body=>$2,
                                                    end=>$3,
                                                    name=>$verbEnv,
                                                    type=>"environment",
                                                    modifyLineBreaksYamlName=>"verbatim",
                                                    linebreaksAtEnd=>{
                                                      end=>$5?1:0,
                                                    },
                                                    horizontalTrailingSpace=>$4?$4:q(),
                                                    aliases=>{
                                                      # begin statements
                                                      BeginStartsOnOwnLine=>"VerbatimBeginStartsOnOwnLine",
                                                      # after end statements
                                                      EndFinishesWithLineBreak=>"VerbatimEndFinishesWithLineBreak",
                                                    },
                                                    );

              # there are common tasks for each of the verbatim objects
              $verbatimBlock->verbatim_common_tasks;
              
              # verbatim children go in special hash
              ${$self}{verbatim}{${$verbatimBlock}{id}}=$verbatimBlock;

              # log file output
              $logger->trace("*VERBATIM environment found: $verbEnv") if $is_t_switch_active;

              # remove the environment block, and replace with unique ID
              ${$self}{body} =~ s/$verbatimRegExp/${$verbatimBlock}{replacementText}/sx;

              $logger->trace("replaced with ID: ${$verbatimBlock}{id}") if $is_t_switch_active;
              
              # possible decoration in log file 
              $logger->trace(${$masterSettings{logFilePreferences}}{showDecorationFinishCodeBlockTrace}) if ${$masterSettings{logFilePreferences}}{showDecorationFinishCodeBlockTrace};
            } 
      } else {
            $logger->trace("*not* looking for $verbEnv as $verbEnv:$yesno") if $is_t_switch_active;
      }
    }
    return;
}

sub find_verbatim_commands{
    my $self = shift;

    # verbatim commands need to be treated separately to verbatim environments;
    # note that, for example, we could quite reasonably have \lstinline!%!, which 
    # would need to be found *before* trailing comments have been removed. Similarly, 
    # verbatim commands need to be put back in *after* trailing comments have been put 
    # back in
    $logger->trace('*Searching for VERBATIM commands (see verbatimCommands)') if $is_t_switch_active;
    $logger->trace(Dumper(\%{$masterSettings{verbatimCommands}})) if($is_tt_switch_active);
    while( my ($verbCommand,$yesno)= each %{$masterSettings{verbatimCommands}}){
        if($yesno){
            $logger->trace("looking for $verbCommand:$yesno Commands") if $is_t_switch_active;

            my $verbatimRegExp = qr/
                            (
                                \\$verbCommand     
                                \h*                                             
                            )                                                   # name of command into $1
                            (
                                \[
                                    (?:
                                        (?!
                                            (?:(?<!\\)\[) 
                                        ).
                                    )*?     # not including [, but \[ ok
                                (?<!\\)     # not immediately pre-ceeded by \
                                \]          # [optional arguments]
                                \h*
                            )?              # opt arg into $2
                            (
                              .
                            )               # delimiter into $3
                            (
                              .*?
                            )               # body into $4
                            \3
                            (\h*)?          # possibly followed by horizontal space
                            (\R)?           # possibly followed by a line break 
                        /mx;

            while( ${$self}{body} =~ m/$verbatimRegExp/){

              # create a new Verbatim object
              my $verbatimCommand = LatexIndent::Verbatim->new( begin=>$1.($2?$2:q()).$3,
                                                    body=>$4,
                                                    end=>$3,
                                                    name=>$verbCommand,
                                                    type=>"command",
                                                    modifyLineBreaksYamlName=>"verbatim",
                                                    linebreaksAtEnd=>{
                                                      end=>$6?1:0,
                                                    },
                                                    horizontalTrailingSpace=>$5?$5:q(),
                                                    aliases=>{
                                                      # begin statements
                                                      BeginStartsOnOwnLine=>"VerbatimBeginStartsOnOwnLine",
                                                      # after end statements
                                                      EndFinishesWithLineBreak=>"VerbatimEndFinishesWithLineBreak",
                                                    },
                                                    optArg=>$2?$2:q(),
                                                    );
              # there are common tasks for each of the verbatim objects
              $verbatimCommand->verbatim_common_tasks;

              # output, if desired
              $logger->trace(Dumper($verbatimCommand),'ttrace') if($is_tt_switch_active);

              # verbatim children go in special hash
              ${$self}{verbatim}{${$verbatimCommand}{id}}=$verbatimCommand;

              # log file output
              $logger->trace("*VERBATIM command found: $verbCommand") if $is_t_switch_active;

              # remove the environment block, and replace with unique ID
              ${$self}{body} =~ s/$verbatimRegExp/${$verbatimCommand}{replacementText}/sx;

              $logger->trace("replaced with ID: ${$verbatimCommand}{id}") if $is_t_switch_active;
              
              # possible decoration in log file 
              $logger->trace(${$masterSettings{logFilePreferences}}{showDecorationFinishCodeBlockTrace}) if ${$masterSettings{logFilePreferences}}{showDecorationFinishCodeBlockTrace};
            } 
      } else {
            $logger->trace("*not* looking for $verbCommand as $verbCommand:$yesno") if $is_t_switch_active;
      }
    }
    return;

}

sub find_verbatim_special{
    my $self = shift;

    # loop through specialBeginEnd
    while( my ($specialName,$BeginEnd)= each %{$masterSettings{specialBeginEnd}}){

      # only classify special Verbatim if lookForThis is 'verbatim'
      if( (ref($BeginEnd) eq "HASH") and ${$BeginEnd}{lookForThis}=~m/v/s and ${$BeginEnd}{lookForThis} eq 'verbatim'){
            $logger->trace('*Searching for VERBATIM special (see specialBeginEnd)') if $is_t_switch_active;

            my $verbatimRegExp = qr/
                            (
                                ${$BeginEnd}{begin}
                            )
                            (
                                .*?
                            )                    
                            (
                                ${$BeginEnd}{end}
                            )                    
                            (\h*)?                    # possibly followed by horizontal space
                            (\R)?                     # possibly followed by a line break 
                        /sx;

            while( ${$self}{body} =~ m/$verbatimRegExp/sx){

              # create a new Verbatim object
              my $verbatimBlock = LatexIndent::Verbatim->new( begin=>$1,
                                                    body=>$2,
                                                    end=>$3,
                                                    name=>$specialName,
                                                    modifyLineBreaksYamlName=>"specialBeginEnd",
                                                    linebreaksAtEnd=>{
                                                      end=>$5?1:0,
                                                    },
                                                    horizontalTrailingSpace=>$4?$4:q(),
                                                    type=>"special",
                                                    aliases=>{
                                                      # begin statements
                                                      BeginStartsOnOwnLine=>"SpecialBeginStartsOnOwnLine",
                                                      # after end statements
                                                      EndFinishesWithLineBreak=>"SpecialEndFinishesWithLineBreak",
                                                    },
                                                    );
              # there are common tasks for each of the verbatim objects
              $verbatimBlock->verbatim_common_tasks;

              # verbatim children go in special hash
              ${$self}{verbatim}{${$verbatimBlock}{id}}=$verbatimBlock;

              # log file output
              $logger->trace("*VERBATIM special found: $specialName") if $is_t_switch_active;

              # remove the special block, and replace with unique ID
              ${$self}{body} =~ s/$verbatimRegExp/${$verbatimBlock}{replacementText}/sx;

              $logger->trace("replaced with ID: ${$verbatimBlock}{id}") if $is_t_switch_active;
              
              # possible decoration in log file 
              $logger->trace(${$masterSettings{logFilePreferences}}{showDecorationFinishCodeBlockTrace}) if ${$masterSettings{logFilePreferences}}{showDecorationFinishCodeBlockTrace};
            } 
    }
  }
}

sub  put_verbatim_back_in {
    my $self = shift;
    my %input = @_;

    # if there are no verbatim children, return
    return unless(${$self}{verbatim});

    my $verbatimCount=0;
    my $toMatch = q();
    if($input{match} eq "everything-except-commands"){
        $toMatch = "noindentblockenvironmentspecial";

        # count the number of non-command verbatim objects
        while( my ($key,$child)= each %{${$self}{verbatim}}){
            ${$child}{type} = "environment" if !(defined ${$child}{type});
            $verbatimCount++ if($toMatch =~ m/${$child}{type}/);
        }
        return unless($verbatimCount>0);
    } else {
        $toMatch = "command";
        # count the number of command verbatim objects
        while( my ($key,$child)= each %{${$self}{verbatim}}){
            ${$child}{type} = "environment" if !(defined ${$child}{type});
            $verbatimCount++ if($toMatch =~ m/${$child}{type}/);
        }
        return unless($verbatimCount>0);
    }
    
    # search for environments/commands
    $logger->trace('*Putting verbatim back in') if $is_t_switch_active;
    $logger->trace('pre-processed body:') if $is_tt_switch_active;
    $logger->trace(${$self}{body}) if($is_tt_switch_active);

    # loop through document children hash
    my $verbatimFound=0;
    while($verbatimFound < $verbatimCount){
        while( my ($key,$child)= each %{${$self}{verbatim}}){
          if($toMatch =~ m/${$child}{type}/){
            if(${$self}{body} =~ m/${$child}{id}/mx){
                # possibly remove trailing line break
                if(defined ${$child}{EndFinishesWithLineBreak} 
                    and ${$child}{EndFinishesWithLineBreak}==-1
                    and ${$self}{body} =~ m/${$child}{id}\h*\R/s){
                    $logger->trace("m-switch active, removing trailing line breaks from ${$child}{name}") if $is_t_switch_active;
                    ${$self}{body} =~ s/${$child}{id}(\h*)?(\R|\h)*/${$child}{id} /s;
                }
                # replace ids with body
                ${$self}{body} =~ s/${$child}{id}/${$child}{begin}${$child}{body}${$child}{end}/s;

                # log file info
                $logger->trace('Body now looks like:') if $is_tt_switch_active;
                $logger->trace(${$self}{body},'ttrace') if($is_tt_switch_active);

                # delete the child so it won't be operated upon again
                delete ${$self}{verbatim}{${$child}{id}};
                $verbatimFound++;
              } elsif ($is_m_switch_active and ${$masterSettings{modifyLineBreaks}{textWrapOptions}}{columns}>1 and ${$self}{body} !~ m/${$child}{id}/){
                $logger->trace("${$child}{id} not found in body using /m matching, it may have been split across line (see modifyLineBreaks: textWrapOptions)") if($is_t_switch_active);

                # search for a version of the verbatim ID that may have line breaks 
                my $verbatimIDwithLineBreaks = join("\\R?",split(//,${$child}{id}));
                my $verbatimIDwithLineBreaksRegExp = qr/$verbatimIDwithLineBreaks/s;  

                # replace the line-broken verbatim ID with a non-broken verbatim ID
                ${$self}{body} =~ s/$verbatimIDwithLineBreaksRegExp/${$child}{id}/s;

                # note: we do *not* label this as found, as we need to go back through
                #       and search for the newly modified ID
              }
            }

            # logfile info
            $logger->trace('*Post-processed body:') if $is_tt_switch_active;
            $logger->trace(${$self}{body}) if($is_tt_switch_active);
          }
    }
    return;
}

sub verbatim_common_tasks{

    my $self = shift;

    # get yaml settings
    $self->yaml_modify_line_breaks_settings if $is_m_switch_active;

    # give unique id
    $self->create_unique_id;

    # the replacement text can be just the ID, but the ID might have a line break at the end of it
    $self->get_replacement_text;

    # the above regexp, when used below, will remove the trailing linebreak in ${$self}{linebreaksAtEnd}{end}
    # so we compensate for it here
    $self->adjust_replacement_text_line_breaks_at_end;
    
    # modify line breaks end statements
    $self->modify_line_breaks_end if $is_m_switch_active;
}

sub create_unique_id{
    my $self = shift;

    $verbatimCounter++;
    ${$self}{id} = "$tokens{verbatim}$verbatimCounter$tokens{endOfToken}";
    return;
}

sub yaml_get_textwrap_removeparagraphline_breaks{
    my $self = shift;
    $logger->trace("No text wrap or remove paragraph line breaks for verbatim code blocks, ${$self}{name}") if ${$masterSettings{logFilePreferences}}{showDecorationFinishCodeBlockTrace};
}

1;
