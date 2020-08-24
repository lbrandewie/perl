#!/usr/bin/perl
#
# report1.pl
#
# report engine for PingMonitor
#
# copyright 2019 L. P. "Lars" Brandewie. All rights reserved.
#

use lib "../lib";

use psGV;
use psTargetRec;
use psGroupRec;

use strict;

our $gv = psGV->new();
our $version = $gv->version();
our $reportdir = $gv->get_setting_system("ReportFolder");

our ($now, $min, $secs, %ping, %thehash, @allgroups, %members, @displaynames, @groups, @shortnames, @yellow, @pages, @reports, %page);

print "report1 $version running at $reportdir\n";

$min = int(time() / 60);

if ($ARGV[0] eq "-once") {
    doit($min);
    exit 0;
}

while (1) {                 # call doit() when I oughta

    $now = time();
    $min = int($now / 60);
    $secs = $now % 60;

    if ($secs < 28) {
        sleep(28 - $secs);
    } elsif (($secs >= 30) && ($secs <= 32)) {
        doit($min);
        sleep 4;
    } elsif ($secs > 30) {
        sleep(88 - $secs);
    } else {
        sleep(1);
    }
}

sub doit {                  # get it done
    
    my $min = shift;
    
    my (@files, @temp, $line, $sn, $rptfile, $x, $y, $cnt, $rec);
    
    @allgroups = @displaynames = @shortnames = @yellow = @files = @groups = %members = %thehash = @pages = @reports = %page = ();
        
        
    open IN, "../system/groups.txt";
    flock IN, 1;
    
    while (defined($line = <IN>)) {
        if ($line =~ /\|/) {
            $rec = psGroupRec->new($line);
            $ping{$rec->name()} = $rec->ping();
            push @allgroups, $rec->name();
            $page{$rec->name()} = $rec->page();
        }
    }
    close IN;
    
    open IN, "../system/targets.txt";
    flock IN, 1;
    
    while (defined($line = <IN>)) {
        if ($line =~ /\|/) {
            $rec = psTargetRec->new($line);
            push @displaynames, $rec->dispname();
            push @shortnames, $rec->target();
            push @yellow, $rec->yellow();
            push @files, "../data/" . $rec->target() . ".txt";
            push @groups, $rec->group();
            $members{$rec->group()}++;
        }
    }
    close IN;

    open IN, "../system/pages.txt";
    flock IN, 1;
    
    while (defined ($line = <IN>)) {
        chomp $line;
        if ($line =~ /\|/) {
            @temp = split /\|/, $line;
            if (checkpage($temp[1])) {
                push @pages, $temp[1];
            }
        }
    }
    close IN;    
    
    unlink <../reports/*>;
    
    for my $file (@files) {
        
        $sn = substr($file, 8, -4);

        open IN, $file;
        flock IN, 1;
        while (defined($line = <IN>)) {
            chomp $line;
            @temp = split /\|/, $line;
            $thehash{"$temp[0]|$sn"} = "$temp[1]|$temp[2]";
        }
        close IN;
    }
    
    for ($x = 0; $x < @pages; $x++) {
        push @reports, ["$pages[$x]_summary", "$pages[$x]_detail1", "$pages[$x]_detail2", "$pages[$x]_detail3", "$pages[$x]_detail4", "$pages[$x]_detail5", "$pages[$x]_detail6"];
    }
    
    for ($y = 0; $y < @pages; $y++) {
        $cnt = 0;
        for ($x = $min; $x >= ($min - 1200); $x -= 240) {
            $cnt++;
            makepage($reportdir, "$pages[$y]_detail$cnt", $x, $x - 239, $pages[$y]);
        }
    }
    for ($y = 0; $y < @pages; $y++) {
        makepage2($reportdir, "$pages[$y]_summary", $min, $min - 1430, $pages[$y]);
    }
}

sub checkpage {

    my $page = shift;
    
    for my $group (@allgroups) {
        if (($page{$group} eq $page) && $ping{$group} && $members{$group}) {
            return 1;
        }
    }
    return 0;
}
    
sub makepage {

    my $reportdir = shift;
    my $rptname = shift;
    
    my $startx = shift;
    my $endx = shift;
    my $pagename = shift;
    
    my ($x, $y, @temp);
    
    my $rptfile = "$reportdir/$rptname.htm";

    open OUT, ">$rptfile" or die "Can't open report file $rptfile: $!\n";
    flock OUT, 2;
    
    print OUT qq ®<html><head><title>PiumaSoft PingMonitor</title><meta http-equiv='refresh' content="30;URL='$rptname.htm'" /></head><body>®;
    
    print OUT "<p><table><tr>";
    
    for ($y = 0; $y < @pages; $y++) {
        print OUT "<td>";
        for ($x = 0; $x <= 6; $x++) {
            if ($rptname eq $reports[$y][$x]) {
                print OUT "$reports[$y][$x]<br>";
            } else {
                print OUT "<a href='$reports[$y][$x].htm'>$reports[$y][$x]</a><br>";
            }
        }
        print OUT "</td>";
    }
    
    print OUT "</tr></table></p>\n";
    
    
    print OUT "<table border='1' cellpadding='2' cellspaciing='2'><tr><th rowspan='2'>UTC</th>";
    
    for my $group (@allgroups) {
        if ($page{$group} eq $pagename) {
            if ($ping{$group} && $members{$group}) {
                print OUT "<th colspan='", $members{$group}, "'>$group</th>";
            }
        }
    }
    
    print OUT "</tr>\n";
    
    for my $group (@allgroups) {
        if ($page{$group} eq $pagename) {
            if ($ping{$group} && $members{"$group"}) {
                for ($x = 0; $x < @displaynames; $x++) {
                    if ($groups[$x] eq $group) {
                        print OUT "<th>$displaynames[$x]</th>";
                    }
                }
            }
        }
    }
    
    print OUT "</tr>\n";
    
    
    for ($x = $startx; $x >= $endx; $x--) {
        print OUT "<tr align='center'>\n<td>", substr(scalar(gmtime(60 * $x)), 0, -8), "</td>\n";
        
        for my $group (@allgroups) {
            if ($ping{$group} && ($page{$group} eq $pagename)) {
                for ($y = 0; $y < @shortnames; $y++) {
                    if ($groups[$y] eq $group) {
                        @temp = split /\|/, $thehash{"$x|$shortnames[$y]"};
                        
                        if ($temp[0] eq "U") {
                            if ($temp[1] < $yellow[$y]) {
                                print OUT "<td bgcolor='00FF00'>$temp[1] ms</td>\n";
                            } else {
                                print OUT "<td bgcolor='FFFF00'>$temp[1] ms</td>\n";
                            }
                        } elsif ($temp[0] eq "D") {
                            print OUT "<td bgcolor='FF0000'>&nbsp;</td>\n";
                        } elsif ($temp[0] eq "G") {
                            print OUT "<td bgcolor='AAAAFF'>$temp[1] ms</td>\n";
                        } else {
                            print OUT "<td>&nbsp;</td>\n";
                        }
                    }
                }
            }
        }
        
        print OUT "</tr>\n";
    }
    print OUT "</table></body></html>";
    close OUT;
}    

sub makepage2 {

    my $reportdir = shift;
    my $rptname = shift;
    
    my $startx = shift;
    my $endx = shift;
    my $pagename = shift;
    
    my ($x, $y, @temp);
    
    my $rptfile = "$reportdir/$rptname.htm";

    open OUT, ">$rptfile" or die "Can't open report file $rptfile: $!\n";
    flock OUT, 2;
    
    print OUT qq ®<html><head><title>PiumaSoft PingMonitor</title><meta http-equiv='refresh' content="30;URL='$rptname.htm'" /></head><body>®;
    
    print OUT "<p><table><tr>";
    
    for ($y = 0; $y < @pages; $y++) {
        print OUT "<td>";
        for ($x = 0; $x <= 6; $x++) {
            if ($rptname eq $reports[$y][$x]) {
                print OUT "$reports[$y][$x]<br>";
            } else {
                print OUT "<a href='$reports[$y][$x].htm'>$reports[$y][$x]</a><br>";
            }
        }
        print OUT "</td>";
    }
    
    print OUT "</tr></table></p>\n";
    
    print OUT "<table border='1' cellpadding='2' cellspaciing='2'><tr><th rowspan='2'>UTC</th>";
    
    for my $group (@allgroups) {
        if ($page{$group} eq $pagename) {
            if ($ping{$group} && $members{$group}) {
                print OUT "<th colspan='", $members{$group}, "'>$group</th>";
            }
        }
    }
    
    print OUT "</tr>\n";
    
    for my $group (@allgroups) {
        if ($page{$group} eq $pagename) {
            if ($ping{$group} && $members{"$group"}) {
                for ($x = 0; $x < @displaynames; $x++) {
                    if ($groups[$x] eq $group) {
                        print OUT "<th>$displaynames[$x]</th>";
                    }
                }
            }
        }
    }
    
    print OUT "</tr>\n";
    
    
    for ($x = $startx; $x >= $endx; $x -= 10) {
        print OUT "<tr align='center'>\n<td>", substr(scalar(gmtime(60 * $x)), 0, -8), "</td>\n";
        
        for my $group (@allgroups) {
            if ($ping{$group} && ($page{$group} eq $pagename)) {
                for ($y = 0; $y < @shortnames; $y++) {
                    if ($groups[$y] eq $group) {
                        @temp = split /\|/, summarize($x, $shortnames[$y]);
                        
                        if ($temp[0] eq "U") {
                            if ($temp[1] < $yellow[$y]) {
                                print OUT "<td bgcolor='00FF00'>$temp[1] ms</td>\n";
                            } else {
                                print OUT "<td bgcolor='FFFF00'>$temp[1] ms</td>\n";
                            }
                        } elsif ($temp[0] eq "D") {
                            print OUT "<td bgcolor='FF0000'>&nbsp;</td>\n";
                        } elsif ($temp[0] eq "G") {
                            print OUT "<td bgcolor='AAAAFF'>$temp[1] ms</td>\n";
                        } else {
                            print OUT "<td>&nbsp;</td>\n";
                        }
                    }
                }
            }
        }
        
        print OUT "</tr>\n";
    }
    print OUT "</table></body></html>";
    close OUT;
}    


sub summarize {

    my $min = shift;
    my $thing = shift;
    my $maxtime = 0;
    my ($up, $down, $garbled, $nodata, @temp);
    
    for (my $x = $min; $x >= ($min - 9); $x--) {
        @temp = split /\|/, $thehash{"$x|$thing"};
        if ($temp[0] eq "U") {
            $up++;
            $maxtime = max($temp[1], $maxtime);
        } elsif ($temp[0] eq "G") {
            $garbled++;
            $maxtime = max($temp[1], $maxtime);
        } elsif ($temp[0] eq "D") {
            $down++;
        } else {
            $nodata++;
        }
    }
    
    if ($nodata == 10) {
        return "N|";
    } elsif ($down) {
        return "D|";
    } elsif ($garbled) {
        return "G|$maxtime";
    } else {
        return "U|$maxtime";
    }
}    

sub max {

    $_[0] > $_[1] ? $_[0] : $_[1];
}

