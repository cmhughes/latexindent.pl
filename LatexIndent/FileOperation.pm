package LatexIndent::FileOperation;

use strict;
use warnings;
use utf8;
use Encode   qw/ encode decode find_encoding /;

use Exporter qw/import/;
our @EXPORT_OK = qw/copy_with_encode exist_with_encode open_with_encode zero_with_encode read_yaml_with_encode isdir_with_encode mkdir_with_encode/;


sub copy_with_encode {
    use File::Copy;
    my ($source, $destination) = @_;

    if ($^O eq 'MSWin32') {
        require Win32::Unicode::File;
        Win32::Unicode::File->import(qw(copyW));
        copyW( $source, $destination, 1 );
    }
    else {
        copy( $source, $destination );
    }
}


sub exist_with_encode {
    my ($filename) = @_;

    if ($^O eq 'MSWin32') {
        require Win32::Unicode::File;
        Win32::Unicode::File->import(qw(statW));
        return statW( $filename );
    }
    else {
        return -e $filename;
    }
}


sub zero_with_encode {
    my ($filename) = @_;

    if ($^O eq 'MSWin32') {
        require Win32::Unicode::File;
        Win32::Unicode::File->import(qw(file_size));
        my $size = file_size( $filename );
            if ($size) {
                return 0;
            } else {
                return 1;
            }
    }
    else {
        return -z $filename;
    }
}


sub open_with_encode {
    my $mode       = shift;
    my $filename       = shift;
    my $fh;

    if ($^O eq 'MSWin32') {
        require Win32::Unicode::File;
        Win32::Unicode::File->import;
        $fh = Win32::Unicode::File->new;
        open $fh, $mode, $filename or die "Can't open file: $!";
        return $fh;
    }
    else {
        open( $fh, $mode, $filename ) or die "Can't open file: $!";
        return $fh;
    }
}



sub read_yaml_with_encode {
    use YAML::Tiny;
    my $filename       = shift;

    my $fh = open_with_encode( '<:encoding(UTF-8)', $filename )  or die $!;  
    my $yaml_string = join( "", <$fh> );
    return YAML::Tiny->read_string( $yaml_string );
}


sub isdir_with_encode {
    my $path       = shift;

    if ($^O eq 'MSWin32') {
        require Win32::Unicode::File;
        Win32::Unicode::File->import(qw(file_type));
        
        return file_type('d', $path);
    }
    else {
        return -d $path;
    }
}

sub mkdir_with_encode {
    my $path = shift;

    if ($^O eq 'MSWin32') {
        require Win32::Unicode::Dir;
        Win32::Unicode::Dir->import(qw(mkdirW));
        
        mkdirW($path) or die "Cannot create directory $path: $!";
    }
    else {
        require File::Path;
        File::Path->import(qw(make_path));

        my $created = make_path($path);
        die "Cannot create directory $path" unless $created;
    }
}

1;