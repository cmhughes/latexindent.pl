# OptionalArgument.pm
#   creates a class for the OptionalArgument objects
#   which are a subclass of the Document object.
package LatexIndent::OptionalArgument;
use strict;
use warnings;
use LatexIndent::Tokens qw/%tokens/;
use LatexIndent::TrailingComments qw/$trailingCommentRegExp/;
use Exporter qw/import/;
our @ISA = "LatexIndent::Document"; # class inheritance, Programming Perl, pg 321
our @EXPORT_OK = qw/find_optional_arguments/;
our $optionalArgumentCounter;
our $optArgRegExp = qr/      
                               (?<!\\)     # not immediately pre-ceeded by \
                               (
                                \[
                                   \h*
                                   (\R*)
                               )
                               (.*?)
                               (\R*)
                               (?<!\\)     # not immediately pre-ceeded by \
                               (
                                \]          # [optional arguments]
                                \h*
                               )
                               (\R)?
                           /sx;

sub find_optional_arguments{
    my $self = shift;

    # pick out the optional arguments
    while(${$self}{body} =~ m/$optArgRegExp\h*($trailingCommentRegExp)*(.*)/s){
        # log file output
        $self->logger("Optional argument found, body in ${$self}{name}",'heading');
        $self->logger("(last argument)") if($8 eq '');

        # create a new Optional Argument object
        my $optionalArg = LatexIndent::OptionalArgument->new(begin=>$1,
                                                name=>${$self}{name}.":optionalArgument",
                                                nameForIndentationSettings=>${$self}{parent},
                                                parent=>${$self}{parent},
                                                body=>$3.($4?$4:q()),
                                                end=>$5,
                                                linebreaksAtEnd=>{
                                                  begin=>$2?1:0,
                                                  body=>$4?1:0,
                                                  end=>$6?1:0,
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
                                                # the last argument (determined by $8 eq '') needs information from the argument container object
                                                endImmediatelyFollowedByComment=>($8 eq '')?${$self}{endImmediatelyFollowedByComment}:($7?1:0),
                                              );

        # the settings and storage of most objects has a lot in common
        $self->get_settings_and_store_new_object($optionalArg);
        }
  }

sub get_object_attribute_for_indentation_settings{
    my $self = shift;
    
    return ${$self}{modifyLineBreaksYamlName};
}

sub create_unique_id{
    my $self = shift;

    $optionalArgumentCounter++;
    ${$self}{id} = "$tokens{optionalArgument}$optionalArgumentCounter";
    return;
}

sub tasks_particular_to_each_object{
    my $self = shift;

    # search for ifElseFi blocks
    $self->find_ifelsefi;

    # search for special begin/end
    $self->find_special;

}

1;
