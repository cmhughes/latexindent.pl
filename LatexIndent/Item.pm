package LatexIndent::Item;
use strict;
use warnings;
use feature qw(say);
use LatexIndent::LogFile qw/$grammarLeadingSpace/;

sub explain {
    my ($self, $level) = @_;
    say $grammarLeadingSpace x $level, "Item";
    say $grammarLeadingSpace x $level, $_->explain($level+2) foreach @{$self->{Element}};
    return;
}

sub indent {
    my ($self, $itemHeading) = @_;
    my $body = q();

    $body .= $_->indent foreach (@{$self->{Element}});
    return $body unless ${$self}{itemsPresent};

    $body =~ s/^/      /mg;
    $body =~ s/^\h*//s unless $itemHeading =~ m/\R/s;
    $body = $itemHeading.$body;

    return $body;
}
1;
