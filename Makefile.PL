
use ExtUtils::MakeMaker;

WriteMakefile(
    'NAME'         => 'Net::SMTP::OneLiner',
    'VERSION_FROM' => 'OneLiner.pm',
    PREREQ_PM      => { version => 0, },
    AUTHOR         => 'Paul Miller <jettero@cpan.org>',
);
