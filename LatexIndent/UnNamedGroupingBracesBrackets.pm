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
                        \{|\[|,|&       # starting with { [ , or &
                     )
                     \h*
                  )                     # $1 into beginning bit
                  (\R*)                 # $2 linebreaksAtEnd of begin
                  ($optAndMandRegExp)   # $3 mand|opt arguments (at least one) stored into body
                  (\R)?                 # $6 linebreak 
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

    # the un-named object is a little special, as it doesn't have a name; as such, if there are blank lines before
    # the braces/brackets, we have to insert them
    #${$self}{replacementText} = ${$self}{beginningbit}.(${${$self}{linebreaksAtEnd}}{begin}?"\n":q()).${$self}{id};
    ${$self}{replacementText} = ${$self}{beginningbit}.${$self}{id};

    # but now turn off the switch for linebreaksAtEnd{begin}, otherwise the first brace gets too much indentation
    # (see, for example, test-cases/namedGroupingBracesBrackets/special-characters-minimal.tex)
    ${${$self}{linebreaksAtEnd}}{begin} = 0;
    $self->logger("Beginning bit is: ${$self}{beginningbit}",'trace');
    delete ${$self}{beginningbit};
}

sub check_for_blank_lines_at_beginning{
    # some examples can have blank line tokens at the beginning of the body, 
    # which can confuse the routine below 
    # See, for example, 
    #       test-cases/namedGroupingBracesBrackets/special-characters-minimal-blank-lines-m-switch.tex
    #   compared to
    #       test-cases/namedGroupingBracesBrackets/special-characters-minimal-blank-lines-default.tex
    my $self = shift;

    # blank line token
    my $blankLineToken = $self->get_blank_line_token;

    # if the body begins with 2 or more blank line tokens
    if(${$self}{body} =~ m/^((?:$blankLineToken\R){2,})/s){

        # remove them
        ${$self}{body} =~ s/^((?:$blankLineToken\R)+)//s;

        # store
        my $blank_line_tokens_at_beginning_of_body = $1;

        # and count them, for use after the indentation routine
        ${$self}{blankLinesAtBeginning} = () = $blank_line_tokens_at_beginning_of_body =~ /$blankLineToken\R/sg
    }
    return;
}

sub put_blank_lines_back_in_at_beginning{
    my $self = shift;

    # blank line token
    my $blankLineToken = $self->get_blank_line_token;

    # some bodies have blank lines at the beginning
    if(${$self}{blankLinesAtBeginning}){
        for(my $i=0; $i<${$self}{blankLinesAtBeginning}; $i++){
            ${$self}{body} = $blankLineToken.${$self}{body};
        }
    }
    return
}

1;