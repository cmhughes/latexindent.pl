package LatexIndent::TrailingComments;
use strict;
use warnings;
use LatexIndent::Tokens qw/%tokens/;
use LatexIndent::Switches qw/$is_t_switch_active $is_tt_switch_active/;
use Data::Dumper;
use Exporter qw/import/;
our @EXPORT_OK = qw/remove_trailing_comments put_trailing_comments_back_in $trailingCommentRegExp add_comment_symbol construct_trailing_comment_regexp/;
our @trailingComments;
our $commentCounter = 0;
our $trailingCommentRegExp;

sub construct_trailing_comment_regexp{
    $trailingCommentRegExp = qr/(?<!\\)%$tokens{trailingComment}\d+$tokens{endOfToken}/;
}

sub add_comment_symbol{
    # add a trailing comment token after, for example, a square brace [
    # or a curly brace { when, for example, BeginStartsOnOwnLine == 2
    my $self = shift;

    # increment the comment counter
    $commentCounter++;

    # store the comment -- without this, it won't get processed correctly at the end
    push(@trailingComments,{id=>$tokens{trailingComment}.$commentCounter.$tokens{endOfToken},value=>q()});

    # log file info
    $self->logger("Updating trailing comment array",'heading');
    $self->logger(Dumper(\@trailingComments),'ttrace') if($is_tt_switch_active);

    # the returned value
    return $tokens{trailingComment}.$commentCounter.$tokens{endOfToken};
}

sub remove_trailing_comments{
    my $self = shift;
    $self->logger("Storing trailing comments",'heading');

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
                            push(@trailingComments,{id=>$tokens{trailingComment}.$commentCounter.$tokens{endOfToken},value=>$1});

                            # replace comment with dummy text
                            "%".$tokens{trailingComment}.$commentCounter.$tokens{endOfToken};
                       /xsmeg;
    if(@trailingComments){
        $self->logger("Trailing comments stored in:") if($is_t_switch_active);
        $self->logger(Dumper(\@trailingComments)) if($is_t_switch_active);
    } else {
        $self->logger("No trailing comments found") if($is_t_switch_active);
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
      $self->logger("replace %$trailingcommentID with %$trailingcommentValue") if($is_t_switch_active);
    }
    return;
}

1;
