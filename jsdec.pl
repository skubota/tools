#!/usr/local/bin/perl -w

use strict;
use Data::Dumper;
use JE;
use HTML::Parser;
my $html_parser = HTML::Parser->new(
    api_version     => 3,
    start_h         => [ \&read_tags, "self, tagname, attr, text" ],
    text_h          => [ \&read_text, "dtext" ],
    marked_sections => 1,
);

if ( $ARGV[0] ) {
    $html_parser->parse_file( $ARGV[0] );
}
else {
    $html_parser->parse_file("-");
}

sub read_tags {
    my ( $self, $event, $tagname, $attr, $text ) = @_;
    if ( $tagname eq 'script' ) {
        if ( $attr->{src} ) {
            print "script src: ", $attr->{src}, "\n";
        }
    }
}

sub read_text {
    my ($text) = @_;
    my $j = new JE;
    $text =~ s/document\.location\.href=(.+)[;]/jsdec_href=$1;/g;
    $text =~ s/document\.location=(.+)[;]/jsdec_location=$1;/g;
    $text =~ s/window.onerror=(.+)[;]/jsdec_onerror=$1;/g;
    $text =~ s/document\.cookie=(.+)[;]/jsdec_cookie=$1;/g;
    $text =~ s/document\.write\((.+)\)[;]/jsdec_write=$1;/g;
    $text =~ s/alert\((.+)\)[;]/jsdec_alert=$1;/g;
    $text =~ s/[\r\n]*//g;

    my $obj = $j->eval($text);
    print "<!-- onerror: -->", $j->{jsdec_onerror}, "\n"
        if ( $j->{jsdec_onerror} );
    print "<!-- cookie: -->", $j->{jsdec_cookie}, "\n"
        if ( $j->{jsdec_cookie} );
    print "<!-- location: -->", $j->{jsdec_location}, "\n"
        if ( $j->{jsdec_location} );
    print "<!-- href: -->",  $j->{jsdec_href},  "\n" if ( $j->{jsdec_href} );
    print "<!-- write: -->", $j->{jsdec_write}, "\n" if ( $j->{jsdec_write} );
    print "<!-- alert: -->", $j->{jsdec_alert}, "\n" if ( $j->{jsdec_alert} );
}

