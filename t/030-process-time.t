use v6;
use Test;

use Linux::Proc::Time :ALL;

plan 4;

my $prog = q:to/HERE/;
my $i = 0;
for 1..1_000_000 {
    $i += 2;
}
HERE
my $script = '/tmp/prog';
spurt $script, $prog;

#my $cmd = 'sleep 2';
my $cmd = "perl6 $script";

my ($res, $uts, $HMS);
my $debug = True;

#$uts = False;
$HMS = False;
lives-ok { $res = time-command $cmd, :$uts, :$HMS };
say $res if $debug;

$uts = False;
$HMS = True;
lives-ok { $res = time-command $cmd, :$uts, :$HMS };
say $res if $debug;

$uts = True;
$HMS = True;
lives-ok { $res = time-command $cmd, :$uts, :$HMS };
say $res if $debug;

$uts = True;
$HMS = False;
lives-ok { $res = time-command $cmd, :$uts, :$HMS };
say $res if $debug;
