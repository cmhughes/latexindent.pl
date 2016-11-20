# Command.pm
#   creates a class for the Command objects
#   which are a subclass of the Document object.
package LatexIndent::Command;
use strict;
use warnings;
use Data::Dumper;
use Exporter qw/import/;
our @ISA = "LatexIndent::Document"; # class inheritance, Programming Perl, pg 321
our @EXPORT_OK = qw/get_command_regexp/;
our $commandCounter;

sub get_command_regexp{

    my $self = shift;

    # grab the arguments regexp
    my $optAndMandRegExp = $self->get_arguments_regexp;

    # store the regular expresssion for matching and replacing 
    my $commandRegExp = qr/
                  (\\)   
                  (
                   [a-zA-Z@\*0-9_]+? # lowercase|uppercase letters, @, *, numbers
                  )                
                  \h*
                  (\R*)?
                  ($optAndMandRegExp)
                  (\R)?
                /sx;

    return $commandRegExp;
}

sub tasks_particular_to_each_object{
    my $self = shift;

    # search for arguments
    $self->find_opt_mand_arguments;
    
    # if the last argument finishes with a linebreak, it won't get interpreted at 
    # the right time (see test-cases/commands/commands-one-line-nested-simple-mod1.tex for example)
    # so this little bit fixes it
    if(${${${${${$self}{children}}[0]}{children}[-1]}{linebreaksAtEnd}}{end} and ${${$self}{linebreaksAtEnd}}{end} == 0 
        and defined ${${${${$self}{children}}[0]}{children}[-1]}{EndFinishesWithLineBreak} 
        and ${${${${$self}{children}}[0]}{children}[-1]}{EndFinishesWithLineBreak} >= 1 ){

        # update the Command object
        $self->logger("Adjusting linebreaksAtEnd in command ${$self}{name}","trace");
        ${${$self}{linebreaksAtEnd}}{end} = ${${${${${$self}{children}}[0]}{children}[-1]}{linebreaksAtEnd}}{end};
        ${$self}{replacementText} .= "\n";

        # update the argument object
        $self->logger("Adjusting argument object in command, ${$self}{name}","trace");
        ${${${${$self}{children}}[0]}{linebreaksAtEnd}}{body} = 0;
        ${${${$self}{children}}[0]}{body} =~ s/\R$//s;

        # update the last mandatory/optional argument
        $self->logger("Adjusting last argument in command, ${$self}{name}","trace");
        ${${${${${$self}{children}}[0]}{children}[-1]}{linebreaksAtEnd}}{end} = 0;
        ${${${${$self}{children}}[0]}{children}[-1]}{EndFinishesWithLineBreak} = 0;
        ${${${${$self}{children}}[0]}{children}[-1]}{replacementText} =~ s/\R$//s;

        # output to log file
        $self->logger(Dumper(${${${$self}{children}}[0]}{children}[-1]),"trace");
    }
}

sub create_unique_id{
    my $self = shift;

    $commandCounter++;
    ${$self}{id} = "${$self->get_tokens}{command}$commandCounter";
    return;
}

1;
