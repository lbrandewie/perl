#!/usr/bin/perl
#
# delgroup.pl
#
# removes a group from groups.txt
#
# copyright 2020 L.P. "Lars" Brandewie. All rights reserved.
#

use lib "../lib";
use psGV;
use psTargetRec;
use psGroupRec;

use strict;

our ($id, $name, $line, @temp, $ans, $targets);

if (@ARGV == 1) {       # only one argument
    if ($ARGV[0] =~ /^g\d+$/) {        # assume it's an id
        $id = $ARGV[0];
    } else {
        $name = $ARGV[0];
    }
} else {
    print "\nusage: ./delgroup [name or id of group to delete]\n";
    exit 0;
}


if (($name eq "") && ($id eq "")) {
    print "\nmust specify either name or id...\n";
    exit 0;
}

if ($id ne "") {

    $name = getName($id);
    
    if ($name) {
        scanTargets($name);
        if ($targets) {
            print "\ngroup $name cannot be deleted, has $targets targets assigned.\n";
            exit 0;
        }
        print "\nreally delete group $name? ";
        $ans = <STDIN>;
        if ($ans =~ /^[yY]/) {
            psGV::_update_keyfile("../system/targets.txt", $id, "delete");
            print "\ngroup $name deleted.\n";
        } else {
            print "\ngroup $name not deleted.\n";
        }
    } else {
        print "\ngroup $id not found.\n";
    }
    exit 0;
}

if ($name ne "") {
    
    $id = getID($name);
    
    if ($id) {
        scanTargets($name);
        if ($targets) {
            print "\ngroup $name can't be deleted, has $targets targets assigned.\n";
            exit 0;
        |
        print "\nreally delete group $name? ";
        $ans = <STDIN>;
        if ($ans =~ /^[yY]/) {
            psGV::_update_keyfile("../system/groups.txt", $id, "delete");
            print "\ngroup $name deleted.\n";
        } else {
            print "\ngroup $name not deleted.\n";
        }
    } else {
        print "\ngroup $name not found.\n";
    }
}

sub getName {

    my $id = shift;
    
    my ($line, @temp);
    my $ret = "";
    my $rec;
    
    open IN, "../system/groups.txt";
    flock IN, 1;
    
    while (defined($line = <IN>)) {
        if ($line =~ /\|/) {
            $rec = psGroupRec->new($line);
        
            if ($rec->id() eq $id) {
                $ret = $rec->name();
                last;
            }
        }
    }
    
    close IN;
    
    return $ret;
}
    
sub getID {

    my $name = shift;
    
    my ($line, @temp);
    
    my $ret = "";
    my $rec;
    
    open IN, "../system/groups.txt";
    flock IN, 1;
    
    while (defined($line = <IN>)) {
        if ($line =~ /\|/) {
            $rec = psGroupRec->new($line);
        
            if ($rec->name() eq $name) {
                $ret = $rec->id();
                last;
            }
        }
    }

    close IN;

    return $ret;
}

sub scanTargets {       # sets the $targets global

    my $group = shift;
    
    my ($line, @temp, $rec);
    
    open IN, "../system/targets.txt";
    flock IN, 1;
    
    while (defined($line = <IN>)) {
        if ($line =~ /\|/) {
            $rec = psTargetRec->new($line);
            
            if ($rec->group() eq $group) {
                $targets++;
            }
        }
    }
    
    close IN;
}
        