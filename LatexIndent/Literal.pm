package LatexIndent::Literal;
use strict;
use warnings;
use feature qw(say);
use LatexIndent::LogFile qw/$grammarLeadingSpace/;

sub explain {
    my ($self, $level, $label) = @_;
    $label //= 'Body';
    (my $body = $self->{body}) =~ s/\R*$//sg;
    say $grammarLeadingSpace x $level, "$label: ", $body;
}

sub indent {
    my $self = shift;
    $self->{body} =~ s/\R\h+/\n/sg;
    return $self->{body};
}

 
1;
