# vi:set syntax=perl:
# $Id: Makefile.PL,v 1.1 2005/08/23 11:13:43 jettero Exp $

use ExtUtils::MakeMaker;

WriteMakefile(
    'NAME'         => 'Net::SMTP::OneLiner',
    'VERSION_FROM' => 'OneLiner.pm',
    'PREREQ_PM'    => {'Net::SMTP'},

);
