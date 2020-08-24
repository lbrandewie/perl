#!/usr/bin/perl
#
# editpage.pl
#
# edits a page name in pages.txt
#
# copyright 2020 L.P. "Lars" Brandewie. All rights reserved.
#

use lib "../lib";
use psGV;

use strict;

our ($id, $newname, $oldname, $line, @temp, @out, $name);

if (@ARGV != 2) {
    print "\nusage: ./editpage [page id] [new name of page]\n";
    exit 0;
}

$id = $ARGV[0];
$newname = $ARGV[1];

$oldname = getName($id);

if ($oldname) {
    if (noSuchName($newname)) {
        open INOUT, "+<../system/groups.txt";
        flock INOUT, 2;
        
        while (defined($line = <INOUT>)) {
            chomp $line;
            @temp = split /\|/, $line;
            
            if ($temp[4] eq $oldname) {
                $temp[4] = $newname;
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
        
        psGV::_update_keyfile("../system/pages.txt", $id, 1 => $newname);
        print "\npage $oldname edited.\n";
    }
} else {
    print "\npage $id not found.\n";
}

sub getName {

    my $id = shift;
    
    my ($line, @temp);
    
    my $ret = "";
    
    open IN, "../system/pages.txt";
    flock IN, 1;

    while (defined($line = <IN>)) {
        chomp $line;
        @temp = split /\|/, $line;
        
        if ($temp[0] eq $id) {
            $ret = $temp[1];
            last;
        }
    }
    
    close IN;
    
    return $ret;
}

sub noSuchName {

    my $name = shift;
    
    my ($line, @temp);
    
    my $ret = 1;
    
    open IN, "../system/pages.txt";
    flock IN, 1;
    
    while (defined($line = <IN>)) {
        chomp $line;
        @temp = split /\|/, $line;
        
        if ($temp[1] eq $name) {
            $ret = 0;
            last;
        }
    }
    
    close IN;
    
    return $ret;
}


            