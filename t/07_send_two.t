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

$Net::SMTP::OneLiner::DEBUG = 1;
    send_mail( "jetero\@cpan.org", "jettero\@cpan.org", "test - " . time, "This is your test... #1", undef, 'paul@mei.net');

$Net::SMTP::OneLiner::HOSTNAME = "mx.voltar.org";
    send_mail( "jetero\@cpan.org", "jettero\@cpan.org", "test - " . time, "This is your test... #2", 'paul@mei.net');

    ok 1;  # yeah, I don't really check to see if it worked... that's what DEBUG = 1 is all about...
    ok 1;
