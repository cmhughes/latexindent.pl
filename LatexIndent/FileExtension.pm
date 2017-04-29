package LatexIndent::FileExtension;
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
use utf8;
use PerlIO::encoding;
use open ':std', ':encoding(UTF-8)';
use File::Basename; # to get the filename and directory path
use Exporter qw/import/;
use LatexIndent::GetYamlSettings qw/%masterSettings/;
our @EXPORT_OK = qw/file_extension_check/;

sub file_extension_check{
    my $self = shift;

    # grab the filename
    my $fileName = ${$self}{fileName};

    # grab the file extension preferences
    my %fileExtensionPreference= %{$masterSettings{fileExtensionPreference}};

    # sort the file extensions by preference 
    my @fileExtensions = sort { $fileExtensionPreference{$a} <=> $fileExtensionPreference{$b} } keys(%fileExtensionPreference);
    
    # get the base file name, allowing for different extensions (possibly no extension)
    my ($dir, $name, $ext) = fileparse($fileName, @fileExtensions);

    # check to make sure given file type is supported
    if( -e $fileName  and !$ext ){
        my $message = "The file $fileName exists , but the extension does not correspond to any given in fileExtensionPreference; consinder updating fileExtensionPreference.";
        $self->logger($message,'heading');
        $self->output_logfile;
        die($message);
    }

    # if no extension, search according to fileExtensionPreference
    if (!$ext) {
        $self->logger("File extension work:",'heading');
        $self->logger("latexindent called to act upon $fileName with an, as yet, unrecognised file extension;");
        $self->logger("searching for file with an extension in the following order (see fileExtensionPreference):");
        $self->logger(join("\n",@fileExtensions));

        my $fileFound = 0;
        # loop through the known file extensions (see @fileExtensions)
        foreach (@fileExtensions ){
            if ( -e $fileName.$_ ) {
               $self->logger("$fileName$_ found!");
               $fileName .= $_;
               $self->logger("Updated fileName to $fileName");
               ${$self}{fileName} = $fileName ;
               $fileFound = 1;
               $ext = $_;
               last;
            }
        }
        unless($fileFound){
          $self->logger("I couldn't find a match for $fileName in fileExtensionPreference (see defaultSettings.yaml)");
          foreach (@fileExtensions ){
            $self->logger("I searched for $fileName$_");
          }
          $self->logger("but couldn't find any of them.");
          $self->logger("Consider updating fileExtensionPreference. Error: Exiting, no indendation done.");
          $self->output_logfile;
          die "I couldn't find a match for $fileName in fileExtensionPreference.\nExiting, no indendation done."; 
        }
      } else {
        # if the file has a recognised extension, check that the file exists
        unless( -e $fileName ){
          my $message = "Error: I couldn't find $fileName, are you sure it exists?. No indentation done. Exiting.";
          $self->logger($message);
          $self->output_logfile;
          die $message;
        }
      }

    # store the file extension
    ${$self}{fileExtension} = $ext;

    # read the file into the Document body
    my @lines;
    open(MAINFILE, $fileName) or die "Could not open input file, $fileName";
    push(@lines,$_) while(<MAINFILE>);
    close(MAINFILE);

    # the all-important step: update the body
    ${$self}{body} = join("",@lines);
}
1;
