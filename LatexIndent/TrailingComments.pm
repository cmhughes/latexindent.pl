package LatexIndent::TrailingComments;
use strict;
use warnings;
use Data::Dumper;
use Exporter qw/import/;
our @EXPORT_OK = qw/remove_trailing_comments put_trailing_comments_back_in get_trailing_comment_token get_trailing_comment_regexp add_comment_symbol/;
our @trailingComments;
our $commentCounter = 0;

sub add_comment_symbol{
    # add a trailing comment token after, for example, a square brace [
    # or a curly brace { when, for example, BeginStartsOnOwnLine == 2
    my $self = shift;
    my $trailingCommentToken = $self->get_trailing_comment_token;

    # increment the comment counter
    $commentCounter++;

    # store the comment -- without this, it won't get processed correctly at the end
    push(@trailingComments,{id=>$trailingCommentToken.$commentCounter,value=>q()});

    # log file info
    $self->logger("Updating trailing comment array",'heading');
    $self->logger(Dumper(\@trailingComments),'ttrace');

    # the returned value
    return $trailingCommentToken.$commentCounter;
}

sub remove_trailing_comments{
    my $self = shift;
    $self->logger("Storing trailing comments",'heading');
    my $trailingCommentToken = $self->get_trailing_comment_token;

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
                            push(@trailingComments,{id=>$trailingCommentToken.$commentCounter,value=>$1});

                            # replace comment with dummy text
                            "%".$trailingCommentToken.$commentCounter;
                       /xsmeg;
    if(@trailingComments){
        $self->logger("Trailing comments stored in:",'trace');
        $self->logger(Dumper(\@trailingComments),'trace');
    } else {
        $self->logger("No trailing comments found",'trace');
    }
    return;
}

sub put_trailing_comments_back_in{
    my $self = shift;
    return unless( @trailingComments > 0 );

    $self->logger("Returning trailing comments to body",'heading');

    # loop through trailing comments in reverse so that, for example, 
    # latexindenttrailingcomment1 doesn't match the first 
    # part of latexindenttrailingcomment18, which would result in an 8 left over (bad)
    while( my $comment = pop @trailingComments){
      my $trailingcommentID = ${$comment}{id};
      my $trailingcommentValue = ${$comment}{value};
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
      $self->logger("replace %$trailingcommentID with %$trailingcommentValue",'trace');
    }
    return;
}

sub get_trailing_comment_token{
    my $self = shift;
    return ${$self->get_tokens}{trailingComment};
}

sub get_trailing_comment_regexp{
    my $self = shift;
    
    my $trailingCommentToken = $self->get_trailing_comment_token;

    return qr/(?<!\\)%$trailingCommentToken\d+/;
}
1;
