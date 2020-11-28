package LatexIndent::Element;
use strict;
use warnings;
use feature qw(say);
use LatexIndent::Literal;

sub explain {
    my ($self, $level) = @_;
    ($self->{Command} 
      || $self->{Literal}
      || $self->{Environment} )->explain($level)
}

sub indent {
    my $self = shift;
    my $body = ($self->{Command} 
                || $self->{Literal}
                || $self->{Environment})->indent;
    return $body;
}
 
1;
