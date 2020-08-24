#
# psTargetRec.pm
#
# encapsulate a record from the targets.txt file
#
# copyright 2019 L. P. "Lars" Brandewie. All rights reserved.
#

package psTargetRec;

use strict;

sub new {

    my $class = shift;
    my $line = shift;
    my $self = {};
    
    bless $self, $class;
    
    chomp $line;
    
    my @temp = split /\|/, $line;
    
    $self->{"_id"} = $temp[0];
    $self->{"_dispname"} = $temp[1];
    $self->{"_target"} = $temp[2];
    $self->{"_yellow"} = $temp[3];
    $self->{"_group"} = $temp[4];
    
    return $self;
}

sub id {

    my $self = shift;
    
    return $self->{"_id"};
}

sub dispname {
    
    my $self = shift;
    
    return $self->{"_dispname"};
}

sub group {

    my $self = shift;
    
    return $self->{"_group"};
}

sub target {

    my $self = shift;
    
    return $self->{"_target"};
}

sub yellow {

    my $self = shift;
    
    return $self->{"_yellow"};
}

1;
