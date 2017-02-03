package utils;
use strict;
use warnings FATAL => 'all';

use DateTime;
use DateTime::Format::Strptime;

use Exporter qw/ import /;
our @EXPORT_OK = qw/ assert trim current_time parse_time /;

my $DEBUG = 1;

sub assert {
    return unless $DEBUG;

    my ($condition, $error_text) = @_;
    unless ($condition) {
        my (undef, undef, $line) = caller;
        print STDERR "WRONG ASSERTION ON LINE $line\n";
        die $error_text;
    }
}

sub trim {
    (my $s = $_[0]) =~ s/^\s+|\s+$//g;
    return $s;
}

sub current_time {
    return DateTime->now()->iso8601();
}

sub parse_time {
    my ($str) = @_;
    my $strp = DateTime::Format::Strptime->new(pattern => '%FT%T', time_zone => 'UTC');
    return $strp->parse_datetime($str);
}

1;
