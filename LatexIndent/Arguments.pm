package LatexIndent::Arguments;
use strict;
use warnings;

sub explain {
    my ($self, $level) = @_;
    
    # possible 'between' arguments
    $_->explain($level) foreach (@{$self->{Between}});
    
    # definitely Optional or Mandatory argument
    ($self->{OptionalArg} || $self->{MandatoryArg})->explain($level);
  }

sub indent {
    my $self = shift;

    # initialise the body
    my $body = q();

    # possible 'between' arguments
    $body .= $_->indent foreach (@{$self->{Between}}); 

    # definitely Optional or Mandatory argument
    $body .= ($self->{OptionalArg} || $self->{MandatoryArg})->indent;
    return $body;
  }
1;
