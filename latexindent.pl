#!/usr/bin/env perl

use strict;
use warnings;
use FindBin;                   # help find defaultSettings.yaml
use YAML::Tiny;                # interpret defaultSettings.yaml and other potential settings files
use Getopt::Long;              # to get the switches/options/flags
use LatexIndent::Document;
use LatexIndent::Environment;

# get the options
my $overwrite;
my $outputToFile;
my $silentMode;
my $tracingMode;
my $tracingModeVeryDetailed;
my $readLocalSettings=0;
my $onlyDefault;
my $showhelp;
my $cruftDirectory;

GetOptions (
 "overwrite|w"=>\$overwrite,
"outputfile|o:s"=>\$outputToFile,
"silent|s"=>\$silentMode,
"trace|t"=>\$tracingMode,
"ttrace|tt"=>\$tracingModeVeryDetailed,
"local|l:s"=>\$readLocalSettings,
"onlydefault|d"=>\$onlyDefault,
"help|h"=>\$showhelp,
"cruft|c=s"=>\$cruftDirectory,
);

# original name of file
my $fileName = $ARGV[0];

my @mainfile;               # @mainfile: stores input file; used to
my @lines;

open(MAINFILE, $fileName) or die "Could not open input file, $fileName";
while(<MAINFILE>) {
     s/^\t*// if($_ !~ /^((\s*)|(\t*))*$/);
     s/^\s*// if($_ !~ /^((\s*)|(\t*))*$/);
     push(@lines,$_);
   }
close(MAINFILE);
open(MAINFILE, $fileName) or die "Could not open input file, $fileName";
@mainfile=<MAINFILE>;
close(MAINFILE);

print "*-*-*-*-*-*-*-*-*-*-*-*-*-*-\n";
print "*-*-*-*-*-*-*-*-*-*-*-*-*-*-\n";
print "*-*-*-*-*-*-*-*-*-*-*-*-*-*-\n";
my $document = LatexIndent::Document->new(body=>join("",@lines),name=>$fileName);
$document->operate_on_file;

# test cases
# PASS
#   success/environments-simple.tex
#   success/environments-simple-nested.tex
#   success/environments-nested-nested.tex
#   success/environments-one-line.tex
#   success/environments-challenging.tex
#
# Necessary changes from 2.1 to 3.0
#   OLD
#       latexindent.pl -o myfile.tex outputfile.tex
#   NEW
#       latexindent.pl -o outputfile.tex myfile.tex 
#       latexindent.pl -o=outputfile.tex myfile.tex 

exit(0);
