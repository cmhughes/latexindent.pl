package LatexIndent::TrailingComments;
use strict;
use warnings;
use Data::Dumper;
use Exporter qw/import/;
our @EXPORT_OK = qw/remove_trailing_comments put_trailing_comments_back_in get_trailing_comment_token get_trailing_comment_regexp/;

sub remove_trailing_comments{
    my $self = shift;
    $self->logger("Storing trailing comments",'heading');
    my $commentCounter = 0;
    $self->get_trailing_comment_token;

    # perform the substitution
    ${$self}{body} =~ s/
                            (?<!\\)  # not preceeded by a \
                            %        # % 
                            (
                                \h*? # followed by possible horizontal space
                                .*?  # and anything else
                            )
                            $        # up to the end of a line
                        /   
                            # increment comment counter and store comment
                            $commentCounter++;
                            ${${$self}{trailingcomments}}{"${$self}{trailingCommentToken}$commentCounter"}= $1;

                            # replace comment with dummy text
                            "%".${$self}{trailingCommentToken}.$commentCounter;
                       /xsmeg;
    if(%{$self}{trailingcomments}){
        $self->logger("Trailing comments stored in:",'trace');
        $self->logger(Dumper(\%{%{$self}{trailingcomments}}),'trace');
    } else {
        $self->logger("No trailing comments found",'trace');
    }
    return;
}

sub put_trailing_comments_back_in{
    my $self = shift;
    return unless(%{$self}{trailingcomments});

    $self->logger("Returning trailing comments to body",'heading');
    while( my ($trailingcommentID,$trailingcommentValue)= each %{%{$self}{trailingcomments}}){
        if(${$self}{body} =~ m/%$trailingcommentID
                                (
                                    (?!          # not immediately preceeded by 
                                        (?<!\\)  # \
                                        %        # %
                                    ).*?
                                )                # captured into $1
                                (\h*)?$                
                            /mx and $1 ne ''){
            $self->logger("Comment not at end of line $trailingcommentID, moving it to end of line");
            ${$self}{body} =~ s/%$trailingcommentID(.*)$/$1%$trailingcommentValue/m;
        } else {
            ${$self}{body} =~ s/%$trailingcommentID/%$trailingcommentValue/;
        }
        $self->logger("replace $trailingcommentID with $trailingcommentValue",'trace');
    }
    return;
}

sub get_trailing_comment_token{
    my $self = shift;

    ${$self}{trailingCommentToken} = "latexindenttrailingcomment";
    return;
}

sub get_trailing_comment_regexp{
    my $self = shift;
    
    $self->get_trailing_comment_token if(!${$self}{trailingCommentToken});

    ${$self}{trailingCommentRegExp} = qr/(?<!\\)%${$self}{trailingCommentToken}\d+/;
    return;
}
1;
