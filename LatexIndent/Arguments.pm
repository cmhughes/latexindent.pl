package LatexIndent::Arguments;
use strict;
use warnings;

sub explain {
    my ($self, $level) = @_;
    
    # possible 'between' arguments
    $self->{Between}->explain($level) if defined $self->{Between}; 
    
    # definitely Optional or Mandatory argument
    ($self->{OptionalArg} || $self->{MandatoryArg})->explain($level);
  }

sub indent {
    my $self = shift;

    # initialise the body
    my $body = q();

    # possible 'between' arguments
    $body .= $self->{Between}->indent if defined $self->{Between}; 

    # definitely Optional or Mandatory argument
    $body .= ($self->{OptionalArg} || $self->{MandatoryArg})->indent;
    return $body;
  }
1;
