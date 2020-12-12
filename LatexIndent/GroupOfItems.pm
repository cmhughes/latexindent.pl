package LatexIndent::GroupOfItems;
use strict;
use warnings;
use feature qw(say);
use LatexIndent::LogFile qw/$grammarLeadingSpace/;

sub explain {
    my ($self, $level) = @_;
    say $grammarLeadingSpace x $level, "GroupOfItems";
    say $grammarLeadingSpace x $level, $_->explain($level+2) foreach @{$self->{Item}};
    return;
}

sub indent {
    my $self = shift;
    my $body = q();

    print "item headings?...",defined $self->{itemHeading},"\n";
    my $count = 0;
    foreach (@{$self->{Item}}){
        my $itemHeading = ( $count>0 ? ${$self->{itemHeading}}[$count-1]: q());

        ${$_}{itemsPresent} = (defined $self->{itemHeading} ? 1 : 0);
        $body .= $_->indent($itemHeading);
        $count++;
    }

    return $body;
}
1;
