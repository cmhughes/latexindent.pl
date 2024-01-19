package LatexIndent::FileOperation;

use strict;
use warnings;
use utf8;
use Encode   qw/ encode decode find_encoding /;
use LatexIndent::Switches   qw/%switches/;

use Exporter qw/import/;
our @EXPORT_OK = qw/Copy_new Exist_new Open_new Zero_new ReadYaml_new/;

sub Copy_new {
    use File::Copy;
    my ( $source, $destination ) = @_;

    if ( $switches{encoding} and ref( find_encoding( $switches{encoding} ) ) ) {
        my $encodingObject = find_encoding( $switches{encoding} );
        $source = encode( $encodingObject, $source );
        $destination = encode( $encodingObject, $destination );
        copy( $source, $destination );
    }
    else {
        copy( $source, $destination );
    }
}

sub Exist_new {
    my ($filename) = @_;
    
    if ( $switches{encoding} and ref( find_encoding( $switches{encoding} ) ) ) {
        my $encodingObject = find_encoding( $switches{encoding} );
        $filename = encode( $encodingObject, $filename );
        return -e $filename;
    }
    else {
        return -e $filename;
    }
}


sub Zero_new {
    my ($filename) = @_;

    if ( $switches{encoding} and ref( find_encoding( $switches{encoding} ) ) ) {
        my $encodingObject = find_encoding( $switches{encoding} );
        $filename = encode( $encodingObject, $filename );
        return -z $filename;
    }
    else {
        return -z $filename;
    }
}

sub Open_new {
    my $mode       = shift;
    my $filename       = shift;

    my $fh;
    if ( $switches{encoding} and ref( find_encoding( $switches{encoding} ) ) ) {
        my $encodingObject = find_encoding( $switches{encoding} );
        $filename = encode( $encodingObject, $filename );
        open( $fh, $mode, $filename );
        return $fh;
    }
    else {
        open( $fh, $mode, $filename );
        return $fh;
    }
}

sub ReadYaml_new {
    use YAML::Tiny;
    my $filename       = shift;
    
    my $fh;
    if ( $switches{encoding} and ref( find_encoding( $switches{encoding} ) ) ) {
        my $encodingObject = find_encoding( $switches{encoding} );
        $filename = encode( $encodingObject, $filename );
        return YAML::Tiny->read($filename );
    }
    else {
        return YAML::Tiny->read($filename );
    }
}

1;