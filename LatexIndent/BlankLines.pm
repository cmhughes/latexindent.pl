package LatexIndent::BlankLines;
use strict;
use warnings;
use LatexIndent::Tokens qw/%tokens/;
use LatexIndent::GetYamlSettings qw/%masterSettings/;
use LatexIndent::Switches qw/$is_m_switch_active $is_t_switch_active $is_tt_switch_active/;
use Exporter qw/import/;
our @EXPORT_OK = qw/protect_blank_lines unprotect_blank_lines condense_blank_lines/;

sub protect_blank_lines{
    my $self = shift;
    return unless $is_m_switch_active;

    unless(${$masterSettings{modifyLineBreaks}}{preserveBlankLines}){
        $self->logger("Blank lines will not be protected (preserveBlankLines=0)",'heading.trace');
        return
    }

    $self->logger("Protecting blank lines (see preserveBlankLines)",'heading.trace');
    ${$self}{body} =~ s/^(\h*)?\R/$tokens{blanklines}\n/mg;
    return;
}

sub condense_blank_lines{
    my $self = shift;
    return unless $is_m_switch_active;

    return unless ${$masterSettings{modifyLineBreaks}}{condenseMultipleBlankLinesInto}>0;

    # if preserveBlankLines is set to 0, then the blank-line-token will not be present
    # in the document -- we change that here
    if(${$masterSettings{modifyLineBreaks}}{preserveBlankLines}==0){
        # turn the switch on
        ${$masterSettings{modifyLineBreaks}}{preserveBlankLines}=1;

        # log file information
        $self->logger("Updating body to inclued blank line token, this requires preserveBlankLines = 1",'ttrace') if($is_tt_switch_active);
        $self->logger("(any blanklines that could have been removed, would have done so by this point)",'ttrace') if($is_tt_switch_active);

        # make the call
        $self->protect_blank_lines ;
        $self->logger("body now looks like:\n${$self}{body}",'ttrace') if($is_tt_switch_active);
     }

    # grab the value from the settings
    my $condenseMultipleBlankLinesInto = ${$masterSettings{modifyLineBreaks}}{condenseMultipleBlankLinesInto};

    # grab the blank-line-token
    my $blankLineToken = $tokens{blanklines};

    # condense!
    $self->logger("Condensing multiple blank lines into $condenseMultipleBlankLinesInto (see condenseMultipleBlankLinesInto)",'heading.trace');
    my $replacementToken = $blankLineToken;
    for (my $i=1; $i<$condenseMultipleBlankLinesInto; $i++ ){
        $replacementToken .= "\n$blankLineToken";
    }

    $self->logger("blank line replacement token: $replacementToken",'ttrace') if($is_tt_switch_active);
    ${$self}{body} =~ s/($blankLineToken\h*\R*\h*){1,}$blankLineToken/$replacementToken/mgs;
    $self->logger("body now looks like:\n${$self}{body}",'ttrace') if($is_tt_switch_active);
    return;
}

sub unprotect_blank_lines{
    my $self = shift;
    return unless $is_m_switch_active;

    return unless ${$masterSettings{modifyLineBreaks}}{preserveBlankLines};

    $self->logger("Unprotecting blank lines (see preserveBlankLines)",'heading.trace');
    my $blankLineToken = $tokens{blanklines};

    # loop through the body, looking for the blank line token
    while(${$self}{body} =~ m/$blankLineToken/m){
        # when the blank line token occupies the whole line
        if(${$self}{body} =~ m/^\h*$blankLineToken$/m){
            $self->logger("Replacing purely blank lines",'heading.ttrace');
            ${$self}{body} =~ s/^\h*$blankLineToken$//mg;
            $self->logger("body now looks like:\n${$self}{body}",'ttrace') if($is_tt_switch_active);
        }
        # otherwise the blank line has been deleted, so we compensate with an extra
        if(${$self}{body} =~ m/(^\h*)?$blankLineToken/m){
            $self->logger("Replacing blank line token that doesn't take up whole line",'heading.ttrace');
            ${$self}{body} =~ s/(^\h*)?$blankLineToken/$1?"\n".$1:"\n"/me;
            $self->logger("body now looks like:\n${$self}{body}",'ttrace') if($is_tt_switch_active);
        }
    }
    $self->logger("Finished unprotecting lines (see preserveBlankLines)",'heading.trace');
    $self->logger("body now looks like ${$self}{body}",'ttrace') if($is_tt_switch_active);
}

1;
