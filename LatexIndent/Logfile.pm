package LatexIndent::Logfile;
use strict;
use warnings;
use Exporter qw/import/;
our @EXPORT_OK = qw/logger output_logfile/;
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
          } elsif(${$line}{level} eq 'verbose') {
            # add tabs to the beginning of lines 
            # for default logfile lines
            ${$line}{line} =~ s/^/\t/mg;
            #print $logfile ${$line}{line},"\n";
          }
  }
  close($logfile);
}


1;
