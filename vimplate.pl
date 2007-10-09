#!/usr/bin/perl -w



use strict;
use warnings;
use Switch;

=head1 NAME

vimplate - the vim template system.

=cut

use constant VERSION => '0.2.4';

use POSIX qw(strftime cuserid setlocale LC_ALL);
use English qw(-no_match_vars);
use Getopt::Long qw(:config no_ignore_case);
use Pod::Usage;

my $vimplaterc = '.vimplaterc';

# unix directory separator by default
my $DIR_SEPARATOR = '/';

my $VIM_PLUGIN_DIR = '.vim';

=head1 DEPENDS on PACKAGES

B<Template-Toolkit> http://search.cpan.org/~abw/Template-Toolkit-2.14

please install Template-Toolkit on your system.

=cut

BEGIN {
  eval {
    require Template;
  };
  if ($EVAL_ERROR =~ /Can't locate Template.pm/) {
    print STDERR "$EVAL_ERROR";
    print STDERR '-' x 60, "\n";
    print STDERR "please install Template-Toolkit!\n";
    print STDERR "example with $^X -MCPAN -e\"install Template\"\n";
    print STDERR '-' x 60, "\n";
    exit 1;
  }
}

=head1 DEPENDS on SETTINGS

B<variable HOME>

on unix/bsd/linux the variable home is set.
On Windows please set the variable home to the value
where .vimplaterc should be located.

=cut



# Fix for windows home path variable,
# added by Jay Taylor on 2007-02-25.
unless ($ENV{'HOME'}) {
  $ENV{'HOME'} = $ENV{'HOMEPATH'};
}

unless ($ENV{'HOME'}) {
  print STDERR "Variable HOME isn't set!\n";
  print STDERR "This environment variable is required.\n";
  print STDERR "Please read the documentation.\n";
  exit 1;
}
else {
  if ($^O =~ /Win/) {
    $DIR_SEPARATOR = '\\';
    $VIM_PLUGIN_DIR = 'vimfiles';
    $vimplaterc = $ENV{'HOME'}.$DIR_SEPARATOR.$vimplaterc;
    unless ($ENV{'USER'}) {
      $ENV{'USER'} = $ENV{'USERNAME'};
    }
    unless ($ENV{'USER'}) {
      print STDERR "Variable USER isn't set!\n";
      print STDERR "Please set this variable.\n";
      #print "Firstname: ";
      #$ENV{'USER'} = <>;
    }
  }
}

$vimplaterc = $ENV{'HOME'}.$DIR_SEPARATOR.'.vimplaterc';

=head1 SYNOPSIS

=over 4

=item vimplate <-template=<template>> [-out=<file>]
               [-user=<user>] [-dir=<dir>] [-config=<file>]

=item vimplate <-createconfig>

=item vimplate <-listtemplates>

=item vimplate <-listusers>

=item vimplate <-version>

=item vimplate <-help|-h|-?>

=item vimplate <-man>

=back

=cut

my %opt = ();
GetOptions(
            \%opt, 'template|t=s', '-out|o=s',
                   'user=s', 'dir=s', 'config=s',
                   'createconfig',
                   'listtemplates!',
                   'listusers!',
                   'version!',
                   'help|h|?!',
                   'man!',
  )
  or pod2usage(-verbose => 0, -exitval => 1, -output => \*STDERR);

=head1 OPTIONS

=over 4

=item B<-help|-h|-?>

Print a brief help message and exit.

=cut

if (defined $opt{help}) {
  pod2usage(-verbose => 1, -exitval => 0)
}

=item B<-man>

Print the manual page and exit.

=cut

if (defined $opt{man}) {
  pod2usage(-verbose => 2, -exitval => 0)
}

=item B<-version>

Print the version and exit.

=cut

if (defined $opt{version}) {
  print 'vimplate version '.VERSION."\n";
  exit 0;
}

=item B<-createconfig>

Write a vimplate config to $HOME/.vimplaterc
or %HOME%\.vimplaterc (on Windows) and exit.

=cut

