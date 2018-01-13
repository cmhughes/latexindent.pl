#!/usr/bin/env perl
# a helper script to make the subsitutions for line numbers 
# from defaultSettings.yaml in documentation/latexindent.tex
use strict;
use warnings;

# store the names of each field
my @namesAndOffsets = (
                        {name=>"fileExtensionPreference",numberOfLines=>4},
                        {name=>"logFilePreferences",numberOfLines=>10},
                        {name=>"verbatimEnvironments",numberOfLines=>3},
                        {name=>"verbatimCommands",numberOfLines=>2},
                        {name=>"noIndentBlock",numberOfLines=>2},
                        {name=>"removeTrailingWhitespace",numberOfLines=>2},
                        {name=>"fileContentsEnvironments",numberOfLines=>2},
                        {name=>"lookForPreamble",numberOfLines=>4},
                        {name=>"indentAfterItems",numberOfLines=>4},
                        {name=>"itemNames",numberOfLines=>2},
                        {name=>"specialBeginEnd",numberOfLines=>13,mustBeAtBeginning=>1},
                        {name=>"indentAfterHeadings",numberOfLines=>9},
                        {name=>"noAdditionalIndentGlobalEnv",numberOfLines=>1,special=>"noAdditionalIndentGlobal"},
                        {name=>"noAdditionalIndentGlobal",numberOfLines=>12},
                        {name=>"indentRulesGlobalEnv",numberOfLines=>1,special=>"indentRulesGlobal"},
                        {name=>"indentRulesGlobal",numberOfLines=>12},
                        {name=>"commandCodeBlocks",numberOfLines=>10},
                        {name=>"modifylinebreaks",numberOfLines=>2,special=>"modifyLineBreaks"},
                        {name=>"textWrapOptions",numberOfLines=>1},
                        {name=>"textWrapOptionsAll",numberOfLines=>2,special=>"textWrapOptions"},
                        {name=>"removeParagraphLineBreaks",numberOfLines=>12},
                        {name=>"paragraphsStopAt",numberOfLines=>8},
                        {name=>"oneSentencePerLine",numberOfLines=>21},
                        {name=>"sentencesFollow",numberOfLines=>8},
                        {name=>"sentencesBeginWith",numberOfLines=>3},
                        {name=>"sentencesEndWith",numberOfLines=>5},
                        {name=>"modifylinebreaksEnv",numberOfLines=>9,special=>"environments"},
                      );

# loop through defaultSettings.yaml and count the lines as we go through
my $lineCounter = 1;
open(MAINFILE,"../defaultSettings.yaml");
while(<MAINFILE>){
    # loop through the names and search for a match
    foreach my $thing (@namesAndOffsets){
      my $name = (defined ${$thing}{special} ? ${$thing}{special} : ${$thing}{name} ); 
      my $beginning = (${$thing}{mustBeAtBeginning}? qr/^/ : qr/\h*/);
      ${$thing}{firstLine} = $lineCounter if $_=~m/$beginning$name:/;
    }
    $lineCounter++;
  }
close(MAINFILE);

# store the file
my @lines;
open(MAINFILE,"../documentation/latexindent.tex");
push(@lines,$_) while(<MAINFILE>);
close(MAINFILE);
my $documentationFile = join("",@lines);

# make the substitutions
for (@namesAndOffsets){
    my $firstLine = ${$_}{firstLine}; 
    my $lastLine = $firstLine + ${$_}{numberOfLines}; 
    $documentationFile =~ s/\h*\\lstdefinestyle\{${$_}{name}\}\{\h*\R*
                            	\h*style=yaml-LST,\h*\R*
                            	\h*firstnumber=\d+,linerange=\{\d+-\d+\},\h*\R*
                            	\h*numbers=left,?\h*\R*
                            \h*\}
                          /\\lstdefinestyle\{${$_}{name}\}\{
                            	style=yaml-LST,
                            	firstnumber=$firstLine,linerange=\{$firstLine-$lastLine\},
                            	numbers=left,
                            \}/xs;
}

# overwrite the original file
open(OUTPUTFILE,">","../documentation/latexindent.tex");
print OUTPUTFILE $documentationFile;
close(OUTPUTFILE);

# and operate upon it with latexindent.pl
system('latexindent.pl -w -s -m -l ../documentation/latexindent.tex');
exit; 
