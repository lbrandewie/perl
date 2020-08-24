#!/usr/bin/perl
#
# addtarget.pl
#
# adds a target to the targets.txt file
#
# copyright (c) 2020 L.P. "Lars" Brandewie, all rights reserved.
#

use strict;

use lib "../lib";
use psGV;
use psGroupRec;
use psTargetRec;

our ($name, $target, $yellow, $group, @temp, $found, $x, $newid, $line, $opt, $val);


if ($ARGV[0] !~ /^-/) {
    $name = $ARGV[0];
    $target = $ARGV[1];
    $yellow = $ARGV[2];
    $group = $ARGV[3];
} else {

    for ($x = 0; $x < @ARGV; $x += 2) {
        $opt = lc($ARGV[$x]);
        $val = $ARGV[$x + 1];
        if ($opt eq "-n") {
            $name = $val;
        } elsif ($opt eq "-t") {
            $target = $val;
        } elsif ($opt eq "-y") {
            $yellow = $val;
        } elsif ($opt eq "-g") {
            $group = $val;
        }
    }
}

if ($name eq "") {
    print "\ntarget name not specified.\n";
    exit 0;
}

if ($target eq "") {
    print "\ntarget not specified.\n";
    exit 0;
}

if ($yellow < 0.1) {
    print "\nyellow threshold must be at least 0.1 ms\n";
    exit 0;
}

if ($group eq "") {
    print "\ngroup not specified.\n";
    exit 0;
}

unless (isValidGroup($group)) {
    print "\ngroup $group not found.\n";
    exit 0;
}

unless (isValidTarget($name)) {
    print "\ntarget $name already exists.\n";
    exit 0;
}

$newid = "t" . psGV::_increment_setting("../system/settings_system.txt", "TargetNum");

psGV::_update_keyfile("../system/targets.txt", $newid, 1 => $name, 2 => $target, 3 => $yellow, 4 => $group);

print "\ntarget $name successfully added.\n";


sub isValidGroup {          # group name must already exist

    my $group = shift;
    my ($line, @temp);
    my $ret = 0;
    my $rec;
    
    open IN, "../system/groups.txt";
    flock IN, 1;

    while (defined($line = <IN>)) {
        if ($line =~ /\|/) {
            $rec = psGroupRec->new($line);
            if ($rec->name() eq $group) {
                $ret = 1;
                last;
            }
        }
    }
    
    close IN;
    
    return $ret;
}

sub isValidTarget {         # no such target name may already exist

    my $name = shift;
    
    my ($line, @temp);
    my $ret = 1;
    my $rec;
    
    open IN, "../system/targets.txt";
    flock IN, 1;

    while (defined ($line = <IN>)) {
        if ($line =~ /\|/) {
            $rec = psTargetRec->new($line);
            if ($rec->dispname() eq $name) {
                $ret = 0;
                last;
            }
        }
    }

    close IN;
    
    return $ret;
}

    