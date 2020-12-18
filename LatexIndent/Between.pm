package LatexIndent::Between;
use strict;
use warnings;
use feature qw(say);
use LatexIndent::LogFile qw/$grammarLeadingSpace/;

sub explain {
    my ($self, $level, $label) = @_;
    $label //= 'Between';
    my $body = q();

    if($self->{body}){
        ($body = $self->{body}) =~ s/\R*$//sg;
    }
    else {
        say $grammarLeadingSpace x $level, "$label: (Trailing comment follows)";
        $self->{TrailingComment}->explain($level);
        return;
    }
    say $grammarLeadingSpace x $level, "$label: ", $body;
    return;
}

sub indent {
    my $self = shift;
    return $self->{body} if $self->{body};

    return $self->{TrailingComment}->indent();
}

1;
