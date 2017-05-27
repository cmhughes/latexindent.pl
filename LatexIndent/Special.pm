package LatexIndent::Special;
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
use LatexIndent::TrailingComments qw/$trailingCommentRegExp/;
use LatexIndent::GetYamlSettings qw/%masterSettings/;
use LatexIndent::Switches qw/$is_t_switch_active $is_tt_switch_active/;
use Data::Dumper;
use Exporter qw/import/;
our @ISA = "LatexIndent::Document"; # class inheritance, Programming Perl, pg 321
our @EXPORT_OK = qw/find_special construct_special_begin/;
our $specialCounter;
our $specialBegins = q();
our $specialAllMatchesRegExp = q();
our %individualSpecialRegExps;

sub construct_special_begin{
    my $self = shift;

    # put together a list of the begin terms in special
    while( my ($specialName,$BeginEnd)= each %{$masterSettings{specialBeginEnd}}){
      # only append the regexps if lookForThis is 1
      $specialBegins .= ($specialBegins eq ""?q():"|").${$BeginEnd}{begin} if(${$BeginEnd}{lookForThis});
    }

    # put together a list of the begin terms in special
    while( my ($specialName,$BeginEnd)= each %{$masterSettings{specialBeginEnd}}){

      # only append the regexps if lookForThis is 1
      if(${$BeginEnd}{lookForThis}){
        # the beginning parts
        $specialBegins .= ($specialBegins eq ""?q():"|").${$BeginEnd}{begin};

        # the overall regexp
        $specialAllMatchesRegExp .= ($specialAllMatchesRegExp eq ""?q():"|")
                                    .qr/
                                    ${$BeginEnd}{begin}
                                    (?:                        # cluster-only (), don't capture 
                                        (?!             
                                            (?:$specialBegins) # cluster-only (), don't capture
                                        ).                     # any character, but not anything in $specialBegins
                                    )*?                 
                                    ${$BeginEnd}{end}
                             /sx;

        # store the individual special regexp
        $individualSpecialRegExps{$specialName} = qr/
                                  (
                                      ${$BeginEnd}{begin}
                                      \h*
                                      (\R*)?
                                  )
                                  (
                                      (?:                        # cluster-only (), don't capture 
                                          (?!             
                                              (?:$specialBegins) # cluster-only (), don't capture
                                          ).                     # any character, but not anything in $specialBegins
                                      )*?                 
                                     (\R*)?
                                  )                       
                                  (
                                    ${$BeginEnd}{end}
                                  )
                                  (\h*)
                                  (\R)?
                               /sx

        } else {
            $self->logger("The special regexps won't include anything from $specialName (see lookForThis)",'heading') if $is_t_switch_active ;
        }
    }

    # move $$ to the beginning
    if($specialBegins =~ m/\|\\\$\\\$/){
      $specialBegins =~ s/\|(\\\$\\\$)//;
      $specialBegins = $1."|".$specialBegins; 
    }

    # info to the log file
    $self->logger("The special beginnings regexp is: $specialBegins (see specialBeginEnd)",'heading') if $is_t_switch_active;

    # overall special regexp
    $self->logger("The overall special regexp is: $specialAllMatchesRegExp(see specialBeginEnd)",'heading') if $is_t_switch_active;

  }

sub find_special{
    my $self = shift;

    # no point carrying on if the list of specials is empty
    return if($specialBegins eq "");

    # otherwise loop through the special begin/end
    $self->logger("Searching for special begin/end (see specialBeginEnd)") if $is_t_switch_active ;
    $self->logger(Dumper(\%{$masterSettings{specialBeginEnd}})) if $is_tt_switch_active;

    # keep looping as long as there is a special match of some kind
    while(${$self}{body} =~ m/$specialAllMatchesRegExp/sx){

        # loop through each special match
        while( my ($specialName,$BeginEnd)= each %{$masterSettings{specialBeginEnd}}){

            # log file
            if(${$BeginEnd}{lookForThis}){
                $self->logger("Looking for $specialName",'heading') if $is_t_switch_active ;
            } else {
                $self->logger("Not looking for $specialName (see lookForThis)",'heading') if $is_t_switch_active ;
                next;
            }

            # the regexp
            my $specialRegExp = $individualSpecialRegExps{$specialName};
            
            while(${$self}{body} =~ m/$specialRegExp(\h*)($trailingCommentRegExp)?/){

                # global substitution
                ${$self}{body} =~ s/
                                    $specialRegExp(\h*)($trailingCommentRegExp)?
                                   /
                                    # log file output
                                    $self->logger("special found: $specialName",'heading') if $is_t_switch_active;

                                    # create a new special object
                                    my $specialObject = LatexIndent::Special->new(begin=>$1,
                                                                            body=>$3,
                                                                            end=>$5,
                                                                            name=>$specialName,
                                                                            linebreaksAtEnd=>{
                                                                              begin=>$2?1:0,
                                                                              body=>$4?1:0,
                                                                              end=>$7?1:0,
                                                                            },
                                                                            aliases=>{
                                                                              # begin statements
                                                                              BeginStartsOnOwnLine=>"SpecialBeginStartsOnOwnLine",
                                                                              # body statements
                                                                              BodyStartsOnOwnLine=>"SpecialBodyStartsOnOwnLine",
                                                                              # end statements
                                                                              EndStartsOnOwnLine=>"SpecialEndStartsOnOwnLine",
                                                                              # after end statements
                                                                              EndFinishesWithLineBreak=>"SpecialEndFinishesWithLineBreak",
                                                                            },
                                                                            modifyLineBreaksYamlName=>"specialBeginEnd",
                                                                            endImmediatelyFollowedByComment=>$7?0:($9?1:0),
                                                                            horizontalTrailingSpace=>$6?$6:q(),
                                                                          );

                                    # the settings and storage of most objects has a lot in common
                                    $self->get_settings_and_store_new_object($specialObject);
                                    ${@{${$self}{children}}[-1]}{replacementText}.($8?$8:q()).($9?$9:q());
                                    /xseg;

    $self->wrap_up_tasks;
            }
         }
     }
}


sub create_unique_id{
    my $self = shift;

    $specialCounter++;

    ${$self}{id} = "$tokens{specialBeginEnd}$specialCounter";
    return;
}

1;
