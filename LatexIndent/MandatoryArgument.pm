package LatexIndent::MandatoryArgument;
use strict;
use warnings;
use LatexIndent::AlignmentAtAmpersand qw/align_at_ampersand find_aligned_block double_back_slash_else main_formatting individual_padding multicolumn_padding multicolumn_pre_check  multicolumn_post_check dont_measure/;

sub explain {
    my ($self, $level) = @_;
    $_->explain($level) foreach @{$self->{Element}};
}

sub indent {
    my $self = shift;
    my $body = q();
    $body .= $_->indent foreach @{$self->{Element}};

    # indentation of the body
    $body =~ s/^/\t/mg;

    # remove the first line of indentation, if appropriate
    $body =~ s/^\t//s if !$self->{linebreaksAtEndBegin};

    #$self->{lookForAlignDelims}=1;
    #$self->{alignDoubleBackSlash}=1;
    #$self->{spacesBeforeDoubleBackSlash}=1;
    #$self->{multiColumnGrouping}=0;
    #$self->{alignRowsWithoutMaxDelims}=1;
    #$self->{spacesBeforeAmpersand}=1;
    #$self->{spacesAfterAmpersand}=1;
    #$self->{justification}="left";
    #$self->{alignFinalDoubleBackSlash}=0;
    #$self->{dontMeasure}=0;
    #$self->{delimiterRegEx}="(?<!\\\\)(&)";
    #$self->{delimiterJustification}="left";
    #$self->{bodyLineBreaks} = 10;
    #$self->{body} = $body;
    #${${$self}{linebreaksAtEnd}}{begin} =1;

    #$self->align_at_ampersand;
    #print ${$self}{body},"\n";

    # assemble the body
    $body =  $self->{begin}                   # begin
            .$self->{leadingHorizontalSpace}
            .$self->{linebreaksAtEndBegin}
            .$body                           # body
            .$self->{linebreaksAtEndBody}
            .$self->{end}                    # end
            .$self->{horizontalTrailingSpace}
            .$self->{linebreaksAtEndEnd};
    return $body;
}
1;
