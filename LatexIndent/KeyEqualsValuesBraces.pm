# KeyEqualsValuesBraces.pm
#   creates a class for the KeyEqualsValuesBraces objects
#   which are a subclass of the Document object.
package LatexIndent::KeyEqualsValuesBraces;
use strict;
use warnings;
use Data::Dumper;
use Exporter qw/import/;
our @ISA = "LatexIndent::Document"; # class inheritance, Programming Perl, pg 321
our @EXPORT_OK = qw/get_key_equals_values_regexp/;
our $key_equals_values_braces_Counter;

sub get_key_equals_values_regexp{
    my $self = shift;

    # grab the arguments regexp
    my $optAndMandRegExp = $self->get_arguments_regexp;

    # trailing comment regexp
    my $trailingCommentRegExp = $self->get_trailing_comment_regexp;

    # blank line token
    my $blankLineToken = $self->get_blank_line_token;

    # store the regular expresssion for matching and replacing 
    my $key_equals_values_bracesRegExp = qr/
                  (
                    (?:
                       (?:(?<!\\)\{)
                           |
                           ,
                           |
                       (?:(?<!\\)\[)
                     )
                     (?:\h|\R|$blankLineToken|$trailingCommentRegExp)*
                  )                                                                 # $1                                 
                  (\\)?                                                             # $2
                  (
                   [a-zA-Z@\*0-9_]+? # lowercase|uppercase letters, @, *, numbers
                  )                                                                 # $3
                  (
                    \h*\R*=\h*
                  )                                                                 # $4
                  (\R*)?                                                            # $5
                  ($optAndMandRegExp)                                               # $6
                  (\R)?                                                             # $9
                /sx;

    return $key_equals_values_bracesRegExp; 
}

sub create_unique_id{
    my $self = shift;

    $key_equals_values_braces_Counter++;
    ${$self}{id} = "${$self->get_tokens}{key_equals_values_braces}$key_equals_values_braces_Counter";
    return;
}

sub get_replacement_text{
    my $self = shift;

    # the replacement text for a key = {value} needes to accomodate the leading [ OR { OR % OR , OR any combination thereof
    $self->logger("Custom replacement text routine for ${$self}{name}");
    ${$self}{replacementText} = ${$self}{beginningbit}.${$self}{id};
    delete ${$self}{beginningbit};
}

1;
