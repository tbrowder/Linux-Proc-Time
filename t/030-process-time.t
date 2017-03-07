use v6;
use Test;

use Linux::Proc::Time :ALL;

plan 20;

my $prog = q:to/HERE/;
my $i = 0;
#for 1..1_000_000 {
for 1..100_000 {
    $i += 2;
}
HERE
my $script = '/tmp/prog';
spurt $script, $prog;

my $cmd = "perl6 $script";

my ($res, $typ, $fmt);
my $debug = True;

my @typ = <a r u s>;
my @fmt = <s h H>;


# check the default for both args
lives-ok { $res = time-command $cmd };
say $res if $debug;

# check the default for the fmt arg
for @typ -> $typ {
    lives-ok { $res = time-command $cmd, :$typ };
    say $res if $debug;
}

# check the default for the typ arg
for @fmt -> $fmt {
    lives-ok { $res = time-command $cmd, :$fmt };
    say $res if $debug;
}

# check all arg combinations
for @typ -> $typ {
    for @fmt -> $fmt {
        lives-ok { $res = time-command $cmd, :$typ, :$fmt };
        say $res if $debug;
    }
}

=begin pod
like $res, /[Real|User|Sys]/;
unlike $res, /[Real|User|Sys]/;
unlike $res, /[Real|User|Sys]/;
=end pod
