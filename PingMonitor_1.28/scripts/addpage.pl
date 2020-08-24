#!/usr/bin/perl
#
# addpage.pl
#
# adds a page to pages.txt
#
# copyright 2020 L.P. "Lars" Brandewie. All rights reserved.
#

use lib "../lib";
use psGV;

use strict;

our ($newid, $name);

if (@ARGV == 1) {
    $name = $ARGV[0];
} elsif (@ARGV == 0) {
    print "\nusage: ./addpage 'name of page'\n";
    exit 0;
} else {
    print "\nput quotes around that if it has spaces in it...\n";
    exit 0;
}

$newid = "p" . psGV::_increment_setting("../system/settings_system.txt", "PageNum");

psGV::_update_keyfile("../system/pages.txt", $newid, 1 => $name);

print "\npage $name added\n";

