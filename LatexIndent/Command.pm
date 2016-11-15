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
                  \h*
                  (\R*)?
                  ($optAndMandRegExp)
                  (\R)?
                /sx;

    # trailing comment regexp
    my $trailingCommentRegExp = $self->get_trailing_comment_regexp;

    while( ${$self}{body} =~ m/$commandRegExp\h*($trailingCommentRegExp)?/){
      # log file output
      $self->logger("command found: $2",'heading');

      # create a new command object
      my $command = LatexIndent::Command->new(begin=>$1.$2.($3?$3:q()),
                                              name=>$2,
                                              body=>$4,
                                              end=>q(),
                                              linebreaksAtEnd=>{
                                                begin=>$3?1:0,
                                                end=>$7?1:0,
                                              },
                                              modifyLineBreaksYamlName=>"commands",
                                              regexp=>$commandRegExp,
                                              endImmediatelyFollowedByComment=>$7?0:($8?1:0),
                                              aliases=>{
                                                # begin statements
                                                BeginStartsOnOwnLine=>"CommandStartsOnOwnLine",
                                                # body statements
                                                BodyStartsOnOwnLine=>"CommandNameFinishesWithLineBreak",
                                              },
                                            );

      # the settings and storage of most objects has a lot in common
      $self->get_settings_and_store_new_object($command);
    } 
    return;
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
