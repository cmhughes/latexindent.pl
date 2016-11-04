package LatexIndent::BlankLines;
use strict;
use warnings;
use Exporter qw/import/;
our @EXPORT_OK = qw/protect_blank_lines unprotect_blank_lines condense_blank_lines get_blank_line_token/;

sub protect_blank_lines{
    my $self = shift;
    return unless $self->is_m_switch_active;

    # grab the settings
    my %masterSettings = %{$self->get_master_settings};
    
    unless(${$masterSettings{modifyLineBreaks}}{preserveBlankLines}){
        $self->logger("Blank lines will not be protected (preserveBlankLines=0)",'heading.trace');
        return
    }

    # get the blank-line-token
    my $blankLineToken = $self->get_blank_line_token;

    $self->logger("Protecting blank lines (see preserveBlankLines)",'heading.trace');
    ${$self}{body} =~ s/^(\h*)?\R/$blankLineToken\n/mg;
    return;
}

sub condense_blank_lines{
    my $self = shift;
    return unless $self->is_m_switch_active;

    # grab the settings
    my %masterSettings = %{$self->get_master_settings};
    return unless ${$masterSettings{modifyLineBreaks}}{condenseMultipleBlankLinesInto}>0;

    # if preserveBlankLines is set to 0, then the blank-line-token will not be present
    # in the document -- we change that here
    if(${$masterSettings{modifyLineBreaks}}{preserveBlankLines}==0){
        # turn the switch on
        ${$masterSettings{modifyLineBreaks}}{preserveBlankLines}=1;

        # log file information
        $self->logger("Updating body to inclued blank line token, this requires preserveBlankLines = 1",'ttrace');
        $self->logger("(any blanklines that could have been removed, would have done so by this point)",'ttrace');

        # make the call
        $self->protect_blank_lines ;
        $self->logger("body now looks like:\n${$self}{body}",'ttrace');
     }

    # grab the value from the settings
    my $condenseMultipleBlankLinesInto = ${$masterSettings{modifyLineBreaks}}{condenseMultipleBlankLinesInto};

    # grab the blank-line-token
    my $blankLineToken = $self->get_blank_line_token;

    # condense!
    $self->logger("Condensing multiple blank lines into $condenseMultipleBlankLinesInto (see condenseMultipleBlankLinesInto)",'heading.trace');
    my $replacementToken = $blankLineToken;
    for (my $i=1; $i<$condenseMultipleBlankLinesInto; $i++ ){
        $replacementToken .= "\n$blankLineToken";
    }

    $self->logger("blank line replacement token: $replacementToken",'ttrace');
    ${$self}{body} =~ s/($blankLineToken\h*\R*\h*){1,}$blankLineToken/$replacementToken/mgs;
    $self->logger("body now looks like:\n${$self}{body}",'ttrace');
    return;
}

sub unprotect_blank_lines{
    my $self = shift;
    return unless $self->is_m_switch_active;

    # grab the settings
    my %masterSettings = %{$self->get_master_settings};
    return unless ${$masterSettings{modifyLineBreaks}}{preserveBlankLines};

    $self->logger("Unprotecting blank lines (see preserveBlankLines)",'heading.trace');
    my $blankLineToken = $self->get_blank_line_token;

    # loop through the body, looking for the blank line token
    while(${$self}{body} =~ m/$blankLineToken/m){
        # when the blank line token occupies the whole line
        if(${$self}{body} =~ m/^\h*$blankLineToken$/m){
            $self->logger("Replacing purely blank lines",'heading.ttrace');
            ${$self}{body} =~ s/^\h*$blankLineToken$//mg;
            $self->logger("body now looks like:\n${$self}{body}",'ttrace');
        }
        # otherwise the blank line has been deleted, so we compensate with an extra
        if(${$self}{body} =~ m/(^\h*)?$blankLineToken/m){
            $self->logger("Replacing blank line token that doesn't take up whole line",'heading.ttrace');
            ${$self}{body} =~ s/(^\h*)?$blankLineToken/$1?"\n".$1:"\n"/me;
            $self->logger("body now looks like:\n${$self}{body}",'ttrace');
        }
    }
    $self->logger("Finished unprotecting lines (see preserveBlankLines)",'heading.trace');
    $self->logger("body now looks like ${$self}{body}",'ttrace');
}

sub get_blank_line_token{
    my $self = shift;
    return ${$self->get_tokens}{blanklines};
}

1;