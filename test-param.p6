#!/usr/bin/env perl6

my token fmt { ^ :i a|b $ }

foo;

#sub foo(:$fmt where { if $fmt.defined { $fmt ~~ &fmt } else {True}}) {
#sub foo(:$fmt where { $fmt.defined.not || $fmt ~~ &fmt }) {
sub foo(:$fmt where { !$fmt.defined || $fmt ~~ &fmt }) {
    if $fmt {
	say "fmt = $fmt"
    }
    else {
        say "fmt = undefined"
    }
}
