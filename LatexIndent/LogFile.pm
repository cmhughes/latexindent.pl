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
use Exporter qw/import/;
our @EXPORT_OK = qw/logger output_logfile processSwitches/;
our @logFileNotes;

# log file methods, using log4perl; references
#   pattern layout: http://search.cpan.org/~mschilli/Log-Log4perl-1.32/lib/Log/Log4perl/Layout/PatternLayout.pm
#   multiple appenders: https://stackoverflow.com/questions/8620347/perl-log4perl-printing-and-logging-at-the-same-time-in-a-line?rq=1
#   getting started: https://www.perl.com/pub/2002/09/11/log4perl.html 

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
      -i, --information
          information from the log file will also be output to the screen
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
    
    # layout of the logfile information, for example
    #
    #       2017/09/16 11:59:09 INFO: message
    #       2017/09/16 12:23:53 INFO: LogFile.pm:156 LatexIndent::LogFile::processSwitches - message
    my $layout = Log::Log4perl::Layout::PatternLayout->new("%p: ".($switches{ttrace} ? "%F{1}:%L %M - ":'')."%m{indent}%n");

    # details for the Log4perl logging
    my $appender = Log::Log4perl::Appender->new(
        "Log::Dispatch::File",
        filename => $logfileName,
        mode     => "write",
        utf8     => 1,
    );

    # add the layout
    $appender->layout($layout);

    # adjust the logger object
    $latexindent_logger->add_appender($appender);

    # appender object for output to screen
    my $appender_screen = q();

    # output to screen, if appropriate
    if($switches{information}){
        $appender_screen = Log::Log4perl::Appender->new(
            "Log::Log4perl::Appender::Screen",
            stderr => 0,
            utf8   => 1,
        );

        $appender_screen->layout($layout);
        $latexindent_logger->add_appender($appender_screen);
    }
    
    # initiate the log message
    my $logmessage = q();

    # details of the script to log file
    $logmessage = "$FindBin::Script version $versionNumber, $versionDate, a script to indent .tex files\n";
    $logmessage .= "$FindBin::Script lives here: $FindBin::RealBin/\n";

    my $time = localtime();
    $logmessage .= $time;

    # get the logger, output the log message
    my $logger = get_logger("Document");
    $logger->info($logmessage);

    # log the switches from the user
    $logmessage = "Processing switches:\n";

    # check on the trace mode switch (should be turned on if ttrace mode active)
    $switches{trace} = $switches{ttrace} ?  1 : $switches{trace};
    
    # output details of switches
    $logmessage .= '-i|--information: information from the log file will also be output to the screen'."\n" if($switches{information});
    $logmessage .= '-t|--trace: Trace mode active (you have used either -t or --trace)'."\n" if($switches{trace} and !$switches{ttrace});
    $logmessage .= '-tt|--ttrace: TTrace mode active (you have used either -tt or --ttrace)'."\n" if($switches{tracingModeVeryDetailed});
    $logmessage .= '-s|--silent: Silent mode active (you have used either -s or --silent)'."\n" if($switches{silentMode});
    $logmessage .= '-d|--onlydefault: Only defaultSettings.yaml will be used (you have used either -d or --onlydefault)'."\n" if($switches{onlyDefault});
    $logmessage .= "-w|--overwrite: Overwrite mode active, will make a back up of ${$self}{fileName} first"."\n" if($switches{overwrite});
    $logmessage .= "-l|--localSettings: Read localSettings YAML file"."\n" if($switches{readLocalSettings});
    $logmessage .= "-y|--yaml: YAML settings specified via command line"."\n" if($switches{yaml});
    $logmessage .= "-o|--outputfile: output to file"."\n" if($switches{outputToFile});
    $logmessage .= "-m|--modifylinebreaks: modify line breaks"."\n" if($switches{modifyLineBreaks});
    $logmessage .= "-g|--logfile: logfile name"."\n" if($switches{logFileName});
    $logmessage .= "-c|--cruft: cruft directory"."\n" if($switches{cruftDirectory});

    # log the switch messages
    $logger->info($logmessage);

    # check if overwrite and outputfile are active similtaneously
    if($switches{overwrite} and $switches{outputToFile}){
        $logger->info("Options check, -w and -o specified\nYou have called latexindent.pl with both -o and -w\noutput to file) will take priority, and -w (over write) will be ignored");
        $switches{overwrite}=0;
    }

    $logger->info("Directory for backup files and $logfileName: ${$self}{cruftDirectory}");

    # output location of modules
    if($FindBin::Script eq 'latexindent.pl' or ($FindBin::Script eq 'latexindent.exe' and $switches{trace} )) {
        my @listOfModules = ('FindBin', 'YAML::Tiny', 'File::Copy', 'File::Basename', 'Getopt::Long','File::HomeDir','Unicode::GCString','Log::Log4perl');
        $logmessage = "Perl modules are being loaded from the following directories:\n";
        foreach my $moduleName (@listOfModules) {
                (my $file = $moduleName) =~ s|::|/|g;
                $logmessage .= $INC{$file .'.pm'}."\n";
              }
        $logger->info($logmessage);
        $logmessage = "Latex Indent perl modules are being loaded from, for example:\n";
                (my $file = 'LatexIndent::Document') =~ s|::|/|g;
                $logmessage .= $INC{$file .'.pm'};
        $logger->info($logmessage);
    }

    # read the YAML settings
    $self->readSettings;
    
    # the user may have specified their own settings for the rest of the log file,
    # for example:
    #
    #   logFilePreferences:
    #       PatternLayout:
    #           default: "%p: %m{indent}%n"
    #           trace: "%p: %m{indent}%n"
    #           ttrace: "%d %p: %F{1}:%L %M - %m{indent}%n"
    #
    # e.g, default mode:
    #       2017/09/16 11:59:09 INFO: message
    # or trace mode:
    #       2017/09/16 11:59:09 INFO: message
    # or in trace mode:
    #       2017/09/16 12:23:53 INFO: LogFile.pm:156 LatexIndent::LogFile::processSwitches - message
    my $pattern = q();
    if($switches{ttrace}){
      $pattern = ${${$masterSettings{logFilePreferences}}{PatternLayout}}{ttrace};
    } elsif($switches{trace}){
      $pattern = ${${$masterSettings{logFilePreferences}}{PatternLayout}}{trace};
    } else {
      $pattern = ${${$masterSettings{logFilePreferences}}{PatternLayout}}{default};
    }
    $layout = Log::Log4perl::Layout::PatternLayout->new($pattern);
    $appender->layout($layout);

    $appender_screen->layout($layout) if $switches{information};
    return;
}

sub output_logfile{
  my $logger = get_logger("Document");

  # initiate the log message
  my $logmessage = q();

  # github info line
  $logmessage .= "Please direct all communication/issues to:\nhttps://github.com/cmhughes/latexindent.pl\n" if ${$masterSettings{logFilePreferences}}{showGitHubInfoFooter};
  
  # put the final line in the logfile
  $logmessage .= "${$masterSettings{logFilePreferences}}{endLogFileWith}";

  # output the log message
  $logger->info($logmessage);

}

1;
