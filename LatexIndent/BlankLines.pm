package LatexIndent::BlankLines;
#	This program is free software: you can redistribute it and/or modify
#	it under the terms of the GNU General Public License as published by
#	the Free Software Foundation, either version 3 of the License, or
#	(at your option) any later version.
#
#	This program is distributed in the hope that it will be useful,
#	but WITHOUT ANY WARRANTY; without even the implied warranty of
#	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#	GNU General Public License for more details.
#
#	See http://www.gnu.org/licenses/.
#
#	Chris Hughes, 2017
#
#	For all communication, please visit: https://github.com/cmhughes/latexindent.pl
use strict;
use warnings;
use LatexIndent::Tokens qw/%tokens/;
use LatexIndent::GetYamlSettings qw/%masterSettings/;
use LatexIndent::Switches qw/$is_m_switch_active $is_t_switch_active $is_tt_switch_active/;
use Exporter qw/import/;
our @EXPORT_OK = qw/protect_blank_lines unprotect_blank_lines condense_blank_lines/;

sub protect_blank_lines{
    return unless $is_m_switch_active;
    my $self = shift;

    unless(${$masterSettings{modifyLineBreaks}}{preserveBlankLines}){
        $self->logger("Blank lines will not be protected (preserveBlankLines=0)",'heading') if $is_t_switch_active;
        return
    }

    $self->logger("Protecting blank lines (see preserveBlankLines)",'heading') if $is_t_switch_active;
    ${$self}{body} =~ s/^(\h*)?\R/$tokens{blanklines}\n/mg;
    return;
}

sub condense_blank_lines{
    return unless $is_m_switch_active;

    return unless ${$masterSettings{modifyLineBreaks}}{condenseMultipleBlankLinesInto}>0;

    my $self = shift;

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
    $self->logger("Condensing multiple blank lines into $condenseMultipleBlankLinesInto (see condenseMultipleBlankLinesInto)",'heading') if $is_t_switch_active;
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
    return unless $is_m_switch_active;

    return unless ${$masterSettings{modifyLineBreaks}}{preserveBlankLines};
    my $self = shift;

    $self->logger("Unprotecting blank lines (see preserveBlankLines)",'heading') if $is_t_switch_active;
    my $blankLineToken = $tokens{blanklines};

    # loop through the body, looking for the blank line token
    while(${$self}{body} =~ m/$blankLineToken/s){
        # when the blank line token occupies the whole line
        ${$self}{body} =~ s/^\h*$blankLineToken$//mg;

        # when there's stuff *after* the blank line token
        ${$self}{body} =~ s/(^\h*)$blankLineToken/"\n".$1/meg;

        # when there is stuff before and after the blank line token
        ${$self}{body} =~ s/^(.*?)$blankLineToken\h*(.*?)\h*$/$1."\n".($2?"\n".$2:$2)/meg;

        # when there is only stuff *after* the blank line token
        ${$self}{body} =~ s/^$blankLineToken\h*(.*?)$/$1."\n"/emg;
    }
    $self->logger("Finished unprotecting lines (see preserveBlankLines)",'heading') if $is_t_switch_active;
    $self->logger("body now looks like ${$self}{body}",'ttrace') if($is_tt_switch_active);
}

1;
