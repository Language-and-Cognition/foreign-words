package utils;
use strict;
use warnings FATAL => 'all';

use Exporter qw/ import /;
our @EXPORT_OK = qw/ assert /;

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

1;