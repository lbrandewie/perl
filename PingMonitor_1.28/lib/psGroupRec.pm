#
# psGroupRec.pm
#
# encapsulate a record from the groups.txt file
#
# copyright 2019 L. P. "Lars" Brandewie. All rights reserved.
#

package psGroupRec;

use strict;

sub new {

    my $class = shift;
    my $line = shift;
    my $self = {};
    
    bless $self, $class;
    
    chomp $line;
    
    my @temp = split /\|/, $line;
    
    $self->{"_id"} = $temp[0];
    $self->{"_name"} = $temp[1];
    $self->{"_ping"} = $temp[2];
    $self->{"_log"} = $temp[3];
    $self->{"_page"} = $temp[4];
    $self->{"_email"} = $temp[5];
    
    return $self;
}


sub id {

    my $self = shift;
    
    return $self->{"_id"};
}


sub email {

    my $self = shift;
    
    return $self->{"_email"};
}


sub log {

    my $self = shift;
    
    return $self->{"_log"};
}


sub name {
    
    my $self = shift;
    
    return $self->{"_name"};
}


sub page {

    my $self = shift;
    
    return $self->{"_page"};
}


sub ping {

    my $self = shift;
    
    return $self->{"_ping"};
}


1;
