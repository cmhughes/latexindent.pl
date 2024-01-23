package LatexIndent::FileOperation;

use strict;
use warnings;
use utf8;
use Encode   qw/ encode decode find_encoding /;

use Exporter qw/import/;
our @EXPORT_OK = qw/copy_with_encode exist_with_encode open_with_encode zero_with_encode read_yaml_with_encode/;

use Win32;
my $encodingObject;
if ($^O eq 'MSWin32') {
    my $encoding_sys = 'cp' . Win32::GetACP();
    $encodingObject = find_encoding( $encoding_sys );
}
else {
    $encodingObject = "utf-8";
}


sub copy_with_encode {
    use File::Copy;
    my ( $source, $destination ) = @_;

    $source = encode( $encodingObject, $source );
    $destination = encode( $encodingObject, $destination );
    copy( $source, $destination );

}

sub exist_with_encode {
    my ($filename) = @_;
    
    $filename = encode( $encodingObject, $filename );
    return -e $filename;
}


sub zero_with_encode {
    my ($filename) = @_;

    $filename = encode( $encodingObject, $filename );
    return -z $filename;
}

sub open_with_encode {
    my $mode       = shift;
    my $filename       = shift;

    my $fh;
    $filename = encode( $encodingObject, $filename );
    open( $fh, $mode, $filename );
    return $fh;
}

sub read_yaml_with_encode {
    use YAML::Tiny;
    my $filename       = shift;
    
    my $fh;
    $filename = encode( $encodingObject, $filename );
    return YAML::Tiny->read($filename );
}

1;