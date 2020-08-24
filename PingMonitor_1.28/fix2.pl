#!/usr/bin/perl

@files = <scripts/*>;

foreach $file (@files) {
    if ($file =~ /\.pl$/) {
        $newname = $file;
        $newname =~ s/\.pl//;
        rename $file, $newname;
    }
}


mkdir "data" unless -d "data";
mkdir "logs" unless -d "logs";
mkdir "reports" unless -d "reports";
