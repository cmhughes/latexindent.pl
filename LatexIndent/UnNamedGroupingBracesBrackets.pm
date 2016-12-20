# UnNamedGroupingBracesBrackets.pm
#   creates a class for the UnNamedGroupingBracesBrackets objects
#   which are a subclass of the Document object.
package LatexIndent::UnNamedGroupingBracesBrackets;
use strict;
use warnings;
use Exporter qw/import/;
our @ISA = "LatexIndent::Command"; # class inheritance, Programming Perl, pg 321
our @EXPORT_OK = qw/get_unnamed_grouping_braces_brackets_regexp/;
our $unNamedGroupingBracesCounter;

sub get_unnamed_grouping_braces_brackets_regexp{
    my $self = shift;

    # grab the arguments regexp
    my $optAndMandRegExp = $self->get_arguments_regexp;

    # trailing comment regexp
    my $trailingCommentRegExp = $self->get_trailing_comment_regexp;

    # blank line token
    my $blankLineToken = $self->get_blank_line_token;

    # for example #1 #2, etc
    my $numberedArgRegExp = $self->get_numbered_arg_regexp;

    # store the regular expresssion for matching and replacing 
    my $un_named_grouping_braces_RegExp = qr/
                  # NOT
                  (?!
                      (?:
                        (?:(?<!\\)\]) 
                        |
                        (?:(?<!\\)\}) 
                      )
                      (?:\h|\R|$blankLineToken|$trailingCommentRegExp|$numberedArgRegExp)*  # 0 or more h-space, blanklines, trailing comments
                  )
                  # END of NOT
                  (
                     (?:
                        \{|\[|,
                     )
                     \h*
                  )                    # $1 into beginning bit
                  (\R*)                # $2 linebreaksAtEnd of begin
                  ($optAndMandRegExp)  # $3 mand|opt arguments (at least one) stored into body
                  (\R)?                # $6 linebreak 
                /sx;

    return $un_named_grouping_braces_RegExp; 
}

sub create_unique_id{
    my $self = shift;

    $unNamedGroupingBracesCounter++;
    ${$self}{id} = "${$self->get_tokens}{unNamedgroupingBraces}$unNamedGroupingBracesCounter";
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
