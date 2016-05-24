# Environment.pm
#   creates a class for the Environment objects
#   which are a subclass of the Document object.
package LatexIndent::Environment;
use strict;
use warnings;
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
    #print "begin:\n",${$self}{begin},"\n";
    #print "end:\n",${$self}{end},"\n";

    # ${$self}{body} =~ s/\R*$//;        # remove line break(s) at end of body
    ${$self}{body} =~ s/^\h*/$indentation/mg unless(!${$self}{linebreaksAtEnd}{begin});  # add indentation
    ${$self}{end} =~ s/^\h*/$previousIndent/mg;  # add indentation
    #print "body:\n",${$self}{body},"\n";
    # ${$self}{begin} =~ s/\R*$//;       # remove line break(s) before body
    # ${$self}{body} =~ s/\R*//mg;       # remove line break(s) from body
    return $self;
}

sub get_indentation_settings_for_this_object{
    my $self = shift;

    # check for storage of repeated environments
    if ($previouslyFoundSettings{${$self}{name}}){
        $self->logger("Using stored settings for ${$self}{name}",'trace');
    } else {
        $self->logger("Storing settings for ${$self}{name}",'trace');

        # get master settings
        $self->masterYamlSettings;

        # check for noAdditionalIndent and indentRules
        # otherwise use defaultIndent
        my $indentation = (${${$self}{settings}{noAdditionalIndent}}{${$self}{name}})
                                ?
                                q()
                                :
                     (${${$self}{settings}{indentRules}}{${$self}{name}}
                                ||
                     ${$self}{settings}{defaultIndent});
        %{${previouslyFoundSettings}{${$self}{name}}} = (
                        indent=>$indentation,
                      );
        # there's no need for the current object to keep all of the settings
        delete ${$self}{settings};
    }

    # append indentation settings to the ENVIRONMENT object
    while( my ($key,$value)= each %{${previouslyFoundSettings}{${$self}{name}}}){
            ${$self}{$key} = $value;
    }

    return;
}

1;
