# OptionalArgument.pm
#   creates a class for the OptionalArgument objects
#   which are a subclass of the Document object.
package LatexIndent::OptionalArgument;
use strict;
use warnings;
use Data::Dumper;
use Exporter qw/import/;
our @ISA = "LatexIndent::Document"; # class inheritance, Programming Perl, pg 321
our @EXPORT_OK = qw/find_optional_arguments/;
our $optionalArgumentCounter;

sub find_optional_arguments{
    my $self = shift;

    my $optArgRegExp = qr/      
                                   \h*         # 0 or more spaces
                                   \R*         # 0 or more line breaks
                                   (?<!\\)     # not immediately pre-ceeded by \
                                   (
                                    \[
                                       \h*
                                       (\R*)
                                   )
                                   (.*?)
                                   (\R*)
                                   (?<!\\)     # not immediately pre-ceeded by \
                                   \]          # [optional arguments]
                                   \h*
                                   (\R)?
                               /sx;

    # pick out the optional arguments
    while(${$self}{body} =~ m/$optArgRegExp/){
        # log file output
        $self->logger("Optional argument found, body $2",'heading');

        # create a new Optional Argument object
        my $optionalArg = LatexIndent::OptionalArgument->new(begin=>"$1",
                                                name=>${$self}{name}.":optionalArgument",
                                                body=>$3.($4?$4:q()),
                                                end=>"]",
                                                linebreaksAtEnd=>{
                                                  begin=>$2?1:0,
                                                  body=>$4?1:0,
                                                  end=>$5?1:0,
                                                },
                                                aliases=>{
                                                  # begin statements
                                                  BeginStartsOnOwnLine=>"LSqBStartsOnOwnLine",
                                                  # body statements
                                                  BodyStartsOnOwnLine=>"OptArgBodyStartsOnOwnLine",
                                                  # end statements
                                                  EndStartsOnOwnLine=>"RSqBStartsOnOwnLine",
                                                  # after end statements
                                                  EndFinishesWithLineBreak=>"RSqBFinishesWithLineBreak",
                                                },
                                                modifyLineBreaksYamlName=>"optionalArguments",
                                                regexp=>$optArgRegExp,
                                              );
        # there are a number of tasks common to each object
        $optionalArg->tasks_common_to_each_object;

        # store children in special hash
        push(@{${$self}{children}},$optionalArg);

        # grab switches and settings
        $self->get_switches;
        $self->masterYamlSettings;

        # wrap_up_tasks
        $self->wrap_up_tasks;

        # no need to keep settings/switches
        delete ${$self}{settings};
        delete ${$self}{switches};
        }
  }

sub create_unique_id{
    my $self = shift;

    $optionalArgumentCounter++;
    ${$self}{id} = "LATEX-INDENT-OPTIONAL-ARGUMENT$optionalArgumentCounter";
    return;
}

1;
