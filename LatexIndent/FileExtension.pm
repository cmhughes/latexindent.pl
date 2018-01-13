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
use Log::Log4perl qw(get_logger :levels);
use LatexIndent::GetYamlSettings qw/%masterSettings/;
use LatexIndent::Switches qw/%switches/;
our @EXPORT_OK = qw/file_extension_check/;

sub file_extension_check{
    my $self = shift;

    # grab the logger object
    my $logger = get_logger("Document");

    # grab the filename
    my $fileName = ${$self}{fileName};

    # grab the file extension preferences
    my %fileExtensionPreference= %{$masterSettings{fileExtensionPreference}};

    # sort the file extensions by preference 
    my @fileExtensions = sort { $fileExtensionPreference{$a} <=> $fileExtensionPreference{$b} } keys(%fileExtensionPreference);
    
    # get the base file name, allowing for different extensions (possibly no extension)
    my ($name, $dir, $ext) = fileparse($fileName, @fileExtensions);
    ${$self}{baseName} = $name;

    # check to make sure given file type is supported
    if( -e $fileName  and !$ext ){
        my $message = "The file $fileName exists , but the extension does not correspond to any given in fileExtensionPreference; consinder updating fileExtensionPreference.";
        $logger->fatal("*$message");
        die($message);
    }

    # if no extension, search according to fileExtensionPreference
    if ($fileName ne "-"){
        if (!$ext) {
            $logger->info("*File extension work:");
            $logger->info("latexindent called to act upon $fileName with a file extension;\nsearching for file with an extension in the following order (see fileExtensionPreference):");
            $logger->info(join("\n",@fileExtensions));

            my $fileFound = 0;
            # loop through the known file extensions (see @fileExtensions)
            foreach (@fileExtensions ){
                if ( -e $fileName.$_ ) {
                   $logger->info("$fileName$_ found!");
                   $fileName .= $_;
                   $logger->info("Updated fileName to $fileName");
                   ${$self}{fileName} = $fileName ;
                   $fileFound = 1;
                   $ext = $_;
                   last;
                }
            }
            unless($fileFound){
              $logger->fatal("*I couldn't find a match for $fileName in fileExtensionPreference (see defaultSettings.yaml)");
              foreach (@fileExtensions ){
                $logger->fatal("I searched for $fileName$_");
              }
              $logger->fatal("but couldn't find any of them.\nConsider updating fileExtensionPreference.\nExiting, no indendation done.");
              die "I couldn't find a match for $fileName in fileExtensionPreference.\nExiting, no indendation done."; 
            }
          } else {
            # if the file has a recognised extension, check that the file exists
            unless( -e $fileName ){
              my $message = "I couldn't find $fileName, are you sure it exists?.\nNo indentation done.\nExiting.";
              $logger->fatal("*$message");
              die $message;
            }
          }
     }

    # store the file extension
    ${$self}{fileExtension} = $ext;

    # check to see if -o switch is active
    if($switches{outputToFile}){
        
        $logger->info("*-o switch active: output file check");

        if ($fileName eq "-" and $switches{outputToFile} =~ m/^\+/){
            $logger->info("STDIN input mode active, -o switch is removing all + symbols");
            $switches{outputToFile} =~ s/\+//g;
        }
        # the -o file name might begin with a + symbol
        if($switches{outputToFile} =~ m/^\+(.*)/ and $1 ne "+"){
            $logger->info("-o switch called with + symbol at the beginning: $switches{outputToFile}");
            $switches{outputToFile} = ${$self}{baseName}.$1;
            $logger->info("output file is now: $switches{outputToFile}");
        }

        my $strippedFileExtension = ${$self}{fileExtension};
        $strippedFileExtension =~ s/\.//; 
        $strippedFileExtension = "tex" if ($strippedFileExtension eq "");

        # grab the name, directory, and extension of the output file
        my ($name, $dir, $ext) = fileparse($switches{outputToFile}, $strippedFileExtension);

        # if there is no extension, then add the extension from the file to be operated upon
        if(!$ext){
            $logger->info("-o switch called with file name without extension: $switches{outputToFile}");
            $switches{outputToFile} = $name.($name=~m/\.\z/ ? q() : ".").$strippedFileExtension;
            $logger->info("Updated to $switches{outputToFile} as the file extension of the input file is $strippedFileExtension");
        }

        # the -o file name might end with ++ in which case we wish to search for existence, 
        # and then increment accordingly
        $name =~ s/\.$//;
        if($name =~ m/\+\+$/){
            $logger->info("-o switch called with file name ending with ++: $switches{outputToFile}");
            $name =~ s/\+\+$//;
            $name = ${$self}{baseName} if ($name eq "");
            my $outputFileCounter = 0;
            my $fileName = $name.$outputFileCounter.".".$strippedFileExtension; 
            $logger->info("will search for existence and increment counter, starting with $fileName");
            while( -e $fileName ){
                $logger->info("$fileName exists, incrementing counter");
                $outputFileCounter++;
                $fileName = $name.$outputFileCounter.".".$strippedFileExtension; 
            }
            $logger->info("$fileName does not exist, and will be the output file");
            $switches{outputToFile} = $fileName;
        }
    }

    # read the file into the Document body
    my @lines;
    if($fileName ne "-"){
        open(MAINFILE, $fileName) or die "Could not open input file, $fileName";
        push(@lines,$_) while(<MAINFILE>);
        close(MAINFILE);
    } else {
            push(@lines,$_) while (<>)
    }

    # the all-important step: update the body
    ${$self}{body} = join("",@lines);
}
1;
