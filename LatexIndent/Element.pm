package LatexIndent::Element;
use strict;
use warnings;
use feature qw(say);

sub explain {
    my ($self, $level) = @_;
    ($self->{Command} 
      || $self->{KeyEqualsValuesBraces}
      || $self->{NoIndentBlock} 
      || $self->{Verbatim} 
      || $self->{FileContents} 
      || $self->{Environment} 
      || $self->{NamedGroupingBracesBrackets} 
      || $self->{Special}
      || $self->{IfElseFi}
      || $self->{Literal}
      || $self->{TrailingComment}
      || $self->{BlankLine}
      || $self->{Heading}
    )->explain($level);
    return;
}

sub indent {
    my $self = shift;
    my $body = ($self->{Command} 
                || $self->{KeyEqualsValuesBraces}
                || $self->{NoIndentBlock} 
                || $self->{Verbatim} 
                || $self->{FileContents} 
                || $self->{Environment}
                || $self->{NamedGroupingBracesBrackets} 
                || $self->{Special}
                || $self->{IfElseFi}
                || $self->{Literal}
                || $self->{TrailingComment}
                || $self->{BlankLine}
                || $self->{Heading}
              )->indent;
    return $body;
}
 
1;
