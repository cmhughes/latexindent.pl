package LatexIndent::TrailingComments;
use strict;
use warnings;
use FindBin; 
use Data::Dumper;
use Exporter qw/import/;
our @EXPORT_OK = qw/remove_trailing_comments put_trailing_comments_back_in/;

sub remove_trailing_comments{
    my $self = shift;
    $self->logger("Storing trailing comments",'heading');
    my $commentCounter = 0;
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
                            ${${$self}{trailingcomments}}{"latexindenttrailingcomment$commentCounter"}= $1;

                            # replace comment with dummy text
                            "% latexindenttrailingcomment".$commentCounter;
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
        if(${$self}{body} =~ m/%\h$trailingcommentID
                                (
                                    (?!          # not immediately preceeded by 
                                        (?<!\\)  # \
                                        %        # %
                                    ).*?
                                )                # captured into $1
                                (\h*)?$                
                            /mx and $1 ne ''){
            $self->logger("Comment not at end of line $trailingcommentID, moving it to end of line");
            ${$self}{body} =~ s/%\h$trailingcommentID(.*)$/$1%$trailingcommentValue/m;
        } else {
            ${$self}{body} =~ s/%\h$trailingcommentID/%$trailingcommentValue/;
        }
        $self->logger("replace $trailingcommentID with $trailingcommentValue",'trace');
    }
    return;
}


1;
