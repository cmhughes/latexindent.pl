package LatexIndent::NamedGroupingBracesBrackets;
use strict;
use warnings;
use feature qw(say);
use LatexIndent::LogFile qw/$grammarLeadingSpace/;

sub explain {
    my ($self, $level) = @_;
    say $grammarLeadingSpace x $level, "NamedGroupingBracesBrackets";
    say $grammarLeadingSpace x ($level+1), "Name: $self->{name}";
    say $grammarLeadingSpace x $level, $_->explain($level+2) foreach @{$self->{Arguments}};
    return;
}

sub indent {
    my $self = shift;
    my $body = q();
    $body .= $_->indent foreach (@{$self->{Arguments}});

    # assemble the body
    $body = $self->{name}                   # begin
            .$body                          # body
            .$self->{linebreaksAtEndEnd};   # end
    return $body;
}
1;
