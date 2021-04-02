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
      || $self->{Preamble} 
      || $self->{PreambleVerbatim} 
      || $self->{FileContents} 
      || $self->{FileContentsVerbatim} 
      || $self->{Environment} 
      || $self->{EnvironmentStructure} 
      || $self->{BeginsWithBackSlash}
      || $self->{NamedGroupingBracesBrackets} 
      || $self->{Special}
      || $self->{IfElseFi}
      || $self->{Literal}
      || $self->{VerbatimLiteral}
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
                || $self->{Preamble} 
                || $self->{PreambleVerbatim} 
                || $self->{FileContents} 
                || $self->{FileContentsVerbatim} 
                || $self->{Environment}
                || $self->{EnvironmentStructure} 
                || $self->{BeginsWithBackSlash}
                || $self->{NamedGroupingBracesBrackets} 
                || $self->{Special}
                || $self->{IfElseFi}
                || $self->{Literal}
                || $self->{VerbatimLiteral}
                || $self->{TrailingComment}
                || $self->{BlankLine}
                || $self->{Heading}
              )->indent;
    return ($self->{leadingBlankLines}?$self->{leadingBlankLines}:q()).$body;
}
 
1;
