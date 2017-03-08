# Linux::Proc::Time

[![Build Status](https://travis-ci.org/tbrowder/Linux-Proc-Time-Perl6.svg?branch=master)]
  (https://travis-ci.org/tbrowder/Linux-Proc-Time-Perl6)

This module uses the GNU **time** command (usually installed as '/usr/bin/time') to time user commands.

## Synopsis

    use Linux::Proc::Time :time-command;
    my $cmd = "some-user-prog arg1 arg2";
    my $user-time = time-command $cmd;
    say $user-time;
    42.70 # seconds

## Getting the time command

On Debian hosts the **time** command may not installed by default but it is available in
package 'time' ???.  It can also be built from source available at the Free Software
Foundation's git site.  Clone the source repository:

  git clone https://git.savannah.gnu.org/git/time.git

The build and install instructions are in the repository along with the source code.

Unfortunately, there is no equivalent command available for Windows unless you install Cygwin or an equivalent system.

## The time command

The details for running time are described in time's man page which can be viewed by
running 'man 1 time'.

This module will look for time in the following locations and order:

- the location defined by the LINUX_PROC_TIME environment variable
- /usr/local/bin/time
- /usr/bin/time

If the time command is not found, an exception will be thrown.
Likewise, if the time command returns an exit code other than zero, an exception will be thrown.



