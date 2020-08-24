#
# psGV.pm
#
# carries global variables in its namespace and maintains settings and other files
#
# copyright (c) 2019 L. P. "Lars" Brandewie. All Rights Reserved.
#
# note: access to this script conveys no rights.
#


package psGV;

use strict;


sub new {                           # gimme a new one please

    my $class = shift;
    my $self = {};
    
    bless $self, $class;
    
    $self->{"_version"}  = "1.28";
    
    $self->{"_settings_system"} = {};
    %{$self->{"_settings_system"}} = _read_settings("../system/settings_system.txt");
    
    $self;
}


sub get_setting_system {
    my $self = shift;
    my $name = shift;
    
    $self->{"_settings_system"}{"$name"};
}


sub set_setting_system {            # set one or more system settings
    my $self = shift;
    my %stuff = @_;
    my $x;
    
    for ($x = 0; $x < @_; $x += 2) {
        if ($_[$x] eq "") {
            die "blank setting in psGV->set_setting_system";
        }
    }
    
    %{$self->{"_settings_system"}} = _set_settings("../system/settings_system.txt", %stuff);
}


sub version {                       # returns but does not set version
    my $self = shift;
    $self->{"_version"};
}


sub _delete_from_list {             # delete all copies of $arg from list

    my $arg = shift;
    my @stuff = @_;
    
    my @out;
    
    for (my $x = 0; $x < @stuff; $x++) {
        if ($stuff[$x] ne $arg) {
            push @out, $stuff[$x];
        }
    }
    @out;
}

sub _increment_setting {            # increment a given setting and return the new value

    my $filename = shift;
    my $setting = shift;
    my ($line, $name, $val, %temp);
    
    open SETTINGS, "+<$filename";
    flock SETTINGS, 2;
    
    while (defined($line = <SETTINGS>)) {
        chomp $line;
        ($name, $val) = split / *= */, $line;
        $temp{$name} = $val;
    }
    $temp{$setting}++;
    
    seek SETTINGS, 0, 0;
    for my $k (sort keys %temp) {
        print SETTINGS "$k = $temp{$k}\n";
    }
    
    truncate SETTINGS, tell(SETTINGS);
    close SETTINGS;
    
    $temp{$setting};
}


sub _move_down {        # move a unique key down in a list (up in the array)

    my $arg = shift;
    my $temp;
    
    my @stuff = @_;
    
    for (my $x = 0; $x < $#stuff; $x++) {
        if ($stuff[$x] eq $arg) {
            $temp = $stuff[$x];
            $stuff[$x] = $stuff[$x + 1];
            $stuff[$x + 1] = $temp;
            last;
        }
    }
    @stuff;
}


sub _move_up {          # move a unique key up in a list (down in the array)

    my $arg = shift;
    my $temp;
    
    my @stuff = @_;
    
    for (my $x = 1; $x < @stuff; $x++) {
        if ($stuff[$x] eq $arg) {
            $temp = $stuff[$x];
            $stuff[$x] = $stuff[$x - 1];
            $stuff[$x - 1] = $temp;
            last;
        }
    }
    @stuff;
}


sub _read_settings {                # read settings from a generic settings file and return them as a hash

    my $filename = shift;
    my (%temp, $line, $name, $val);
    
    open SETTINGS, $filename;
    flock SETTINGS, 1;
    
    while (defined($line = <SETTINGS>)) {
        chomp $line;
        ($name, $val) = split / *= */, $line;
        $temp{"$name"} = $val;
    }
    close SETTINGS;
    
    %temp;
}


