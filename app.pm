use strict;
use warnings;


# TODO write and read json from a file
sub get_words {
    my %words = (
        hi => ['привет'],
        bye => ['пока'],
        year => ['год'],
    );
    return %words;
}

my %words = get_words;
print "$words{bye}->[0]\n";
