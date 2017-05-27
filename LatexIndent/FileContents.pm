package LatexIndent::FileContents;
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
use LatexIndent::Tokens qw/%tokens/;
use LatexIndent::GetYamlSettings qw/%masterSettings/;
use LatexIndent::Switches qw/$is_t_switch_active $is_tt_switch_active/;
use Data::Dumper;
use Exporter qw/import/;
our @EXPORT_OK = qw/find_file_contents_environments_and_preamble/;
our @ISA = "LatexIndent::Document"; # class inheritance, Programming Perl, pg 321
our $fileContentsCounter;

sub find_file_contents_environments_and_preamble{
    my $self = shift;

    # store the file contents blocks in an array which, depending on the value 
    # of indentPreamble, will be put into the verbatim hash, or otherwise 
    # stored as children to be operated upon
    my @fileContentsStorageArray; 

    # fileContents environments
    $self->logger('looking for FILE CONTENTS environments (see fileContentsEnvironments)','heading');
    $self->logger(Dumper(\%{$masterSettings{fileContentsEnvironments}})) if($is_t_switch_active);
    while( my ($fileContentsEnv,$yesno)= each %{$masterSettings{fileContentsEnvironments}}){
        if($yesno){
            $self->logger("looking for $fileContentsEnv:$yesno environments");

            # the trailing * needs some care
            if($fileContentsEnv =~ m/\*$/){
                $fileContentsEnv =~ s/\*$//;
                $fileContentsEnv .= '\*';
            }

            my $fileContentsRegExp = qr/
                            (
                            \\begin\{
                                    $fileContentsEnv       
                                   \}                     
                            )
                            (
                                .*?
                            )                            
                            (
                                \\end\{$fileContentsEnv\}  
                                \h*
                            )                    
                            (\R)?  
                        /sx;

            while( ${$self}{body} =~ m/$fileContentsRegExp/sx){

              # create a new Environment object
              my $fileContentsBlock = LatexIndent::FileContents->new( begin=>$1,
                                                    body=>$2,
                                                    end=>$3,
                                                    name=>$fileContentsEnv,
                                                    linebreaksAtEnd=>{
                                                      begin=>0,
                                                      body=>0,
                                                      end=>$4?1:0,
                                                    },
                                                    modifyLineBreaksYamlName=>"filecontents",
                                                    );
              # give unique id
              $fileContentsBlock->create_unique_id;

              # the replacement text can be just the ID, but the ID might have a line break at the end of it
              $fileContentsBlock->get_replacement_text;

              # count body line breaks
              $fileContentsBlock->count_body_line_breaks;

              # the above regexp, when used below, will remove the trailing linebreak in ${$self}{linebreaksAtEnd}{end}
              # so we compensate for it here
              $fileContentsBlock->adjust_replacement_text_line_breaks_at_end;

              # store the fileContentsBlock, and determine location afterwards
              push(@fileContentsStorageArray,$fileContentsBlock);

              # log file output
              $self->logger("FILECONTENTS environment found: $fileContentsEnv");

              # remove the environment block, and replace with unique ID
              ${$self}{body} =~ s/$fileContentsRegExp/${$fileContentsBlock}{replacementText}/sx;

              $self->logger("replaced with ID: ${$fileContentsBlock}{id}");
            } 
      } else {
            $self->logger("*not* looking for $fileContentsEnv as $fileContentsEnv:$yesno");
      }
    }

    # determine if body of document contains \begin{document} -- if it does, then assume
    # that the body has a preamble
    my $preambleRegExp = qr/
                        (.*?)
                        (\R*\h*)?            # linebreaks at end of body into $2
                        \\begin\{document\}
                /sx;
    my $preamble = q();

    my $needToStorePreamble = 0;

    # try and find the preamble
    if( ${$self}{body} =~ m/$preambleRegExp/sx and ${$masterSettings{lookForPreamble}}{${$self}{fileExtension}}){

        $self->logger("\\begin{document} found in body (after searching for filecontents)-- assuming that a preamble exists");

        # create a preamble object
        $preamble = LatexIndent::Preamble->new( begin=>q(),
                                              body=>$1,
                                              end=>q(),
                                              name=>"preamble",
                                              linebreaksAtEnd=>{
                                                begin=>0,
                                                body=>$2?1:0,
                                                end=>0,
                                              },
                                              afterbit=>($2?$2:q())."\\begin{document}",
                                              modifyLineBreaksYamlName=>"preamble",
                                              );

        # give unique id
        $preamble->create_unique_id;

        # get the replacement_text
        $preamble->get_replacement_text;

        # log file output
        $self->logger("preamble found: $preamble");

        # remove the environment block, and replace with unique ID
        ${$self}{body} =~ s/$preambleRegExp/${$preamble}{replacementText}/sx;

        $self->logger("replaced with ID: ${$preamble}{replacementText}");
        # indentPreamble set to 1
        if($masterSettings{indentPreamble}){
            $self->logger("storing ${$preamble}{id} for indentation (see indentPreamble)");
            $needToStorePreamble = 1;
        } else {
            # indentPreamble set to 0
            $self->logger("NOT storing ${$preamble}{id} for indentation -- will store as VERBATIM object (see indentPreamble)");
            $preamble->unprotect_blank_lines;
            ${$self}{verbatim}{${$preamble}{id}} = $preamble;
        }
    } else {
        ${$self}{preamblePresent} = 0;
    }

    # loop through the fileContents array, check if it's in the preamble
    foreach(@fileContentsStorageArray){
              my $indentThisChild = 0;
              # verbatim children go in special hash
              if($preamble ne '' and ${$preamble}{body} =~ m/${$_}{id}/){
                $self->logger("filecontents (${$_}{id}) is within preamble");
                # indentPreamble set to 1
                if($masterSettings{indentPreamble}){
                    $self->logger("storing ${$_}{id} for indentation (indentPreamble is 1)");
                    $indentThisChild = 1;
                } else {
                    # indentPreamble set to 0
                    $self->logger("Storing ${$_}{id} as a VERBATIM object (indentPreamble is 0)");
                    ${$self}{verbatim}{${$_}{id}}=$_;
                }
              } else {
                    $self->logger("storing ${$_}{id} for indentation (${$_}{name} found outside of preamble)");
                    $indentThisChild = 1;
              }
              # store the child, if necessary
              if($indentThisChild){
                    $_->remove_leading_space;
                    $_->get_indentation_settings_for_this_object;
                    $_->tasks_particular_to_each_object;
                    push(@{${$self}{children}},$_);
              }
    }

    if($needToStorePreamble){
        $preamble->dodge_double_backslash;
        $preamble->remove_leading_space;
        $preamble->find_commands_or_key_equals_values_braces if($masterSettings{preambleCommandsBeforeEnvironments});
        $preamble->tasks_particular_to_each_object;
        push(@{${$self}{children}},$preamble);
    }
    return;
}

sub create_unique_id{
    my $self = shift;

    $fileContentsCounter++;
    ${$self}{id} = "$tokens{filecontents}$fileContentsCounter$tokens{endOfToken}";
    return;
}

sub tasks_particular_to_each_object{
    my $self = shift;

    # search for environments
    $self->find_environments;

    # search for ifElseFi blocks
    $self->find_ifelsefi;

    # search for headings (part, chapter, section, setc)
    $self->find_heading;
    
    # search for commands with arguments
    $self->find_commands_or_key_equals_values_braces;

    # search for special begin/end
    $self->find_special;


}

1;
