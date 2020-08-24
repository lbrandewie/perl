#!/usr/bin/perl

undef $/;

@files = <data/*>;
push @files, <docs/*>;
push @files, <lib/*>;
push @files, <logs/*>;
push @files, <reports/*>;
push @files, <scripts/*>;
push @files, <system/*>;

foreach $file (@files) {
    open INOUT, "+<$file";
    $contents = <INOUT>;

    $contents =~ s/\015//mg;
    seek INOUT, 0, 0;
    print INOUT $contents;
    truncate INOUT, tell(INOUT);
    close INOUT;
}




