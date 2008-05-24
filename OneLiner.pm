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
our $VERSION = '1.2.0';

our $HOSTNAME = "localhost";
our $ELHO     = "localhost";
our $DEBUG    = 0;
our $TIMEO    = 20;

1;

sub send_mail {
    my ($from, $to, $subj, $msg, $cc, $bcc, $labl) = @_;
    my $smtp = Net::SMTP->new($HOSTNAME, Hello=>$ELHO, Timeout=>$TIMEO, Debug=>$DEBUG) or croak $!;

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
    $smtp->datasend("Subject: $subj\n\n");

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

The hostname of the SMTP server you wish to use.

=head2 $Net::SMTP::OneLiner::EHLO = "localhost"

The hostname you wish to send in the EHLO greeting.  It normally doesn't matter what you put here -- even if you change the
HOSTNAME.

=head2 $Net::SMTP::OneLiner::DEBUG = 0

If this is set to true, OneLiner will tell Net::SMTP to spew forth many lines of debugging info.

=head2 $Net::SMTP::OneLiner::TIMEO = 20

Use this to change the communication timeout (in seconds) with the SMTP host.

=head1 Bugs

Please report bugs immediately!  The author has not tested this
module worth a lick -- expecting it to work just fine.  If this
is not the case, he would like to know, so he can fix it.

=head2 Bad BCC: Bug

BCC: recipients were not working at all!  Thanks to Stephen Thomas for finding this bug.

=head1 Author

Jettero Heller jettero@cpan.org

=head1 COPYRIGHT

    GPL!  I included a gpl.txt for your reading enjoyment.

    Though, additionally, I will say that I'll be tickled if you were to
    include this package in any commercial endeavor.  Also, any thoughts to
    the effect that using this module will somehow make your commercial
    package GPL should be washed away.

    I hereby release you from any such silly conditions.

    This package and any modifications you make to it must remain GPL.  Any
    programs you (or your company) write shall remain yours (and under
    whatever copyright you choose) even if you use this package's intended
    and/or exported interfaces in them.

=cut
