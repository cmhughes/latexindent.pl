package LatexIndent::Heading;
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
use LatexIndent::Switches qw/$is_m_switch_active $is_t_switch_active $is_tt_switch_active/;
use LatexIndent::TrailingComments qw/$trailingCommentRegExp/;
use LatexIndent::GetYamlSettings qw/%masterSettings/;
use Data::Dumper;
use Exporter qw/import/;
our @ISA = "LatexIndent::Document"; # class inheritance, Programming Perl, pg 321
our @EXPORT_OK = qw/find_heading construct_headings_levels/;
our $headingCounter;
our @headingsRegexpArray;
our $allHeadingsRegexp = q();

sub construct_headings_levels{
    my $self = shift;

    # grab the heading levels
    my %headingsLevels = %{$masterSettings{indentAfterHeadings}};

    # output to log file
    $self->logger("Constructing headings reg exp for example, chapter, section, etc (see indentAfterThisHeading)") if $is_t_switch_active ;

    # delete the values that have indentAfterThisHeading set to 0
    while( my ($headingName,$headingInfo)= each %headingsLevels){
        if(!${$headingsLevels{$headingName}}{indentAfterThisHeading}){
            $self->logger("Not indenting after $headingName (see indentAfterThisHeading)",'heading') if $is_t_switch_active;
            delete $headingsLevels{$headingName};
        } else {
            # *all heading* regexp, remembering put starred headings at the front of the regexp
            if($headingName =~ m/\*/){
                 $self->logger("Putting $headingName at the beginning of the allHeadings regexp, as it contains a *") if $is_t_switch_active ;
                 $allHeadingsRegexp = $headingName.($allHeadingsRegexp eq '' ?q():"|$allHeadingsRegexp");
            } else {
                 $self->logger("Putting $headingName at the END of the allHeadings regexp, as it contains a *") if $is_t_switch_active ;
                 $allHeadingsRegexp .= ($allHeadingsRegexp eq '' ?q():"|").$headingName ;
            }
        }
    }

    # check for a * in the name
    $allHeadingsRegexp =~ s/\*/\\\*/g;

    # sort the file extensions by preference 
    my @sortedByLevels = sort { ${$headingsLevels{$a}}{level} <=> $headingsLevels{$b}{level} } keys(%headingsLevels);

    # it could be that @sortedByLevels is empty;
    return if !@sortedByLevels;

    $self->logger("All headings regexp: $allHeadingsRegexp",'heading') if $is_t_switch_active; 
    $self->logger("Now to construct headings regexp for each level:",'heading') if $is_t_switch_active; 

    # loop through the levels, and create a regexp for each (min and max values are the first and last values respectively from sortedByLevels)
    for(my $i = ${$headingsLevels{$sortedByLevels[0]}}{level}; $i <= ${$headingsLevels{$sortedByLevels[-1]}}{level}; $i++ ){
        # level regexp
        my @tmp = grep { ${$headingsLevels{$_}}{level} == $i } keys %headingsLevels;
        if(@tmp){
            my $headingsAtThisLevel = q();
            foreach(@tmp){
               # put starred headings at the front of the regexp
               if($_ =~ m/\*/){
                    $self->logger("Putting $_ at the beginning of this regexp, as it contains a *") if $is_t_switch_active;
                    $headingsAtThisLevel = $_.($headingsAtThisLevel eq '' ?q():"|$headingsAtThisLevel");
               } else {
                    $self->logger("Putting $_ at the END of this regexp, as it contains a *") if $is_t_switch_active;
                    $headingsAtThisLevel .= ($headingsAtThisLevel eq '' ?q():"|").$_ ;
               }
            }

            # make the stars escaped correctly
            $headingsAtThisLevel =~ s/\*/\\\*/g;
            push(@headingsRegexpArray,$headingsAtThisLevel);
            $self->logger("Heading level regexp for level $i will contain: $headingsAtThisLevel");
        }
    }
  }

