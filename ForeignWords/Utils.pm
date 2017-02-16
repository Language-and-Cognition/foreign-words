package ForeignWords::Utils;
use English;
use strict;
use warnings FATAL => 'all';

use DateTime;
use DateTime::Format::Strptime;
use Time::HiRes qw / usleep /;

use Exporter qw/ import /;
our @EXPORT_OK = qw/ assert trim current_time parse_time slow_print /;

my $DEBUG = 1;

sub assert {
    return unless $DEBUG;

    my ($condition, $error_text) = @_;
    unless ($condition) {
        my (undef, $filename, $line) = caller;
        print STDERR "WRONG ASSERTION AT $filename:$line\n";
        die $error_text;
    }
}

sub trim {
    (my $s = $_[0]) =~ s/^\s+|\s+$//g;
    return $s;
}

sub current_time {
    # TODO This will not work as expected after 2038
    return DateTime->now()->epoch();
}

sub parse_time {
    my ($str) = @_;
    my $strp = DateTime::Format::Strptime->new(pattern => '%s', time_zone => 'UTC');
    return $strp->parse_datetime($str);
}

sub slow_print {
    my $old_value = $OUTPUT_AUTOFLUSH;
    $OUTPUT_AUTOFLUSH = 1;
    my ($text) = @_;
    for my $c (split //, $text) {
        print "$c";
        usleep 0.95e4 unless ($c =~ m/\s/);
    }
    $OUTPUT_AUTOFLUSH = $old_value;
}

1;
