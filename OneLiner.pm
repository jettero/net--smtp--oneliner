
package Net::SMTP::OneLiner;

use strict;
use warnings;

use Carp;
use Net::SMTP;

require Exporter;

our @ISA = qw(Exporter);

our @EXPORT = qw( send_mail ); ## no critic
our $VERSION = "2.0008";

our $HOSTNAME = "localhost";
our $PORT     = 25;
our $ELHO     = "localhost";
our $DEBUG    = 0;
our $TIMEO    = 20;

our $CONTENT_TYPE      = "text/plain; charset=UTF-8";
our $TRANSFER_ENCODING = "8bit";
our $MESSAGE_ID;

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

    $smtp->mail($from) or croak $smtp->message;
    $smtp->to(@$to, @$cc, @$bcc) or croak $smtp->message;

    $smtp->data or croak $smtp->message;

    for ($from, @$to, @$cc) {
        $_ = "$labl->{$_} <$_>" if defined $labl->{$_};
    }

    $to = join(", ", @$to);
    $cc = join(", ", @$cc);

    my $mid = $MESSAGE_ID || join(".", time, map {int rand time} 1..5);

    $smtp->datasend("From: $from\n");
    $smtp->datasend("To: $to\n") if $to;
    $smtp->datasend("CC: $cc\n") if $cc;
    $smtp->datasend("Subject: $subj\n") if $subj;
    $smtp->datasend("Content-Type: $CONTENT_TYPE\n");
    $smtp->datasend("Content-Transfer-Encoding: $TRANSFER_ENCODING\n");
    $smtp->datasend("Message-ID: $mid\n");
    $smtp->datasend("\n");

    $smtp->datasend($msg);

    $smtp->dataend;
    $smtp->quit;

    return;
}

1;
