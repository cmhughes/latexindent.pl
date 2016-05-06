#!/usr/bin/env perl

use strict;
use warnings;
use FindBin;        # help find defaultSettings.yaml
use YAML::Tiny;     # interpret defaultSettings.yaml and other potential settings files
use LatexIndent::Document;
use LatexIndent::Environment;

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
my $document = LatexIndent::Document->new(body=>join("",@lines));
$document->process_body_of_text;

# test cases
# PASS
#   success/environments-simple.tex
#   success/environments-simple-nested.tex
#   success/environments-nested-nested.tex
#   success/environments-one-line.tex

exit(0);
