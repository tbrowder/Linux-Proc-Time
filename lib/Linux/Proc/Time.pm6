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
# Purpose : Collect the process times for a system command
# Params  : The command as a string, optionally a parameter to ask for user time only
# Returns : A list of times or user time only
sub time-command(Str:D $cmd, :$uts) is export(:time-command) {
    # runs the input cmd using the system 'time' function and returns
    # the process times shown below

    use File::Temp;
    # get a temp file (File::Find)
    my ($filename, $filehandle);
    if !$DEBUG {
	($filename, $filehandle) = tempfile;
    }
    else {
	($filename, $filehandle) = tempfile(:tempdir('./tmp'), :!unlink);
    }
    my $TCMD = "time -p -o $filename";
    my $proc = shell "$TCMD $cmd"; #, :out;

    if $uts {
        return read-sys-time(:uts(True), $filename);
    }
    else {
        return read-sys-time($filename);
    }

} # time-command
