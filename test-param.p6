#!/usr/bin/env perl6

my token fmt { ^ :i a|b $ }

foo;

sub foo(:$fmt where { if $fmt.defined { $fmt ~~ &fmt } else {True}}) {
    if $fmt {
	say "fmt = $fmt"
    }
    else {
        say "fmt = undefined"
    }
}
