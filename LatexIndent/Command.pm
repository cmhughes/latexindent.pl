# Command.pm
#   creates a class for the Command objects
#   which are a subclass of the Document object.
package LatexIndent::Command;
use strict;
use warnings;
use Data::Dumper;
use Exporter qw/import/;
our @ISA = "LatexIndent::Document"; # class inheritance, Programming Perl, pg 321
our @EXPORT_OK = qw/find_commands/;
our $commandCounter;

#sub indent{
#    my $self = shift;
#    $self->logger("Command object doesn't receive any direct indentation, (its arguments already have done)");
#    return;
#}
sub determine_total_indentation{
    my $self = shift;

    # calculate and grab the surrounding indentation
    $self->get_surrounding_indentation;

    # logfile information
    my $surroundingIndentation = ${$self}{surroundingIndentation};
    $self->logger("Custom indentation routine for Command",'heading');
    $self->logger("indentation *surrounding* object: '$surroundingIndentation'");
    $self->logger("*total* indentation to be added: '$surroundingIndentation${$self}{indentation}'");

    # form the total indentation of the object
    ${$self}{indentation} = $surroundingIndentation;

}

sub find_commands{
    my $self = shift;

    # grab the arguments regexp
    my $optAndMandRegExp = $self->get_arguments_regexp;

    # store the regular expresssion for matching and replacing the \begin{}...\end{} statements
    my $commandRegExp = qr/
                  (\\(?!\[|\])|@)
                  (
                    [^\\]*?
                  )                
                  ($optAndMandRegExp)
                  (\R)?
                /sx;

    # trailing comment regexp
    my $trailingCommentRegExp = $self->get_trailing_comment_regexp;

    while( ${$self}{body} =~ m/$commandRegExp\h*($trailingCommentRegExp)?/){
      # log file output
      $self->logger("command found: $2",'heading');

      # store the arguments
      my $arguments = $3;

      # create a new command object
      my $command = LatexIndent::Command->new(begin=>$1.$2,
                                              name=>$2,
                                              body=>$3,
                                              end=>q(),
                                              linebreaksAtEnd=>{
                                                end=>$6?1:0,
                                              },
                                              modifyLineBreaksYamlName=>"intentionallyleftblank",
                                              regexp=>$commandRegExp,
                                              endImmediatelyFollowedByComment=>$6?0:($7?1:0),
                                            );

      ${${$command}{linebreaksAtEnd}}{begin}= ($arguments =~ m/^\h*\R+/s)?1:0;

      # the settings and storage of most objects has a lot in common
      $self->get_settings_and_store_new_object($command);
    } 
    return;
}

sub tasks_particular_to_each_object{
    my $self = shift;

    # search for arguments
    $self->find_opt_mand_arguments;
}

sub create_unique_id{
    my $self = shift;

    $commandCounter++;
    ${$self}{id} = "${$self->get_tokens}{command}$commandCounter";
    return;
}

sub get_indentation_information{
    # custom version of get_indentation_information
    
    my $self = shift;

    # returning 1 means that noAdditionalIndent is active
    $self->logger("Custom version of get_indentation_information used for Command object (${$self}{name})");
    return 1;
}

1;
