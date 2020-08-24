#!/usr/bin/perl
#
# setopt.pl
#
# sets user-settable options is settings_system.txt
#
# Copyright 2020 L.P. "Lars" Brandewie. All rights reserved.
#

use lib "../lib";
use psGV;

use strict;

our (@good, $x, $opt, $val, @args, $gv);

@good = qw(EmailFrom EmailSquelchMin EmailSubject ReportFolder);

$gv = psGV->new();


for ($x = 0; $x < @ARGV; $x += 2) {
    $opt = $ARGV[$x];
    $val = $ARGV[$x + 1];
    
    if (is_member($opt, \@good)) {
        if (($opt eq "EmailSquelchMin") && ($val < 10)) {
            print "\nEmailSquelchMin cannot be set to less than 10.\n";
            exit 0;
        }
        push @args, $opt, $val;
    } else {
        print "\nI don't understand option $opt, or you can't set it. quitting.\n";
        exit 0;
    }
}

$gv->set_setting_system(@args);

print "\nsetting(s) adjusted.\n";
    

sub is_member {			    # determine if $test is in @{$arr}
    
    my ($test, $arr) = @_;
	
	foreach $a (@{$arr}) {
		return 1 if $a eq $test;
	}
	0;
}
