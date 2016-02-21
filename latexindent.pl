#!/usr/bin/env perl

use strict;
use warnings;
use FindBin;        # help find defaultSettings.yaml
use YAML::Tiny;     # interpret defaultSettings.yaml and other potential settings files

# original name of file
my $fileName = $ARGV[0];

my @mainfile;               # @mainfile: stores input file; used to

open(MAINFILE, $fileName) or die "Could not open input file, $fileName";
@mainfile=<MAINFILE>;
close(MAINFILE);

my $newlines = join("",@mainfile);

if( $newlines =~ m/(.*?)\\begin{(.*?)}(.*)\\end{\2}(.*)/s){
  print "before env: \n",$1,"\n";
  print "environment found: ",$2,"\n";
  print "body: ",$3,"\n";
  print "after env: ",$4,"\n";
  #my $body = $3;
  #my $new;
  #($new = $body) =~ s/^\s*/%%%/gm,"\n";
  #print "new body: \n$new","\n";
  #($new = $body) =~ s/\R/%%%/gm,"\n";
  #print "new body: \n$new","\n";
}

my @arrayOfRefs;
my $match = $1;
push (@arrayOfRefs,\$match);
$match = $2;
push (@arrayOfRefs,\$match);
$match = $3;
push (@arrayOfRefs,\$match);
push (@arrayOfRefs,\$4);
print "\n\n array of references: ",@arrayOfRefs,"\n\n";
print "\n\n references to array: ",\@arrayOfRefs,"\n\n";

#print ${$arrayOfRefs[0]} = "cmh";
print "output of arrayOfRefs:\n";
foreach my $thing (@arrayOfRefs){
    print ${$thing},"\n";
}
#print "\n\n type of thing: ",ref(\@arrayOfRefs),"\n\n";
#print "\n\n type of thing: ",ref($arrayOfRefs[0]),"\n\n";
#print "dereferenced: \n";
#print ${$arrayOfRefs[0]};
#print ${$arrayOfRefs[1]};
#print ${$arrayOfRefs[2]};
#print ${$arrayOfRefs[3]};

exit(0);
