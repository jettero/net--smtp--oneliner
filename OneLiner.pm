# vi:fdm=marker fdl=0 syntax=perl:
# $Id: OneLiner.pm,v 1.1 2005/08/23 11:13:43 jettero Exp $

package Net::SMTP::OneLiner;

use strict;
use Carp;
use Net::SMTP;
use warnings;

require Exporter;

our @ISA = qw(Exporter);

our @EXPORT = qw( send_mail );
our $VERSION = "2.0";

our $HOSTNAME = "localhost";
our $PORT     = 25;
our $ELHO     = "localhost";
our $DEBUG    = 0;
our $TIMEO    = 20;

our $CONTENT_TYPE      = "text/plain; charset=UTF-8";
our $TRANSFER_ENCODING = "quoted-printable";

1;

sub send_mail {
    my ($from, $to, $subj, $msg, $cc, $bcc, $labl) = @_;

    my $to_hit = $HOSTNAME;
       $to_hit .= ":$PORT" if $PORT ne "25";

    my $smtp = Net::SMTP->new($to_hit, Hello=>$ELHO, Timeout=>$TIMEO, Debug=>$DEBUG) or croak $!;

    $to  = [ $to  ] unless ref $to;
    $cc  = [ $cc  ] unless ref $cc;
    $bcc = [ $bcc ] unless ref $bcc;

    @$to  = grep {defined $_} @$to;
    @$cc  = grep {defined $_} @$cc;
    @$bcc = grep {defined $_} @$bcc;

    croak "You need to specifie at least one recipient" unless (@$to + @$cc + @$bcc) > 0;

    $smtp->mail($from);
    $smtp->to(@$to, @$cc, @$bcc);

    $smtp->data;

    for ($from, @$to, @$cc) {
        $_ = "$labl->{$_} <$_>" if defined $labl->{$_};
    }

    $to = join(", ", @$to);
    $cc = join(", ", @$cc);

    $smtp->datasend("From: $from\n");
    $smtp->datasend("To: $to\n") if $to;
    $smtp->datasend("CC: $cc\n") if $cc;
    $smtp->datasend("Subject: $subj\n") if $subj;
    $smtp->datasend("Content-Type: $CONTENT_TYPE\n");
    $smtp->datasend("Content-Transfer-Encoding: $TRANSFER_ENCODING\n");
    $smtp->datasend("\n");

    $smtp->datasend($msg);

    $smtp->dataend;
    $smtp->quit;
}

__END__

=head1 NAME

Net::SMTP::OneLiner - extension that polutes the local namespace with a send_mail() function.

=head1 A brief example

    use Net::SMTP::OneLiner;

    my $from = 'me@mydomain.tld';
    my $to   = [qw(some@targ.tld one@targ.tld)];
    my $cc   = [qw(some@targ.tld one@targ.tld)];
    my $bcc  = [qw(some@targ.tld one@targ.tld)];
    my $subj = "The Subject";
    my $msg  = "The Message";
    my $labl = { 'me@mydomain.tld' => "My RealName", 'one@targ.tld' => "Their realname" };

     
    # Examples:

    send_mail($from, $to, $subj, $msg);
    send_mail($from, $to, $subj, $msg, $cc);
    send_mail($from, $to, $subj, $msg, undef, $bcc);
    send_mail($from, $to, $subj, $msg, $cc, $bcc, $labl);
    send_mail($from, $to, $subj, $msg, undef, undef, $labl);

    send_mail('me@domain', ['you@domain'], "heyya there", "supz!?!?");

    # The simplest way:

    send_mail('me@domain', 'you@domain', "heyya there", "supz!?!?");

    # At this time, the mail server, must be the localhost.

=head1 VARS

Hirosi Taguti requested a method for changing the SMTP host.  I provided that and a few other variables.
The values listed are the defaults.

=head2 $Net::SMTP::OneLiner::HOSTNAME = "localhost"

The hostname of the SMTP server you wish to use.  This takes all the arguments
you'd expect a IO::Socket::INET object to take.
 
=head2 $Net::SMTP::OneLiner::PORT = 25;

The port on the smtp server you wish to use.  If you use this, do not set the
port in $Net::SMTP::OneLiner::HOSTNAME or you will create bugs for yourself.

=head2 $Net::SMTP::OneLiner::EHLO = "localhost"

The hostname you wish to send in the EHLO greeting.  It normally doesn't matter what you put here -- even if you change the
HOSTNAME.

=head2 $Net::SMTP::OneLiner::DEBUG = 0

If this is set to true, OneLiner will tell Net::SMTP to spew forth many lines of debugging info.

=head2 $Net::SMTP::OneLiner::TIMEO = 20

Use this to change the communication timeout (in seconds) with the SMTP host.

=head2 $Net::SMTP::OneLiner::CONTENT_TYPE = "text/plain; charset=UTF-8"

Use this to change the content type (e.g. text/html).  This only changes the header and does not alter the message in any way.

=head2 $Net::SMTP::OneLiner::TRANSFER_ENCODING  = "quoted-printable"

Use this to change the transfer encoding.  This only changes the header and does not alter the message in any way.

=head1 Bugs

Please report bugs immediately!  The author has not tested this
module worth a lick -- expecting it to work just fine.  If this
is not the case, he would like to know, so he can fix it.

=head2 Bad BCC: Bug

BCC: recipients were not working at all!  Thanks to Stephen Thomas for finding this bug.

=head1 AUTHOR

Paul Miller <paul@cpan.org>

I am using this software in my own projects...  If you find bugs, please
please please let me know. :) Actually, let me know if you find it handy at
all.  Half the fun of releasing this stuff is knowing that people use it.

=head1 COPYRIGHT

Copyright (c) 2007 Paul Miller -- LGPL [attached]

=head1 SEE ALSO

perl(1)

=cut
