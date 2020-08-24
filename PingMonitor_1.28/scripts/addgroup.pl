#!/usr/bin/perl
#
# addgroup.pl
#
# adds a group to groups.txt
#
# copyright 2020 L.P. "Lars" Brandewie. All rights reserved.
#

use lib "../lib";
use psGV;
use psGroupRec;

use strict;

our ($name, $ping, $log, $page, $email, $x, $opt, $val, $newid);

if ($ARGV[0] !~ /^-/) {
    $name = $ARGV[0];
    $ping = $ARGV[1];
    $log = $ARGV[2];
    $page = $ARGV[3];
    $email = $ARGV[4];
} else {
    for ($x = 0; $x < @ARGV; $x += 2) {
        $opt = lc($ARGV[$x]);
        $val = $ARGV[$x + 1];
        if ($opt eq "-n") {
            $name = $val;
        } elsif ($opt eq "-ping") {
            $ping = $val;
        } elsif ($opt eq "-l") {
            $log = $val;
        } elsif ($opt eq "-page") {
            $page = $val;
        } elsif ($opt eq "-e") {
            $email = $val;
        } else {
            print "\nI don't understand argument $opt. quitting.\n";
            exit 0;
        }
    }
}

if ($name eq "") {
    print "\nmust specify name (-n).\n";
    exit 0;
} elsif (nameExists($name)) {
    print "\nname $name already exists.\n";
    exit 0;
}

if ($ping eq "") {
    print "\nmust specify ping setting (-ping).\n";
    exit 0;
} elsif (($ping ne "0") && ($ping ne "1")) {
    print "\nping setting must be either 0 or 1.\n";
    exit 0;
}

if ($log eq "") {
    print "\nmust specify log setting (-l).\n";
    exit 0;
} elsif (($log ne "0") && ($log ne "1")) {
    print "\nlog setting must be either 0 or 1.\n";
    exit 0;
}

if ($page eq "") {
    print "\nmust specify page setting (-page).\n";
    exit 0;
} elsif (pageDoesNotExist($page)) {
    print "\npage $page does not exist.\n";
    exit 0;
}

if ($email eq "") {
    print "\nmust specify email setting (-e).\n";
    exit 0;
}

$newid = "g" . psGV::_increment_setting("../system/settings_system.txt", "GroupNum");
psGV::_update_keyfile("../system/groups.txt", $newid, 1 => $name, 2 => $ping, 3 => $log, 4 => $page, 5 => $email);
print "\ngroup $name added.\n";
       
sub nameExists {

    my $name = shift;
    
    my ($line, @temp);
    my $ret = 0;
    my $rec;
    
    open IN, "../system/groups.txt";
    flock IN, 1;
    
    while (defined($line = <IN>)) {
        if ($line =~ /\|/) {
            $rec = psGroupRec->new($line);
            if ($rec->name() eq $name) {
                $ret = 1;
                last;
            }
        }
    }
    
    close IN;
    
    return $ret;
}

sub pageDoesNotExist {

    my $page = shift;
    
    my ($line, @temp);
    
    my $ret = 1;
    
    open IN, "../system/pages.txt";
    flock IN, 1;
    
    while (defined($line = <IN>)) {
        chomp $line;
        @temp = split /\|/, $line;
        if ($temp[1] eq $page) {
            $ret = 0;
            last;
        }
    }
    
    close IN;
    
    return $ret;
}