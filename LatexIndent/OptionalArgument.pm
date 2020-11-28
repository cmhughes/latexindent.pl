package LatexIndent::OptionalArgument;
use strict;
use warnings;

sub explain {
    my ($self, $level) = @_;
    $_->explain($level) foreach @{$self->{Element}};
}

sub indent {
    my $self = shift;
    my $body = q();
    $body .= $_->indent foreach @{$self->{Element}};

    # indentation of the body
    $body =~ s/^/\t/mg;

    # remove the first line of indentation, if appropriate
    $body =~ s/^\t//s if !$self->{linebreaksAtEndBegin};

    # assemble the body
    $body = $self->{begin}                   # begin
            .$self->{leadingHorizontalSpace}
            .$self->{linebreaksAtEndBegin}
            .$body                           # body
            .$self->{linebreaksAtEndBody}
            .$self->{end};                   # end
    return $body;
}
1;
