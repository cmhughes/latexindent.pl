package LatexIndent::BackUpFileProcedure;

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
use LatexIndent::GetYamlSettings qw/%mainSettings/;
use LatexIndent::Switches        qw/%switches/;
use LatexIndent::LogFile         qw/$logger/;
use File::Basename;    # to get the filename and directory path
use File::Copy;        # to copy the original file to backup (if overwrite option set)
use Exporter qw/import/;
use Encode   qw/decode/;
our @EXPORT_OK = qw/create_back_up_file check_if_different/;

use LatexIndent::FileOperation qw/copy_with_encode exist_with_encode open_with_encode  zero_with_encode read_yaml_with_encode/;
use utf8;

# copy main file to a backup in the case of the overwrite switch being active

sub create_back_up_file {
    my $self = shift;

    return unless ( ${$self}{overwrite} );

    # if we want to overwrite the current file create a backup first
    $logger->info("*Backup procedure (-w flag active):");

    my $fileName = ${$self}{fileName};

    # grab the file extension preferences
    my %fileExtensionPreference = %{ $mainSettings{fileExtensionPreference} };

    # sort the file extensions by preference
    my @fileExtensions
        = sort { $fileExtensionPreference{$a} <=> $fileExtensionPreference{$b} } keys(%fileExtensionPreference);

    # backup file name is the base name
    my $backupFileNoExt = basename( ${$self}{fileName}, @fileExtensions );

    # add the user's backup directory to the backup path
    $backupFileNoExt = "${$self}{cruftDirectory}/$backupFileNoExt";

    # local variables, determined from the YAML settings
    my $onlyOneBackUp       = $mainSettings{onlyOneBackUp};
    my $maxNumberOfBackUps  = $mainSettings{maxNumberOfBackUps};
    my $cycleThroughBackUps = $mainSettings{cycleThroughBackUps};
    my $backupExtension     = $mainSettings{backupExtension};

    # if both onlyOneBackUp and maxNumberOfBackUps are set, then we have a conflict
    # err on the side of caution and turn off onlyOneBackUp
    if ( $onlyOneBackUp and $maxNumberOfBackUps >= 1 ) {
        $logger->warn("*onlyOneBackUp=$onlyOneBackUp and maxNumberOfBackUps=$maxNumberOfBackUps");
        $logger->warn("setting onlyOneBackUp=0 which will allow you to reach $maxNumberOfBackUps backups");
        $onlyOneBackUp = 0;
    }

    # determine the backup file name by adjoining backupExtension
    my $backupFile = $backupFileNoExt . $backupExtension;

    # if onlyOneBackUp is *not* set, add a number to the backup file name
    if ( !$onlyOneBackUp ) {
        my $backupCounter = 0;

        # if the file already exists, increment the number until either
        # the file does not exist, or you reach the maximal number of backups
        while ( exist_with_encode( $backupFile . $backupCounter ) and $backupCounter != ( $maxNumberOfBackUps - 1 ) ) {
            $logger->info("$backupFile$backupCounter already exists, incrementing by 1 (see maxNumberOfBackUps)");
            $backupCounter++;
        }
        $backupFile .= $backupCounter;
    }

    # if the backup file already exists, output some information in the log file
    # and proceed to cycleThroughBackUps if the latter is set
    if ( exist_with_encode( $backupFile ) ) {
        if ($onlyOneBackUp) {
            $logger->info("$backupFile will be overwritten (see onlyOneBackUp)");
        }
        else {
            $logger->info("$backupFile will be overwritten (maxNumberOfBackUps reached, see maxNumberOfBackUps)");

            # some users may wish to cycle through backup files, e.g.:
            #    copy myfile.bak1 to myfile.bak0
            #    copy myfile.bak2 to myfile.bak1
            #    copy myfile.bak3 to myfile.bak2
            #
            #    current backup is stored in myfile.bak4
            if ($cycleThroughBackUps) {
                $logger->info("cycleThroughBackUps detected (see cycleThroughBackUps)");
                my $oldBackupFile;
                my $newBackupFile;
                for ( my $i = 1; $i < $maxNumberOfBackUps; $i++ ) {
                    $oldBackupFile = $backupFileNoExt . $backupExtension . $i;
                    $newBackupFile = $backupFileNoExt . $backupExtension . ( $i - 1 );

                    # check that the oldBackupFile exists
                    if ( exist_with_encode( $oldBackupFile ) ) {
                        $logger->info("Copying $oldBackupFile to $newBackupFile...");
                        if ( !( copy_with_encode( $oldBackupFile, $newBackupFile ) ) ) {
                            $logger->fatal("*Could not write to backup file $newBackupFile. Please check permissions.");
                            $logger->fatal("Exiting, no indentation done.");
                            $self->output_logfile();
                            exit(5);
                        }
                    }
                }
            }
        }
    }

    # output these lines to the log file
    $logger->info("Backing up $fileName to $backupFile...");
    $logger->info("$fileName will be overwritten after indentation");
    if ( !( copy_with_encode( $fileName, $backupFile ) ) ) {
        $logger->fatal("*Could not write to backup file $backupFile. Please check permissions.");
        $logger->fatal("Exiting, no indentation done.");
        $self->output_logfile();
        exit(5);
    }
}

sub check_if_different {
    my $self = shift;

    if ( ${$self}{originalBody} eq ${$self}{body} ) {
        $logger->info("*-wd switch active");
        $logger->info("Original body matches indented body, NOT overwriting, no backup files created");
        return;
    }

    # otherwise, continue
    $logger->info("*-wd switch active");
    $logger->info("Original body is *different* from indented body");
    $logger->info("activating overwrite switch, -w");
    ${$self}{overwrite} = 1;
    $self->create_back_up_file;
}

1;
