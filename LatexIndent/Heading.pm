package LatexIndent::Heading;
use strict;
use warnings;
use feature qw(say);
use Exporter qw/import/;
our @EXPORT_OK = qw/$trailingCommentRegExp/;
use LatexIndent::LogFile qw/$grammarLeadingSpace/;

our $trailingCommentRegExp = qr/(?<!\\)%.*?/;

sub explain {
    my ($self, $level) = @_;
    my $body = q();
    $body .= $_->indent foreach (@{$self->{Arguments}});
    $body .= $_->indent foreach (@{$self->{Element}});
    say $grammarLeadingSpace x $level, "Heading ",$self->{begin}.$self->{name}.$body,"\n";
    return;
}

sub indent {
    my $self = shift;

    my $heading;
    $heading  = $self->{begin}.$self->{name};
    $heading .= $_->indent foreach (@{$self->{Arguments}});
    $heading .= $self->{linebreaksAtEndEnd};

    my $body = q();
    $body .= $_->indent foreach (@{$self->{Element}});

    # indentation of the body
    $body =~ s/^/\t/mg;

    return $heading.$body;
  }
1;
