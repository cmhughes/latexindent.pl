# MandatoryArgument.pm
#   creates a class for the MandatoryArgument objects
#   which are a subclass of the Document object.
package LatexIndent::MandatoryArgument;
use strict;
use warnings;
use LatexIndent::Tokens qw/%tokens/;
use LatexIndent::TrailingComments qw/$trailingCommentRegExp/;
use Exporter qw/import/;
our @ISA = "LatexIndent::Document"; # class inheritance, Programming Perl, pg 321
our @EXPORT_OK = qw/find_mandatory_arguments get_mand_arg_reg_exp/;
our $mandatoryArgumentCounter;

sub find_mandatory_arguments{
    my $self = shift;

    my $mandArgRegExp = $self->get_mand_arg_reg_exp;

    # pick out the mandatory arguments
    while(${$self}{body} =~ m/$mandArgRegExp\h*($trailingCommentRegExp)*(.*)/s){
        # log file output
        $self->logger("Mandatory argument found, body in ${$self}{name}",'heading');
        $self->logger("(last argument)") if($8 eq '');

        # create a new Mandatory Argument object
        my $mandatoryArg = LatexIndent::MandatoryArgument->new(begin=>$1,
                                                name=>${$self}{name}.":mandatoryArgument",
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
                                                  BeginStartsOnOwnLine=>"LCuBStartsOnOwnLine",
                                                  # body statements
                                                  BodyStartsOnOwnLine=>"MandArgBodyStartsOnOwnLine",
                                                  # end statements
                                                  EndStartsOnOwnLine=>"RCuBStartsOnOwnLine",
                                                  # after end statements
                                                  EndFinishesWithLineBreak=>"RCuBFinishesWithLineBreak",
                                                },
                                                modifyLineBreaksYamlName=>"mandatoryArguments",
                                                regexp=>$mandArgRegExp,
                                                # the last argument (determined by $8 eq '') needs information from the argument container object
                                                endImmediatelyFollowedByComment=>($8 eq '')?${$self}{endImmediatelyFollowedByComment}:($7?1:0),
                                              );

        # the settings and storage of most objects has a lot in common
        $self->get_settings_and_store_new_object($mandatoryArg);
        }
  }

sub create_unique_id{
    my $self = shift;

    $mandatoryArgumentCounter++;
    ${$self}{id} = "$tokens{mandatoryArgument}$mandatoryArgumentCounter";
    return;
}

sub get_mand_arg_reg_exp{

    my $mandArgRegExp = qr/      
                                   (?<!\\)     # not immediately pre-ceeded by \
                                   (
                                    \{
                                       \h*
                                       (\R*)   # linebreaks after { into $2
                                   )           # { captured into $1
                                   (
                                       (?:
                                           (?!
                                               (?:(?<!\\)\{) 
                                           ).
                                       )*?     # not including {, but \{ ok
                                   )            # body into $3
                                   (\R*)       # linebreaks after body into $4
                                   (?<!\\)     # not immediately pre-ceeded by \
                                   (
                                    \}         # {mandatory arguments}
                                    \h*
                                   )           # } into $5
                                   (\R)?       # linebreaks after } into $6
                               /sx;

    return $mandArgRegExp;
}

sub get_object_attribute_for_indentation_settings{
    my $self = shift;
    
    return ${$self}{modifyLineBreaksYamlName};
}

sub update_child_id_reg_exp{
    return;
  }


1;