sub _set_settings {                 # set one or more settings in a given file (and return the new settings)

    my $filename = shift;
    my %stuff = @_;                     # get rest of args as a hash
    my (%temp, $line, $name, $val);
    
    open SETTINGS, "+<$filename";
    flock SETTINGS, 2;
    
    while (defined($line = <SETTINGS>)) {
        chomp $line;
        ($name, $val) = split / *= */, $line;
        $temp{"$name"} = $val;
    }
    
    for my $k (keys %stuff) {          # overwrite with new stuff
        $temp{"$k"} = $stuff{"$k"};
    }

    seek SETTINGS, 0, 0;
    
    for my $k (sort keys %temp) {      # keep file sorted
        print SETTINGS "$k = ", $temp{$k}, "\n";
    }
    
    truncate SETTINGS, tell(SETTINGS);
    close SETTINGS;
    
    %temp;
}


sub _touch {                    # make sure a file exists

    my $filename = shift;
    
    unless (-e $filename) {
        open TOUCH, ">$filename";
        close TOUCH;
    }
}


sub _update_datafile {          # updates certain fields of a data file and trims it
 
    my $filename = shift;
    my $minute = shift;
    my %args = @_;

    my $lim = $minute - 1440;
    my ($line, @temp, %thehash);
    
    _touch($filename);
    
    open DATA, "+<$filename";
    flock DATA, 2;
    
    while (defined($line = <DATA>)) {
        chomp $line;
        
        if ($line > $lim) {     # data less than a day old?
            @temp = split /\|/, $line;
            
            $thehash{$temp[0]} = $line;
        }
    }
    
    if ($thehash{$minute}) {
        @temp = split /\|/, $thehash{$minute};
    } else {
        @temp = ($minute);
    }

    for my $key (keys %args) {
        $temp[$key] = $args{$key};
    }
        
    $thehash{$minute} = join("|", @temp);
    
    seek DATA, 0, 0;
    
    for my $key (sort {$a <=> $b} keys %thehash) {
        print DATA $thehash{$key}, "\n";
    }
    truncate DATA, tell(DATA);
    close DATA;
}

sub _update_keyfile {

    my $filename = shift;
    my $key = shift;
    my ($line, %thehash, @temp, %args, @id);
    
    open DATA, "+<$filename";
    flock DATA, 2;
    while (defined($line = <DATA>)) {
        chomp $line;
        if ($line =~ /\|/) {
            @temp = split /\|/, $line;
            $thehash{$temp[0]} = $line;
            push @id, $temp[0];
        }
    }
    
    if ($_[0] eq "delete") {    # delete the key rather than updating it
        @id = _delete_from_list($key, @id);
    } elsif ($_[0] eq "moveup") {
        @id = _move_up($key, @id);
    } elsif ($_[0] eq "movedown") {
        @id = _move_down($key, @id);
    } else {
        %args = @_;

        if ($thehash{$key}) {
            @temp = split /\|/, $thehash{$key};
        } else {
            @temp = ($key);
            push @id, $key;
        }
        
        for my $key (keys %args) {
            $temp[$key] = $args{$key};
        }
        
        $thehash{$key} = join("|", @temp);
    }
    seek DATA, 0, 0;
    
    for my $key (@id) {
        print DATA $thehash{$key}, "\n";
    }
    
    truncate DATA, tell(DATA);
    close DATA;
}


sub _update_logfile {

    my $file = shift;
    my $min = shift;
    my $lim = $min - 1440;
    
    my @newstuff = @_;
    
    my (@stuff, @temp, $x);

    _touch($file);
    
    open DATA, "+<$file";
    flock DATA, 2;
    @stuff = <DATA>;
    
    my $start = -1;
    
    for ($x = 0; $x < @stuff; $x++) {
        if ($stuff[$x] =~ /\|/) {
            @temp = split /\|/, $stuff[$x];
            if ($temp[0] > $lim) {
                $start = $x;
                last;
            }
        }
    }
    
    seek DATA, 0, 0;
    
    if ($start > -1) {
        for ($x = $start; $x < @stuff; $x++) {
            print DATA $stuff[$x];
        }
    }
    
    print DATA @newstuff, "\n";
    truncate DATA, tell(DATA);
    close DATA;
}


1;

