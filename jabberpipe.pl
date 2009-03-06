#!/usr/local/bin/perl -w

use strict;
use warnings;
use Getopt::Long;
use Net::Jabber;
use utf8;
#
# % uname -a | jabberpipe.pl --server=jabber.jp --user=pipes --pass=pass --room=chat
# % date | jabberpipe.pl --server=jabber.jp --user=pipes --pass=pass --to='to@example.jp'
#
#################################################################
my $server = '';             #jabberサーバー
my $user   = '';             #jabberユーザネーム
my $pass   = '';             #jabberパスワード
my $res    = 'jabberpipe';
my $nick   = 'jabberpipe';
my $type   = 'chat';
my $room   = 'jabberpipe';
my $to     = '';
#################################################################
GetOptions(
    '--server|s=s' => \$server,
    '--user|u=s'   => \$user,
    '--pass|p=s'   => \$pass,
    '--res|r=s'    => \$res,
    '--nick|n=s'   => \$nick,
    '--room=s'     => \$room,
    '--type|t=s'   => \$type,
    '--to=s'       => \$to,
);

# Jabber Initialize
my $jabber = new Net::Jabber::Client(
  debuglevel => 0,
  debugfile  => "debug.log",
);
my $status = $jabber->Connect( hostname => $server );
if ( !( defined($status) ) ) {
    print "ERROR:  Jabber server is down or connection was not allowed.\n";
    print "        ($!)\n";
    exit(0);
}
my @result = $jabber->AuthSend(
    username => $user,
    password => $pass,
    resource => $res
);
if ( $result[0] ne "ok" ) {
    print "ERROR: Authorization failed: $result[0] - $result[1]\n";
    exit(0);
}
my %roster = $jabber->RosterGet();
$jabber->PresenceSend();

$type='groupchat' if($room);
if($type eq 'groupchat'){
  $jabber->MUCJoin( room => $room, server => 'conference.'.$server, nick => $nick );
  $to=$room . '@conference.' . $server;
}
sleep 2;
while (<STDIN>) {
    chomp;
    $jabber->MessageSend(
        to   => $to,
        type => $type,
        body => $_
    );
}
$jabber->Disconnect();

