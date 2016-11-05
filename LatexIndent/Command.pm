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

sub find_commands{

    my $self = shift;

    $self->logger("Searching for commands with optional and mandatory arguments",'heading');

    # grab the arguments regexp
    my $optAndMandRegExp = $self->get_arguments_regexp;

    # store the regular expresssion for matching and replacing 
    my $commandRegExp = qr/
                  (\\(?!\[|\])|@)   # either: 
                                    #   \\ but not \\[ or \\]
                                    #          or
                                    #          @
                  (
                  [^\\|(?<!\\)\{]*? # not \\ or {, but \{ is ok
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
                                              modifyLineBreaksYamlName=>"commands",
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

sub last_body_check{
    my $self = shift;

    $self->logger("Last body check for Command object (${$self}{name}) to ensure that linebreaksAtEnd is as it should be",'heading');
    ${${$self}{linebreaksAtEnd}}{begin} = (${$self}{body} =~ m/^\h*\R+/s)?1:0;
    return;
}

1;
