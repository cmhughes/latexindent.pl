#!/usr/bin/env perl
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
#	For details of how to use this file, please see readme.txt

# load packages/modules: assume strict and warnings are part of every perl distribution
use strict;
use warnings;

# list of modules
my @listOfModules = ('FindBin','YAML::Tiny','File::Copy','File::Basename','Getopt::Long','File::HomeDir');

# check the other modules are available
foreach my $moduleName (@listOfModules)
{
    # references:
    #       http://stackoverflow.com/questions/251694/how-can-i-check-if-i-have-a-perl-module-before-using-it
    #       http://stackoverflow.com/questions/1917261/how-can-i-dynamically-include-perl-modules-without-using-eval
    eval {
        (my $file = $moduleName) =~ s|::|/|g;
        require $file . '.pm';
        $moduleName->import();
        1;
    } or die "$moduleName Perl Module not currently installed; please install the module, and then try running latexindent.pl again; exiting";
}

# now that we have confirmed the modules are available, load them
use FindBin;            # help find defaultSettings.yaml
use YAML::Tiny;         # interpret defaultSettings.yaml and other potential settings files
use File::Copy;         # to copy the original file to backup (if overwrite option set)
use File::Basename;     # to get the filename and directory path
use Getopt::Long;       # to get the switches/options/flags
use File::HomeDir;      # to get users home directory, regardless of OS

# get the options
my $overwrite;
my $outputToFile;
my $silentMode;
my $tracingMode;
my $readLocalSettings;
my $onlyDefault;
my $showhelp;
my $cruftDirectory;

GetOptions ("w"=>\$overwrite,
"o"=>\$outputToFile,
"s"=>\$silentMode,
"t"=>\$tracingMode,
"l"=>\$readLocalSettings,
"d"=>\$onlyDefault,
"h"=>\$showhelp,
"c=s"=>\$cruftDirectory,
);

# version number
my $versionNumber = "2.1R";

# Check the number of input arguments- if it is 0 then simply
# display the list of options (like a manual)
if(scalar(@ARGV) < 1 or $showhelp)
{
    print <<ENDQUOTE
latexindent.pl version $versionNumber
usage: latexindent.pl [options] [file][.tex]
      -h  help (see the documentation for detailed instructions and examples)
      -o  output to another file; sample usage
                latexindent.pl -o myfile.tex outputfile.tex
      -w  overwrite the current file- a backup will be made, but still be careful
      -s  silent mode- no output will be given to the terminal
      -t  tracing mode- verbose information given to the log file
      -l  use localSettings.yaml (assuming it exists in the directory of your file)
      -d  ONLY use defaultSettings.yaml, ignore ALL user files
      -c=cruft directory used to specify the location of backup files and indent.log
ENDQUOTE
    ;
    exit(2);
}

# set up default for cruftDirectory using the one from the input file,
# unless it has been specified using -c="/some/directory"
$cruftDirectory=dirname $ARGV[0] unless(defined($cruftDirectory));

die "Could not find directory $cruftDirectory\nExiting, no indentation done." if(!(-d $cruftDirectory));

# we'll be outputting to the logfile and to standard output
my $logfile;
my $out = *STDOUT;

# open the log file
open($logfile,">","$cruftDirectory/indent.log") or die "Can't open indent.log";

# output time to log file
my $time = localtime();
print $logfile $time;

# output version to log file
print $logfile <<ENDQUOTE

$FindBin::Script version $versionNumber, a script to indent .tex files
$FindBin::Script lives here: $FindBin::RealBin/

ENDQUOTE
;

# latexindent.exe is a standalone executable, and caches 
# the required perl modules onto the users system; they will
# only be displayed if the user specifies the trace option
if($FindBin::Script eq 'latexindent.exe' and !$tracingMode )
{
print $logfile <<ENDQUOTE
$FindBin::Script is a standalone script and caches the required perl modules
onto your system. If you'd like to see their location in your log file, indent.log, 
call the script with the tracing option, e.g latexindent.exe -t myfile.tex

ENDQUOTE
;
}

# output location of modules
if($FindBin::Script eq 'latexindent.pl' or ($FindBin::Script eq 'latexindent.exe' and $tracingMode ))
{
    print $logfile "Modules are being loaded from the following directories:\n ";
    foreach my $moduleName (@listOfModules)
    {
            (my $file = $moduleName) =~ s|::|/|g;
            require $file . '.pm';
            print $logfile "\t",$INC{$file .'.pm'},"\n";
          }
}

# cruft directory
print $logfile "Directory for backup files and indent.log: $cruftDirectory\n";

# a quick options check
if($outputToFile and $overwrite)
{
    print $logfile <<ENDQUOTE

WARNING:
\t You have called latexindent.pl with both -o and -w
\t -o (output to file) will take priority, and -w (over write) will be ignored

ENDQUOTE
;
    $overwrite = 0;
}

