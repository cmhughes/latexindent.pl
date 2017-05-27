package LatexIndent::Environment;
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
use LatexIndent::Switches qw/$is_t_switch_active $is_tt_switch_active/;
use Data::Dumper;
use Exporter qw/import/;
our @ISA = "LatexIndent::Document"; # class inheritance, Programming Perl, pg 321
our @EXPORT_OK = qw/find_environments/;
our $environmentCounter;

# store the regular expresssion for matching and replacing the \begin{}...\end{} statements
our $environmentRegExp = qr/
            (
                \\begin\{
                        (
                         [a-zA-Z@\*0-9_\\]+ # lowercase|uppercase letters, @, *, numbers
                        )                 # environment name captured into $2
                       \}                 # \begin{<something>} statement
                       \h*                # horizontal space
                       (\R*)?             # possible line breaks (into $3)
            )                             # begin statement captured into $1
            (
                (?:                       # cluster-only (), don't capture 
                    (?!                   # don't include \begin in the body
                        (?:\\begin)       # cluster-only (), don't capture
                    ).                    # any character, but not \\begin
                )*?                       # non-greedy
                        (\R*)?            # possible line breaks (into $5)
            )                             # environment body captured into $4
            (
                \\end\{\2\}               # \end{<something>} statement
            )                             # captured into $6
            (\h*)?                        # possibly followed by horizontal space
            (\R)?                         # possibly followed by a line break 
            /sx;

sub find_environments{
    my $self = shift;


    while( ${$self}{body} =~ m/$environmentRegExp\h*($trailingCommentRegExp)?/){

      # global substitution
      ${$self}{body} =~ s/
                $environmentRegExp(\h*)($trailingCommentRegExp)?
             /
                # log file output
                $self->logger("environment found: $2",'heading') if $is_t_switch_active;

                # create a new Environment object
                my $env = LatexIndent::Environment->new(begin=>$1,
                                                        name=>$2,
                                                        body=>$4,
                                                        end=>$6,
                                                        linebreaksAtEnd=>{
                                                          begin=>$3?1:0,
                                                          body=>$5?1:0,
                                                          end=>$8?1:0,
                                                        },
                                                        modifyLineBreaksYamlName=>"environments",
                                                        endImmediatelyFollowedByComment=>$8?0:($10?1:0),
                                                        horizontalTrailingSpace=>$7?$7:q(),
                                                      );

                # the settings and storage of most objects has a lot in common
                $self->get_settings_and_store_new_object($env);
                ${@{${$self}{children}}[-1]}{replacementText}.($9?$9:q()).($10?$10:q());
                /xseg;
    $self->adjust_line_breaks_end_parent;
    } 
    return;
}

sub tasks_particular_to_each_object{
    my $self = shift;

    # if the environment is empty, we may need to update linebreaksAtEnd{body}
    if(${$self}{body} =~ m/^\h*$/s and ${${$self}{linebreaksAtEnd}}{begin}){
          $self->logger("empty environment body (${$self}{name}), updating linebreaksAtEnd{body} to be 1") if($is_t_switch_active);
          ${${$self}{linebreaksAtEnd}}{body} = 1;
    }

    # search for items as the first order of business
    $self->find_items;

    # search for headings (important to do this before looking for commands!)
    $self->find_heading;

    # search for commands, keys, named grouping braces
    $self->find_commands_or_key_equals_values_braces;

    # search for arguments
    $self->find_opt_mand_arguments;

    # search for ifElseFi blocks
    $self->find_ifelsefi;

    # search for special begin/end
    $self->find_special;
}

sub create_unique_id{
    my $self = shift;

    $environmentCounter++;
    ${$self}{id} = "$tokens{environments}$environmentCounter";
    return;
}


1;
