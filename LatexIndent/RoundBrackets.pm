# RoundBrackets.pm
#   creates a class for the OptionalArgument objects
#   which are a subclass of the Document object.
package LatexIndent::RoundBrackets;
use strict;
use warnings;
use LatexIndent::Tokens qw/%tokens/;
use LatexIndent::TrailingComments qw/$trailingCommentRegExp/;
use LatexIndent::Switches qw/$is_t_switch_active $is_tt_switch_active/;
use Exporter qw/import/;
our @ISA = "LatexIndent::Document"; # class inheritance, Programming Perl, pg 321
our @EXPORT_OK = qw/find_round_brackets/;
our $roundBracketCounter;
our $roundBracketRegExp = qr/      
                           (?<!\\)
                           (
                               \(
                              \h*
                              (\R*)
                           )
                            (.*?)
                            (\R*)
                            (?<!\\)     # not immediately pre-ceeded by \
                            (
                             \)          # [optional arguments]
                            )
                            (\h*)
                            (\R)?
                           /sx;

sub indent{
    return;
}

sub find_round_brackets{
    my $self = shift;

    # pick out the optional arguments
    while(${$self}{body} =~ m/$roundBracketRegExp\h*($trailingCommentRegExp)*(.*)/s){
        # log file output

        ${$self}{body} =~ s/
                            $roundBracketRegExp(\h*)($trailingCommentRegExp)*(.*)
                           /
                            # create a new Optional Argument object
                            my $roundBracket = LatexIndent::RoundBrackets->new(begin=>$1,
                                                                    name=>${$self}{name}.":roundBracket",
                                                                    nameForIndentationSettings=>${$self}{parent},
                                                                    parent=>${$self}{parent},
                                                                    body=>$3.($4?$4:q()),
                                                                    end=>$5,
                                                                    linebreaksAtEnd=>{
                                                                      begin=>$2?1:0,
                                                                      body=>$4?1:0,
                                                                      end=>$7?1:0,
                                                                    },
                                                                    modifyLineBreaksYamlName=>"roundBracket",
                                                                    # the last argument (determined by $10 eq '') needs information from the argument container object
                                                                    endImmediatelyFollowedByComment=>($10 eq '')?${$self}{endImmediatelyFollowedByComment}:($9?1:0),
                                                                    horizontalTrailingSpace=>$6?$6:q(),
                                                                  );

                            # the settings and storage of most objects has a lot in common
                            $self->get_settings_and_store_new_object($roundBracket);
                            ${@{${$self}{children}}[-1]}{replacementText}.($8?$8:q()).($9?$9:q()).($10?$10:q());
                            /xseg;
        }
  }

sub get_object_attribute_for_indentation_settings{
    my $self = shift;
    
    return ${$self}{modifyLineBreaksYamlName};
}

sub create_unique_id{
    my $self = shift;

    $roundBracketCounter++;
    ${$self}{id} = "$tokens{roundBracket}$roundBracketCounter";
    return;
}

sub tasks_particular_to_each_object{
    return;
}

1;
