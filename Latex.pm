package Latex;
use strict;
use warnings;
use feature qw(say);
use Data::Dumper 'Dumper';

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
    say "\t"x$level, "Command:";
    say "\t"x($level+1), "Name: $self->{name}";
 
    for my $arg (@{$self->{MandatoryArgs}}) {
        say "\t"x$level, "\tArg:";
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
    say "\t"x$level, "$label: ", $self->{body};
}
1;
