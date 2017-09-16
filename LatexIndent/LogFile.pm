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
use LatexIndent::GetYamlSettings qw/%masterSettings/;
use LatexIndent::Switches qw/%switches/;
use LatexIndent::Version qw/$versionNumber $versionDate/;
use FindBin; 
use File::Basename; # to get the filename and directory path
use Log::Log4perl qw(get_logger :levels);
use Log::Log4perl::Appender::Screen;
use Exporter qw/import/;
our @EXPORT_OK = qw/logger output_logfile processSwitches/;
our @logFileNotes;

# log file methods
# log file methods
# log file methods
#   reference: http://stackoverflow.com/questions/6736998/help-calling-a-sub-routine-from-a-perl-module-and-printing-to-logfile

sub logger{
    shift;
    my $line = shift;
    my $infoLevel = shift;
    push(@logFileNotes,{line=>$line,level=>$infoLevel?$infoLevel:'default'});
    return
}

sub processSwitches{
    # -v switch is just to show the version number
    if($switches{version}) {
        print $versionNumber,", ",$versionDate,"\n";
        exit(2);
    }

    if(scalar(@ARGV) < 1 or $switches{showhelp}) {
    print <<ENDQUOTE
latexindent.pl version $versionNumber, $versionDate
usage: latexindent.pl [options] [file][.tex|.sty|.cls|.bib|...]
      -v, --version
          displays the version number and date of release
      -h, --help
          help (see the documentation for detailed instructions and examples)
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
          use localSettings.yaml (assuming it exists in the directory of your file);
          alternatively, use myyaml.yaml, if it exists; sample usage:
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
ENDQUOTE
    ;
    exit(2);
}

    # if we've made it this far, the processing of switches and logging begins
    my $self = shift;

    # log4perl reference: https://www.perl.com/pub/2002/09/11/log4perl.html
    my $latexindent_logger = get_logger("Document");
    $latexindent_logger->level($INFO);
    
    # cruft directory
    ${$self}{cruftDirectory} = $switches{cruftDirectory}||(dirname ${$self}{fileName});
    die "Could not find directory ${$self}{cruftDirectory}\nExiting, no indentation done." if(!(-d ${$self}{cruftDirectory}));

    my $logfileName = ($switches{cruftDirectory} ? ${$self}{cruftDirectory} : '').($switches{logFileName}||"indent.log");

    # details for the Log4perl logging
    my $appender = Log::Log4perl::Appender->new(
        "Log::Dispatch::File",
        filename => $logfileName,
        mode     => "write",
        utf8     => 1,
    );

    $latexindent_logger->add_appender($appender);

    ## output to screen, if appropriate
    #my $appender_screen = Log::Log4perl::Appender::Screen->new(
    #    stderr => 1,
    #    utf8   => 1,
    #);

    #$latexindent_logger->add_appender($appender_screen);
    
    my $logger = get_logger("Document");

    # layout of the first few lines of the logfile information
    my $layout = Log::Log4perl::Layout::PatternLayout->new("%m%n");
    $appender->layout($layout);

    # details of the script to log file
    $logger->info("$FindBin::Script version $versionNumber, $versionDate, a script to indent .tex files");
    $logger->info("$FindBin::Script lives here: $FindBin::RealBin/");

    my $time = localtime();
    $logger->info($time);

    # log the switches from the user
    $logger->info('Processing switches');

    # check on the trace mode switch (should be turned on if ttrace mode active)
    $switches{trace} = $switches{ttrace} ?  1 : $switches{trace};
    
    # for the rest of the log file, layout of the logfile information, for example
    #
    #       2017/09/16 11:59:09 INFO: message
    #       2017/09/16 12:23:53 INFO: LogFile.pm:156 LatexIndent::LogFile::processSwitches - message
    $layout = Log::Log4perl::Layout::PatternLayout->new("%d %p: ".($switches{trace} ? "%F{1}:%L %M - ":'')."%m{indent}%n");
    $appender->layout($layout);

    # output details of switches
    my $switchMessage = q();
    $switchMessage .= '-t|--trace: Trace mode active (you have used either -t or --trace)'."\n" if($switches{trace} and !$switches{ttrace});
    $switchMessage .= '-tt|--ttrace: TTrace mode active (you have used either -tt or --ttrace)'."\n" if($switches{tracingModeVeryDetailed});
    $switchMessage .= '-s|--silent: Silent mode active (you have used either -s or --silent)'."\n" if($switches{silentMode});
    $switchMessage .= '-d|--onlydefault: Only defaultSettings.yaml will be used (you have used either -d or --onlydefault)'."\n" if($switches{onlyDefault});
    $switchMessage .= "-w|--overwrite: Overwrite mode active, will make a back up of ${$self}{fileName} first"."\n" if($switches{overwrite});
    $switchMessage .= "-l|--localSettings: Read localSettings YAML file"."\n" if($switches{readLocalSettings});
    $switchMessage .= "-y|--yaml: YAML settings specified via command line"."\n" if($switches{yaml});
    $switchMessage .= "-o|--outputfile: output to file"."\n" if($switches{outputToFile});
    $switchMessage .= "-m|--modifylinebreaks: modify line breaks"."\n" if($switches{modifyLineBreaks});
    $switchMessage .= "-g|--logfile: logfile name"."\n" if($switches{logFileName});
    $switchMessage .= "-c|--cruft: cruft directory"."\n" if($switches{cruftDirectory});

    # log the switch messages
    $logger->info($switchMessage);

    # check if overwrite and outputfile are active similtaneously
    if($switches{overwrite} and $switches{outputToFile}){
        $logger->info("Options check");
        $logger->info("You have called latexindent.pl with both -o and -w");
        $logger->info("-o (output to file) will take priority, and -w (over write) will be ignored");
        $switches{overwrite}=0;
    }

    $logger->info("Directory for backup files and $logfileName: ${$self}{cruftDirectory}");

    # output location of modules
    if($FindBin::Script eq 'latexindent.pl' or ($FindBin::Script eq 'latexindent.exe' and $switches{trace} )) {
        my @listOfModules = ('FindBin', 'YAML::Tiny', 'File::Copy', 'File::Basename', 'Getopt::Long','File::HomeDir','Unicode::GCString','Log::Log4perl');
        $logger->info("Perl modules are being loaded from the following directories:");
        foreach my $moduleName (@listOfModules) {
                (my $file = $moduleName) =~ s|::|/|g;
                require $file . '.pm';
                $logger->info($INC{$file .'.pm'});
              }
        $logger->info("Latex Indent perl modules are being loaded from, for example:");
                (my $file = 'LatexIndent::Document') =~ s|::|/|g;
                require $file . '.pm';
                $logger->info($INC{$file .'.pm'});
    }
    return;
}

sub output_logfile{
  my $logger = get_logger("Document");

  # github info line
  $logger->info("Please direct all communication/issues to:\nhttps://github.com/cmhughes/latexindent.pl") if ${$masterSettings{logFilePreferences}}{showGitHubInfoFooter};
  
  # put the final line in the logfile
  $logger->info("${$masterSettings{logFilePreferences}}{endLogFileWith}");


}


1;
