package LatexIndent::Verbatim;
use strict;
use warnings;
use feature qw(say);
use LatexIndent::LogFile qw/$grammarLeadingSpace/;
use Exporter qw/import/;
our @EXPORT_OK = qw/put_verbatim_back_in/;
our $verbatimCounter = 0;
our $verbatimToken = "LaTeX-Indent-Verbatim";
our @verbatimStorage;

sub explain {
    my ($self, $level) = @_;
    say $grammarLeadingSpace x $level, "Verbatim";
    say $grammarLeadingSpace x ($level+1), "Begin: $self->{begin}";
    say $grammarLeadingSpace x ($level+1), "Name: $self->{name}";
    say $grammarLeadingSpace x ($level+1), "Type: $self->{type}";
    return;
}

sub indent {
    my $self = shift;

    $verbatimCounter++;
    
    my $body = q();
    $body .= ($_->{lead} ? $_->{lead} : q()).$_->indent foreach @{$self->{VerbatimLiteral}};

    # Preamble verbatim won't have the following fields, so set up defaults
    $self->{end}//=q();
    $self->{trailingHorizontalSpace}//=q();
    $self->{linebreaksAtEndEnd}//=q();

    push(@verbatimStorage,
         ({
            id=>$verbatimToken.$verbatimCounter,
            begin=>$self->{begin}.($self->{type} ne 'Preamble: verbatim' ? $self->{name}."}" : q()),
            body=>$body,
            end=>$self->{end}.$self->{trailingHorizontalSpace}.$self->{linebreaksAtEndEnd},
          }));

    return $verbatimToken.$verbatimCounter;   
}

sub put_verbatim_back_in{

    my $self = shift;

    # important:
    #   we loop through the verbatim array in *reverse*
    #   so that the IDs such as, for example,
    #
    #       LaTeX-Indent-Verbatim1
    #
    #   does *not* match to
    #
    #       LaTeX-Indent-Verbatim11
    #   
    ${$self}{body} =~ s/${$_}{id}/${$_}{begin}${$_}{body}${$_}{end}/s foreach(reverse @verbatimStorage);
    return;
}
1;