# can't call the script with MORE THAN 2 files
if(scalar(@ARGV)>2)
{
    for my $fh ($out,$logfile) {print $fh <<ENDQUOTE

ERROR:
\t You're calling latexindent.pl with more than two file names
\t The script can take at MOST two file names, but you
\t need to call it with the -o switch; for example

\t latexindent.pl -o originalfile.tex outputfile.tex

No indentation done :(
Exiting...
ENDQUOTE
    };
    exit(2);
}

# don't call the script with 2 files unless the -o flag is active
if(!$outputToFile and scalar(@ARGV)==2)
{
for my $fh ($out,$logfile) {
print $fh <<ENDQUOTE

ERROR:
\t You're calling latexindent.pl with two file names, but not the -o flag.
\t Did you mean to use the -o flag ?

No indentation done :(
Exiting...
ENDQUOTE
};
    exit(2);
}

# if the script is called with the -o switch, then check that
# a second file is present in the call, e.g
#           latexindent.pl -o myfile.tex output.tex
if($outputToFile and scalar(@ARGV)==1)
{
    for my $fh ($out,$logfile) {print $fh <<ENDQUOTE
ERROR: When using the -o flag you need to call latexindent.pl with 2 arguments

latexindent.pl -o "$ARGV[0]" [needs another name here]

No indentation done :(
Exiting...
ENDQUOTE
};
    exit(2);
}

# Read in defaultSettings.YAML file
my $defaultSettings = YAML::Tiny->new;

# Open defaultSettings.yaml
$defaultSettings = YAML::Tiny->read( "$FindBin::RealBin/defaultSettings.yaml" );
print $logfile "Reading defaultSettings.yaml from $FindBin::RealBin/defaultSettings.yaml\n\n" if($defaultSettings);

# if latexindent.exe is invoked from TeXLive, then defaultSettings.yaml won't be in 
# the same directory as it; we need to navigate to it
if(!$defaultSettings)
{
    $defaultSettings = YAML::Tiny->read( "$FindBin::RealBin/../../texmf-dist/scripts/latexindent/defaultSettings.yaml");
    print $logfile "Reading defaultSettings.yaml (2nd attempt, TeXLive, Windows) from $FindBin::RealBin/../../texmf-dist/scripts/latexindent/defaultSettings.yaml\n\n" if($defaultSettings);
}

# if both of the above attempts have failed, we need to exit
if(!$defaultSettings)
{
  for my $fh ($out,$logfile) {
 print $fh <<ENDQUOTE
 ERROR  There seems to be a yaml formatting error in defaultSettings.yaml
        Please check it for mistakes- you can find a working version at https://github.com/cmhughes/latexindent.pl
        if you would like to overwrite your current version

        Exiting, no indendation done.
ENDQUOTE
};
 exit(2);
}

# setup the DEFAULT variables and hashes from the YAML file

# scalar variables
my $defaultIndent = $defaultSettings->[0]->{defaultIndent};
my $alwaysLookforSplitBraces = $defaultSettings->[0]->{alwaysLookforSplitBraces};
my $alwaysLookforSplitBrackets = $defaultSettings->[0]->{alwaysLookforSplitBrackets};
my $backupExtension = $defaultSettings->[0]->{backupExtension};
my $indentPreamble = $defaultSettings->[0]->{indentPreamble};
my $onlyOneBackUp = $defaultSettings->[0]->{onlyOneBackUp};
my $maxNumberOfBackUps = $defaultSettings->[0]->{maxNumberOfBackUps};
my $removeTrailingWhitespace = $defaultSettings->[0]->{removeTrailingWhitespace};
my $cycleThroughBackUps = $defaultSettings->[0]->{cycleThroughBackUps};

# hash variables
my %lookForAlignDelims= %{$defaultSettings->[0]->{lookForAlignDelims}};
my %indentRules= %{$defaultSettings->[0]->{indentRules}};
my %verbatimEnvironments= %{$defaultSettings->[0]->{verbatimEnvironments}};
my %noIndentBlock= %{$defaultSettings->[0]->{noIndentBlock}};
my %checkunmatched= %{$defaultSettings->[0]->{checkunmatched}};
my %checkunmatchedELSE= %{$defaultSettings->[0]->{checkunmatchedELSE}};
my %checkunmatchedbracket= %{$defaultSettings->[0]->{checkunmatchedbracket}};
my %noAdditionalIndent= %{$defaultSettings->[0]->{noAdditionalIndent}};
my %indentAfterHeadings= %{$defaultSettings->[0]->{indentAfterHeadings}};
my %indentAfterItems= %{$defaultSettings->[0]->{indentAfterItems}};
my %itemNames= %{$defaultSettings->[0]->{itemNames}};
my %constructIfElseFi= %{$defaultSettings->[0]->{constructIfElseFi}};

# need new hashes to store the user and local data before
# overwriting the default
my %lookForAlignDelimsUSER;
my %indentRulesUSER;
my %verbatimEnvironmentsUSER;
my %noIndentBlockUSER;
my %checkunmatchedUSER;
my %checkunmatchedELSEUSER;
my %checkunmatchedbracketUSER;
my %noAdditionalIndentUSER;
my %indentAfterHeadingsUSER;
my %indentAfterItemsUSER;
my %itemNamesUSER;
my %constructIfElseFiUSER;

# for printing the user and local settings to the log file
my %dataDump;

# empty array to store the paths
my @absPaths;

# scalar to read user settings
my $userSettings;

# get information about user settings- first check if indentconfig.yaml exists
my $indentconfig = File::HomeDir->my_home . "/indentconfig.yaml";
# if indentconfig.yaml doesn't exist, check for the hidden file, .indentconfig.yaml
$indentconfig = File::HomeDir->my_home . "/.indentconfig.yaml" if(! -e $indentconfig);

if ( -e $indentconfig and !$onlyDefault )
{
      print $logfile "Reading path information from $indentconfig\n";
      # if both indentconfig.yaml and .indentconfig.yaml exist
      if ( -e File::HomeDir->my_home . "/indentconfig.yaml" and  -e File::HomeDir->my_home . "/.indentconfig.yaml")
      {
            print $logfile File::HomeDir->my_home,"/.indentconfig.yaml has been found, but $indentconfig takes priority\n";
      }
      elsif ( -e File::HomeDir->my_home . "/indentconfig.yaml" )
      {
            print $logfile "Alternatively, ",File::HomeDir->my_home,"/.indentconfig.yaml can be used\n";

      }
      elsif ( -e File::HomeDir->my_home . "/.indentconfig.yaml" )
      {
            print $logfile "Alternatively, ",File::HomeDir->my_home,"/indentconfig.yaml can be used\n";
      }

      # read the absolute paths from indentconfig.yaml
      $userSettings = YAML::Tiny->read( "$indentconfig" );

      # integrity check
      if($userSettings)
      {
        %dataDump = %{$userSettings->[0]};
        print $logfile Dump \%dataDump;
        print $logfile "\n";
        @absPaths = @{$userSettings->[0]->{paths}};
      }
      else
      {
        print $logfile <<ENDQUOTE
WARNING:  $indentconfig
          contains some invalid .yaml formatting- unable to read from it.
          No user settings loaded.
ENDQUOTE
;
      }
}
else
{
      if($onlyDefault)
      {
        print $logfile "Only default settings requested, not reading USER settings from $indentconfig\n";
        print $logfile "Ignoring localSettings.yaml\n" if($readLocalSettings);
        $readLocalSettings = 0;
      }
      else
      {
        # give the user instructions on where to put indentconfig.yaml or .indentconfig.yaml
        print $logfile "Home directory is ",File::HomeDir->my_home,"\n";
        print $logfile "To specify user settings you would put indentconfig.yaml here: \n\t",File::HomeDir->my_home,"/indentconfig.yaml\n\n";
        print $logfile "Alternatively, you can use the hidden file .indentconfig.yaml as: \n\t",File::HomeDir->my_home,"/.indentconfig.yaml\n\n";
      }
}

# get information about LOCAL settings, assuming that localSettings.yaml exists
my $directoryName = dirname $ARGV[0];

# add local settings to the paths, if appropriate
if ( (-e "$directoryName/localSettings.yaml") and $readLocalSettings and !(-z "$directoryName/localSettings.yaml"))
{
    print $logfile "\nAdding $directoryName/localSettings.yaml to paths\n\n";
    push(@absPaths,"$directoryName/localSettings.yaml");
}
elsif ( !(-e "$directoryName/localSettings.yaml") and $readLocalSettings)
{
      print $logfile "WARNING\n\t$directoryName/localSettings.yaml not found\n";
      print $logfile "\tcarrying on without it.\n";
}

# read in the settings from each file
foreach my $settings (@absPaths)
{
  # check that the settings file exists and that it isn't empty
  if (-e $settings and !(-z $settings))
  {
      print $logfile "Reading USER settings from $settings\n";
      $userSettings = YAML::Tiny->read( "$settings" );

      # if we can read userSettings
      if($userSettings)
      {
            # output settings to $logfile
            %dataDump = %{$userSettings->[0]};
            print $logfile Dump \%dataDump;
            print $logfile "\n";

            # scalar variables
            $defaultIndent = $userSettings->[0]->{defaultIndent} if defined($userSettings->[0]->{defaultIndent});
            $alwaysLookforSplitBraces = $userSettings->[0]->{alwaysLookforSplitBraces} if defined($userSettings->[0]->{alwaysLookforSplitBraces});
            $alwaysLookforSplitBrackets = $userSettings->[0]->{alwaysLookforSplitBrackets} if defined($userSettings->[0]->{alwaysLookforSplitBrackets});
            $backupExtension = $userSettings->[0]->{backupExtension} if defined($userSettings->[0]->{backupExtension});
            $indentPreamble = $userSettings->[0]->{indentPreamble} if defined($userSettings->[0]->{indentPreamble});
            $onlyOneBackUp = $userSettings->[0]->{onlyOneBackUp} if defined($userSettings->[0]->{onlyOneBackUp});
            $maxNumberOfBackUps = $userSettings->[0]->{maxNumberOfBackUps} if defined($userSettings->[0]->{maxNumberOfBackUps});
            $removeTrailingWhitespace = $userSettings->[0]->{removeTrailingWhitespace} if defined($userSettings->[0]->{removeTrailingWhitespace});
            $cycleThroughBackUps = $userSettings->[0]->{cycleThroughBackUps} if defined($userSettings->[0]->{cycleThroughBackUps});

            # hash variables - note that each one requires two lines,
            # one to read in the data, one to put the keys&values in correctly

            %lookForAlignDelimsUSER= %{$userSettings->[0]->{lookForAlignDelims}} if defined($userSettings->[0]->{lookForAlignDelims});
            @lookForAlignDelims{ keys %lookForAlignDelimsUSER } = values %lookForAlignDelimsUSER if (%lookForAlignDelimsUSER);

            %indentRulesUSER= %{$userSettings->[0]->{indentRules}} if defined($userSettings->[0]->{indentRules});
            @indentRules{ keys %indentRulesUSER } = values %indentRulesUSER if (%indentRulesUSER);

            %verbatimEnvironmentsUSER= %{$userSettings->[0]->{verbatimEnvironments}} if defined($userSettings->[0]->{verbatimEnvironments});
            @verbatimEnvironments{ keys %verbatimEnvironmentsUSER } = values %verbatimEnvironmentsUSER if (%verbatimEnvironmentsUSER);

            %noIndentBlockUSER= %{$userSettings->[0]->{noIndentBlock}} if defined($userSettings->[0]->{noIndentBlock});
            @noIndentBlock{ keys %noIndentBlockUSER } = values %noIndentBlockUSER if (%noIndentBlockUSER);

            %checkunmatchedUSER= %{$userSettings->[0]->{checkunmatched}} if defined($userSettings->[0]->{checkunmatched});
            @checkunmatched{ keys %checkunmatchedUSER } = values %checkunmatchedUSER if (%checkunmatchedUSER);

            %checkunmatchedbracketUSER= %{$userSettings->[0]->{checkunmatchedbracket}} if defined($userSettings->[0]->{checkunmatchedbracket});
            @checkunmatchedbracket{ keys %checkunmatchedbracketUSER } = values %checkunmatchedbracketUSER if (%checkunmatchedbracketUSER);

            %noAdditionalIndentUSER= %{$userSettings->[0]->{noAdditionalIndent}} if defined($userSettings->[0]->{noAdditionalIndent});
            @noAdditionalIndent{ keys %noAdditionalIndentUSER } = values %noAdditionalIndentUSER if (%noAdditionalIndentUSER);

            %indentAfterHeadingsUSER= %{$userSettings->[0]->{indentAfterHeadings}} if defined($userSettings->[0]->{indentAfterHeadings});
            @indentAfterHeadings{ keys %indentAfterHeadingsUSER } = values %indentAfterHeadingsUSER if (%indentAfterHeadingsUSER);

            %indentAfterItemsUSER= %{$userSettings->[0]->{indentAfterItems}} if defined($userSettings->[0]->{indentAfterItems});
            @indentAfterItems{ keys %indentAfterItemsUSER } = values %indentAfterItemsUSER if (%indentAfterItemsUSER);

            %itemNamesUSER= %{$userSettings->[0]->{itemNames}} if defined($userSettings->[0]->{itemNames});
            @itemNames{ keys %itemNamesUSER } = values %itemNamesUSER if (%itemNamesUSER);

            %constructIfElseFiUSER= %{$userSettings->[0]->{constructIfElseFi}} if defined($userSettings->[0]->{constructIfElseFi});
            @constructIfElseFi{ keys %constructIfElseFiUSER } = values %constructIfElseFiUSER if (%constructIfElseFiUSER);
       }
       else
       {
             # otherwise print a warning that we can not read userSettings.yaml
             print $logfile "WARNING\n\t$settings \n\t contains invalid yaml format- not reading from it\n";
       }

  }
  else
  {
      # otherwise keep going, but put a warning in the log file
      print $logfile "\nWARNING\n\t",File::HomeDir->my_home,"/indentconfig.yaml\n";
      if (-z $settings)
      {
          print $logfile "\tspecifies $settings \n\tbut this file is EMPTY- not reading from it\n\n"
      }
      else
      {
          print $logfile "\tspecifies $settings \n\tbut this file does not exist- unable to read settings from this file\n\n"
      }
  }
}


# if we want to over write the current file
# create a backup first
if ($overwrite)
{
    print $logfile "\nBackup procedure:\n";
    # original name of file
    my $filename = $ARGV[0];

    # get the base file name, allowing for different extensions
    my $backupFile = basename($filename,(".tex",".sty",".cls"));

    # add the user's backup directory to the backup path
    $backupFile = "$cruftDirectory/$backupFile";

    # if both ($onlyOneBackUp and $maxNumberOfBackUps) then we have
    # a conflict- er on the side of caution and turn off onlyOneBackUp
    if($onlyOneBackUp and $maxNumberOfBackUps>1)
    {
        print $logfile "\t WARNING: onlyOneBackUp=$onlyOneBackUp and maxNumberOfBackUps: $maxNumberOfBackUps\n";
        print $logfile "\t\t setting onlyOneBackUp=0 which will allow you to reach $maxNumberOfBackUps back ups\n";
        $onlyOneBackUp = 0;
    }

    # if the user has specified that $maxNumberOfBackUps = 1 then
    # they only want one backup
    if($maxNumberOfBackUps==1)
    {
        $onlyOneBackUp=1 ;
        print $logfile "\t FYI: you set maxNumberOfBackUps=1, so I'm setting onlyOneBackUp: 1 \n";
    }
    elsif($maxNumberOfBackUps<=0 and !$onlyOneBackUp)
    {
#        print $logfile "\t FYI: maxNumberOfBackUps=$maxNumberOfBackUps which won't have any effect\n";
#        print $logfile "\t      on the script- at least ONE backup is made when the -w flag is invoked.\n";
#        print $logfile "\t      I'm setting onlyOneBackUp: 0, which means that you'll get a new back up file \n";
#        print $logfile "\t      every time you run the script.\n";
        $onlyOneBackUp=0 ;
        $maxNumberOfBackUps=-1;
    }

    # if onlyOneBackUp is set, then the backup file will
    # be overwritten each time
    if($onlyOneBackUp)
    {
        $backupFile .= $backupExtension;
        print $logfile "\t copying $filename to $backupFile\n";
        print $logfile "\t $backupFile was overwritten\n\n" if (-e $backupFile);
    }
    else
    {
        # start with a backup file .bak0 (or whatever $backupExtension is present)
        my $backupCounter = 0;
        $backupFile .= $backupExtension.$backupCounter;

        # if it exists, then keep going: .bak0, .bak1, ...
        while (-e $backupFile or $maxNumberOfBackUps>1)
        {
            if($backupCounter==$maxNumberOfBackUps)
            {
                print $logfile "\t maxNumberOfBackUps reached ($maxNumberOfBackUps)\n";

                # some users may wish to cycle through back up files, e.g:
                #    copy myfile.bak1 to myfile.bak0
                #    copy myfile.bak2 to myfile.bak1
                #    copy myfile.bak3 to myfile.bak2
                #
                #    current back up is stored in myfile.bak4
                if($cycleThroughBackUps)
                {
                    print $logfile "\t cycleThroughBackUps detected (see cycleThroughBackUps) \n";
                    for(my $i=1;$i<=$maxNumberOfBackUps;$i++)
                    {
                        # remove number from backUpFile
                        my $oldBackupFile = $backupFile;
                        $oldBackupFile =~ s/$backupExtension.*/$backupExtension/;
                        my $newBackupFile = $oldBackupFile;

                        # add numbers back on
                        $oldBackupFile .= $i;
                        $newBackupFile .= $i-1;

                        # check that the oldBackupFile exists
                        if(-e $oldBackupFile){
                        print $logfile "\t\t copying $oldBackupFile to $newBackupFile \n";
                            copy($oldBackupFile,$newBackupFile) or die "Could not write to backup file $backupFile. Please check permissions. Exiting.\n";
                        }
                    }
                }

                # rest maxNumberOfBackUps
                $maxNumberOfBackUps=1 ;
                last; # break out of the loop
            }
            elsif(!(-e $backupFile))
            {
                $maxNumberOfBackUps=1 ;
                last; # break out of the loop
            }
            print $logfile "\t $backupFile already exists, incrementing by 1...\n";
            $backupCounter++;
            $backupFile =~ s/$backupExtension.*/$backupExtension$backupCounter/;
        }
        print $logfile "\n\t copying $filename to $backupFile\n\n";
    }

    # output these lines to the log file
    print $logfile "\t Backup file: ",$backupFile,"\n";
    print $logfile "\t Overwriting file: ",$filename,"\n\n";
    copy($filename,$backupFile) or die "Could not write to backup file $backupFile. Please check permissions. Exiting.\n";
}

if(!($outputToFile or $overwrite))
{
    print $logfile "Just out put to the terminal :)\n\n" if !$silentMode  ;
}


# scalar variables
my $line;                   # $line: takes the $line of the file
my $inpreamble=!$indentPreamble;
                            # $inpreamble: switch to determine if in
                            #               preamble or not
my $inverbatim=0;           # $inverbatim: switch to determine if in
                            #               a verbatim environment or not
my $delimiters=0;           # $delimiters: switch that governs if
                            #              we need to check for & or not
my $matchedbraces=0;        # $matchedbraces: counter to see if { }
                            #               are matched; it will be
                            #               positive if too many {
                            #               negative if too many }
                            #               0 if matched
my $matchedBRACKETS=0;      # $matchedBRACKETS: counter to see if [ ]
                            #               are matched; it will be
                            #               positive if too many {
                            #               negative if too many }
                            #               0 if matched
my $commandname;            # $commandname: either \parbox, \marginpar,
                            #               or anything else from %checkunmatched
my $commanddetails;         # $command details: a scalar that stores
                            #               details about the command
                            #               that splits {} across lines
my $countzeros;             # $countzeros:  a counter that helps
                            #               when determining if we're in
                            #               an else construct
my $lookforelse=0;          # $lookforelse: a boolean to help determine
                            #               if we need to look for an
                            #               else construct
my $trailingcomments;       # $trailingcomments stores the comments at the end of
                            #           a line
my $lineCounter=0;          # $lineCounter keeps track of the line number
my $inIndentBlock=0;        # $inindentblock: switch to determine if in
                            #               a inindentblock or not
my $headingLevel=0;         # $headingLevel: scalar that stores which heading
                            #               we are under: \part, \chapter, etc

# array variables
my @indent;                 # @indent: stores current level of indentation
my @lines;                  # @lines: stores the newly indented lines
my @block;                  # @block: stores blocks that have & delimiters
my @commandstore;           # @commandstore: stores commands that
                            #           have split {} across lines
my @commandstorebrackets;   # @commandstorebrackets: stores commands that
                            #           have split [] across lines
my @mainfile;               # @mainfile: stores input file; used to
                            #            grep for \documentclass
my @headingStore;           # @headingStore: stores headings: chapter, section, etc
my @indentNames;            # @indentNames: keeps names of commands and
                            #               environments that have caused
                            #               indentation to increase
my @environmentStack;       # @environmentStack: stores the (nested) names
                            #                    of environments

# check to see if the current file has \documentclass, if so, then
# it's the main file, if not, then it doesn't have preamble
open(MAINFILE, $ARGV[0]) or die "Could not open input file";
    @mainfile=<MAINFILE>;
close(MAINFILE);

# if the MAINFILE doesn't have a \documentclass statement, then
# it shouldn't have preamble
if(scalar(@{[grep(m/^\s*\\documentclass/, @mainfile)]})==0)
{
    $inpreamble=0;

    print $logfile "Trace:\tNo documentclass detected, assuming no preamble\n" if($tracingMode);
}
else
{
    print $logfile "Trace:\t documentclass detected, assuming preamble\n" if($tracingMode);
}

# the previous OPEN command puts us at the END of the file
open(MAINFILE, $ARGV[0]) or die "Could not open input file";

# loop through the lines in the INPUT file
while(<MAINFILE>)
{
    # increment the line counter
    $lineCounter++;

    # tracing mode
    print $logfile "\n" if($tracingMode and !($inpreamble or $inverbatim or $inIndentBlock));

    # check to see if we're still in the preamble
    # or in a verbatim environment or in IndentBlock
    if(!($inpreamble or $inverbatim or $inIndentBlock))
    {
        # if not, remove all leading spaces and tabs
        # from the current line, assuming it isn't empty
        #s/^\ *//;
        #s/^\s+//;
        #s/^\t+//;
        s/^\t*// if($_ !~ /^((\s*)|(\t*))*$/);
        s/^\s*// if($_ !~ /^((\s*)|(\t*))*$/);

        # tracing mode
        print $logfile "Line $lineCounter\t removing leading spaces\n" if($tracingMode);
    }
    else
    {
        # otherwise check to see if we've reached the main
        # part of the document
        if(m/^\s*\\begin{document}/)
        {
            $inpreamble = 0;

            # tracing mode
            print $logfile "Line $lineCounter\t \\begin{document} found \n" if($tracingMode);
        }
        else
        {
            # tracing mode
            if($inpreamble)
            {
                print $logfile "Line $lineCounter\t still in PREAMBLE, doing nothing\n" if($tracingMode);
            }
            elsif($inverbatim)
            {
                print $logfile "Line $lineCounter\t in VERBATIM-LIKE environment, doing nothing\n" if($tracingMode);
            }
            elsif($inIndentBlock)
            {
                print $logfile "Line $lineCounter\t in NO INDENT BLOCK, doing nothing\n" if($tracingMode);
            }
        }
    }

    # \END{ENVIRONMENTS}, or CLOSING } or CLOSING ]
    # \END{ENVIRONMENTS}, or CLOSING } or CLOSING ]
    # \END{ENVIRONMENTS}, or CLOSING } or CLOSING ]

    print $logfile "Line $lineCounter\t << PHASE 1: looking for reasons to DECREASE indentation of CURRENT line \n" if($tracingMode);
    # check to see if we have \end{something} or \]
    &at_end_of_env_or_eq() unless ($inpreamble or $inIndentBlock);

    # check to see if we have %* \end{something} for alignment blocks
    # outside of environments
    &end_command_with_alignment();

    # check to see if we're at the end of a noindent
    # block %\end{noindent}
    &at_end_noindent();

    # only check for unmatched braces if we're not in
    # a verbatim-like environment or in the preamble or in a
    # noIndentBlock or in a delimiter block
    if(!($inverbatim or $inpreamble or $inIndentBlock or $delimiters))
    {
        # The check for closing } and ] relies on counting, so
        # we have to remove trailing comments so that any {, }, [, ]
        # that are found after % are not counted
        #
        # note that these lines are NOT in @lines, so we
        # have to store the $trailingcomments to put
        # back on after the counting
        #
        # note the use of (?<!\\)% so that we don't match \%
        if ( $_=~ m/(?<!\\)%.*/)
        {
            s/((?<!\\)%.*)//;
            $trailingcomments=$1;

            # tracing mode
            print $logfile "Line $lineCounter\t Removed trailing comments to count braces and brackets: $1\n" if($tracingMode);
        }

        # check to see if we're at the end of a \parbox, \marginpar
        # or other split-across-lines command and check that
        # we're not starting another command that has split braces (nesting)
        &end_command_or_key_unmatched_braces();

        # check to see if we're at the end of a command that splits
        # [ ] across lines
        &end_command_or_key_unmatched_brackets();

        # check for a heading such as \chapter, \section, etc
        &indent_heading();

        # check for \item
        &indent_item();

        # check for \else or \fi
        &indent_if_else_fi();

        # add the trailing comments back to the end of the line
        if(scalar($trailingcomments))
        {
            # some line break magic, http://stackoverflow.com/questions/881779/neatest-way-to-remove-linebreaks-in-perl
            s/\R//;
            $_ = $_ . $trailingcomments."\n" ;

            # tracing mode
            print $logfile "Line $lineCounter\t counting braces/brackets complete\n" if($tracingMode);
            print $logfile "Line $lineCounter\t Adding trailing comments back on: $trailingcomments\n" if($tracingMode);

            # empty the trailingcomments
            $trailingcomments='';

        }
        # remove trailing whitespace
        if ($removeTrailingWhitespace)
        {
            print $logfile "Line $lineCounter\t removing trailing whitespace (see removeTrailingWhitespace)\n" if ($tracingMode);
            s/\s+$/\n/;
        }
    }

    # ADD CURRENT LEVEL OF INDENTATION
    # ADD CURRENT LEVEL OF INDENTATION
    # ADD CURRENT LEVEL OF INDENTATION
    # (unless we're in a delimiter-aligned block)
    if(!$delimiters)
    {
        # make sure we're not in a verbatim block or in the preamble
        if($inverbatim or $inpreamble or $inIndentBlock)
        {
           # just push the current line as is
           push(@lines,$_);
        }
        else
        {
            # add current value of indentation to the current line
            # and output it
            # unless this would only create trailing whitespace and the
            # corresponding option is set
            unless ($_ =~ m/^$/ and $removeTrailingWhitespace){
                $_ = join("",@indent).$_;
            }
            push(@lines,$_);
            # tracing mode
            print $logfile "Line $lineCounter\t || PHASE 2: Adding current level of indentation: ",join(", ",@indentNames),"\n" if($tracingMode);
        }
    }
    else
    {
        # output to @block if we're in a delimiter block
        push(@block,$_);

        # tracing mode
        print $logfile "Line $lineCounter\t In delimeter block, waiting for block formatting\n" if($tracingMode);
    }

    # \BEGIN{ENVIRONMENT} or OPEN { or OPEN [
    # \BEGIN{ENVIRONMENT} or OPEN { or OPEN [
    # \BEGIN{ENVIRONMENT} or OPEN { or OPEN [

    # only check for new environments or commands if we're
    # not in a verbatim-like environment or in the preamble
    # or in a noIndentBlock, or delimiter block
    if(!($inverbatim or $inpreamble or $inIndentBlock or $delimiters))
    {

        print $logfile "Line $lineCounter\t >> PHASE 3: looking for reasons to INCREASE indentation of SUBSEQUENT lines \n" if($tracingMode);

        # check if we are in a
        #   % \begin{noindent}
        # block; this is similar to a verbatim block, the user
        # may not want some blocks of code to be touched
        #
        # IMPORTANT: this needs to go before the trailing comments
        # are removed!
        &at_beg_noindent();

        # check for
        #   %* \begin{tabular}
        # which might be used to align blocks that contain delimeters that
        # are NOT contained in an alignment block in the usual way, e.g
        #   \matrix{
        #       %* \begin{tabular}
        #           1 & 2 \\
        #           3 & 4 \\
        #       %* \end{tabular}
        #           }
        &begin_command_with_alignment();

        # remove trailing comments so that any {, }, [, ]
        # that are found after % are not counted
        #
        # note that these lines are already in @lines, so we
        # can remove the trailing comments WITHOUT having
        # to put them back in
        #
        # Note that this won't match \%
        s/(?<!\\)%.*// if( $_=~ m/(?<!\\)%.*/);

        # tracing mode
        print $logfile "Line $lineCounter\t Removing trailing comments for brace count (line is already stored)\n" if($tracingMode);

        # check to see if we have \begin{something} or \[
        &at_beg_of_env_or_eq();

        # check to see if we have \parbox, \marginpar, or
        # something similar that might split braces {} across lines,
        # specified in %checkunmatched hash table
        &start_command_or_key_unmatched_braces();

        # check for an else statement (braces, not \else)
        &check_for_else();

        # check for a command that splits [] across lines
        &start_command_or_key_unmatched_brackets();

        # check for a heading
        &indent_after_heading();

        # check for \item
        &indent_after_item();

        # check for \if or \else command
        &indent_after_if_else_fi();

        # tracing mode
        print $logfile "Line $lineCounter\t Environments: ",join(", ",@environmentStack),"\n" if($tracingMode and scalar(@environmentStack));
    }
}

# close the main file
close(MAINFILE);

# put line count information in the log file
print $logfile "Line Count of $ARGV[0]: ",scalar(@mainfile),"\n";
print $logfile "Line Count of indented $ARGV[0]: ",scalar(@lines);
if(scalar(@mainfile) != scalar(@lines))
{
  print $logfile <<ENDQUOTE
WARNING: \t line count of original file and indented file does
\t not match- consider reverting to a back up, see $backupExtension;
ENDQUOTE
;
}
else
{
    print $logfile "\n\nLine counts of original file and indented file match";
}

# output the formatted lines to the terminal
print @lines if(!$silentMode);

# if -w is active then output to $ARGV[0]
if($overwrite)
{
    open(OUTPUTFILE,">",$ARGV[0]);
    print OUTPUTFILE @lines;
    close(OUTPUTFILE);
}

# if -o is active then output to $ARGV[1]
if($outputToFile)
{
    open(OUTPUTFILE,">",$ARGV[1]);
    print OUTPUTFILE @lines;
    close(OUTPUTFILE);
}

# close the log file
close($logfile);

exit;

sub indent_if_else_fi{
    # PURPOSE: set indentation of line that contains \else, \fi  command
    #
    #

    # @indentNames could be empty -- if so, exit
    return 0 unless(@indentNames);

    # look for \fi
    if( $_ =~ m/^\s*\\fi/ and $constructIfElseFi{$indentNames[-1]})
    {
        # tracing mode
        print $logfile "Line $lineCounter\t \\fi command found, matching: \\",$indentNames[-1], "\n" if($tracingMode);
        &decrease_indent($indentNames[-1]);
    }
    elsif( ($_ =~ m/^\s*\\else/ or $_ =~ m/^\s*\\or/) and $constructIfElseFi{$indentNames[-1]})
    {
        # tracing mode
        print $logfile "Line $lineCounter\t \\else command found, matching: \\",$indentNames[-1], "\n" if($tracingMode);
        print $logfile "Line $lineCounter\t decreasing indent, but indentNames is still  \\",join(", ",@indentNames), "\n" if($tracingMode);
        pop(@indent);
    }
}

sub indent_after_if_else_fi{
    # PURPOSE: set indentation *after* \if construct such as
    #
    #               \ifnum\x=2
    #                   <stuff>
    #                   <stuff>
    #               \else
    #                   <stuff>
    #                   <stuff>
    #               \fi
    #
    #   How to read /^\s*\\(if.*?)(\s|\\|\#)
    #
    #       ^\s*        begins with multiple spaces (possibly none)
    #       \\(if.*?)(\s|\\|\#)   matches \if... up to either a
    #                             space, a \, or a #
    if( $_ =~ m/^\s*\\(if.*?)(\s|\\|\#)/ and $constructIfElseFi{$1})
    {
        # tracing mode
        print $logfile "Line $lineCounter\t ifelsefi construct found: $1 \n" if($tracingMode);
        &increase_indent($1);
    }
    elsif(@indentNames)
    {
        if( ($_ =~ m/^\s*\\else/ or $_ =~ m/^\s*\\or/ ) and $constructIfElseFi{$indentNames[-1]})
        {
            # tracing mode
            print $logfile "Line $lineCounter\t setting indent *after* \\else or \\or command found for $indentNames[-1] \n" if($tracingMode);
            &increase_indent($indentNames[-1]);
            # don't want to store the name of the \if construct twice
            # so remove the second copy
            pop(@indentNames);
        }
  }
  }

sub indent_item{
    # PURPOSE: this subroutine sets the indentation for the item *itself*

    if( $_ =~ m/^\s*\\(.*?)(\[|\s)/ and $itemNames{$1} and $indentAfterItems{$environmentStack[-1]})
    {
        # tracing mode
        print $logfile "Line $lineCounter\t $1 found within ",$environmentStack[-1]," environment (see indentAfterItems and itemNames)\n" if($tracingMode);
        if($itemNames{$indentNames[-1]})
        {
            print $logfile "Line $lineCounter\t $1 found- neutralizing indentation from previous ",$indentNames[-1],"\n" if($tracingMode);
            &decrease_indent($1);
        }
    }

}

sub indent_after_item{
    # PURPOSE: Set the indentation *after* the item
    #          This matches a line that begins with
    #
    #               \item
    #               \item[
    #               \myitem
    #               \myitem[
    #
    #           or anything else specified in itemNames
    #
    if( $_ =~ m/^\s*\\(.*?)(\[|\s)/
            and $itemNames{$1}
            and $indentAfterItems{$environmentStack[-1]})
    {
        # tracing mode
        print $logfile "Line $lineCounter\t $1 found within ",$environmentStack[-1]," environment (see indentAfterItems and itemNames)\n" if($tracingMode);
        &increase_indent($1);
    }
}
sub begin_command_with_alignment{
    # PURPOSE: This matches
    #           %* \begin{tabular}
    #          with any number of spaces (possibly none) between
    #          the * and \begin{noindent}.
    #
    #          the comment symbol IS indended!
    #
    #          This is to align blocks that contain delimeters that
    #          are NOT contained in an alignment block in the usual way, e.g
    #             \matrix{
    #                 %* \begin{tabular}
    #                     1 & 2 \\
    #                     3 & 4 \\
    #                 %* \end{tabular}
    #                     }

    if( $_ =~ m/^\s*%\*\s*\\begin{(.*?)}/ and $lookForAlignDelims{$1})
    {
           $delimiters=1;
           # tracing mode
           print $logfile "Line $lineCounter\t Delimiter environment started: $1 (see lookForAlignDelims)\n" if($tracingMode);
    }
}

sub end_command_with_alignment{
    # PURPOSE: This matches
    #           %* \end{tabular}
    #          with any number of spaces (possibly none) between
    #          the * and \end{tabular} (or any other name used from
    #          lookFroAlignDelims)
    #
    #          Note: the comment symbol IS indended!
    #
    #          This is to align blocks that contain delimeters that
    #          are NOT contained in an alignment block in the usual way, e.g
    #             \matrix{
    #                 %* \begin{tabular}
    #                     1 & 2 \\
    #                     3 & 4 \\
    #                 %* \end{tabular}
    #                     }

    if( $_ =~ m/^\s*%\*\s*\\end{(.*?)}/ and $lookForAlignDelims{$1})
    {
        # same subroutine used at the end of regular tabular, align, etc
        # environments
        if($delimiters)
        {
            &print_aligned_block();
        }
        else
        {
            # tracing mode
            print $logfile "Line $lineCounter\t FYI: did you mean to start a delimiter block on a previous line? \n" if($tracingMode);
            print $logfile "Line $lineCounter\t      perhaps using %* \\begin{$1}\n" if($tracingMode);
        }
    }
}

sub indent_heading{
    # PURPOSE: This matches
    #           \part
    #           \chapter
    #           \section
    #           \subsection
    #           \subsubsection
    #           \paragraph
    #           \subparagraph
    #
    #           and anything else listed in indentAfterHeadings
    #
    #           This subroutine specifies the indentation for the
    #           heading itself, i.e the line that has \chapter, \section etc
    if( $_ =~ m/^\s*\\(.*?)(\[|{)/ and $indentAfterHeadings{$1})
    {
       # tracing mode
       print $logfile "Line $lineCounter\t Heading found: $1 \n" if($tracingMode);

       # get the heading settings- it's a hash within a hash
       my %currentHeading = %{$indentAfterHeadings{$1}};

       # local scalar
       my $previousHeadingLevel = $headingLevel;

       # if current heading level < old heading level,
       if($currentHeading{level}<$previousHeadingLevel)
       {
            # decrease indentation, but only if
            # specified in indentHeadings. Note that this check
            # needs to be done here- decrease_indent won't
            # check a nested hash

            if(scalar(@headingStore))
            {
               while($currentHeading{level}<$previousHeadingLevel and scalar(@headingStore))
               {
                    my $higherHeadingName = pop(@headingStore);
                    my %higherLevelHeading = %{$indentAfterHeadings{$higherHeadingName}};

                    # tracing mode
                    print $logfile "Line $lineCounter\t stepping UP heading level from $higherHeadingName \n" if($tracingMode);

                    &decrease_indent($higherHeadingName) if($higherLevelHeading{indent});
                    $previousHeadingLevel=$higherLevelHeading{level};
               }
               # put the heading name back in to storage
               push(@headingStore,$1);
            }
       }
       elsif($currentHeading{level}==$previousHeadingLevel)
       {
            if(scalar(@headingStore))
            {
                 my $higherHeadingName = pop(@headingStore);
                 my %higherLevelHeading = %{$indentAfterHeadings{$higherHeadingName}};
                 &decrease_indent($higherHeadingName) if($higherLevelHeading{indent});
            }
            # put the heading name back in to storage
            push(@headingStore,$1);
       }
       else
       {
            # put the heading name into storage
            push(@headingStore,$1);
       }
    }
}

sub indent_after_heading{
    # PURPOSE: This matches
    #           \part
    #           \chapter
    #           \section
    #           \subsection
    #           \subsubsection
    #           \paragraph
    #           \subparagraph
    #
    #           and anything else listed in indentAfterHeadings
    #
    #           This subroutine is specifies the indentation for
    #           the text AFTER the heading, i.e the body of conent
    #           in each \chapter, \section, etc
    if( $_ =~ m/^\s*\\(.*?)(\[|{)/ and $indentAfterHeadings{$1})
    {
       # get the heading settings- it's a hash within a hash
       my %currentHeading = %{$indentAfterHeadings{$1}};

       &increase_indent($1) if($currentHeading{indent});

       # update heading level
       $headingLevel = $currentHeading{level};
    }
}



sub at_end_noindent{
    # PURPOSE: This matches
    #           % \end{noindent}
    #          with any number of spaces (possibly none) between
    #          the comment and \end{noindent}.
    #
    #          the comment symbol IS indended!
    #
    #          This is for blocks of code that the user wants
    #          to leave untouched- similar to verbatim blocks

    if( $_ =~ m/^%\s*\\end{(.*?)}/ and $noIndentBlock{$1})
    {
            $inIndentBlock=0;
            # tracing mode
            print $logfile "Line $lineCounter\t % \\end{no indent block} found, switching inIndentBlock OFF \n" if($tracingMode);
    }
}



sub at_beg_noindent{
    # PURPOSE: This matches
    #           % \begin{noindent}
    #          with any number of spaces (possibly none) between
    #          the comment and \begin{noindent}.
    #
    #          the comment symbol IS indended!
    #
    #          This is for blocks of code that the user wants
    #          to leave untouched- similar to verbatim blocks

    if( $_ =~ m/^%\s*\\begin{(.*?)}/ and $noIndentBlock{$1})
    {
           $inIndentBlock = 1;
           # tracing mode
           print $logfile "Line $lineCounter\t % \\begin{no indent block} found, switching inIndentBlock ON \n" if($tracingMode);
    }
}

sub start_command_or_key_unmatched_brackets{
    # PURPOSE: This matches
    #              \pgfplotstablecreatecol[...
    #
    #              or any other command/key that has brackets [ ]
    #              split across lines specified in the
    #              hash tables, %checkunmatchedbracket
    #
    # How to read: ^\s*(\\)?(.*?)(\[\s*)
    #
    #       ^       line begins with
    #       \s*     any (or no)spaces
    #       (\\)?   matches a \ backslash but not necessarily
    #       (.*?)   non-greedy character match and store the result
    #       ((?<!\\)\[\s*) match [ possibly leading with spaces
    #                      but it WON'T match \[

    if ($_ =~ m/^\s*(\\)?(.*?)(\s*(?<!\\)\[)/
        and (scalar($checkunmatchedbracket{$2})
             or $alwaysLookforSplitBrackets)
        )
        {
            # store the command name, because $2
            # will not exist after the next match
            $commandname = $2;
            $matchedBRACKETS=0;

            # match [ but don't match \[
            $matchedBRACKETS++ while ($_ =~ /(?<!\\)\[/g);
            # match ] but don't match \]
            $matchedBRACKETS-- while ($_ =~ /(?<!\\)\]/g);

            # set the indentation
            if($matchedBRACKETS != 0 )
            {
                  # tracing mode
                  print $logfile "Line $lineCounter\t Found opening BRACKET [ $commandname\n" if($tracingMode);

                  &increase_indent($commandname);

                  # store the command name
                  # and the value of $matchedBRACKETS
                  push(@commandstorebrackets,{commandname=>$commandname,
                                      matchedBRACKETS=>$matchedBRACKETS});

            }
        }
}

sub end_command_or_key_unmatched_brackets{
    # PURPOSE:  Check for the closing BRACKET of a command that
    #           splits its BRACKETS across lines, such as
    #
    #               \pgfplotstablecreatecol[ ...
    #
    #           It works by checking if we have any entries
    #           in the array @commandstorebrackets, and making
    #           sure that we're not starting another command/key
    #           that has split BRACKETS (nesting).
    #
    #           It also checks that the line is not commented.
    #
    #           We count the number of [ and ADD to the counter
    #                                  ] and SUBTRACT to the counter
    if(scalar(@commandstorebrackets)
        and  !($_ =~ m/^\s*(\\)?(.*?)(\s*\[)/
                    and (scalar($checkunmatchedbracket{$2})
                         or $alwaysLookforSplitBrackets))
        and $_ !~ m/^\s*%/
       )
    {
       # get the details of the most recent command name
       $commanddetails = pop(@commandstorebrackets);
       $commandname = $commanddetails->{'commandname'};
       $matchedBRACKETS = $commanddetails->{'matchedBRACKETS'};

       # match [ but don't match \[
       $matchedBRACKETS++ while ($_ =~ m/(?<!\\)\[/g);

       # match ] but don't match \]
       $matchedBRACKETS-- while ($_ =~ m/(?<!\\)\]/g);

       # if we've matched up the BRACKETS then
       # we can decrease the indent by 1 level
       if($matchedBRACKETS == 0)
       {
            # tracing mode
            print $logfile "Line $lineCounter\t Found closing BRACKET ] $commandname\n" if($tracingMode);

            # decrease the indentation (if appropriate)
            &decrease_indent($commandname);
       }
       else
       {
           # otherwise we need to enter the new value
           # of $matchedBRACKETS and the value of $command
           # back into storage
           push(@commandstorebrackets,{commandname=>$commandname,
                                       matchedBRACKETS=>$matchedBRACKETS});
           # tracing mode
           print $logfile "Line $lineCounter\t Searching for closing BRACKET ] $commandname\n" if($tracingMode);
       }
     }
}

sub start_command_or_key_unmatched_braces{
    # PURPOSE: This matches
    #              \parbox{...
    #              \parbox[..]..{
    #              empty header/.style={
    #              \foreach \something
    #              etc
    #
    #              or any other command/key that has BRACES
    #              split across lines specified in the
    #              hash tables, %checkunmatched, %checkunmatchedELSE
    #
    # How to read: ^\s*(\\)?(.*?)(\[|{|\s)
    #
    #       ^                  line begins with
    #       \s*                any (or no) spaces
    #       (\\)?              matches a \ backslash but not necessarily
    #       (.*?)              non-greedy character match and store the result
    #       (\[|}|=|(\s*\\))   either [ or { or = or space \

    if ($_ =~ m/^\s*(\\)?(.*?)(\[|{|=|(\s*\\))/
            and (scalar($checkunmatched{$2})
                 or scalar($checkunmatchedELSE{$2})
                 or $alwaysLookforSplitBraces)
        )
        {
            # store the command name, because $2
            # will not exist after the next match
            $commandname = $2;
            $matchedbraces=0;

            # by default, don't look for an else construct
            $lookforelse=0;
            if(scalar($checkunmatchedELSE{$2}))
            {
                $lookforelse=1;
            }

            # match { but don't match \{
            $matchedbraces++ while ($_ =~ /(?<!\\){/g);

            # match } but don't match \}
            $matchedbraces-- while ($_ =~ /(?<!\\)}/g);

            # tracing mode
            print $logfile "Line $lineCounter\t matchedbraces = $matchedbraces\n" if($tracingMode);

            # set the indentation
            if($matchedbraces > 0 )
            {
                  # tracing mode
                  print $logfile "Line $lineCounter\t Found opening BRACE { $commandname\n" if($tracingMode);

                  &increase_indent($commandname);

                  # store the command name
                  # and the value of $matchedbraces
                  push(@commandstore,{commandname=>$commandname,
                                      matchedbraces=>$matchedbraces,
                                      lookforelse=>$lookforelse,
                                      countzeros=>0});

            }
            elsif($matchedbraces<0)
            {
                # if $matchedbraces < 0 then we must be matching
                # braces from a previous split-braces command

                # keep matching { OR }, and don't match \{ or \}
                while ($_ =~ m/(((?<!\\){)|((?<!\\)}))/g)
                {

                     # store the match, either { or }
                     my $braceType = $1;

                     # exit the loop if @commandstore is empty
                     last if(!@commandstore);

                     # get the details of the most recent command name
                     $commanddetails = pop(@commandstore);
                     $commandname = $commanddetails->{'commandname'};
                     $matchedbraces = $commanddetails->{'matchedbraces'};
                     $countzeros = $commanddetails->{'countzeros'};
                     $lookforelse= $commanddetails->{'lookforelse'};

                     $matchedbraces++ if($1 eq "{");
                     $matchedbraces-- if($1 eq "}");

                     # if we've matched up the braces then
                     # we can decrease the indent by 1 level
                     if($matchedbraces == 0)
                     {
                          $countzeros++ if $lookforelse;

                          # tracing mode
                          print $logfile "Line $lineCounter\t Found closing BRACE } $1\n" if($tracingMode);

                          # decrease the indentation (if appropriate)
                          &decrease_indent($commandname);

                         if($countzeros==1)
                         {
                              push(@commandstore,{commandname=>$commandname,
                                                  matchedbraces=>$matchedbraces,
                                                  lookforelse=>$lookforelse,
                                                  countzeros=>$countzeros});
                         }
                     }
                     else
                     {
                            # otherwise we need to put the command back for the
                            # next brace count
                            push(@commandstore,{commandname=>$commandname,
                                                matchedbraces=>$matchedbraces,
                                                lookforelse=>$lookforelse,
                                                countzeros=>$countzeros});
                     }
                }
            }
        }
}

sub end_command_or_key_unmatched_braces{
    # PURPOSE:  Check for the closing BRACE of a command that
    #           splits its BRACES across lines, such as
    #
    #               \parbox{ ...
    #
    #           or one of the tikz keys, such as
    #
    #              empty header/.style={
    #
    #           It works by checking if we have any entries
    #           in the array @commandstore, and making
    #           sure that we're not starting another command/key
    #           that has split BRACES (nesting).
    #
    #           It also checks that the line is not commented.
    #
    #           We count the number of { and ADD to the counter
    #                                  } and SUBTRACT to the counter
    if(scalar(@commandstore)
      and  !($_ =~ m/^\s*(\\)?(.*?)(\[|{|=|(\s*\\))/
                    and (scalar($checkunmatched{$2})
                         or scalar($checkunmatchedELSE{$2})
                         or $alwaysLookforSplitBraces))
        and $_ !~ m/^\s*%/
       )
    {
       # keep matching { OR }, and don't match \{ or \}
       while ($_ =~ m/(((?<!\\){)|((?<!\\)}))/g)
       {
            # store the match, either { or }
            my $braceType = $1;

            # exit the loop if @commandstore is empty
            last if(!@commandstore);

            # get the details of the most recent command name
            $commanddetails = pop(@commandstore);
            $commandname = $commanddetails->{'commandname'};
            $matchedbraces = $commanddetails->{'matchedbraces'};
            $countzeros = $commanddetails->{'countzeros'};
            $lookforelse= $commanddetails->{'lookforelse'};

            $matchedbraces++ if($1 eq "{");
            $matchedbraces-- if($1 eq "}");

            # if we've matched up the braces then
            # we can decrease the indent by 1 level
            if($matchedbraces == 0)
            {
                 $countzeros++ if $lookforelse;

                 # tracing mode
                 print $logfile "Line $lineCounter\t Found closing BRACE } $commandname\n" if($tracingMode);

                 # decrease the indentation (if appropriate)
                 &decrease_indent($commandname);

                if($countzeros==1)
                {
                     push(@commandstore,{commandname=>$commandname,
                                         matchedbraces=>$matchedbraces,
                                         lookforelse=>$lookforelse,
                                         countzeros=>$countzeros});
                }
            }
            else
            {
                # otherwise we need to enter the new value
                # of $matchedbraces and the value of $command
                # back into storage
                push(@commandstore,{commandname=>$commandname,
                                    matchedbraces=>$matchedbraces,
                                    lookforelse=>$lookforelse,
                                    countzeros=>$countzeros});

               # tracing mode
               print $logfile "Line $lineCounter\t Searching for closing BRACE } $commandname\n" if($tracingMode);
            }
     }
     }
}

sub check_for_else{
    # PURPOSE: Check for an else clause
    #
    #          Some commands have the form
    #
    #               \mycommand{
    #                   if this
    #               }
    #               {
    #                   else this
    #               }
    #
    #          so we need to look for the else bit, and set
    #          the indentation appropriately.
    #
    #          We only perform this check if there's something
    #          in the array @commandstore, and if
    #          the line itself is not a command, or comment,
    #          and if it begins with {

    if(scalar(@commandstore)
        and  !($_ =~ m/^\s*(\\)?(.*?)(\[|{|=)/
                    and (scalar($checkunmatched{$2})
                         or scalar($checkunmatchedELSE{$2})
                         or $alwaysLookforSplitBraces))
        and $_ =~ m/^\s*{/
        and $_ !~ m/^\s*%/
       )
    {
       # get the details of the most recent command name
       $commanddetails = pop(@commandstore);
       $commandname = $commanddetails->{'commandname'};
       $matchedbraces = $commanddetails->{'matchedbraces'};
       $countzeros = $commanddetails->{'countzeros'};
       $lookforelse= $commanddetails->{'lookforelse'};

       # increase indentation
       if($lookforelse and $countzeros==1)
       {
         &increase_indent($commandname);
       }

       # put the array back together
       push(@commandstore,{commandname=>$commandname,
                           matchedbraces=>$matchedbraces,
                           lookforelse=>$lookforelse,
                           countzeros=>$countzeros});
    }
}

sub at_beg_of_env_or_eq{
    # PURPOSE: Check if we're at the BEGINning of an environment
    #          or at the BEGINning of a displayed equation \[
    #
    #          This subroutine checks for matches of the form
    #
    #               \begin{environmentname}
    #          or
    #               \[
    #
    #          It also checks to see if the current environment
    #          should have alignment delimiters; if so, we need to turn
    #          ON the $delimiter switch

    # How to read
    #  m/^\s*(\$)?\\begin{(.*?)}/
    #
    #   ^               beginning of a line
    #   \s*             any white spaces (possibly none)
    #   (\$)?           possibly a $ symbol, but not required
    #   \\begin{(.*)?}  \begin{environmentname}
    #
    # How to read
    #  m/^\s*()(\\\[)/
    #
    #  ^        beginning of a line
    #  \s*      any white spaces (possibly none)
    #  ()       empty just so that $1 and $2 are defined
    #  (\\\[)   \[  there are lots of \ because both \ and [ need escaping
    #  \\begin{\\?(.*?)}  \begin{something} where something could start
    #                     with a backslash, e.g \my@env@ which can happen
    #                     in a style or class file, for example

    if( (   ( $_ =~ m/^\s*(\$)?\\begin{\\?(.*?)}/ and $_ !~ m/\\end{$2}/)
         or ($_=~ m/^\s*()(\\\[)/ and $_ !~ m/\\\]/) )
        and $_ !~ m/^\s*%/ )
    {
       # tracing mode
       print $logfile "Line $lineCounter\t \\begin{environment} found: $2 \n" if($tracingMode);

       # increase the indentation
       &increase_indent($2);

       # check for verbatim-like environments
       if($verbatimEnvironments{$2})
       {
           $inverbatim = 1;
           # tracing mode
           print $logfile "Line $lineCounter\t \\begin{verbatim-like} found, $2, switching ON verbatim \n" if($tracingMode);

           # remove the key and value from %lookForAlignDelims hash
           # to avoid any further confusion
           if($lookForAlignDelims{$2})
           {
                print $logfile "WARNING\n\t Line $lineCounter\t $2 is in *both* lookForAlignDelims and verbatimEnvironments\n";
                print $logfile "\t\t\t ignoring lookForAlignDelims and prioritizing verbatimEnvironments\n";
                print $logfile "\t\t\t Note that you only get this message once per environment\n";
                delete $lookForAlignDelims{$2};
           }

       }

       # check to see if we need to look for alignment
       # delimiters
       if($lookForAlignDelims{$2})
       {
           $delimiters=1;
            # tracing mode
            print $logfile "Line $lineCounter\t Delimiter environment started: $2 (see lookForAlignDelims)\n" if($tracingMode);
       }

       # store the name of the environment
       push(@environmentStack,$2);

    }
}

sub at_end_of_env_or_eq{
    # PURPOSE: Check if we're at the END of an environment
    #          or at the END of a displayed equation \]
    #
    #          This subroutine checks for matches of the form
    #
    #               \end{environmentname}
    #          or
    #               \]
    #
    #          Note: environmentname can begin with a backslash
    #                which might happen in a sty or cls file.
    #
    #          It also checks to see if the current environment
    #          had alignment delimiters; if so, we need to turn
    #          OFF the $delimiter switch

    if( ($_ =~ m/^\s*\\end{\\?(.*?)}/ or $_=~ m/^(\\\])/) and $_ !~ m/\s*^%/)
    {

       # check if we're at the end of a verbatim-like environment
       if($verbatimEnvironments{$1})
       {
           $inverbatim = 0;
            # tracing mode

            print $logfile "Line $lineCounter\t \\end{verbatim-like} found: $1, switching off verbatim \n" if($tracingMode);
            print $logfile "Line $lineCounter\t removing leading spaces \n" if($tracingMode);
            #s/^\ *//;
            s/^\t+// if($_ ne "");
            s/^\s+// if($_ ne "");
       }

       # check if we're in an environment that is looking
       # to indent after each \item
       if(scalar(@indentNames) and $itemNames{$indentNames[-1]})
       {
            &decrease_indent($indentNames[-1]);
       }

       # some commands contain \end{environmentname}, which
       # can cause a problem if \begin{environmentname} was not
       # started previously; if @environmentStack is empty,
       # then we don't need to check for \end{environmentname}
       if(@environmentStack)
       {
          # check to see if \end{environment} fits with most recent \begin{...}
          my $previousEnvironment = pop(@environmentStack);

          # check to see if we need to turn off alignment
          # delimiters and output the current block
          if($lookForAlignDelims{$1} and ($previousEnvironment eq $1))
          {
               &print_aligned_block();
          }

          # tracing mode
          print $logfile "Line $lineCounter\t \\end{envrionment} found: $1 \n" if($tracingMode and !$verbatimEnvironments{$1});

          # check to see if \end{environment} fits with most recent \begin{...}
          if($previousEnvironment eq $1)
          {
               # decrease the indentation (if appropriate)
               &decrease_indent($1);
          }
          else
          {
              # otherwise put the environment name back on the stack
              push(@environmentStack,$previousEnvironment);
              print $logfile "Line $lineCounter\t WARNING: \\end{$1} found on its own line, not matched to \\begin{$previousEnvironment}\n" unless ($delimiters or $inverbatim or $inIndentBlock or $1 eq "\\\]");
          }

          # need a special check for \[ and \]
          if($1 eq "\\\]")
          {
               &decrease_indent($1);
               pop(@environmentStack);
          }
       }

       # if we're at the end of the document, we remove all current
       # indentation- this is especially prominent in examples that
       # have headings, and the user has chosen to indentAfterHeadings
       if($1 eq "document" and !(grep(/filecontents/, @indentNames)) and !$inpreamble and !$delimiters and !$inverbatim and !$inIndentBlock)
       {
            @indent=();
            @indentNames=();

            # tracing mode
            if($tracingMode)
            {
                print $logfile "Line $lineCounter\t \\end{$1} found- emptying indent array \n" unless ($delimiters or $inverbatim or $inIndentBlock or $1 eq "\\\]");
            }
       }
    }
}

sub print_aligned_block{
    # PURPOSE: this subroutine does a few things related
    #          to printing blocks of code that contain
    #          delimiters, such as align, tabular, etc
    #
    #          It does the following
    #           - turns off delimiters switch
    #           - processes the block
    #           - deletes the block
    $delimiters=0;

    # tracing mode
    print $logfile "Line $lineCounter\t Delimiter body FINISHED: $1\n" if($tracingMode);

    # print the current FORMATTED block
    @block = &format_block(@block);
    foreach $line (@block)
    {
         # add the indentation and add the
         # each line of the formatted block
         # to the output
         # unless this would only create trailing whitespace and the
         # corresponding option is set
         unless ($line =~ m/^$/ and $removeTrailingWhitespace)
         {
             $line = join("",@indent).$line;
         }
         push(@lines,$line);
    }
    # empty the @block, very important!
    @block=();
}

sub format_block{
    #   PURPOSE: Format a delimited environment such as the
    #            tabular or align environment that contains &
    #
    #   INPUT: @block               array containing unformatted block
    #                               from, for example, align, or tabular
    #   OUTPUT: @formattedblock     array containing FORMATTED block


    # @block is the input
    my @block=@_;

    # tracing mode
    print $logfile "\t\tFormatting alignment block\n" if($tracingMode);

    # step the line counter back to the beginning of the block-
    # it will be increased back to the end of the block in the
    # loop later on:  foreach $row (@tmpblock)
    $lineCounter -= scalar(@block);


    # local array variables
    my @formattedblock;
    my @tmprow=();
    my @tmpblock=();
    my @maxmstringsize=();
    my @ampersandCount=();

    # local scalar variables
    my $alignrowcounter=-1;
    my $aligncolcounter=-1;
    my $tmpstring;
    my $row;
    my $column;
    my $maxmcolstrlength;
    my $i;
    my $j;
    my $fmtstring;
    my $linebreak;
    my $maxNumberAmpersands = 0;
    my $currentNumberAmpersands;
    my $trailingcomments;

    # local hash table
    my %stringsize=();

    # loop through the block and count & per line- store the biggest
    # NOTE: this needs to be done in its own block so that
    # we can know what the maximum number of & in the block is
    foreach $row (@block)
    {
       # delete trailing comments
       $trailingcomments='';
       if($row =~ m/((?<!\\)%.*$)/)
       {
            $row =~ s/((?<!\\)%.*)/%TC/;
            $trailingcomments=$1;
       }

       # reset temporary counter
       $currentNumberAmpersands=0;

       # count & in current row (exclude \&)
       $currentNumberAmpersands++ while ($row =~ /(?<!\\)&/g);

       # store the ampersand count for future
       push(@ampersandCount,$currentNumberAmpersands);

       # overwrite maximum count if the temp count is higher
       $maxNumberAmpersands = $currentNumberAmpersands if($currentNumberAmpersands > $maxNumberAmpersands );

       # put trailing comments back on
       if($trailingcomments)
       {
            $row =~ s/%TC/$trailingcomments/;
       }
    }

    # tracing mode
    print $logfile "\t\tmaximum number of & in any row: $maxNumberAmpersands\n" if($tracingMode);

    # loop through the lines in the @block
    foreach $row (@block)
    {
        # get the ampersand count
        $currentNumberAmpersands = shift(@ampersandCount);

        # increment row counter
        $alignrowcounter++;

        # clear the $linebreak variable
        $linebreak='';

        # check for line break \\
        # and don't mess with a line that doesn't have the maximum
        # number of &
        if($row =~ m/\\\\/ and $currentNumberAmpersands==$maxNumberAmpersands )
        {
          # remove \\ and all characters that follow
          # and put it back in later, once the measurement
          # has been done
          $row =~ s/(\\\\.*)//;
          $linebreak = $1;
        }

        if($currentNumberAmpersands==$maxNumberAmpersands)
        {

            # remove trailing comments
            $trailingcomments='';
            if($row =~ m/((?<!\\)%.*$)/)
            {
                 $row =~ s/((?<!\\)%.*)/%TC/;
                 $trailingcomments=$1;
            }

            # separate the row at each &, but not at \&
            @tmprow = split(/(?<!\\)&/,$row);

            # reset column counter
            $aligncolcounter=-1;

            # loop through each column element
            # removing leading and trailing space
            foreach $column (@tmprow)
            {
               # increment column counter
               $aligncolcounter++;

               # remove leading and trailing space from element
    	       $column =~ s/^\s+//;
               $column =~ s/\s+$//;

               # assign string size to the array
               $stringsize{$alignrowcounter.$aligncolcounter}=length($column);
               if(length($column)==0)
               {
                 $column=" ";
               }

               # put the row back together
               if ($aligncolcounter ==0)
               {
                 $tmpstring = $column;
               }
               else
               {
                 $tmpstring .= "&".$column;
               }
            }


            # put $linebreak back on the string, now that
            # the measurement has been done
            $tmpstring .= $linebreak;

            # put trailing comments back on
            if($trailingcomments)
            {
                 $tmpstring =~ s/%TC/$trailingcomments/;
            }

            push(@tmpblock,$tmpstring);
        }
        else
        {
               # if there are no & then use the
               # NOFORMATTING token
               # remove leading space
    	       s/^\s+//;
               push(@tmpblock,$row."NOFORMATTING");
        }
    }

    # calculate the maximum string size of each column
    for($j=0;$j<=$aligncolcounter;$j++)
    {
        $maxmcolstrlength=0;
        for($i=0; $i<=$alignrowcounter;$i++)
        {
            # make sure the stringsize is defined
            if(defined $stringsize{$i.$j})
            {
                if ($stringsize{$i.$j}>$maxmcolstrlength)
                {
                    $maxmcolstrlength = $stringsize{$i.$j};
                }
            }
        }
        push(@maxmstringsize,$maxmcolstrlength);
    }

    # README: printf( formatting, expression)
    #
    #   formatting has the form %-50s & %-20s & %-19s
    #   (the numbers have been made up for example)
    #       the - symbols mean that each column should be left-aligned
    #       the numbers represent how wide each column is
    #       the s represents string
    #       the & needs to be inserted

    # join up the maximum string lengths using "s %-"
    $fmtstring = join("s & %-",@maxmstringsize);

    # add an s to the end, and a newline
    $fmtstring .= "s ";

    # add %- to the beginning
    $fmtstring = "%-".$fmtstring;

    # process the @tmpblock of aligned material
    foreach $row (@tmpblock)
    {

        $linebreak='';
        # check for line break \\
        if($row =~ m/\\\\/)
        {
          # remove \\ and all characters that follow
          # and put it back in later
          $row =~ s/(\\\\.*$)//;
          $linebreak = $1;
        }

        if($row =~ m/NOFORMATTING/)
        {
            $row =~ s/NOFORMATTING//;
            $tmpstring=$row;

            # tracing mode
            print $logfile "\t\tLine $lineCounter\t maximum number of & NOT found- not aligning delimiters \n" if($tracingMode);
        }
        else
        {
          # remove trailing comments
          $trailingcomments='';
          if($row =~ m/((?<!\\)%.*$)/)
          {
               $row =~ s/((?<!\\)%.*)/%TC/;
               $trailingcomments=$1;
          }

          $tmpstring = sprintf($fmtstring,split(/(?<!\\)&/,$row)).$linebreak."\n";

          # put trailing comments back on
          if($trailingcomments)
          {
               $tmpstring =~ s/%TC/$trailingcomments/;
          }

          # tracing mode
          print $logfile "\t\tLine $lineCounter\t Found maximum number of & so aligning delimiters\n" if($tracingMode);
        }

        # remove trailing whitespace
        if ($removeTrailingWhitespace)
        {
            print $logfile "\t\tLine $lineCounter\t removing trailing whitespace from delimiter aligned line\n" if ($tracingMode);
            $tmpstring =~ s/\s+$/\n/;
        }

        push(@formattedblock,$tmpstring);

        # increase the line counter
        $lineCounter++;
    }

    # return the formatted block
	@formattedblock;
}

sub increase_indent{
       # PURPOSE: Adjust the indentation
       #          of the current environment;
       #          check that it's not an environment
       #          that doesn't want indentation.

       my $command = pop(@_);

       # if the user has specified $indentRules{$command} and
       # $noAdditionalIndent{$command} then they are a bit confused-
       # we remove the $indentRules{$command} and assume that they
       # want $noAdditionalIndent{$command}
       if(scalar($indentRules{$command}) and $noAdditionalIndent{$command})
       {
            print $logfile "WARNING\n\t Line $lineCounter\t $command is in *both* indentRules and noAdditionalIndent\n";
            print $logfile "\t\t\t ignoring indentRules and prioritizing noAdditionalIndent\n";
            print $logfile "\t\t\t Note that you only get this message once per command/environment\n";

            # remove the key and value from %indentRules hash
            # to avoid any further confusion
            delete $indentRules{$command};
       }

       # if the command is in verbatimEnvironments and in indentRules then
       # remove it from %indentRules hash
       # to avoid any further confusion
       if($indentRules{$command} and $verbatimEnvironments{$command})
       {
            # remove the key and value from %indentRules hash
            # to avoid any further confusion
            print $logfile "WARNING\n\t Line $lineCounter\t $command is in *both* indentRules and verbatimEnvironments\n";
            print $logfile "\t\t\t ignoring indentRules and prioritizing verbatimEnvironments\n";
            print $logfile "\t\t\t Note that you only get this message once per environment\n";
            delete $indentRules{$command};
       }

       if(scalar($indentRules{$command}))
       {
          # if there's a rule for indentation for this environment
          push(@indent, $indentRules{$command});
          # tracing mode
          print $logfile "Line $lineCounter\t increasing indent using rule for $command (see indentRules)\n" if($tracingMode);
          push(@indentNames,"$command");
       }
       else
       {
          # default indentation
          if(!($noAdditionalIndent{$command} or $verbatimEnvironments{$command} or $inverbatim))
          {
            push(@indent, $defaultIndent);
            push(@indentNames,"$command");
            # tracing mode
            print $logfile "Line $lineCounter\t increasing indent using defaultIndent\n" if($tracingMode);
          }
          elsif($noAdditionalIndent{$command})
          {
            # tracing mode
            print $logfile "Line $lineCounter\t no additional indent added for $command (see noAdditionalIndent)\n" if($tracingMode);
          }
       }
}

sub decrease_indent{
       # PURPOSE: Adjust the indentation
       #          of the current environment;
       #          check that it's not an environment
       #          that doesn't want indentation.

       my $command = pop(@_);

       if(!($noAdditionalIndent{$command} or $verbatimEnvironments{$command} or $inverbatim))
       {
            print $logfile "Line $lineCounter\t removing ", $indentNames[-1], " from indentNames\n" if($tracingMode);
            pop(@indent);
            pop(@indentNames);
            # tracing mode
            if($tracingMode)
            {
                if(@indentNames)
                {
                    print $logfile "Line $lineCounter\t decreasing indent to: ",join(", ",@indentNames),"\n" ;
                }
                else
                {
                    print $logfile "Line $lineCounter\t indent now empty \n";
              }
            }
       }
}

