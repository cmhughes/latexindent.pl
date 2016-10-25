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

sub indent{
    my $self = shift;
    $self->logger("Command object doesn't receive any direct indentation, (its arguments already have done)");
    return;
}

sub find_commands{
    my $self = shift;

    # grab the arguments regexp
    my $optAndMandRegExp = $self->get_arguments_regexp;

    # store the regular expresssion for matching and replacing the \begin{}...\end{} statements
    my $commandRegExp = qr/
                  (\\(?!\[|\])|@)
                  (
                  #(?!     
                  #    (?:\\|\{|\}|\[|\]) 
                  #  )
                    [^\\]*?
                  )                
                  ($optAndMandRegExp)
                /sx;

    # trailing comment regexp
    my $trailingCommentRegExp = $self->get_trailing_comment_regexp;

    while( ${$self}{body} =~ m/$commandRegExp\h*($trailingCommentRegExp)?/){
      #print "1: $1\n";
      #print "2: $2\n";
      #print "3: $3\n";
      #print "4: $4\n";
      #print "5: $5\n";
      #print "6: $6\n";
      # log file output
      $self->logger("command found: $2",'heading');

      # create a new command object
      my $env = LatexIndent::Command->new(begin=>$1.$2,
                                              name=>$2,
                                              body=>$3,
                                              end=>q(),
                                              #linebreaksAtEnd=>{
                                              #  end=>$5?1:0,
                                              #},
                                              modifyLineBreaksYamlName=>"intentionallyleftblank",
                                              regexp=>$commandRegExp,
                                              endImmediatelyFollowedByComment=>$5?0:($6?1:0),
                                            );

      # the settings and storage of most objects has a lot in common
      $self->get_settings_and_store_new_object($env);
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


1;
