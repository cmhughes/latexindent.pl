package LatexIndent::CommandLineArgs;

use strict;
use warnings;
use feature qw( say state );
use utf8;
use Config      qw( %Config );
use Encode      qw( decode encode );

use Exporter qw/import/;
our @EXPORT_OK = qw/commandlineargs_with_encode @new_args/;

#https://stackoverflow.com/a/63868721
#https://stackoverflow.com/a/44489228
sub commandlineargs_with_encode{

    if ($^O eq 'MSWin32') {
    require Win32::API;
    import Win32::API qw( ReadMemory );
    #use open ':std', ':encoding('.do { require Win32; "cp".Win32::GetConsoleOutputCP() }.')'; 

    use constant PTR_SIZE => $Config{ptrsize};

    use constant PTR_PACK_FORMAT =>
          PTR_SIZE == 8 ? 'Q'
        : PTR_SIZE == 4 ? 'L'
        : die("Unrecognized ptrsize\n");

    use constant PTR_WIN32API_TYPE =>
          PTR_SIZE == 8 ? 'Q'
        : PTR_SIZE == 4 ? 'N'
        : die("Unrecognized ptrsize\n");


    sub lstrlenW {
        my ($ptr) = @_;

        state $lstrlenW = Win32::API->new('kernel32', 'lstrlenW', PTR_WIN32API_TYPE, 'i')
            or die($^E);

        return $lstrlenW->Call($ptr);
    }


    sub decode_LPCWSTR {
        my ($ptr) = @_;
        return undef if !$ptr;

        my $num_chars = lstrlenW($ptr)
            or return '';

        return decode('UTF-16le', ReadMemory($ptr, $num_chars * 2));
    }


    # Returns true on success. Returns false and sets $^E on error.
    sub LocalFree {
        my ($ptr) = @_;

        state $LocalFree = Win32::API->new('kernel32', 'LocalFree', PTR_WIN32API_TYPE, PTR_WIN32API_TYPE)
            or die($^E);

        return $LocalFree->Call($ptr) == 0;
    }


    sub GetCommandLine {
        state $GetCommandLine = Win32::API->new('kernel32', 'GetCommandLineW', '', PTR_WIN32API_TYPE)
            or die($^E);

        return decode_LPCWSTR($GetCommandLine->Call());
    }


    # Returns a reference to an array on success. Returns undef and sets $^E on error.
    sub CommandLineToArgv {
        my ($cmd_line) = @_;

        state $CommandLineToArgv = Win32::API->new('shell32', 'CommandLineToArgvW', 'PP', PTR_WIN32API_TYPE)
            or die($^E);

        my $cmd_line_encoded = encode('UTF-16le', $cmd_line."\0");
        my $num_args_buf = pack('i', 0);  # Allocate space for an "int".

        my $arg_ptrs_ptr = $CommandLineToArgv->Call($cmd_line_encoded, $num_args_buf)
            or return undef;

        my $num_args = unpack('i', $num_args_buf);
        my @args =
            map { decode_LPCWSTR($_) }
                unpack PTR_PACK_FORMAT.'*',
                    ReadMemory($arg_ptrs_ptr, PTR_SIZE * $num_args);

        LocalFree($arg_ptrs_ptr);
        return \@args;
    }


        my $cmd_line = GetCommandLine();
        our @new_args = $cmd_line;
        $cmd_line =~ s/(^(.*?)\.pl\"? )//g;
        $cmd_line =~ s/(^(.*?)\.exe\"? )//g;
        my $args = CommandLineToArgv($cmd_line) or die("CommandLineToArgv: $^E\n");
        @ARGV = @{$args};
    }
    else {
        my $encodingObject = "utf-8";
        @ARGV = map { decode($encodingObject, $_) } @ARGV;
        our @new_args = @ARGV;
    }

}

1;