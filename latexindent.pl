#!/usr/bin/env perl

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
    #"help|h"=>\$showhelp,
    #"cruft|c=s"=>\$cruftDirectory,
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

my $document = LatexIndent::Document->new(name=>"masterdocument",fileName=>$ARGV[0],switches=>\%switches);
$document->processSwitches;
$document->readSettings;
$document->file_extension_check;
$document->operate_on_file;

# Necessary changes from 2.1 to 3.0
#
# TEST CASES:
#       - on Windows, move defaultSettings.yaml to a different directory
#           and see if logfile is updated correctly

exit(0);
