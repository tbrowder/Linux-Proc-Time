use v6;
use Test;

use Misc::Utils :ALL;

plan 1;

my $cmd = 'ls -ld * > /dev/null';
my $uts;

lives-ok { $uts = time-command($cmd, :uts(True)) };

