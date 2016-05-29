# Environment.pm
#   creates a class for the Environment objects
#   which are a subclass of the Document object.
package LatexIndent::Environment;
use strict;
use warnings;
use Data::Dumper;
our @ISA = "LatexIndent::Document"; # class inheritance, Programming Perl, pg 321
our %previouslyFoundSettings;

sub indent{
    my $self = shift;
    my $previousIndent = shift;
    $self->logger("indenting ENVIRONMENT ${$self}{name}");
    $self->logger("indentation *before* object: '$previousIndent'");
    $self->logger("indentation *of* object: '${$self}{indent}'");
    $self->logger("*total* indentation to be added: '$previousIndent${$self}{indent}'");
    my $indentation = $previousIndent.${$self}{indent};

    # line break stuff
    # line break stuff
    # line break stuff

    # ${$self}{body} =~ s/\R*$//;        # remove line break(s) at end of body

    # remove line break(s) before body
    #${$self}{begin} =~ s/\R*$// if(${$self}{BodyStartsOnOwnLine}==0);       

    # add a line break after \begin{statement} if appropriate
    if(${$self}{BodyStartsOnOwnLine} and !${$self}{linebreaksAtEnd}{begin}){
        $self->logger("Updating linebreaks on begin.");
        ${$self}{begin} .= "\n";       
        ${$self}{linebreaksAtEnd}{begin} = 1;
     }

    # add a line break after body, if appropriate
    if(${$self}{EndStartsOnOwnLine} and !${$self}{linebreaksAtEnd}{body}){
        $self->logger("Updating linebreaks on body.");
        ${$self}{body} .= "\n";
        ${$self}{linebreaksAtEnd}{body} = 1;
    }

    # adjust indendation
    ${$self}{body} =~ s/^\h*/$indentation/mg unless(!${$self}{linebreaksAtEnd}{begin});  # add indentation
    ${$self}{end} =~ s/^\h*/$previousIndent/mg unless(!${$self}{linebreaksAtEnd}{body});  # add indentation

    # ${$self}{body} =~ s/\R*//mg;       # remove line break(s) from body
    return $self;
}

sub get_indentation_settings_for_this_object{
    my $self = shift;

    # check for storage of repeated environments
    if ($previouslyFoundSettings{${$self}{name}}){
        $self->logger("Using stored settings for ${$self}{name}",'trace');
    } else {
        my $name = ${$self}{name};
        $self->logger("Storing settings for $name",'trace');

        # get master settings
        $self->masterYamlSettings;

        # check for noAdditionalIndent and indentRules
        # otherwise use defaultIndent
        my $indentation = (${${$self}{settings}{noAdditionalIndent}}{$name})
                                ?
                                q()
                                :
                     (${${$self}{settings}{indentRules}}{$name}
                                ||
                     ${$self}{settings}{defaultIndent});

        # check if the -m switch is active
        $self->get_switches;
        my $modLineBreaksSwitch = ${${$self}{switches}}{modifyLineBreaks}?${${$self}{switches}}{modifyLineBreaks}:0;

        # settings for modifying line breaks, off by default
        my $BeginStartsOnOwnLine = undef;
        my $BodyStartsOnOwnLine = undef;
        my $EndStartsOnOwnLine = undef;
        my $EndFinishesWithLineBreak = undef;

        # if the -m switch is active, update these settings
        if($modLineBreaksSwitch){
                $BeginStartsOnOwnLine = (${${$self}{settings}{modifyLineBreaks}}{everyBeginStartsOnOwnLine}
                                                             or
                                        ${${${$self}{settings}{modifyLineBreaks}}{$name}}{BeginStartsOnOwnLine})
                                            ?  1 : 0;
                $BodyStartsOnOwnLine = (${${$self}{settings}{modifyLineBreaks}}{everyBodyStartsOnOwnLine}
                                                             or
                                           ${${${$self}{settings}{modifyLineBreaks}}{$name}}{BodyStartsOnOwnLine})
                                            ?  1 : 0;
                $EndStartsOnOwnLine =  (${${$self}{settings}{modifyLineBreaks}}{everyEndStartsOnOwnLine}
                                                             or
                                           ${${${$self}{settings}{modifyLineBreaks}}{$name}}{EndStartsOnOwnLine})
                                            ?  1 : 0;
                $EndFinishesWithLineBreak =  (${${$self}{settings}{modifyLineBreaks}}{everyEndFinishesWithLineBreak}
                                                             or
                                           ${${${$self}{settings}{modifyLineBreaks}}{$name}}{EndFinishesWithLineBreak})
                                            ?  1 : 0;
        }

        # store the settings
        %{${previouslyFoundSettings}{$name}} = (
                        indent=>$indentation,
                        modLineBreaksSwitch=>$modLineBreaksSwitch,
                        BeginStartsOnOwnLine=>$BeginStartsOnOwnLine,
                        BodyStartsOnOwnLine=>$BodyStartsOnOwnLine,
                        EndStartsOnOwnLine=>$EndStartsOnOwnLine,
                        EndFinishesWithLineBreak=>$EndFinishesWithLineBreak,
                      );
        # there's no need for the current object to keep all of the settings
        delete ${$self}{settings};
        delete ${$self}{switches};
    }


    # append indentation settings to the ENVIRONMENT object
    while( my ($key,$value)= each %{${previouslyFoundSettings}{${$self}{name}}}){
            ${$self}{$key} = $value;
    }

    return;
}

1;
