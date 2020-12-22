package LatexIndent::Verbatim;
use strict;
use warnings;
use feature qw(say);
use LatexIndent::LogFile qw/$grammarLeadingSpace/;

sub explain {
    my ($self, $level) = @_;
    say $grammarLeadingSpace x $level, "Verbatim";
    say $grammarLeadingSpace x ($level+1), "Begin: $self->{begin}";
    say $grammarLeadingSpace x ($level+1), "Name: $self->{name}";
    say $grammarLeadingSpace x ($level+1), "Type: $self->{type}";
    return;
}

sub indent {
    my $self = shift;
    my $body = $self->{body};

    # assemble the body
    $body =  $self->{begin}                   # begin
            .$self->{name}
            ."}"
            .$body                            # body
            .$self->{end}                     # end
            .$self->{trailingHorizontalSpace}
            .$self->{linebreaksAtEndEnd};   
    return $body;
}
1;
