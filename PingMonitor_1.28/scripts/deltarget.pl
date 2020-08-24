#!/usr/bin/perl
#
# deltarget.pl
#
# removes a target from targets.txt
#
# copyright 2020 L.P. "Lars" Brandewie. All rights reserved.
#

use strict;

use lib "../lib";

use psGV;
use psTargetRec;

our ($id, $name, $line, @temp, $ans);

if (@ARGV == 1) {       # only one argument
    if (substr($ARGV[0], 0, 1) eq "t") {        # assume it's an id
        $id = $ARGV[0];
    } else {
        $name = $ARGV[0];
    }
} elsif (lc($ARGV[0]) eq "-i") {
    $id = $ARGV[1];
} elsif (lc($ARGV[0]) eq "-n") {
    $name = $ARGV[1];
}

if (($name eq "") && ($id eq "")) {
    print "\nmust specify either name (-n) or id (-i)...\n";
    exit 0;
}

if ($id ne "") {
    $name = getName($id);

    if ($name) {
        print "\mreally delete target $name? ";
        $ans = <STDIN>;
        if ($ans =~ /^[yY]/) {
            psGV::_update_keyfile("../system/targets.txt", $id, "delete");
            print "\ntarget $name deleted.\n";
        } else {
            print "\ntarget $name not deleted.\n";
        }
    } else {
        print "\ntarget $id not found.\n";
    }
    exit 0;
}

if ($name ne "") {
    
    $id = getID($name);
    
    if ($id) {
        print "\nreally delete target $name? ";
        $ans = <STDIN>;
        if ($ans =~ /^[yY]/) {
            psGV::_update_keyfile("../system/targets.txt", $id, "delete");
            print "\ntarget $name deleted.\n";
        } else {
            print "\ntarget $name not deleted.\n";
        }
    } else {
        print "\ntarget $name not found.\n";
    }
}

sub getName {

    my $id = shift;
    
    my ($line, @temp, $rec);
    my $ret = "";
    
    open IN, "../system/targets.txt";
    flock IN, 1;
    
    while (defined($line = <IN>)) {
        if ($line =~ /\|/) {
            $rec = psTargetRec->new($line);
        
            if ($rec->id() eq $id) {
                $ret = $rec->name();
                $last;
            }
        }
    }
    
    close IN;
    
    return $ret;
}

sub getID {

    my $name = shift;
    
    my ($line, @temp, $rec) {
    
    my $ret = "";
    
    open IN, "../system/targets.txt";
    flock IN, 1;
    
    while (defined($line = <IN>)) {
        if ($line =~ /\|/) {
            $rec = psTargetRec->new($line);
        
            if ($rec->name() eq $name) {
                $ret = $rec->id();
                last;
            }
        }
    }
    
    close IN;
    
    return $ret;
}
