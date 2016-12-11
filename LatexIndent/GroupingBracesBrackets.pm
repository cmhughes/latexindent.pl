# GroupingBracesBrackets.pm
#   creates a class for the GroupingBracesBrackets objects
#   which are a subclass of the Document object.
package LatexIndent::GroupingBracesBrackets;
use strict;
use warnings;
use Exporter qw/import/;
our @ISA = "LatexIndent::Command"; # class inheritance, Programming Perl, pg 321
our @EXPORT_OK = qw/get_grouping_braces_brackets_regexp/;
our $groupingBracesCounter;

sub get_grouping_braces_brackets_regexp{
    my $self = shift;

    # grab the arguments regexp
    my $optAndMandRegExp = $self->get_arguments_regexp;

    # trailing comment regexp
    my $trailingCommentRegExp = $self->get_trailing_comment_regexp;

    # blank line token
    my $blankLineToken = $self->get_blank_line_token;

    # store the regular expresssion for matching and replacing 
    my $grouping_braces_RegExp = qr/
                  (
                     \h|\R
                  )
                  (
                   [a-zA-Z@\*]+?       # lowercase|uppercase letters, @, *, numbers, forward slash, dots
                  )                    # $2 name
                  (\h*)                # $3 h-space
                  (\R*)                # $4 linebreaks
                  ($optAndMandRegExp)  # $5 mand|opt arguments (at least one)
                  (\R)?                # $8 linebreak 
                /sx;

    return $grouping_braces_RegExp; 
}

sub create_unique_id{
    my $self = shift;

    $groupingBracesCounter++;
    ${$self}{id} = "${$self->get_tokens}{groupingBraces}$groupingBracesCounter";
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
