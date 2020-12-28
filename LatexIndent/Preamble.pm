package LatexIndent::Preamble;
use strict;
use warnings;
use feature qw(say);
use LatexIndent::LogFile qw/$grammarLeadingSpace/;

sub explain {
    my ($self, $level) = @_;
    say $grammarLeadingSpace x $level, "Preamble";
    say $grammarLeadingSpace x $level, $_->explain($level+2) foreach @{$self->{Element}};
    return;
}

sub indent {
    my $self = shift;

    my $body = $self->{begin};
    $body .= $_->indent foreach (@{$self->{Arguments}});
    $body .= $_->indent foreach (@{$self->{Element}});

    return $body;
}
1;
