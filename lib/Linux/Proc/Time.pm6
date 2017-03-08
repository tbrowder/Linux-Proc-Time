unit module Linux::Proc::Time:auth<github:tbrowder>;

# file:  ALL-SUBS.md
# title: Subroutines Exported by the `:ALL` Tag

# export a debug var for users
our $DEBUG is export(:DEBUG) = False;
BEGIN {
    if %*ENV<LINUX_PROC_TIME_DEBUG> {
	$DEBUG = True;
    }
    else {
	$DEBUG = False;
    }
}


#------------------------------------------------------------------------------
# Subroutine: time-command
# Purpose : Collect the process times for a system command (using the GNU 'time' command).
# Params  : The command as a string, and two parameters with default values that describe which type of time values to return and in what format. Note that special characters are not recognized by the 'run' routine, so results may not be as expected if they are part of the command.
# Returns : A list of real (wall clock), user, and system times (in h:mm:ss.ss or hms format); or user time (in seconds) only.
sub time-command(Str:D $cmd, 
                 :$typ where { $typ ~~ /^ :i [a|all|r|real|u|user|s|sys] $/ } = 'u', 
                 :$fmt where { $fmt ~~ /^ :i [b|bare|s|seconds|h|hms|h:m:s] $/ } = 'b',
               ) is export(:time-command) {
    # runs the input cmd using the system 'run' function and returns
    # the process times shown below

    # look for the time program in several places:
    my $TCMD;
    my $TE = 'LINUX_PROC_TIME';
    my @t = <
        /usr/bin/time
        /usr/local/bin
    >;
    if %*ENV{$TE}:exists && %*ENV{$TE}.IO.f {
        $TCMD = %*ENV{$TE};
    }
    else { 
        for @t -> $t {
            if $t.IO.f {
                $TCMD = $t;
                last;
            }
        }
    }
    if !$TCMD.defined {
        die "FATAL: The 'time' command was not found on this host.";
    }
       
    $TCMD ~= ' -p'; # the '-t' option gives the standard POSIX output display
    my $args = "$TCMD $cmd";
    my $proc = run $args.words, :err;
    my $exitcode = $proc.exitcode;
    if $exitcode {
        die "FATAL: The '$args' command returned a non-zero exitcode: $exitcode";
    }

    my $result = $proc.err.slurp-rest;
    return read-sys-time($result, :$typ, :$fmt);

} # time-command

#------------------------------------------------------------------------------
# Subroutine: read-sys-time
# Purpose : An internal helper function that is not exported.
# Params  : A string that contains output from the GNU 'time' command, and two parameters with default values that describe which type of tome values to return and in what format.
# Returns : A single value or multiple values depending upon the presence of a true ':$uts' variable.  The multiple values can be in one of two formats: hms or h:m:s (HMS) depending on the presence of a true ':$HMS' variable.
sub read-sys-time($result,
                 :$typ where { $typ ~~ /^ :i [a|all|r|real|u|user|s|sys] $/ } = 'u', 
                 :$fmt where { $fmt ~~ /^ :i [b|bare|s|seconds|h|hms|h:m:s] $/ } = 'b',
                 --> Str) {

    say "DEBUG: time result '$result'" if $DEBUG;
    # get the individual seconds for each type of time
    my ($Rts, $Uts, $Sts);
    for $result.lines -> $line {
	say "DEBUG: line: $line" if $DEBUG;

	my $typ = $line.words[0];
	my $sec = $line.words[1];
	given $typ {
            when /real/ {
		$Rts = sprintf "%.3f", $sec;
		say "DEBUG: rts: $Rts" if $DEBUG;
            }
            when /user/ {
		$Uts = sprintf "%.3f", $sec;
		say "DEBUG: uts: $Uts" if $DEBUG;
            }
            when /sys/ {
		$Sts = sprintf "%.3f", $sec;
		say "DEBUG: sts: $Sts" if $DEBUG;
            }
	}
    }

    if $fmt eq 'b' {
        # returning raw seconds
        given $typ {
            when 'a' {
                return "Real: $Rts; User: $Uts; Sys: $Sts";
            }
            when 'r' {
                return $Rts;
            }
            when 'u' {
                return $Uts;
            }
            when 's' {
                return $Sts;
            }
        }
    }

    # returning formatted time
    # convert each to hms or h:m:s

    given $typ {
        when 'a' {
            my $rt = delta-time-hms(+$Rts, :$fmt);
            my $ut = delta-time-hms(+$Uts, :$fmt);
            my $st = delta-time-hms(+$Sts, :$fmt);
            return "Real: $rt; User: $ut; Sys: $st";
        }
        when 'r' {
            my $t = delta-time-hms(+$Rts, :$fmt);
            return $t;
        }
        when 'u' {
            my $t = delta-time-hms(+$Uts, :$fmt);
            return $t;
        }
        when 's' {
            my $t = delta-time-hms(+$Sts, :$fmt);
            return $t;
        }
    }

} # read-sys-time

#------------------------------------------------------------------------------
# Subroutine: delta-time-hms
# Purpose : Convert time in seconds to hms ('h') or h:m:s ('H') format
# Params  : Time in seconds
# Returns : Time in hms format, e.g, '3h02m02.65s', or h:m:s format, e.g., '3:02:02.65'.
sub delta-time-hms($Time,
                   :$fmt where { $fmt ~~ /^ :i [b|bare|s|seconds|h|hms|h:m:s] $/ } = 'b',
                  ) is export(:delta-time-hms) {
    #say "DEBUG exit: Time: $Time";
    #exit;

    my $time = $Time; 

    my UInt $sec-per-min = 60;
    my UInt $min-per-hr  = 60;
    my UInt $sec-per-hr  = $sec-per-min * $min-per-hr;

    my UInt $hr  = ($time/$sec-per-hr).UInt;
    my $sec = $time - ($sec-per-hr * $hr);
    my UInt $min = ($sec/$sec-per-min).UInt;

    $sec = $sec - ($sec-per-min * $min);

    my $ts;
    if $fmt ~~ /^ :i [b|bare] $/ {
        $ts = ~$time;
    }
    elsif $fmt ~~ /^ :i [s|seconds] $/ {
        $ts = sprintf "%.2fs", $sec;
    } 
    elsif $fmt ~~ /^ :i [h|hms] $/ {
        $ts = sprintf "%dh%02dm%05.2fs", $hr, $min, $sec;
    } 
    elsif $fmt ~~ /^ :i [h:m:s] $/ {
        $ts = sprintf "%d:%02d:%05.2f", $hr, $min, $sec;
    } 

    return $ts;

} # delta-time-hms
