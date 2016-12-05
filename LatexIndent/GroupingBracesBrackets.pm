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
                   [a-zA-Z@\*]+?       # lowercase|uppercase letters, @, *, numbers, forward slash, dots
                  )                    # $1 name
                  (\h*)                # $2 h-space
                  (\R*)                # $3 linebreaks
                  ($optAndMandRegExp)  # $4 mand|opt arguments (at least one)
                  (\R)?                # $7 linebreak 
                /sx;

    return $grouping_braces_RegExp; 
}

sub create_unique_id{
    my $self = shift;

    $groupingBracesCounter++;
    ${$self}{id} = "${$self->get_tokens}{groupingBraces}$groupingBracesCounter";
    return;
}

1;
