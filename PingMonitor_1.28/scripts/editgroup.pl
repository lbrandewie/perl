#!/usr/bin/perl
#
# editgroup.pl
#
# edits an entry in groups.txt
#
# copyright 2020 L.P. "Lars" Brandewie. All rights reserved.
#

use lib "../lib";
use psGV;
use psGroupRec;

use strict;

our ($id, $name, $ping, $log, $page, $email, $x, $oldname, @out, @args, $opt, $val, $line, @temp);

$id = shift @ARGV;

if (idNotFound($id)) {          # this sets $oldname
    print "\nid $id not found.\n";
    exit 0;
}

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
        print "\nI don't understand option $opt. quitting.\n";
        exit 0;
    }
}

if ($ping ne "") {
    if (($ping ne "0") && ($ping ne "1")) {
        print "\nping setting must be 0 or 1.\n";
        exit 0;
    }
    push @args, 2, $ping;
}

if ($log ne "") {
    if (($log ne "0") && ($log ne "1")) {
        print "\nlog setting must be 0 or 1.\n";
        exit 0;
    }
    push @args, 3, $log;
}

if ($page ne "") {
    if (pageDoesntExist($page)) {
        print "\npage $page doesn't exist.\n";
        exit 0;
    }
    push @args, 4, $page;
}

if ($email ne "") {
    push @args, 5, $email;
}

if ($name ne "") {
    if (nameExists($name)) {
        print "\ngroup $name already exists.\n";
        exit 0;
    } else {        # gotta change any target references to this group
        open INOUT, "+<../system/targets.txt";
        flock INOUT, 2;
        
        while (defined ($line = <INOUT>)) {
            chomp $line;
            @temp = split /\|/, $line;
            
            if ($temp[4] eq $oldname) {
                $temp[4] = $name;
                $line = join "|", @temp;
                push @out, $line . "\n";
            } else {
                push @out, $line . "\n";
            }
        }
        
        seek INOUT, 0, 0;
        print INOUT @out;
        truncate INOUT, tell(INOUT);
        close INOUT;
    
        push @args, 1, $name;
    }
}

psGV::_update_keyfile("../system/groups.txt", $id, @args);
print "\ngroup $oldname edited.\n";


sub idNotFound {

    my $id = shift;
    
    my ($line, @temp, $rec);
    my $ret = 1;
    
    open IN, "../system/groups.txt";
    flock IN, 1;
    
    while (defined($line = <IN>)) {
        if ($line =~ /\|/) {
            $rec = psGroupRec->new($line);
            
            if ($rec->id() eq $id) {
                $ret = 0;
                $oldname = $rec->name();
            }
        }
    }
    
    close IN;
    
    return $ret;
}

sub nameExists {

    my $name = shift;
    
    my ($line, @temp, $rec);
    
    my $ret = 0;
    
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

