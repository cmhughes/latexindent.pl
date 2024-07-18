#!/usr/bin/env perl
#
#   latexindent.pl, version 3.24.4, 2024-07-18
#
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
use FindBin;         # help find defaultSettings.yaml
use Getopt::Long;    # to get the switches/options/flags

# use lib to make sure that @INC contains the latexindent directory
use lib $FindBin::RealBin;
use LatexIndent::Document;

use utf8;
use Encode qw/ encode decode find_encoding /;

use LatexIndent::LogFile qw/$logger/;
use LatexIndent::UTF8CmdLineArgsFileOperation
  qw/commandlineargs_with_encode @new_args/;

commandlineargs_with_encode();
my $commandlineargs = join( ", ", @ARGV );

# get the options
my %switches = ( readLocalSettings => 0 );

GetOptions(
    "version|v"                 => \$switches{version},
    "vversion|vv"               => \$switches{vversion},
    "silent|s"                  => \$switches{silentMode},
    "trace|t"                   => \$switches{trace},
    "ttrace|tt"                 => \$switches{ttrace},
    "local|l:s"                 => \$switches{readLocalSettings},
    "yaml|y=s"                  => \$switches{yaml},
    "onlydefault|d"             => \$switches{onlyDefault},
    "overwrite|w"               => \$switches{overwrite},
    "overwriteIfDifferent|wd"   => \$switches{overwriteIfDifferent},
    "outputfile|o=s"            => \$switches{outputToFile},
    "modifylinebreaks|m"        => \$switches{modifyLineBreaks},
    "logfile|g=s"               => \$switches{logFileName},
    "help|h"                    => \$switches{showhelp},
    "cruft|c=s"                 => \$switches{cruftDirectory},
    "screenlog|sl"              => \$switches{screenlog},
    "replacement|r"             => \$switches{replacement},
    "onlyreplacement|rr"        => \$switches{onlyreplacement},
    "replacementrespectverb|rv" => \$switches{replacementRespectVerb},
    "check|k"                   => \$switches{check},
    "checkv|kv"                 => \$switches{checkverbose},
    "lines|n=s"                 => \$switches{lines},
    "GCString"                  => \$switches{GCString},
);

$logger = LatexIndent::Logger->new();
our $consoleoutcp;
if ( $FindBin::Script eq 'latexindent.exe' ) {
    require Win32;
    import Win32;

    my $encoding_sys = Win32::GetACP()
      ; #https://stackoverflow.com/a/63868721HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Nls\CodePage
    $consoleoutcp = Win32::GetConsoleOutputCP();
    Win32::SetConsoleOutputCP(65001);

    $logger->info("*ANSI Code Page: $encoding_sys");
    if ( $switches{screenlog} ) {
        print "INFO:  ANSI Code Page:  $encoding_sys\n"
          ;    #The values of ACP in the registry
        print "INFO:  Current console output code page: $consoleoutcp \n";
        print "INFO:  Change the current console output code page to 65001\n";
    }
}

if ( $switches{screenlog} ) {
    $logger->info("*Command line:");
    $logger->info("@new_args");
    $logger->info( "Command line arguments:\n" . $commandlineargs );
    print "INFO:  Command line:\n       @new_args\n";
    print "       Command line arguments:\n       " . $commandlineargs . "\n\n";
}

# conditionally load the GCString module
eval "use Unicode::GCString" if $switches{GCString};

# check local settings doesn't interfere with reading the file;
# this can happen if the script is called as follows:
#
#       latexindent.pl -l myfile.tex
#
# in which case, the GetOptions routine mistakes myfile.tex
# as the optional parameter to the l flag.
#
# In such circumstances, we correct the mistake by assuming that
# the only argument is the file to be indented, and place it in @ARGV
if ( $switches{readLocalSettings} and scalar(@ARGV) < 1 ) {
    push( @ARGV, $switches{readLocalSettings} );
    $switches{readLocalSettings} = '';
}

# allow STDIN as input, if a filename is not present
unshift( @ARGV, '-' ) unless @ARGV;

my $document = bless(
    {
        name                     => "mainDocument",
        modifyLineBreaksYamlName => "mainDocument",
        switches                 => \%switches
    },
    "LatexIndent::Document"
);
$document->latexindent( \@ARGV );

if ( $FindBin::Script eq 'latexindent.exe' ) {
    Win32::SetConsoleOutputCP($consoleoutcp);
    if ( $switches{screenlog} ) {
        print
          "\n\nINFO:  Restore the console output code page: $consoleoutcp\n";
    }
}
exit(0);
