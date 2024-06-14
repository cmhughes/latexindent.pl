package LatexIndent::UTF8CmdLineArgsFileOperation;

use strict;
use warnings;
use feature qw( say state );
use utf8;
use Config qw( %Config );
use Encode qw(find_encoding decode encode );

use Exporter qw/import/;
our @EXPORT_OK
    = qw/commandlineargs_with_encode @new_args copy_with_encode exist_with_encode open_with_encode zero_with_encode read_yaml_with_encode isdir_with_encode mkdir_with_encode/;

our $encodingObject;  

if ($^O eq 'MSWin32') {
    my $encoding_sys = 'cp' . Win32::GetACP();
    $encodingObject = find_encoding( $encoding_sys );
    
    # Check if the encoding is valid.
    unless ( ref($encodingObject) ) {
        $encodingObject = find_encoding( 'utf-8' );
    }
}
else {
    $encodingObject = find_encoding( 'utf-8' );
}

sub copy_with_encode {
    use File::Copy;
    my ( $source, $destination ) = @_;

    if ( $FindBin::Script =~ /\.exe$/ ) {
        require Win32::Unicode::File;
        Win32::Unicode::File->import(qw(copyW));
        copyW( $source, $destination, 1 );
    }
    else {
        $source = $encodingObject->encode($source);
        $destination = $encodingObject->encode($destination);
        copy( $source, $destination );
    }
}

sub exist_with_encode {
    my ($filename) = @_;

    if ( $FindBin::Script =~ /\.exe$/ ) {
        require Win32::Unicode::File;
        Win32::Unicode::File->import(qw(statW));
        return statW($filename);
    }
    else {
        $filename = $encodingObject->encode($filename);
        return -e $filename;
    }
}

sub zero_with_encode {
    my ($filename) = @_;

    if ( $FindBin::Script =~ /\.exe$/ ) {
        require Win32::Unicode::File;
        Win32::Unicode::File->import(qw(file_size));
        my $size = file_size($filename);
        if ($size) {
            return 0;
        }
        else {
            return 1;
        }
    }
    else {
        $filename = $encodingObject->encode($filename);
        return -z $filename;
    }
}

sub open_with_encode {
    my $mode     = shift;
    my $filename = shift;
    my $fh;

    if ( $FindBin::Script =~ /\.exe$/ ) {
        require Win32::Unicode::File;
        Win32::Unicode::File->import;
        $fh = Win32::Unicode::File->new;
        if ( open $fh, $mode, $filename ) {
            return $fh;
        }
        else {
            return undef;
        }
    }
    else {
        $filename = $encodingObject->encode($filename);
        if ( open( $fh, $mode, $filename ) ) {
            return $fh;
        }
        else {
            return undef;
        }
    }
}

sub read_yaml_with_encode {
    use YAML::Tiny;
    my $filename = shift;

    my $fh          = open_with_encode( '<:encoding(UTF-8)', $filename ) or return undef;
    my $yaml_string = join( "", <$fh> );
    return YAML::Tiny->read_string($yaml_string);
}

sub isdir_with_encode {
    my $path = shift;

    if ( $FindBin::Script =~ /\.exe$/ ) {
        require Win32::Unicode::File;
        Win32::Unicode::File->import(qw(file_type));

        return file_type( 'd', $path );
    }
    else {
        $path = $encodingObject->encode($path);
        return -d $path;
    }
}

sub mkdir_with_encode {
    my $path = shift;

    if ( $FindBin::Script =~ /\.exe$/ ) {
        require Win32::Unicode::Dir;
        Win32::Unicode::Dir->import(qw(mkdirW));

        mkdirW($path);
    }
    else {
        require File::Path;
        File::Path->import(qw(make_path));
        $path = $encodingObject->encode($path);
        make_path($path);
    }
}

#https://stackoverflow.com/a/63868721
#https://stackoverflow.com/a/44489228
sub commandlineargs_with_encode {
    if ( $FindBin::Script =~ /\.exe$/ ) {
        require Win32::API;
        import Win32::API qw( ReadMemory );

        #use open ':std', ':encoding('.do { require Win32; "cp".Win32::GetConsoleOutputCP() }.')';

        use constant ptr_size => $Config{ptrsize};

        use constant ptr_pack_format => ptr_size == 8 ? 'Q'
            : ptr_size == 4 ? 'L'
            :                 die("Unrecognized ptrsize\n");

        use constant ptr_win32api_type => ptr_size == 8 ? 'Q'
            : ptr_size == 4 ? 'N'
            :                 die("Unrecognized ptrsize\n");

        sub lstrlenw {
            my ($ptr) = @_;

            state $lstrlenw = Win32::API->new( 'kernel32', 'lstrlenW', ptr_win32api_type, 'i' )
                or die($^E);

            return $lstrlenw->Call($ptr);
        }

        sub decode_lpcwstr {
            my ($ptr) = @_;
            return undef if !$ptr;

            my $num_chars = lstrlenw($ptr)
                or return '';

            return decode( 'UTF-16le', ReadMemory( $ptr, $num_chars * 2 ) );
        }

        # Returns true on success. Returns false and sets $^E on error.
        sub localfree {
            my ($ptr) = @_;

            state $localfree = Win32::API->new( 'kernel32', 'LocalFree', ptr_win32api_type, ptr_win32api_type )
                or die($^E);

            return $localfree->Call($ptr) == 0;
        }

        sub getcommandline {
            state $getcommandline = Win32::API->new( 'kernel32', 'GetCommandLineW', '', ptr_win32api_type )
                or die($^E);

            return decode_lpcwstr( $getcommandline->Call() );
        }

        # Returns a reference to an array on success. Returns undef and sets $^E on error.
        sub commandlinetoargv {
            my ($cmd_line) = @_;

            state $commandlinetoargv = Win32::API->new( 'shell32', 'CommandLineToArgvW', 'PP', ptr_win32api_type )
                or die($^E);

            my $cmd_line_encoded = encode( 'UTF-16le', $cmd_line . "\0" );
            my $num_args_buf     = pack( 'i', 0 );                           # Allocate space for an "int".

            my $arg_ptrs_ptr = $commandlinetoargv->Call( $cmd_line_encoded, $num_args_buf )
                or return undef;

            my $num_args = unpack( 'i', $num_args_buf );
            my @args     = map { decode_lpcwstr($_) } unpack ptr_pack_format . '*',
                ReadMemory( $arg_ptrs_ptr, ptr_size * $num_args );

            localfree($arg_ptrs_ptr);
            return \@args;
        }

        my $cmd_line = getcommandline();
        our @new_args = $cmd_line;
        $cmd_line =~ s/(^(.*?)\.pl\"? )//g;
        $cmd_line =~ s/(^(.*?)\.exe\"? )//g;
        my $args = commandlinetoargv($cmd_line) or die("CommandLineToArgv: $^E\n");
        @ARGV = @{$args};
    }
    else {
        @ARGV = map { decode( $encodingObject, $_ ) } @ARGV;
        our @new_args = @ARGV;
    }
}

1;