sub find_heading{

    # if there are no headings regexps, there's no point going any further
    return if!@headingsRegexpArray;

    my $self = shift;

    # otherwise loop through the headings regexp
    $self->logger("Searching for special begin/end (see specialBeginEnd)");

    # loop through each headings match; note that we need to 
    # do it in *reverse* so as to ensure that the lower level headings get matched first of all
    foreach(reverse(@headingsRegexpArray)){
        
        # the regexp
        my $headingRegExp = qr/
                              (
                                  \\($_)        # name stored into $2
                              )                 # beginning bit into $1
                              (
                                  .*?                 
                              )                 # body into $3      
                              (\R*)?            # linebreaks at end of body into $4
                              ((?:\\(?:$allHeadingsRegexp))|$)  # up to another heading, or else the end of the file
                           /sx;
        
        while(${$self}{body} =~ m/$headingRegExp/){

            # log file output
            $self->logger("heading found: $2",'heading');

            ${$self}{body} =~ s/
                                $headingRegExp
                               /
                                # create a new heading object
                                my $headingObject = LatexIndent::Heading->new(begin=>q(),
                                                                        body=>$1.$3,
                                                                        end=>q(),
                                                                        afterbit=>($4?$4:q()).($5?$5:q()),
                                                                        name=>$2.":heading",
                                                                        parent=>$2,
                                                                        nameForIndentationSettings=>$2,
                                                                        linebreaksAtEnd=>{
                                                                          begin=>0,
                                                                          body=>0,
                                                                          end=>0,
                                                                        },
                                                                        modifyLineBreaksYamlName=>"afterHeading",
                                                                        endImmediatelyFollowedByComment=>0,
                                                                      );

                                # the settings and storage of most objects has a lot in common
                                $self->get_settings_and_store_new_object($headingObject);
                                ${@{${$self}{children}}[-1]}{replacementText};
                              /xse;
        }
     }
}

sub get_replacement_text{
    my $self = shift;

    # the replacement text for a heading (chapter, section, etc) needs to put the trailing part back in
    $self->logger("Custom replacement text routine for heading ${$self}{name}");
    ${$self}{replacementText} = ${$self}{id}.${$self}{afterbit};
    delete ${$self}{afterbit};
}

sub create_unique_id{
    my $self = shift;

    $headingCounter++;

    ${$self}{id} = "$tokens{afterHeading}$headingCounter";
    return;
}

sub adjust_replacement_text_line_breaks_at_end{
    return;
}

sub get_object_attribute_for_indentation_settings{
    # when looking for noAdditionalIndent or indentRules, we may need to determine
    # which thing we're looking for, e.g
    #
    #   chapter:
    #       body: 0
    #       optionalArguments: 1
    #       mandatoryArguments: 1
    #       afterHeading: 0
    #
    # this method returns 'body' by default, but the other objects (optionalArgument, mandatoryArgument, afterHeading)
    # return their appropriate identifier.
    my $self = shift;
    
    return ${$self}{modifyLineBreaksYamlName};
}

sub tasks_particular_to_each_object{
    my $self = shift;

    # search for commands, keys, named grouping braces
    $self->find_commands_or_key_equals_values_braces;

    # we need to transfer the details from the modifyLineBreaks of the command
    # child object to the heading object.
    #
    # for example, if we have
    #
    #   \chapter{some heading here}
    #
    # and we want to modify the linebreak before the \chapter command using, for example,
    #
    # commands:
    #     CommandStartsOnOwnLine: 1
    #
    # then we need to transfer this information to the heading object
    if($is_m_switch_active){
        $self->logger("Searching for linebreak preferences immediately infront of ${$self}{parent}",'heading');
        foreach(@{${$self}{children}}){
            if(${$_}{name} eq ${$self}{parent}){
                $self->logger("Named child found: ${$_}{name}");
                if(defined ${$_}{BeginStartsOnOwnLine}){
                    $self->logger("Transferring information from ${$_}{id} (${$_}{name}) to ${$self}{id} (${$self}{name}) for BeginStartsOnOwnLine");
                    ${$self}{BeginStartsOnOwnLine} = ${$_}{BeginStartsOnOwnLine};
                } else {
                    $self->logger("No information found in ${$_}{name} for BeginStartsOnOwnLine");
                }
                last;
            }
        }
    }

    # search for special begin/end
    $self->find_special;

    return;
}

sub add_surrounding_indentation_to_begin_statement{
    # almost all of the objects add surrounding indentation to the 'begin' statements, 
    # but some (e.g HEADING) have their own method
    my $self = shift;
    
    $self->logger("Adding surrounding indentation after (empty, by design!) begin statement of ${$self}{name} (${$self}{id})");
    ${$self}{begin} .= ${$self}{surroundingIndentation};  # add indentation

}

1;
