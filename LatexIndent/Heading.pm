package LatexIndent::Heading;

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
use Data::Dumper;
use LatexIndent::Tokens           qw/%tokens/;
use LatexIndent::Switches         qw/$is_m_switch_active $is_t_switch_active $is_tt_switch_active/;
use LatexIndent::TrailingComments qw/$trailingCommentRegExp/;
use LatexIndent::GetYamlSettings  qw/%mainSettings %previouslyFoundSettings/;
use LatexIndent::LogFile          qw/$logger/;
use Exporter                      qw/import/;
our @ISA = "LatexIndent::Document";    # class inheritance, Programming Perl, pg 321
our @EXPORT_OK
    = qw/find_heading construct_headings_levels $allHeadingsRegexp @headingsRegexpArray after_heading_indentation/;
our $headingCounter;
our @headingsRegexpArray;
our $allHeadingsRegexp = q();
our %headingLevelLookUp;

sub construct_headings_levels {
    my $self = shift;

    # grab the heading levels
    my %headingsLevels = %{ $mainSettings{indentAfterHeadings} };

    # output to log file
    $logger->trace("*Constructing headings reg exp for example, chapter, section, etc (see indentAfterThisHeading)")
        if $is_t_switch_active;

    # delete the values that have indentAfterThisHeading set to 0
    while ( my ( $headingName, $headingInfo ) = each %headingsLevels ) {
        if ( !${ $headingsLevels{$headingName} }{indentAfterThisHeading} ) {
            $logger->trace("Not indenting after $headingName (see indentAfterThisHeading)") if $is_t_switch_active;
            delete $headingsLevels{$headingName};
        }
        else {
            # log the heading and level
            $headingLevelLookUp{$headingName} = ${ $headingsLevels{$headingName} }{level};

            # *all heading* regexp, remembering to put starred headings at the front of the regexp
            if ( $headingName =~ m/\*/ ) {
                $logger->trace("Putting $headingName at the beginning of the allHeadings regexp, as it contains a *")
                    if $is_t_switch_active;
                $allHeadingsRegexp = $headingName . ( $allHeadingsRegexp eq '' ? q() : "|$allHeadingsRegexp" );
            }
            else {
                $logger->trace("Putting $headingName at the END of the allHeadings regexp") if $is_t_switch_active;
                $allHeadingsRegexp .= ( $allHeadingsRegexp eq '' ? q() : "|" ) . $headingName;
            }
        }
    }

    # check for a * in the name
    $allHeadingsRegexp =~ s/\*/\\\*/g;

    # sort the file extensions by preference
    my @sortedByLevels = sort { ${ $headingsLevels{$a} }{level} <=> $headingsLevels{$b}{level} } keys(%headingsLevels);

    # it could be that @sortedByLevels is empty;
    return if !@sortedByLevels;

    $logger->trace("All headings regexp: $allHeadingsRegexp")           if $is_t_switch_active;
    $logger->trace("*Now to construct headings regexp for each level:") if $is_t_switch_active;

# loop through the levels, and create a regexp for each (min and max values are the first and last values respectively from sortedByLevels)
    for (
        my $i = ${ $headingsLevels{ $sortedByLevels[0] } }{level};
        $i <= ${ $headingsLevels{ $sortedByLevels[-1] } }{level};
        $i++
        )
    {
        # level regexp
        my @tmp = grep { ${ $headingsLevels{$_} }{level} == $i } keys %headingsLevels;
        if (@tmp) {
            my $headingsAtThisLevel = q();
            foreach (@tmp) {

                # put starred headings at the front of the regexp
                if ( $_ =~ m/\*/ ) {
                    $logger->trace("Putting $_ at the beginning of this regexp (level $i), as it contains a *")
                        if $is_t_switch_active;
                    $headingsAtThisLevel = $_ . ( $headingsAtThisLevel eq '' ? q() : "|$headingsAtThisLevel" );
                }
                else {
                    $logger->trace("Putting $_ at the END of this regexp (level $i)") if $is_t_switch_active;

                    # note: NOT followed by a * (gets escaped next)
                    $headingsAtThisLevel .= ( $headingsAtThisLevel eq '' ? q() : "|" ) . $_ . "(?!*)";
                }
            }

            # make the stars escaped correctly
            $headingsAtThisLevel =~ s/\*/\\\*/g;
            push( @headingsRegexpArray, $headingsAtThisLevel );
            $logger->trace("Heading level regexp for level $i is: $headingsAtThisLevel")
                if $is_t_switch_active;
        }
    }
}

sub find_heading {

    # if there are no headings regexps, there's no point going any further
    return if !@headingsRegexpArray;
    my $self = shift;

    # otherwise loop through the headings regexp
    $logger->trace("*Searching ${$self}{name} for headings with following levels (see indentAfterHeadings)")
        if $is_t_switch_active;
    $logger->trace( Dumper( \%headingLevelLookUp ) ) if $is_t_switch_active;

    # preamble has already been indented, so now make it verbatim
    if ($mainSettings{indentPreamble}){
       $logger->trace("*protecting preamble which can contain headings commands (indentPreamble: 1)");
       $mainSettings{indentPreamble} = 0;
       $self->find_file_contents_environments_and_preamble;
       ${$self}{preambleIndentationWanted} = 1;
    }

    my @bodyParts = &headings_get_body_parts( ${$self}{body} );

    my $newBody = q();
    foreach (@bodyParts) {
        ${$_}{body} = &after_heading_indentation( ${$_}{body}, 0 );
        $newBody .= ${$_}{body};
    }

    # loop through each level of headings, starting at level 0
    ${$self}{body} = $newBody;

    $logger->trace("*headings indentation complete (see indentAfterHeadings)") if $is_t_switch_active;
    $self->put_verbatim_back_in( match => "preamble" ) if ${$self}{preambleIndentationWanted};
}

