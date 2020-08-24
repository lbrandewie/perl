#!/usr/bin/perl
#
# edittarget.pl
#
# edits a target entry in targets.txt
#
# copyright 2020 L.P. "Lars" Brandewie. All rights reserved.
#

use lib "../lib";
use psGV;
use psTargetRec;
use psGroupRec;

use strict;

our ($id, @args, $x, $line, @temp, $found, $newname, $newyellow, $newgroup, $opt, $val, $oldname);

$id = shift @ARGV;

for ($x = 0; $x < @ARGV; $x += 2) {
    $opt = lc($ARGV[$x]);
    $val = $ARGV[$x + 1];
    
    if ($opt eq "-n") {
        $newname = $val;
        if (isUniqueName($newname)) {
            push @args, 1, $newname;
        } else {
            print "\nname $newname already exists.\n";
            exit 0;
        }
    } elsif ($opt eq "-t") {
        push @args, 2, $val;
    } elsif ($opt eq "-y") {
        $newyellow = $val;
        if ($newyellow >= 0.1) {
            push @args, 3, $newyellow;
        } else {
            print "\nyellow threshould must be at least 0.1 ms\n";
            exit 0;
        }
    } elsif ($opt eq "-g") {
        $newgroup = $val;
        if (isValidGroup($newgroup)) {
            push @args, 4, $newgroup;
        } else {
            print "\ngroup $newgroup not found.\n";
            exit 0;
        }
    } else {
        print "\nI don't understand argument $opt, stopping.\n";
        exit 0;
    }
}

unless (isValidID($id)) {       # sets $oldname
    print "\ntarget $id not found.\n";
    exit 0;
}

psGV::_update_keyfile("../system/targets.txt", $id, @args);
print "\ntarget $oldname edited.\n";

sub isUniqueName {

    my $name = shift;
    my ($line, @temp, $rec);
    my $ret = 1;
    
    open IN, "../system/targets.txt";
    flock IN, 1;
    
    while (defined($line = <IN>)) {
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

sub isValidGroup {

    my $group = shift;
    my ($line, @temp, $rec);
    my $ret = 0;
    
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
        
sub isValidID {

    my $id = shift;
    my ($line, @temp, $rec);
    
    my $ret = 0;
    
    open IN, "../system/targets.txt";
    flock IN, 1;

    while (defined ($line = <IN>)) {
        if ($line =~ /\|/) {
            $rec = psTargetRec->new($line);
            
            if ($rec->id() eq $id) {
                $oldname = $rec->dispname();
                $ret = 1;
                last;
            }
        }
    }

    close IN;
    
    return $ret;
}
