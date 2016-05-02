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

open(MAINFILE, $fileName) or die "Could not open input file, $fileName";
@mainfile=<MAINFILE>;
close(MAINFILE);

my $newlines = join("",@mainfile);

my $document = LatexIndent::Document->new(body=>join("",@mainfile));
$document->process_body_of_text;

# print "object type: ",ref($document),"\n";
# print "object children: ",${@{${$document}{children}}[1]}{body},"\n";


exit(0);






my $env = LatexIndent::Environment->new(name=>"hughesy");
print "object type: ",ref($env),"\n";
print "object name: ",${$env}{name},"\n";

my $output = LatexIndent::Environment::cmh($newlines);
bless $output,'LatexIndent::Environment';
#$output = LatexIndent::Environment->new($output);
#my $output = LatexIndent::Environment::cmh($newlines);

#print "body: \n";
print "BEFORE:\n";
print ${$output}{begin},${$output}{body},${$output}{end};
$output->indent;
print "AFTER:\n";
print ${$output}{begin},${$output}{body},${$output}{end};

#$output->LatexIndent::Environment->new;

