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
    ${$self}{name}=${${$self}{Literal}}{body};
    say $leadingSpace x $level, "Command:";
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
    $label //= 'Literal';
    say $leadingSpace x $level, "$label: ", $self->{body};
}

###########################################################
#   UNPACK
###########################################################

sub Latex::file::unpack
{
    my ($self, $level) = @_;
    my $body = q();
    for my $element (@{$self->{Element}}) {
        $body .= $element->unpack($level);
    }
    return $body;
}
 
sub Latex::element::unpack {
    my ($self, $level) = @_;
    my $body = ($self->{Command} || $self->{Literal})->unpack($level);
    return $body;
}
 
sub Latex::command::unpack {
    my ($self, $level) = @_;
    ${$self}{name}=${${$self}{Literal}}{body};
 
    my $body = $self->{begin}.$self->{name};
    for my $arg (@{$self->{MandatoryArgs}}) {
        $body .= $arg->unpack($level+2);
    }
    return $body;
}
 
sub Latex::mandatoryargs::unpack {
    my ($self, $level) = @_;
    my $body = q();
    $body .= $self->{lbrace};
    $body .= $self->{linebreaksAtEndBegin};
    $body .= ($self->{linebreaksAtEndBegin}?"\t":q()).$_->unpack($level) foreach @{$self->{Element}};
    $body .= $self->{rbrace};
    return $body;
}
 
sub Latex::literal::unpack {
    my ($self, $level, $label) = @_;
    $label //= 'Literal';
    return $self->{body};
}
1;
