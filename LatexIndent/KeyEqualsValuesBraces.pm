package LatexIndent::KeyEqualsValuesBraces;
use strict;
use warnings;
use feature qw(say);
use LatexIndent::LogFile qw/$grammarLeadingSpace/;

sub explain {
    my ($self, $level) = @_;
    say $grammarLeadingSpace x $level, "KeyEqualsValuesBraces";
    say $grammarLeadingSpace x ($level+1), "Name: $self->{name}";
    say $grammarLeadingSpace x ($level+1), "equals: $self->{equals}";
    say $grammarLeadingSpace x ($level+1), "Arguments:";
    say $grammarLeadingSpace x $level, $_->explain($level+2) foreach @{$self->{Arguments}};
    return;
}

sub indent {
    my $self = shift;
    my $body = q();
    $body .= $_->indent foreach (@{$self->{Arguments}});

    # default values of before and after equals
    $self->{beforeEquals}->{body}//=q();
    $self->{afterEquals}->{body}//=q();

    # assemble the body
    $body = $self->{name}                   # key
            .$self->{beforeEquals}->{body}  # 
            .$self->{equals}                # =
            .$self->{afterEquals}->{body}   # 
            .$body                          # body
            .$self->{linebreaksAtEndEnd};   # end
    return $body;
}
1;
