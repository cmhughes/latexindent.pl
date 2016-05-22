package LatexIndent::BackUpFileProcedure;
use strict;
use warnings;
use File::Basename;             # to get the filename and directory path
use File::Copy;                 # to copy the original file to backup (if overwrite option set)
use Exporter qw/import/;
our @EXPORT_OK = qw/create_back_up_file/;

# copy main file to a back up in the case of the overwrite switch being active
# copy main file to a back up in the case of the overwrite switch being active
# copy main file to a back up in the case of the overwrite switch being active

sub create_back_up_file{
    my $self = shift;
    # if we want to over write the current file create a backup first
    if (${%{$self}{switches}}{overwrite}) {
        $self->logger("Backup procedure:",'heading');

        my $fileName = ${$self}{fileName};

        # cruft directory
        my $cruftDirectory=dirname $fileName; # FIX THIS FIX THIS# FIX THIS# FIX THIS# FIX THIS# FIX THIS# FIX THIS# FIX THIS
        $self->logger("Directory for backup files and indent.log: $cruftDirectory");
    
        my @fileExtensions  = (".tex");# FIX THIS FIX THIS# FIX THIS# FIX THIS# FIX THIS# FIX THIS# FIX THIS# FIX THIS

        my $backupFile; 
    
        # backup file name is the base name
        $backupFile = basename($fileName,@fileExtensions);
    
        # add the user's backup directory to the backup path
        $backupFile = "$cruftDirectory/$backupFile";

        # local variables, determined from the YAML settings
        my $onlyOneBackUp = ${$self}{settings}{onlyOneBackUp};
        my $maxNumberOfBackUps = ${$self}{settings}{maxNumberOfBackUps};
        my $cycleThroughBackUps= ${$self}{settings}{cycleThroughBackUps};
        my $backupExtension= ${$self}{settings}{backupExtension};
    
        # if both ($onlyOneBackUp and $maxNumberOfBackUps) then we have
        # a conflict- er on the side of caution and turn off onlyOneBackUp
        if($onlyOneBackUp and $maxNumberOfBackUps>1) {
            $self->logger("WARNING: onlyOneBackUp=$onlyOneBackUp and maxNumberOfBackUps: $maxNumberOfBackUps");
            $self->logger("setting onlyOneBackUp=0 which will allow you to reach $maxNumberOfBackUps back ups");
            $onlyOneBackUp = 0;
        }
    
        # if the user has specified that $maxNumberOfBackUps = 1 then
        # they only want one backup
        if($maxNumberOfBackUps==1) {
            $onlyOneBackUp=1 ;
            $self->logger("FYI: you set maxNumberOfBackUps=1, so I'm setting onlyOneBackUp: 1 ");
        } elsif($maxNumberOfBackUps<=0 and !$onlyOneBackUp) {
            $onlyOneBackUp=0 ;
            $maxNumberOfBackUps=-1;
        }
    
        # if onlyOneBackUp is set, then the backup file will
        # be overwritten each time
        if($onlyOneBackUp) {
            $backupFile .= $backupExtension;
            $self->logger("copying $fileName to $backupFile");
            $self->logger("$backupFile was overwritten") if (-e $backupFile);
        } else {
            # start with a backup file .bak0 (or whatever $backupExtension is present)
            my $backupCounter = 0;
            $backupFile .= $backupExtension.$backupCounter;
    
            # if it exists, then keep going: .bak0, .bak1, ...
            while (-e $backupFile or $maxNumberOfBackUps>1) {
                if($backupCounter==$maxNumberOfBackUps) {
                    $self->logger("maxNumberOfBackUps reached ($maxNumberOfBackUps)");
    
                    # some users may wish to cycle through back up files, e.g:
                    #    copy myfile.bak1 to myfile.bak0
                    #    copy myfile.bak2 to myfile.bak1
                    #    copy myfile.bak3 to myfile.bak2
                    #
                    #    current back up is stored in myfile.bak4
                    if($cycleThroughBackUps) {
                        $self->logger("cycleThroughBackUps detected (see cycleThroughBackUps) ");
                        for(my $i=1;$i<=$maxNumberOfBackUps;$i++) {
                            # remove number from backUpFile
                            my $oldBackupFile = $backupFile;
                            $oldBackupFile =~ s/$backupExtension.*/$backupExtension/;
                            my $newBackupFile = $oldBackupFile;
    
                            # add numbers back on
                            $oldBackupFile .= $i;
                            $newBackupFile .= $i-1;
    
                            # check that the oldBackupFile exists
                            if(-e $oldBackupFile){
                            $self->logger(" copying $oldBackupFile to $newBackupFile ");
                                copy($oldBackupFile,$newBackupFile) or die "Could not write to backup file $backupFile. Please check permissions. Exiting.";
                            }
                        }
                    }
    
                    # rest maxNumberOfBackUps
                    $maxNumberOfBackUps=1 ;
                    last; # break out of the loop
                } elsif(!(-e $backupFile)) {
                    $maxNumberOfBackUps=1 ;
                    last; # break out of the loop
                }
                $self->logger(" $backupFile already exists, incrementing by 1...");
                $backupCounter++;
                $backupFile =~ s/$backupExtension.*/$backupExtension$backupCounter/;
            }
            $self->logger("copying $fileName to $backupFile");
        }
    
        # output these lines to the log file
        $self->logger("Backup file: ",$backupFile,"");
        $self->logger("Overwriting file: ",$fileName,"");
        copy($fileName,$backupFile) or die "Could not write to backup file $backupFile. Please check permissions. Exiting.";
    }

}
1;
