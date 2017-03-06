use v6;
use Test;

use Linux::Proc::Time :ALL;

plan 2;

my $cmd = 'sleep 5';
my $uts;

lives-ok { $uts = time-command($cmd, :uts(True)) };
lives-ok { $uts = time-command($cmd) };