sub headings_get_body_parts {
    my $body = $_[0];

    # create appropriately headed body parts
    my $index = -1;
    my @bodyParts;
    my $currentHeadingLevel = 0;
    my $headingValue;
    foreach ( split( qr/(\\($allHeadingsRegexp))/, $body ) ) {
        $index++;

        # first entry is *before* heading, so nothing to do
        if ( $index == 0 ) {
            push( @bodyParts, { body => $_ } );
            next;
        }

        # very first match gets appended to first "body part"
        if ( $index == 1 or $index == 3 ) {
            ${ $bodyParts[0] }{body} .= $_;
            next;
        }

        # very first previous heading
        if ( $index == 2 ) {
            ${ $bodyParts[0] }{level} = $headingLevelLookUp{$_};
            next;
        }

        #-------------------
        # heading value
        if ( $index % 3 == 1 ) {
            $headingValue = $_;
            next;
        }

        # heading level
        if ( $index % 3 == 2 ) {
            $currentHeadingLevel = $headingLevelLookUp{$_};
            next;
        }

        if ( $currentHeadingLevel >= ${ $bodyParts[-1] }{level} ) {
            ${ $bodyParts[-1] }{body} .= $headingValue . $_;
        }
        else {
            push( @bodyParts, { body => $headingValue . $_, level => $currentHeadingLevel } );
        }
    }

    return @bodyParts;
}

sub after_heading_indentation {
    my $body         = $_[0];
    my $currentLevel = $_[1];

    return $body unless defined $headingsRegexpArray[$currentLevel];

    my $headingRegExp = qr/(\\($headingsRegexpArray[$currentLevel]))/;

    # skip to the next level if there's no headings at this level
    if ( $body !~ m/$headingRegExp/s ) {
        $currentLevel++;
        $body = &after_heading_indentation( $body, $currentLevel );
        return $body;
    }

    # split body by heading regex
    my @newBody = split( $headingRegExp, $body );

    my $headingValue;
    my $name;
    my $index = -1;
    foreach (@newBody) {
        $index++;

        # first entry is *before* heading, so nothing to do
        next if $index == 0;

        # heading value
        if ( $index % 3 == 1 ) {
            $headingValue = $_;
            next;
        }

        # heading name
        if ( $index % 3 == 2 ) {
            $name = $_;
            $_    = "";
            $logger->trace("*found: $name heading") if $is_t_switch_active;
            next;
        }

        # get (sub) body parts
        my $newBodyPart = $_;

        my @bodyParts = &headings_get_body_parts($_);
        if ( scalar(@bodyParts) > 1 ) {
            $newBodyPart = q();
            my $bodyPartCount = -1;
            foreach my $bodyPart (@bodyParts) {
                $bodyPartCount++;
                $bodyPart = ${$bodyPart}{body};
                $bodyPart = &after_heading_indentation( $bodyPart, 0 ) unless $bodyPartCount == $#bodyParts;
                $newBodyPart .= $bodyPart;
            }
        }

        $_ = $newBodyPart;

        # look for next level heading
        $currentLevel++;
        $_ = &after_heading_indentation( $_, $currentLevel );
        $currentLevel--;

        # heading body indentation
        my $codeBlockObj;
        my $modifyLineBreaksName = "afterHeading";
        if ( !$previouslyFoundSettings{ $name . $modifyLineBreaksName } ) {

            $codeBlockObj = LatexIndent::Blocks->new(
                name                       => $name,
                nameForIndentationSettings => $name,
                modifyLineBreaksYamlName   => $modifyLineBreaksName,
                type                       => "heading",
            );
            if ( defined ${ ${ $mainSettings{indentAfterHeadings} }{$name} }{blocksEndBefore} ) {
                ${$codeBlockObj}{blocksEndBefore}
                    = ${ ${ $mainSettings{indentAfterHeadings} }{$name} }{blocksEndBefore};
            }
            $codeBlockObj->yaml_get_indentation_settings_for_this_object;
        }

        if ( ${ $previouslyFoundSettings{ $name . $modifyLineBreaksName } }{indentation} ne '' ) {
            my $addedIndentation = ${ $previouslyFoundSettings{ $name . $modifyLineBreaksName } }{indentation};

            # some heading blocks end before something specific (see headings-single-line-mod1.tex)
            my @afterBlocksEndBefore = ( q(), q(), q() );
            if ( defined ${ $previouslyFoundSettings{ $name . $modifyLineBreaksName } }{blocksEndBefore} ) {
                @afterBlocksEndBefore
                    = split( qr/(${$previouslyFoundSettings{$name.$modifyLineBreaksName}}{blocksEndBefore})/, $_ );
                $_ = $afterBlocksEndBefore[0];
            }

            # add indentation
            $_ =~ s"^"$addedIndentation"mg;
            $_ =~ s"^$addedIndentation""s;
            $_ =~ s"\R$addedIndentation(\h*)$"\n$1"s;
            $_ .= ( defined $afterBlocksEndBefore[1] ? $afterBlocksEndBefore[1] : q() )
                . ( defined $afterBlocksEndBefore[2] ? $afterBlocksEndBefore[2] : q() );
        }
    }

    $body = join( "", @newBody );
    return $body;
}

1;
