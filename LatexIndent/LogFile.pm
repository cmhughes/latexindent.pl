package LatexIndent::LogFile;
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
use FindBin; 
use File::Basename; # to get the filename and directory path
use Exporter qw/import/;
use LatexIndent::Switches qw/%switches/;
use LatexIndent::Version qw/$versionNumber $versionDate/;
our @EXPORT_OK = qw/process_switches $logger/;
our $logger;

sub process_switches{
    # -v switch is just to show the version number
    if($switches{version}) {
        print $versionNumber,", ",$versionDate,"\n";
        exit(0);
    }

    if(scalar(@ARGV) < 1 or $switches{showhelp}) {
    print <<ENDQUOTE
latexindent.pl version $versionNumber, $versionDate
usage: latexindent.pl [options] [file]
      -v, --version
          displays the version number and date of release
      -h, --help
          help (see the documentation for detailed instructions and examples)
      -sl, --screenlog
          log file will also be output to the screen
      -o, --outputfile=<name-of-output-file>
          output to another file; sample usage:
                latexindent.pl -o outputfile.tex myfile.tex
                latexindent.pl -o=outputfile.tex myfile.tex
      -w, --overwrite
          overwrite the current file; a backup will be made, but still be careful
      -s, --silent
          silent mode: no output will be given to the terminal
      -t, --trace
          tracing mode: verbose information given to the log file
      -l, --local[=myyaml.yaml]
          use `localSettings.yaml`, `.localSettings.yaml`, `latexindent.yaml`,
          or `.latexindent.yaml` (assuming one of them exists in the directory of your file or in
          the current working directory); alternatively, use `myyaml.yaml`, if it exists;
          sample usage:
                latexindent.pl -l some.yaml myfile.tex
                latexindent.pl -l=another.yaml myfile.tex
                latexindent.pl -l=some.yaml,another.yaml myfile.tex
      -y, --yaml=<yaml settings>
          specify YAML settings; sample usage:
                latexindent.pl -y="defaultIndent:' '" myfile.tex
                latexindent.pl -y="defaultIndent:' ',maximumIndentation:' '" myfile.tex
      -d, --onlydefault
          ONLY use defaultSettings.yaml, ignore ALL (yaml) user files
      -g, --logfile=<name of log file>
          used to specify the name of logfile (default is indent.log)
      -c, --cruft=<cruft directory>
          used to specify the location of backup files and indent.log
      -m, --modifylinebreaks
          modify linebreaks before, during, and at the end of code blocks;
          trailing comments and blank lines can also be added using this feature
      -r, --replacement
          replacement mode, allows you to replace strings and regular expressions
          verbatim blocks not respected
      -rv, --replacementrespectverb
          replacement mode, allows you to replace strings and regular expressions
          while respecting verbatim code blocks
      -rr, --onlyreplacement
          *only* replacement mode, no indentation;
          verbatim blocks not respected
      -k, --check mode
          will exit with 0 if document body unchanged, 1 if changed
      -kv, --check mode verbose
          as in check mode, but outputs diff to screen as well as to logfile
      -n, --lines=<MIN-MAX>
          only operate on selected lines; sample usage:
                latexindent.pl --lines 3-5 myfile.tex
                latexindent.pl --lines 3-5,7-10 myfile.tex
ENDQUOTE
    ;
    exit(0);
}

    # if we've made it this far, the processing of switches and logging begins
    my $self = shift;

    $logger = LatexIndent::Logger->new();
    
    # cruft directory
    ${$self}{cruftDirectory} = $switches{cruftDirectory}||(dirname ${$self}{fileName});

    # if cruft directory does not exist
    if(!(-d ${$self}{cruftDirectory})){
        $logger->fatal("*Could not find directory ${$self}{cruftDirectory}");
        $logger->fatal("Exiting, no indendation done."); 
        $self->output_logfile();
        exit(6);
    }

    my $logfileName = ($switches{cruftDirectory} ? ${$self}{cruftDirectory}."/" : '').($switches{logFileName}||"indent.log");
    
    # details of the script to log file
    $logger->info("*$FindBin::Script version $versionNumber, $versionDate, a script to indent .tex files");
    $logger->info("$FindBin::Script lives here: $FindBin::RealBin/");

    my $time = localtime();
    $logger->info($time);

    if (${$self}{fileName} ne "-"){
        $logger->info("Filename: ${$self}{fileName}");
    } else {
        $logger->info("Reading input from STDIN");
        if (-t STDIN) {
            my $buttonText = ($FindBin::Script eq 'latexindent.exe') ? 'CTRL+Z followed by ENTER':'CTRL+D';
            print STDERR "Please enter text to be indented: (press $buttonText when finished)\n";
        }
    }

    # log the switches from the user
    $logger->info("*Processing switches:");

    # check on the trace mode switch (should be turned on if ttrace mode active)
    $switches{trace} = $switches{ttrace} ?  1 : $switches{trace};
    
    # output details of switches
    $logger->info("-sl|--screenlog: log file will also be output to the screen") if($switches{screenlog});
    $logger->info("-t|--trace: Trace mode active (you have used either -t or --trace)") if($switches{trace} and !$switches{ttrace});
    $logger->info("-tt|--ttrace: TTrace mode active (you have used either -tt or --ttrace)") if($switches{ttrace});
    $logger->info("-s|--silent: Silent mode active (you have used either -s or --silent)") if($switches{silentMode});
    $logger->info("-d|--onlydefault: Only defaultSettings.yaml will be used (you have used either -d or --onlydefault)") if($switches{onlyDefault});
    $logger->info("-w|--overwrite: Overwrite mode active, will make a back up of ${$self}{fileName} first") if($switches{overwrite});
    $logger->info("-l|--localSettings: Read localSettings YAML file") if($switches{readLocalSettings});
    $logger->info("-y|--yaml: YAML settings specified via command line") if($switches{yaml});
    $logger->info("-o|--outputfile: output to file") if($switches{outputToFile});
    $logger->info("-m|--modifylinebreaks: modify line breaks") if($switches{modifyLineBreaks});
    $logger->info("-g|--logfile: logfile name") if($switches{logFileName});
    $logger->info("-c|--cruft: cruft directory") if($switches{cruftDirectory});
    $logger->info("-r|--replacement: replacement mode") if($switches{replacement});
    $logger->info("-rr|--onlyreplacement: *only* replacement mode, no indentation") if($switches{onlyreplacement});
    $logger->info("-k|--check mode: will exit with 0 if document body unchanged, 1 if changed") if($switches{check});
    $logger->info("-kv|--check mode verbose: as in check mode, but outputs diff to screen") if($switches{checkverbose});
    $logger->info("-n|--lines mode: will only operate on specific lines $switches{lines}") if($switches{lines});

    # check if overwrite and outputfile are active similtaneously
    if($switches{overwrite} and $switches{outputToFile}){
        $logger->info("Options check, -w and -o specified\nYou have called latexindent.pl with both -o and -w\noutput to file) will take priority, and -w (over write) will be ignored");
        $switches{overwrite}=0;
    }

    $logger->info("*Directory for backup files and $logfileName: ${$self}{cruftDirectory}");

    # output location of modules
    if($FindBin::Script eq 'latexindent.pl' or ($FindBin::Script eq 'latexindent.exe' and $switches{trace} )) {
        my @listOfModules = ('FindBin', 'YAML::Tiny', 'File::Copy', 'File::Basename', 'Getopt::Long','File::HomeDir','Unicode::GCString');
        $logger->info("*Perl modules are being loaded from the following directories:");
        foreach my $moduleName (@listOfModules) {
                (my $file = $moduleName) =~ s|::|/|g;
                $logger->info($INC{$file .'.pm'});
              }
        $logger->info("*LatexIndent perl modules are being loaded from, for example:");
                (my $file = 'LatexIndent::Document') =~ s|::|/|g;
        $logger->info($INC{$file .'.pm'});
    }

    return;
}

1;
