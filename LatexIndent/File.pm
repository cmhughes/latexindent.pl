package LatexIndent::File;
use strict;
use warnings;
use feature qw(say);
use Data::Dumper 'Dumper';
our $leadingSpace = "  ";

sub explain {
    my ($self, $level) = @_;
    for my $element (@{$self->{Element}}) {
        $element->explain($level);
    }
}

sub indent {
    my $self = shift;
    my $body = q();
    $body .= $_->indent foreach @{$self->{Element}};
    return $body;
}
 
1;
