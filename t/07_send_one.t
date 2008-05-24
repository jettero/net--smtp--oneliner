# vi:fdm=marker fdl=0 syntax=perl:
# $Id: 07_send_two.t,v 1.1 2005/08/23 11:13:43 jettero Exp $

use strict;
use Test;

unless( $ENV{HOSTNAME} =~ m/^corky/ and $ENV{USER} eq "jettero" ) {
    plan tests => 0;
    exit;
}

plan tests => 2;

use Net::SMTP::OneLiner;

$Net::SMTP::OneLiner::HOSTNAME = "tachy.mei.net";
    send_mail( "jetero\@cpan.org", "jettero\@cpan.org", "test - " . time, "This is your test... #2", 'paul@mei.net');

    ok 1;
