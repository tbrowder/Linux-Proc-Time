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
# Params  : The command as a string, optionally a parameter to ask for user time only. Note that special characters are not recognized by the 'run' routine, so results may not be as expected.
# Returns : A list of times or user time only.
sub time-command(Str:D $cmd, :$uts) is export(:time-command) {
    # runs the input cmd using the system 'run' function and returns
    # the process times shown below

    my $TCMD = "time -p";
    my $args = "$TCMD $cmd";
    my $proc = run $args.words, :err;

    my $result = $proc.err.slurp-rest;
    if $uts {
        return read-sys-time($result, :uts(True));
    }
    else {
        return read-sys-time($result);
    }

} # time-command

#------------------------------------------------------------------------------
# Subroutine: read-sys-time
# Purpose : An internal helper function that is not exported
# Params  : Name of a string that contains output from the GNU 'time' command
# Returns : A list or a single value depending upon the presence of the ':$uts' variable
sub read-sys-time($result, :$uts) {
    say "DEBUG: time result '$result'" if $DEBUG;
    my ($Rts, $Uts, $Sts);
    for $result.lines -> $line {
	#say "DEBUG: line: $line" if $DEBUG;

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

    # back to the caller
    return $Uts if $uts;

    # convert each to hms
    my $rt = delta-time-hms(+$Rts);
    my $ut = delta-time-hms(+$Uts);
    my $st = delta-time-hms(+$Sts);

    # back to the caller
    return $Rts, $rt,
           $Uts, $ut,
           $Sts, $st;
} # read-sys-time

#------------------------------------------------------------------------------
# Subroutine: delta-time-hms
# Purpose : Convert time in seconds to hms format
# Params  : Time in seconds
# Returns : Time in hms format, e.g, "3h02m02.65s"
sub delta-time-hms($Time) is export(:delta-time-hms) {
    #say "DEBUG exit: Time: $Time";
    #exit;

    my $time = $Time; #.Num;

    my UInt $sec-per-min = 60;
    my UInt $min-per-hr  = 60;
    my UInt $sec-per-hr  = $sec-per-min * $min-per-hr;

    my UInt $hr  = ($time/$sec-per-hr).UInt;
    my $sec = $time - ($sec-per-hr * $hr);
    my UInt $min = ($sec/$sec-per-min).UInt;

    $sec = $sec - ($sec-per-min * $min);

    my $ts = sprintf "%dh%02dm%05.2fs", $hr, $min, $sec;
    return $ts;

} # delta-time-hms
