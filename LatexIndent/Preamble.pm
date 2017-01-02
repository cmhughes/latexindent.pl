# Preamble.pm
#   creates a class for the Preamble objects
#   which are a subclass of the Document object.
package LatexIndent::Preamble;
use strict;
use warnings;
use LatexIndent::Tokens qw/%tokens/;
use LatexIndent::GetYamlSettings qw/%masterSettings/;
our @ISA = "LatexIndent::Document"; # class inheritance, Programming Perl, pg 321
our $preambleCounter;

sub create_unique_id{
    my $self = shift;

    $preambleCounter++;
    ${$self}{id} = "$tokens{preamble}$preambleCounter$tokens{endOfToken}";
    return;
}

sub get_replacement_text{
    my $self = shift;

    # the replacement text for preamble needs to put the \\begin{document} back in
    $self->logger("Custom replacement text routine for preamble ${$self}{name}");
    ${$self}{replacementText} = ${$self}{id}.${$self}{afterbit};
    delete ${$self}{afterbit};
}

sub indent{
    # preamble doesn't receive any additional indentation
    return;
}

sub tasks_particular_to_each_object{
    my $self = shift;

    # search for environments
    $self->find_environments;

    # search for ifElseFi blocks
    $self->find_ifelsefi;

    # search for commands with arguments
    $self->find_commands_or_key_equals_values_braces if(!$masterSettings{preambleCommandsBeforeEnvironments});

    # search for special begin/end
    $self->find_special;


}

1;
