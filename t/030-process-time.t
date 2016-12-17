use v6;
use Test;

use Linux::Proc::Time :ALL;

plan 1;

my $cmd = 'ls -ld * > /dev/null';
my $uts;

lives-ok { $uts = time-command($cmd, :uts(True)) };
