use v6;
use Test;

use Linux::Proc::Time :ALL;

#plan 64;

my token num { \d+ [ \. \d* ]? }
my token typr { :i real ':' }
my token typu { :i user ':' }
my token typs { :i sys ':' }
my token typ { &typr | &typu | &typs }
my token sec { :i &num s }
my token h { :i <num> h <num> m <num> s }
my token H { <num> ':' <num> ':' <num> }

my token an { <typr> \s* <num> ';' \s* <typu> \s* <num> ';' \s* <typs> \s* <num> }
my token as { <typr> \s* <num> s ';' \s* <typu> \s* <num> ';' \s* <typs> \s* <num> }
my token as { <typr> \s* <num> ';' \s* <typu> \s* <num> ';' \s* <typs> \s* <num> }

my $prog = q:to/HERE/;
my $i = 0;
for 1..10_000 {
    $i += 2;
}
HERE
my $script = '/tmp/prog';
spurt $script, $prog;

my $cmd = "perl6 $script";

my ($res, $typ, $fmt);
my $debug = True;

my @typ = <a all r real u user s sys>;
my @fmt = ['s', 'seconds', 'h', 'hms', ':', 'h:m:s'];

# check a bad cmd
dies-ok { $res = time-command 'fooie' };
say "debug: \$res = '$res'" if $res && $debug;

# check the default for both args
lives-ok { $res = time-command $cmd };
like $res, &num;
say "debug: \$res = '$res'" if $debug;

# need a subroutine to check $res with like
sub check($res, :$typ, :$fmt) {
    if !$fmt {
        if !$typ { like $res, &num }
        elsif $typ ~~ /a/ { 
            like $res, &t;
            done-testing;
            exit
        }
        elsif $typ ~~ /r/ { 
        }
        elsif $typ ~~ /u/ { 
        }
        elsif $typ ~~ /s/ { }
    }
    elsif $fmt ~~ /s/ {
        if !$typ { }
        elsif $typ ~~ /a/ { }
        elsif $typ ~~ /r/ { }
        elsif $typ ~~ /u/ { }
        elsif $typ ~~ /s/ { }
    }
    elsif $fmt ~~ /':'/ {
        if !$typ { }
        elsif $typ ~~ /a/ { }
        elsif $typ ~~ /r/ { }
        elsif $typ ~~ /u/ { }
        elsif $typ ~~ /s/ { }
    }
    elsif $fmt ~~ /h/ {
        if !$typ { }
        elsif $typ ~~ /a/ { }
        elsif $typ ~~ /r/ { }
        elsif $typ ~~ /u/ { }
        elsif $typ ~~ /s/ { }
    }
}

# check the default for the fmt arg
for @typ -> $typ {
    lives-ok { $res = time-command $cmd, :$typ };
    check $res, :$typ, :$fmt;
    say "debug: \$typ = '$typ'; \$res = '$res'" if $debug;
}

done-testing;
exit;

# check the default for the typ arg
for @fmt -> $fmt {
    lives-ok { $res = time-command $cmd, :$fmt };
    say "debug: \$fmt = '$fmt'; \$res = '$res'" if $debug;
}

# check all arg combinations
for @typ -> $typ {
    for @fmt -> $fmt {
        lives-ok { $res = time-command $cmd, :$typ, :$fmt };
        say "debug: \$typ = '$typ'; \$fmt = '$fmt'; \$res = '$res'" if $debug;
    }
}

done-testing;
