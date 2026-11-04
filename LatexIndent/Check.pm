package LatexIndent::Check;

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
use Exporter              qw/import/;
use LatexIndent::LogFile  qw/$logger/;
use LatexIndent::Switches qw/$is_check_verbose_switch_active/;
our @ISA       = "LatexIndent::Document";    # class inheritance, Programming Perl, pg 321
our @EXPORT_OK = qw/simple_diff/;

sub simple_diff {
    my $self = shift;

    # simple diff...
    $logger->info("*simple diff: (check switch active)");

    # check switch work below here
    if ( ${$self}{originalBody} eq ${$self}{body} ) {
        $logger->info("no differences, no diff to report");
        return;
    }

    # otherwise we loop through the old and new body, and make comparisons;
    # the -1 keeps trailing blank lines, and a final line break common to both is not a line
    my @oldBody = split( "\n", ${$self}{originalBody}, -1 );
    my @newBody = split( "\n", ${$self}{body},         -1 );
    if ( ${$self}{originalBody} =~ m/\n\z/ and ${$self}{body} =~ m/\n\z/ ) {
        pop(@oldBody);
        pop(@newBody);
    }
    my @diff = ();

    # the number of lines in old and new may not be the same (-m, -r, -rr, -rv)
    my $maxLines = ( $#oldBody >= $#newBody ? $#oldBody : $#newBody );

    # loop through to maxLines, accounting for the three scenarios:
    #
    #   oldBody[lineCount] and newBody[lineCount] both defined
    #   oldBody[lineCount] defined and newBody[lineCount] not defined
    #   oldBody[lineCount] not defined and newBody[lineCount] defined
    #
    for ( my $lineCount = 0; $lineCount <= $maxLines; $lineCount++ ) {
        if ( $lineCount <= $#oldBody and $lineCount <= $#newBody ) {
            if ( $oldBody[$lineCount] ne $newBody[$lineCount] ) {
                push( @diff,
                    { old => $oldBody[$lineCount], new => $newBody[$lineCount], lineNumber => $lineCount + 1 } );
            }
        }
        elsif ( $lineCount <= $#oldBody ) {
            push( @diff, { old => $oldBody[$lineCount], lineNumber => $lineCount + 1 } );
        }
        else {
            push( @diff, { new => $newBody[$lineCount], lineNumber => $lineCount + 1 } );
        }
    }

    # ... and this loop combines the diffs into chunks of consecutive line numbers
    my @diffChunks = ();
    foreach (@diff) {

        # start a new chunk at the first diff, and after a gap in the line numbers
        if ( !@diffChunks or ${$_}{lineNumber} > ${ $diffChunks[-1] }{lastLine} + 1 ) {
            push( @diffChunks, { oldLines => [], newLines => [], firstLine => ${$_}{lineNumber} } );
        }
        push( @{ ${ $diffChunks[-1] }{oldLines} }, ${$_}{old} ) if defined ${$_}{old};
        push( @{ ${ $diffChunks[-1] }{newLines} }, ${$_}{new} ) if defined ${$_}{new};
        ${ $diffChunks[-1] }{lastLine} = ${$_}{lineNumber};
    }

    # finally, output the diff chunks
    foreach (@diffChunks) {
        ${$_}{old} = '-' . join( "\n-", @{ ${$_}{oldLines} } );
        ${$_}{new} = '+' . join( "\n+", @{ ${$_}{newLines} } );
        $logger->info("@@ ${$_}{firstLine} -- ${$_}{lastLine} @@");
        $logger->info( ${$_}{old} );
        $logger->info( ${$_}{new} );

        # possibly output to terminal
        if ($is_check_verbose_switch_active) {
            print "\n@@ ${$_}{firstLine} -- ${$_}{lastLine} @@\n";
            print ${$_}{old}, "\n";
            print ${$_}{new}, "\n";
        }
    }
}

1;
