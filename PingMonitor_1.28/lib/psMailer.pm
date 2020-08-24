#
# psMailer.pm
#
# very simple interface to sendmail
#

use strict;

use psGV;

package psMailer;


sub new {

    my $class = shift;
    my $self = {};
    bless $self, $class;
    
    $self;
}

sub send {

    my $self = shift;

    unless ($self->{"_subject"}) {
        die "must set subject to send email in psMailer.pm.";
    }
    
    unless ($self->{"_to"}) {
        die "must set to addres to send email in psMailer.pm.";
    }
    
    unless ($self->{"_from"}) {
        die "must set from address to send email in psMailer.pm.";
    }
    
    unless ($self->{"_body"}) {
        die "must set message body to send email in psMailer.pm.";
    }
    
    unless ($self->{"_assetname"}) {
        die "must set assetname in psMailer.pm.";
    }

    
    open SM, "| /usr/lib/sendmail -oi -t";
    
    print SM "to: " . $self->{"_to"} . "\n";
    print SM "from: " . $self->{"_from"} . "\n";
    print SM "subject: " . $self->{"_subject"} . "\n\n";
    print SM $self->{"_body"} . "\n\n";
    
    close SM;
    
    my $min = int(time() / 60);
    
    _trimSentFile();
    
    open OUT, ">>../system/emails_sent.txt";
    flock OUT, 2;
    print OUT "$min|" . $self->{"_to"} . "|" . $self->{"_assetname"} . "\n";
    close OUT;
}

# accessor subs

sub assetname {

    my $self = shift;
    
    if (@_) {
        $self->{"_assetname"} = shift;
    }
    
    $self->{"_assetname"};
}

sub body {

    my $self = shift;
    
    if (@_) {
        $self->{"_body"} = shift;
    }

    $self->{"_body"};
}

sub from {

    my $self = shift;
    
    if (@_) {
        $self->{"_from"} = shift;
    }
    
    $self->{"_from"};
}

sub subject {

    my $self = shift;
    
    if (@_) {
        $self->{"_subject"} = shift;
    }
    
    $self->{"_subject"};
}

sub to {

    my $self = shift;
    
    if (@_) {
        $self->{"_to"} = shift;
    }
    
    $self->{"_to"};
}

sub _trimSentFile {

    my $min = int(time() / 60);
    my $lim = $min - 1440;
    my ($line, @data);
    
    open INOUT, "+<../system/emails_sent.txt";
    flock INOUT, 2;
    
    while (defined ($line = <INOUT>)) {
        if ($line >= $lim) {            # data is 24 hrs old or less
            push @data, $line;
        }
    }
    
    seek INOUT, 0, 0;
    print INOUT @data;
    truncate INOUT, tell(INOUT);
    close INOUT;
}

1;