if (defined $opt{createconfig}) {
  if (-f $vimplaterc && -s $vimplaterc != 0) {
    print STDERR "\n\t\t!!! OPERATION NOT PERFORMED !!!!\n\n";
    print STDERR "I don't overwrite .vimplaterc.\n";
    print STDERR "Remove or rename the file if you really want to create a new one.\n";
    print STDERR $vimplaterc." already exists!\n\n";
    exit 1;
  }
  eval {
    open(F, '>', $vimplaterc)
  };
  if ($EVAL_ERROR) {
    print STDERR "Can't write ".$vimplaterc.": $!\n";
    exit 1;
  }


  # Get input from the user to setup vimplaterc a bit.  Defaults to the best bet
  # at desirable values for our user.  Added 2007-02-25 by Jay.
  my (@splitname, $first, $middle, $last, $domain, $email, $input, $username);
  @splitname = split(/ /, $ENV{'USER'});
  
  switch (scalar @splitname) {
    case 0 {
      $first = '';
      $middle = '';
      $last = '';
    }
    case 1 {
      $first = $splitname[0];
      $middle = $splitname[0];
      $last = $splitname[0];
    }
    case 2{
      $first = $splitname[0];
      $middle = '';
      $last = $splitname[1];
    }
    else {
      $first = $splitname[0];
      $first = $splitname[1];
      $first = $splitname[2];
    }
  }

  if ($ENV{'USERDOMAIN'}) {
    $domain = $ENV{'USERDOMAIN'};
  } else {
    $domain = do 'cat /etc/hostname';
  }

  $username = $ENV{'USER'};
  $username =~ s/ //g;

  print "\nVimplate .vimplaterc File Creation and Configuration\n";
  print "------------------------------------------------------\n";
  print "(press enter to use auto-detected value)\n\n";
  print "Username (must not contain spaces) <$username>: ";
  chomp($input = <STDIN>);
  if ($input ne "" && !($input =~ m/ /)) {
    $username = $input;
  }

  print "\nFirst name <$first>: ";
  chomp($input = <STDIN>);
  if ($input ne "") {
    $first = $input;
  }

  print "\nMiddle name or initial <$middle>: ";
  chomp($input = <STDIN>);
  if ($input ne "") {
    $middle = $input;
  }

  print "\nLast name <$last>: ";
  chomp($input = <STDIN>);
  if ($input ne "") {
    $last = $input;
  }

  $email = substr($first, 0, 1).$last."@".$domain;
  print "\nEmail address <".$email.">: ";

  chomp($input = <STDIN>);
  if ($input ne "") {
    $email = $input;
  }

  print "\n";

  print F "# This is an example configuration.\n";
  print F "# please see: http://napali.ch/vimplate\n";
  print F "\n";
  print F "# you can use \$Config::opt instead command options:\n";
  print F "#   -user=<user> -dir=<dir>\n";
  print F "\$Config::opt = {\n";
  print F "                  dir  => '".$ENV{HOME}.$DIR_SEPARATOR.$VIM_PLUGIN_DIR.$DIR_SEPARATOR."Templates',\n";
  print F "                  user => '".$username."',\n";
  print F "};\n";
  print F "\n";
  print F "# we need \$Config::user with the option -user=<name>\n";
  print F "\$Config::user = {\n";
  print F "                   $username => {\n";
  print F "                                     firstname  => '".$first."',\n";
  print F "                                     middlename => '".$middle."',\n";
  print F "                                     lastname   => '".$last."',\n";
  print F "                                     mail       => '".$email."',\n";
  print F "                                     etc        => '...',\n";
  print F "                   },\n";
  print F "                   otherUser  => {\n";
  print F "                                     firstname  => 'otherFirstname',\n";
  print F "                                     middlename => 'otherMiddlename',\n";
  print F "                                     lastname   => 'otherLastname',\n";
  print F "                                     mail       => 'otherMail\@example.org',\n";
  print F "                   },\n";
  print F "};\n";
  print F "\n";
  print F "# use \$Config::var for your own variables or subroutines\n";
  print F "\$Config::var = {\n";
  print F "                 yourArray => [ 'C', 'C++', 'Python', 'PHP', 'Java', 'Tcl' ],\n";
  print F "                 example   => sub{time},\n";
  print F "};\n";
  close F
    and print "SUCCESS!\n".$vimplaterc." written.\n";
  exit 0;
}

