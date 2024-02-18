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

    use constant ptr_size => $Config{ptrsize};

    use constant ptr_pack_format =>
          ptr_size == 8 ? 'Q'
        : ptr_size == 4 ? 'L'
        : die("Unrecognized ptrsize\n");

    use constant ptr_win32api_type =>
          ptr_size == 8 ? 'Q'
        : ptr_size == 4 ? 'N'
        : die("Unrecognized ptrsize\n");


    sub lstrlenw {
        my ($ptr) = @_;

        state $lstrlenw = Win32::API->new('kernel32', 'lstrlenW', ptr_win32api_type, 'i')
            or die($^E);

        return $lstrlenw->Call($ptr);
    }


    sub decode_lpcwstr {
        my ($ptr) = @_;
        return undef if !$ptr;

        my $num_chars = lstrlenw($ptr)
            or return '';

        return decode('UTF-16le', ReadMemory($ptr, $num_chars * 2));
    }


    # Returns true on success. Returns false and sets $^E on error.
    sub localfree {
        my ($ptr) = @_;

        state $localfree = Win32::API->new('kernel32', 'LocalFree', ptr_win32api_type, ptr_win32api_type)
            or die($^E);

        return $localfree->Call($ptr) == 0;
    }


    sub getcommandline {
        state $getcommandline = Win32::API->new('kernel32', 'GetCommandLineW', '', ptr_win32api_type)
            or die($^E);

        return decode_lpcwstr($getcommandline->Call());
    }


    # Returns a reference to an array on success. Returns undef and sets $^E on error.
    sub commandlinetoargv {
        my ($cmd_line) = @_;

        state $commandlinetoargv = Win32::API->new('shell32', 'CommandLineToArgvW', 'PP', ptr_win32api_type)
            or die($^E);

        my $cmd_line_encoded = encode('UTF-16le', $cmd_line."\0");
        my $num_args_buf = pack('i', 0);  # Allocate space for an "int".

        my $arg_ptrs_ptr = $commandlinetoargv->Call($cmd_line_encoded, $num_args_buf)
            or return undef;

        my $num_args = unpack('i', $num_args_buf);
        my @args =
            map { decode_lpcwstr($_) }
                unpack ptr_pack_format.'*',
                    ReadMemory($arg_ptrs_ptr, ptr_size * $num_args);

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
        my $encodingObject = "utf-8";
        @ARGV = map { decode($encodingObject, $_) } @ARGV;
        our @new_args = @ARGV;
    }
}

1;