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
use FindBin; 
use File::Basename; # to get the filename and directory path
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
    my $self = shift;

    # details of the script to log file
    $self->logger("$FindBin::Script version 3.1, a script to indent .tex files",'heading');
    $self->logger("$FindBin::Script lives here: $FindBin::RealBin/");

    # time the script is used
    my $time = localtime();
    $self->logger("$time");

    if(scalar(@ARGV) < 1 or $switches{showhelp}) {
    print <<ENDQUOTE
latexindent.pl version 3.1
usage: latexindent.pl [options] [file][.tex|.sty|.cls|.bib|...]
      -h, --help
          help (see the documentation for detailed instructions and examples)
      -o, --outputfile
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
      -d, --onlydefault
          ONLY use defaultSettings.yaml, ignore ALL (yaml) user files
      -g, --logfile
          used to specify the name of logfile (default is indent.log)
      -c, --cruft=<cruft directory> 
          used to specify the location of backup files and indent.log
      -m, --modifylinebreaks
          modify linebreaks before, during, and at the end of code blocks; 
          trailing comments can also be added using this feature
ENDQUOTE
    ;
    exit(2);
}

    # log the switches from the user
    $self->logger('Processing switches','heading');

    # check on the trace mode switch (should be turned on if ttrace mode active)
    $switches{trace} = $switches{ttrace} ?  1 : $switches{trace};

    # output details of switches
    $self->logger('-t|--trace: Trace mode active (you have used either -t or --trace)') if($switches{trace} and !$switches{ttrace});
    $self->logger('-tt|--ttrace: TTrace mode active (you have used either -tt or --ttrace)') if($switches{tracingModeVeryDetailed});
    $self->logger('-s|--silent: Silent mode active (you have used either -s or --silent)') if($switches{silentMode});
    $self->logger('-d|--onlydefault: Only defaultSettings.yaml will be used (you have used either -d or --onlydefault)') if($switches{onlyDefault});
    $self->logger("-w|--overwrite: Overwrite mode active, will make a back up of ${$self}{fileName} first") if($switches{overwrite});
    $self->logger("-l|--localSettings: Read localSettings YAML file") if($switches{readLocalSettings});
    $self->logger("-o|--outputfile: output to file") if($switches{outputToFile});
    $self->logger("-m|--modifylinebreaks: modify line breaks") if($switches{modifyLineBreaks});
    $self->logger("-g|--logfile: logfile name") if($switches{logFileName});
    $self->logger("-c|--cruft: cruft directory") if($switches{cruftDirectory});

    # check if overwrite and outputfile are active similtaneously
    if($switches{overwrite} and $switches{outputToFile}){
        $self->logger("Options check",'heading');
        $self->logger("You have called latexindent.pl with both -o and -w");
        $self->logger("-o (output to file) will take priority, and -w (over write) will be ignored");
        $switches{overwrite}=0;
    }

    # cruft directory
    ${$self}{cruftDirectory} = $switches{cruftDirectory}||(dirname ${$self}{fileName});
    die "Could not find directory ${$self}{cruftDirectory}\nExiting, no indentation done." if(!(-d ${$self}{cruftDirectory}));
    my $logfileName = $switches{logFileName}||"indent.log";
    $self->logger("Directory for backup files and $logfileName: ${$self}{cruftDirectory}",'heading');

    # output location of modules
    if($FindBin::Script eq 'latexindent.pl' or ($FindBin::Script eq 'latexindent.exe' and $switches{trace} )) {
        my @listOfModules = ('FindBin', 'YAML::Tiny', 'File::Copy', 'File::Basename', 'Getopt::Long','File::HomeDir','Unicode::GCString');
        $self->logger("Perl modules are being loaded from the following directories:",'heading');
        foreach my $moduleName (@listOfModules) {
                (my $file = $moduleName) =~ s|::|/|g;
                require $file . '.pm';
                $self->logger($INC{$file .'.pm'});
              }
        $self->logger("Latex Indent perl modules are being loaded from, for example:",'heading');
                (my $file = 'LatexIndent::Document') =~ s|::|/|g;
                require $file . '.pm';
                $self->logger($INC{$file .'.pm'});
    }
    return;
}

sub output_logfile{
  my $self = shift;
  my $logfile;
  my $logfileName = $switches{logFileName}||"indent.log";

  open($logfile,">","${$self}{cruftDirectory}/$logfileName") or die "Can't open $logfileName";

  # put the final line in the logfile
  $self->logger("${$masterSettings{logFilePreferences}}{endLogFileWith}",'heading');

  # github info line
  $self->logger("Please direct all communication/issues to: ",'heading') if ${$masterSettings{logFilePreferences}}{showGitHubInfoFooter};
  $self->logger("https://github.com/cmhughes/latexindent.pl") if ${$masterSettings{logFilePreferences}}{showGitHubInfoFooter};

  # output the logfile
  foreach my $line (@logFileNotes){
        if(${$line}{level} eq 'heading'){
            print $logfile ${$line}{line},"\n";
          } elsif(${$line}{level} eq 'default') {
            # add tabs to the beginning of lines 
            # for default logfile lines
            ${$line}{line} =~ s/^/\t/mg;
            print $logfile ${$line}{line},"\n";
          } 
  }

  close($logfile);
}


1;
