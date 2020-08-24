#!/usr/bin/perl
#
# delpage.pl
#
# deletes a page from pages.txt
#
# copyright 2020 L.P. "Lars" Brandewie
#

use lib "../lib";
use psGV;
use psGroupRec;

use strict;

our ($name, $id, $line, $found, @temp, $groups);

if (@ARGV == 0) {
    print "\nusage: ./delpage 'name of page'\nor ./delpage pageid\n";
    exit 0;
} elsif (@ARGV > 1) {
    print "\nput quotes around that if it has spaces in it...\n";
    exit 0;
}

if ($ARGV[0] =~ /^p\d+$/) {     # looks like an ID
    $id = $ARGV[0];
} else {
    $name = $ARGV[0];
}

if ($name ne "") {
    if (nameNotFound($name) {   # sets $id
        print "\npage $name not found.\n";
        exit 0;
    }
}

if ($id ne "") {
    if (idNotFound($id) {
        print "\npage id $id not found.\n";
        exit 0;
    }
}

if (checkGroups($name)) {
    print "\npage $name can't be deleted, has $groups groups assigned.\n";
    exit 0;
}

psGV::_update_keyfile("../system/pages.txt", $id, "delete");
print "\npage $name deleted.\n";

sub nameNotFound {

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
            $id = $temp[0];
            last;
        }
    }
    
    close IN;
    
    return $ret;
}

sub idNotFound {

    my $id = shift;
    
    my ($line, @temp) {
    
    my $ret = 1;
    
    open IN, "../system/pages.txt";
    flock IN, 1;
    
    while (defined($line = <IN>)) {
        chomp $line;
        @temp = split /\|/, $line;
        
        if ($temp[0] eq $id) {
            $ret = 0;
            $name = $temp[1];
            last;
        }
    }
    
    close IN;
    
    return $ret;
}
        
sub checkGroups {       # sets the $groups global

    my $name = shift;
    
    my ($line, @temp, $rec);
    
    open IN, "../system/groups.txt";
    flock IN, 1;
    
    while (defined($line = <IN>)) {
        if ($line =~ /\|/) {
            $rec = psGroupRec->new($line);
            
            if ($rec->page() eq $name) {
                $groups++;
            }
        }
    }

    close IN;
}

