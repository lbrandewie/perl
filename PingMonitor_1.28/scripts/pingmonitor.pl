#!/usr/bin/perl
#
# pingmonitor.pl
#
# mutli-threaded pinging engine
#
# copyright (c) 2019 L. P. "Lars" Brandewie. All rights reserved.
#

use lib "../lib";

use psGV;
use psTargetRec;
use psGroupRec;
use psMailer;
use threads;

use strict;

our $lastmin;
our (%ping, %log, %email, %lastmailed, $squelch, $emailfrom, $emailsubject, $min);

our $gv = psGV->new();

our $version = $gv->version();

our $unix = -s "/usr/bin/perl";
our $pingcmd = $unix ? "ping -c 4" : "ping";

print "pingmonitor $version running\n";

$min = int(time() / 60);

if ($ARGV[0] eq "-once") {
    doit($min);
    exit 0;
}

run();

sub run {                   # call doit at the right time...

    while (1) {

        my $now = time();
        my $min = int($now / 60);
        my $secs = int($now) % 60;

        if ($secs < 3) {
            doit($min);
            sleep 4;
        } elsif ($secs < 56) {
            sleep(58 - $secs);
        } else {
            sleep(1);
        }
    }
}

sub doit {                  # ping them all and let God sort it out...

    my $min = shift;
    my (@targets, @threads, @groups, $line, @temp, $x, $rec);
    
    if ($min > $lastmin) {

        $squelch = $gv->get_setting_system("EmailSquelchMin");
        $emailfrom = $gv->get_setting_system("EmailFrom");
        $emailsubject = $gv->get_setting_system("EmailSubject");

        open IN, "../system/groups.txt";
        flock IN, 1;
        while (defined($line = <IN>)) {
            if ($line =~ /\|/) {
                $rec = psGroupRec->new($line);
                $ping{$rec->name()} = $rec->ping();
                $log{$rec->name()} = $rec->log();
                $email{$rec->name} = $rec->email();
            }
        }
        close IN;
    
        open IN, "../system/targets.txt";
        flock IN, 1;
        while (defined($line = <IN>)) {
            if ($line =~ /\|/) {
                $rec = psTargetRec->new($line);
                push @targets, $rec->target();
                push @groups, $rec->group();
            }
        }
        close IN;

        open IN, "../system/emails_sent.txt";
        flock IN, 1;
        while (defined($line = <IN>)) {
            if ($line =~ /\|/) {
                chomp $line;
                @temp = split /\|/, $line;
                $lastmailed{"$temp[1]|$temp[2]"} = $temp[0];
            }
        }
        close IN;
        
        for ($x = 0; $x < @targets; $x++) {
            if ($ping{"$groups[$x]"}) {
                push @threads, threads->create(\&pingit, $min, $targets[$x], $log{"$groups[$x]"}, $email{"$groups[$x]"});
            }
        }
        
        for my $thr (@threads) {
            $thr->join();
        }

        $lastmin = $min;
    }
}


sub pingit {                # ping one particular target

    my $min = shift;
    my $targ = shift;
    my $log = shift;
    my $email = shift;
    my $found;
    my $mailer;
    
    my (@stuff, $good, $nogood, $time, $samples, $out, $rec);
    
    @stuff = `$pingcmd $targ`;
    
    if ($log) {
        my $str = "$min|" . scalar(gmtime($min * 60)) . "\n";
        psGV::_update_logfile("../logs/$targ.log", $min, $str, @stuff);
    }
    
    for (my $x = 0; $x < @stuff; $x++) {
	    if ($stuff[$x] =~ /4 packets transmitted, (\d) received/) {
            $found = 1;
	        $rec = $1;
            if ($rec == 0) {    # no packets received
                $out = "D";     # it's down
                $time = 0;
            } else {
                $out = ($rec > 2) ? "U" : "G";
                
                if ($stuff[$x + 1] =~ / = [\d\.]+\/([\d\.]+)\/[\d\.]+/) {
                    $time = $1;
                } else {
                    $time = 0;
                }
            }
            last;
        }
    }
    
    if (!$found) {
        $out = "D";
        $time = 0;
    }
    
    if ($out eq "D") {
        if ($lastmailed{"$email|$targ"} <= ($min - $squelch)) {
            $mailer = psMailer->new();
            $mailer->to($email);
            $mailer->from($emailfrom);
            $mailer->subject($emailsubject);
            $mailer->body("Asset $targ is not responding to pings.");
            $mailer->assetname($targ);
            $mailer->send();
        }
    }
    
    $time = sprintf "%.1f", $time;
    psGV::_update_datafile("../data/$targ.txt", $min, 1 => $out, 2 => $time);
}    
