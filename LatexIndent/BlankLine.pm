package LatexIndent::BlankLine;
use strict;
use warnings;
use feature qw(say);
use LatexIndent::LogFile qw/$grammarLeadingSpace/;

sub explain {
    my ($self, $level) = @_;
    say $grammarLeadingSpace x $level, "Blankline(s): ",join("",@{$self->{body}});
    return;
}

sub indent {
    my $self = shift;
    return join("",@{$self->{body}});
  }
1;
