package LatexIndent::TrailingComment;
use strict;
use warnings;
use feature qw(say);
use Exporter qw/import/;
our @EXPORT_OK = qw/$trailingCommentRegExp/;
use LatexIndent::LogFile qw/$grammarLeadingSpace/;

our $trailingCommentRegExp = qr/(?<!\\)%.*?/;

sub explain {
    my ($self, $level) = @_;
    say $grammarLeadingSpace x $level, "TrailingComment: ",$self->{begin}.$self->{body};
    return;
}

sub indent {
    my $self = shift;
    return $self->{begin}.$self->{body};
  }
1;
