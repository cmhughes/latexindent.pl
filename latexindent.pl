#!/usr/bin/env perl
#   latexindent.pl, version 3.1, 2017-05-27
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
use FindBin;                   # help find defaultSettings.yaml
use Getopt::Long;              # to get the switches/options/flags

# use lib to make sure that @INC contains the latexindent directory
use lib $FindBin::RealBin;
use LatexIndent::Document;

# get the options
my %switches = (readLocalSettings=>0);

GetOptions (
    "silent|s"=>\$switches{silentMode},
    "trace|t"=>\$switches{trace},
    "ttrace|tt"=>\$switches{ttrace},
    "local|l:s"=>\$switches{readLocalSettings},
    "onlydefault|d"=>\$switches{onlyDefault},
    "overwrite|w"=>\$switches{overwrite},
    "outputfile|o=s"=>\$switches{outputToFile},
    "modifylinebreaks|m"=>\$switches{modifyLineBreaks},
    "logfile|g=s"=>\$switches{logFileName},
    "help|h"=>\$switches{showhelp},
    "cruft|c=s"=>\$switches{cruftDirectory},
);

# check local settings doesn't interfer with reading the file;
# this can happen if the script is called as follows:
#
#       latexindent.pl -l myfile.tex
#
# in which case, the GetOptions routine mistakes myfile.tex
# as the optional parameter to the l flag.
#
# In such circumstances, we correct the mistake by assuming that 
# the only argument is the file to be indented, and place it in @ARGV
if($switches{readLocalSettings} and scalar(@ARGV) < 1) {
    push(@ARGV,$switches{readLocalSettings});
    $switches{readLocalSettings} = '';
}

# default value of readLocalSettings
#
#       latexindent -l myfile.tex
#
# means that we wish to use localSettings.yaml
if(defined($switches{readLocalSettings}) and ($switches{readLocalSettings} eq '')){
    $switches{readLocalSettings} = 'localSettings.yaml';
}

my $document = LatexIndent::Document->new(name=>"masterDocument",fileName=>$ARGV[0],switches=>\%switches);
$document->latexindent;
exit(0);
