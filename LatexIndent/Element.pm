package LatexIndent::Element;
use strict;
use warnings;
use feature qw(say);
use LatexIndent::Literal;

sub explain {
    my ($self, $level) = @_;
    ($self->{Command} || $self->{Literal})->explain($level)
}

sub indent {
    my $self = shift;
    my $body = ($self->{Command} || $self->{Literal})->indent;
    return $body;
}
 
1;