{
  package Config;
  our $user;
  our $var;
  our $opt;
  if (-f $vimplaterc) {
    # Note:
    # I added "$@" to the end of error output here because it tells you what the
    # actual error message is, rather than just fail with an unhelpful general
    # message.
    #   -Jay Taylor, 2006-02-24
    do $vimplaterc
      or die "$vimplaterc: error: $!\n$@\n";
  }
}

=item B<-listtemplate>

Print the avaible templates and exit.

=cut

sub listTemplates {
  opendir(DIR, $Config::opt->{dir});
  my ($file, @files);
  FILE: foreach $file (readdir(DIR)) {
    next FILE if ($file!~/\.tt$/);
    $file =~ s/\.tt//;
    push @files, $file;
  }
  close DIR;
  return @files;
}
if (defined $opt{listtemplates}) {
    print "$_\n" for listTemplates();
    exit 0;
}

=item B<-listusers>

Print the avaible users and exit.

=cut

sub listUsers {
  return (sort keys %$Config::user);
}
if (defined $opt{listusers}) {
  print "$_\n" for listUsers();
  exit 0;
}

=item B<-user|u=<username>>

Use the information form user <username> while parsing templates.

=cut

if (defined $opt{user}) {
  $Config::opt->{user} = $opt{user}
}

=item B<-dir|d=<templatedir>>

Search templatefiles in <templatedir>.

=cut

if (defined $opt{dir}) {
  $Config::opt->{dir} = $opt{dir}
}

=item B<-template=<templatefile>>

Use the <templatefile>.

=cut

if (defined $opt{template}) {
  my $tt = Template->new(
                          {
                            INCLUDE_PATH => $Config::opt->{dir},
                            EVAL_PERL    => 1,
                          }
                        );

  my $ttvar = {
    user   => $Config::user->{$Config::opt->{user}},
    var    => $Config::var,
    locale => sub {
      if (@_ > 0) {
        setlocale(LC_ALL, shift);
        return undef;
      } else {
        return setlocale(LC_ALL);
      }
    },
    date => sub {
      my $loc = setlocale(LC_ALL);
      setlocale(LC_ALL, shift) if (@_ > 1);
      my $timestring = POSIX::strftime(shift, localtime);
      setlocale(LC_ALL, $loc);
      return $timestring;
    },
    uc => sub {
      return uc $_[0];
    },
    ucfirst => sub {
      return ucfirst $_[0];
    },
    lc => sub {
      return lc $_[0];
    },
    choice => sub {
      my $text = shift;
      my $i = 0;
      print "$text\n";
      foreach my $line (@_)
      {
        printf("%2d) %s\n", $i++, $line);
      }
      my $input = 0;
      do {
        chomp($input=<STDIN>);
        unless ($input =~ /^\d+$/) {
          $input = -1
        };
      } while ($input < 0 or $input >= scalar(@_));
      return $_[$input];
    },
    input => sub {
      print "$_[0]";
      chomp(my $input=<STDIN>);
      return $input;
    },
  };

  $tt->process($opt{template}.'.tt', $ttvar, $opt{out});
  if ($EVAL_ERROR =~ /file error - .*: not found/) {
    $tt->process(
      $ttvar->{'choice'}("choice: ", listTemplates()).'.tt', $ttvar, $opt{out}
    );
  }
  if ($EVAL_ERROR) {
    print STDERR $EVAL_ERROR;
    exit 1;
  }
  exit 0;
}

pod2usage(-verbose => 1, -exitval => 1, -output => \*STDERR);

=back

=cut

__END__

=head1 DESCRIPTION

B<vimplate> Print a spezified template to standard output.

=head1 AUTHOR

Urs Stotz <stotz@gmx.ch>

=head1 COPYRIGHT

Copyright (c) 2004-2005, Urs Stotz <stotz@gmx.ch>

All rights reserved. This program is free software; you can redistribute it
and/or modify it under the same terms as Perl itself.

=head1 SEE ALSO

L<perl(1)|perl> L<Template(3)|Template>

=cut
