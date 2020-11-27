package Latex;
use strict;
use warnings;
use feature qw(say);
use Data::Dumper 'Dumper';
our $leadingSpace = "  ";

sub Latex::file::explain
{
    my ($self, $level) = @_;
    for my $element (@{$self->{Element}}) {
        $element->explain($level);
    }
}
 
sub Latex::element::explain {
    my ($self, $level) = @_;
    (  $self->{Command} || $self->{Literal})->explain($level)
}
 
sub Latex::command::explain {
    my ($self, $level) = @_;
    say $leadingSpace x $level, "Command:";
    say $leadingSpace x ($level+1), "Begin: $self->{begin}";
    say $leadingSpace x ($level+1), "Name: $self->{name}";
 
    for my $arg (@{$self->{MandatoryArgs}}) {
        say $leadingSpace x $level, $leadingSpace,"Arg:";
        $arg->explain($level+2);
    }
}
 
sub Latex::mandatoryargs::explain {
    my ($self, $level) = @_;
    $_->explain($level) foreach @{$self->{Element}};
}
 
sub Latex::literal::explain {
    my ($self, $level, $label) = @_;
    $label //= 'Body';
    say $leadingSpace x $level, "$label: ", $self->{body};
}

###########################################################
#   UNPACK
###########################################################

sub Latex::file::unpack
{
    my ($self, $level) = @_;
    my $body = q();
    $body .= $_->unpack($level) foreach @{$self->{Element}};
    return $body;
}
 
sub Latex::element::unpack {
    my ($self, $level) = @_;
    my $body = ($self->{Command} || $self->{Literal})->unpack($level);
    return $body;
}
 
sub Latex::command::unpack {
    my ($self, $level) = @_;
    my $body = q();
    $body .= $_->unpack($level+2) foreach (@{$self->{MandatoryArgs}});

    # assemble the body
    $body = $self->{begin}                  # begin
            .$self->{name}
            .$body                          # body
            .$self->{linebreaksAtEndEnd};   # end
    return $body;
}
 
sub Latex::mandatoryargs::unpack {
    my ($self, $level) = @_;
    my $body = q();
    $body .= $_->unpack($level) foreach @{$self->{Element}};

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
 
sub Latex::literal::unpack {
    my ($self, $level, $label) = @_;
    $label //= 'Literal';
    return $self->{body};
}
1;
