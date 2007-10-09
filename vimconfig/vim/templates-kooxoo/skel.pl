#!/usr/bin/perl
#
# @FILE_EXT@
#
# Developed by @AUTHOR@ <@EMAIL@>
# Copyright (c) @YEAR@ @COMPANY@
# All rights reserved.
#
# Changelog:
# @DATE@ - created
#
use Getopt::Long;
use Pod::Usage;
use Log::Log4perl qw(:easy);
use strict;
no strict qw/refs/;
$| = 1;
Log::Log4perl->easy_init( {
        level => $INFO,
        layout => '%5p  %m -- %L%n'
    });

my ($help);
GetOptions("help|?|h" => \$help) or pod2usage(1);
pod2usage(1) if $help;


__END__

=head1 Name

xx.pl brief description

=head1 SYNOPSIS

.pl -ip2city ip2cityfile logfile...

=head1 DESCRIPTION

=head1 OPTIONS

=over 8

=item B<-help>

Print a brief help message and exit.

=item B<-test>

Using the test file.

=item B<-force>

Parse even when the data of the designated date has been generated before.

=item B<-mail>

Don't parse. Just mail result generated before.

=item B<-date>

Parsing the log for designated date.

=back

=cut

# vim: ts=4
# vim600: fdm=marker fdl=0 fdc=3
