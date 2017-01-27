# GroupingBracesBrackets.pm
#   creates a class for the GroupingBracesBrackets objects
#   which are a subclass of the Document object.
package LatexIndent::NamedGroupingBracesBrackets;
use strict;
use warnings;
use LatexIndent::Tokens qw/%tokens/;
use LatexIndent::TrailingComments qw/$trailingCommentRegExp/;
use LatexIndent::Switches qw/$is_t_switch_active $is_tt_switch_active/;
use Exporter qw/import/;
our @ISA = "LatexIndent::Command"; # class inheritance, Programming Perl, pg 321
our @EXPORT_OK = qw/construct_grouping_braces_brackets_regexp $grouping_braces_regexp $grouping_braces_regexpTrailingComment/;
our $groupingBracesCounter;
our $grouping_braces_regexp; 
our $grouping_braces_regexpTrailingComment; 

sub construct_grouping_braces_brackets_regexp{
    my $self = shift;

    # grab the arguments regexp
    my $optAndMandRegExp = $self->get_arguments_regexp;

    # store the regular expresssion for matching and replacing 
    $grouping_braces_regexp = qr/
                  (
                     \h|\R|\{|\[
                  )
                  (
                   [a-zA-Z@\*><]+?       # lowercase|uppercase letters, @, *, numbers, forward slash, dots
                  )                    # $2 name
                  (\h*)                # $3 h-space
                  (\R*)                # $4 linebreaks
                  ($optAndMandRegExp)  # $5 mand|opt arguments (at least one)
                  (\R)?                # $8 linebreak 
                /sx;

    # something {value} grouping braces with trailing comment
    $grouping_braces_regexpTrailingComment = qr/$grouping_braces_regexp\h*((?:$trailingCommentRegExp\h*)*)?/;

}

sub create_unique_id{
    my $self = shift;

    $groupingBracesCounter++;
    ${$self}{id} = "$tokens{groupingBraces}$groupingBracesCounter";
    return;
}

sub get_replacement_text{
    my $self = shift;

    # the replacement text for a key = {value} needes to accomodate the leading [ OR { OR % OR , OR any combination thereof
    $self->logger("Custom replacement text routine for ${$self}{name}") if $is_t_switch_active;
    ${$self}{replacementText} = ${$self}{beginningbit}.${$self}{id};
    delete ${$self}{beginningbit};
}

1;
