package LatexIndent::Logfile;
use strict;
use warnings;
use FindBin; 
use Exporter qw/import/;
our @EXPORT_OK = qw/logger output_logfile processSwitches/;
our @logFileNotes;
our %switches;

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
    $self->logger("$FindBin::Script version 3.0, a script to indent .tex files",'heading');
    $self->logger("$FindBin::Script lives here: $FindBin::RealBin/");

    # time the script is used
    my $time = localtime();
    $self->logger("$time");

    # copy document switches into hash local to this module
    %switches = %{%{$self}{switches}};

    # log the switches from the user
    $self->logger('Processing switches','heading');

    # check on the trace mode switch (should be turned on if ttrace mode active)
    $switches{trace} = $switches{ttrace} ?  1 : $switches{trace};

    # output details of switches
    $self->logger('Trace mode active (you have used either -t or --trace)') if($switches{trace} and !$switches{ttrace});
    $self->logger('TTrace mode active (you have used either -tt or --ttrace)') if($switches{tracingModeVeryDetailed});
    $self->logger('Silent mode active (you have used either -s or --silent)') if($switches{silentMode});
    $self->logger('Only defaultSettings.yaml will be used (you have used either -d or --onlydefault)') if($switches{onlyDefault});

    # output location of modules
    if($FindBin::Script eq 'latexindent.pl' or ($FindBin::Script eq 'latexindent.exe' and $switches{trace} )) {
        my @listOfModules = ('FindBin','YAML::Tiny','File::Copy','File::Basename','Getopt::Long','File::HomeDir');
        $self->logger("Modules are being loaded from the following directories:",'heading');
        foreach my $moduleName (@listOfModules) {
                (my $file = $moduleName) =~ s|::|/|g;
                require $file . '.pm';
                $self->logger($INC{$file .'.pm'});
              }
    }

    return
}

sub output_logfile{
  my $logfile;
  open($logfile,">","indent.log") or die "Can't open indent.log";
  foreach my $line (@logFileNotes){
        if(${$line}{level} eq 'heading'){
            print $logfile ${$line}{line},"\n";
          } elsif(${$line}{level} eq 'default') {
            # add tabs to the beginning of lines 
            # for default logfile lines
            ${$line}{line} =~ s/^/\t/mg;
            print $logfile ${$line}{line},"\n";
          } 

        # trace mode, headings
        if($switches{trace} and ${$line}{level} eq 'heading.trace') {
            print $logfile ${$line}{line},"\n";
          }
        # trace mode, default lines
        if($switches{trace} and ${$line}{level} eq 'trace') {
            # add tabs to the beginning of lines 
            # for default logfile lines
            ${$line}{line} =~ s/^/\t/mg;
            print $logfile ${$line}{line},"\n";
          }
        # ttrace mode, default lines
        if($switches{ttrace} and ${$line}{level} eq 'ttrace') {
            # add tabs to the beginning of lines 
            # for default logfile lines
            ${$line}{line} =~ s/^/\t/mg;
            print $logfile ${$line}{line},"\n";
          }
  }
  close($logfile);
}


1;
