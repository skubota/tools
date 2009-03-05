#!/usr/local/bin/perl

use strict;

my $data = '';

if ( $ARGV[0] ) {
    $data = $ARGV[0];
}
else {
    open my $fp, "-";
    while ( defined( my $line = <$fp> ) ) {
        $data .= $line;
    }
    close $fp;
}

foreach my $char ( split '', $data ) {
    my $c = unpack( "B8", $char );
    vec( $c, 0, 1 ) = 0;
    printf "%s", pack( "c*", oct "0b" . $c );
}
