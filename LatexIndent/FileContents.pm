package LatexIndent::FileContents;

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
#	Chris Hughes, 2017-2025
#
#	For all communication, please visit: https://github.com/cmhughes/latexindent.pl
use strict;
use warnings;
use LatexIndent::Tokens          qw/%tokens/;
use LatexIndent::GetYamlSettings qw/%mainSettings/;
use LatexIndent::Switches        qw/$is_t_switch_active $is_tt_switch_active $is_m_switch_active/;
use LatexIndent::LogFile         qw/$logger/;
use LatexIndent::Verbatim        qw/%verbatimStorage/;
use Data::Dumper;
use Exporter qw/import/;
our @EXPORT_OK = qw/find_file_contents_environments_and_preamble/;
our @ISA       = "LatexIndent::Document";                            # class inheritance, Programming Perl, pg 321
our $fileContentsCounter;

sub find_file_contents_environments_and_preamble {
    my $self = shift;

    return if $mainSettings{indentPreamble};

    # store the file contents blocks in an array which, depending on the value
    # of indentPreamble, will be put into the verbatim hash, or otherwise
    # stored as children to be operated upon
    my @fileContentsStorageArray;

    # fileContents environments
    $logger->trace('*Searching for FILE CONTENTS environments (see fileContentsEnvironments)') if $is_t_switch_active;
    $logger->trace( Dumper( \%{ $mainSettings{fileContentsEnvironments} } ) ) if ($is_tt_switch_active);
    while ( my ( $fileContentsEnv, $yesno ) = each %{ $mainSettings{fileContentsEnvironments} } ) {

        if ( !$yesno ) {
            $logger->trace(" *not* looking for $fileContentsEnv as $fileContentsEnv:$yesno");
            next;
        }

        $logger->trace("looking for $fileContentsEnv environments") if $is_t_switch_active;

        # the trailing * needs some care
        if ( $fileContentsEnv =~ m/\*$/ ) {
            $fileContentsEnv =~ s/\*$//;
            $fileContentsEnv .= '\*';
        }

        my $fileContentsRegExp = qr/
                        (
                        \\begin\{
                                ($fileContentsEnv) # environment name captured into $2
                               \}                  # begin statement captured into $1
                        )
                        (
                            .*?                    # non-greedy match (body) into $3
                        )                            
                        (
                        \\end\{\2\}                # end statement captured into $4
                        \h*                        # possible horizontal spaces
                        )                    
                        (\R)?                      # possibly followed by a line break
                    /sx;

        while ( ${$self}{body} =~ m/$fileContentsRegExp/sx ) {

            # create a new Environment object
            my $fileContentsBlock = LatexIndent::FileContents->new(
                begin           => $1,
                body            => $3,
                end             => $4,
                name            => $2,
                linebreaksAtEnd => {
                    begin => 0,
                    body  => 0,
                    end   => $5 ? 1 : 0,
                },
                modifyLineBreaksYamlName => "filecontents",
            );

            # give unique id
            $fileContentsBlock->create_unique_id;

            # text wrapping can make the ID split across lines
            ${$fileContentsBlock}{idRegExp} = ${$fileContentsBlock}{id};

            if ( $is_m_switch_active and ${ $mainSettings{modifyLineBreaks}{textWrapOptions} }{huge} ne "overflow" ) {
                my $IDwithLineBreaks = join( "\\R?\\h*", split( //, ${$fileContentsBlock}{id} ) );
                ${$fileContentsBlock}{idRegExp} = qr/$IDwithLineBreaks/s;
            }

            # the replacement text can be just the ID, but the ID might have a line break at the end of it
            ${$fileContentsBlock}{replacementText} = ${$fileContentsBlock}{id};

            # the above regexp, when used below, will remove the trailing linebreak in ${$self}{linebreaksAtEnd}{end}
            # so we compensate for it here
            $fileContentsBlock->adjust_replacement_text_line_breaks_at_end;

            # store the fileContentsBlock, and determine location afterwards
            push( @fileContentsStorageArray, $fileContentsBlock );

            # log file output
            $logger->trace("*found: ${$fileContentsBlock}{name} \t\ttype FILECONTENTS environment")
                if $is_t_switch_active;

            # remove the environment block, and replace with unique ID
            ${$self}{body} =~ s/$fileContentsRegExp/${$fileContentsBlock}{replacementText}/sx;

            $logger->trace("replaced with ID: ${$fileContentsBlock}{id}") if $is_tt_switch_active;
        }
    }

    # determine if body of document contains \begin{document} -- if it does, then assume
    # that the body has a preamble
    my $preambleRegExp = qr/
                        (
                         .*?
                        )
                        (\R?\h*\\begin\{document\})
                /sx;
    my $preamble = q();

    my $needToStorePreamble = 0;

    # try and find the preamble
    my $lookForPreamble = ${ $mainSettings{lookForPreamble} }{ ${$self}{fileExtension} };
    $lookForPreamble = 1 if ( ${$self}{fileName} eq "-" and ${ $mainSettings{lookForPreamble} }{STDIN} );

    if ( ${$self}{body} =~ m/$preambleRegExp/sx and $lookForPreamble and !$mainSettings{indentPreamble} ) {

        $logger->trace(
            "\\begin{document} found in body (after searching for filecontents)-- assuming that a preamble exists")
            if $is_t_switch_active;

        # create a new Verbatim object
        my $verbatimBlock = LatexIndent::Verbatim->new(
            begin                   => q(),
            body                    => $1,
            end                     => q(),
            name                    => "preamble",
            type                    => "preamble",
            horizontalTrailingSpace => q(),
            linebreaksAtEnd         => {
                begin => q(),
                body  => q(),
                end   => q(),
            },
            afterbit                 => q(),
            modifyLineBreaksYamlName => "preamble",
        );

        # log file output
        $logger->trace("*found: preamble, storing as verbatim (indentPreamble: 0)") if $is_t_switch_active;

        $verbatimBlock->unprotect_blank_lines
            if ( $is_m_switch_active and ${ $mainSettings{modifyLineBreaks} }{preserveBlankLines} );

        # there are common tasks for each of the verbatim objects
        $verbatimBlock->verbatim_common_tasks;

        # verbatim children go in special hash
        $verbatimStorage{ ${$verbatimBlock}{id} } = $verbatimBlock;

        # replace filecontents in preamble body
        foreach (@fileContentsStorageArray) {
            ${$verbatimBlock}{body} =~ s/${$_}{id}/${$_}{begin}${$_}{body}${$_}{end}/s;
        }

        # remove preamble, and replace with unique ID
        ${$self}{body} =~ s/$preambleRegExp/${$verbatimBlock}{replacementText}$2/s;

        # filecontents *not* in preamble
        foreach (@fileContentsStorageArray) {
            ${$self}{body} =~ s/${$_}{id}/${$_}{begin}${$_}{body}${$_}{end}/s;
        }

    }
    else {
        $logger->trace("*preamble not stored, so putting filecontents back in")
            if ( scalar @fileContentsStorageArray > 0 and $is_t_switch_active );
        foreach (@fileContentsStorageArray) {
            $logger->trace("${$_}{name} put back in document") if $is_t_switch_active;
            ${$self}{body} =~ s/${$_}{id}/${$_}{begin}${$_}{body}${$_}{end}/s;
        }
    }

    return;
}

sub create_unique_id {
    my $self = shift;

    $fileContentsCounter++;
    ${$self}{id} = "$tokens{filecontents}$fileContentsCounter$tokens{endOfToken}";
    return;
}

sub tasks_particular_to_each_object {
    my $self = shift;
    return;
}

1;
