package ForeignWords::Constants;
use strict;
use warnings FATAL => 'all';

use constant {
    NUMBER_OF_CHOICES_IN_QUESTION => 4,
    NUMBER_OF_WORDS_IN_BATCH => 5,
};
use constant LANGUAGE => 'English';
use constant MEMORIZING_FACTOR => 3;
use constant DAY => 60 * 60 * 24;

use Exporter qw/ import /;
our @EXPORT_OK = qw/
                     NUMBER_OF_CHOICES_IN_QUESTION
                     NUMBER_OF_WORDS_IN_BATCH
                     LANGUAGE
                     MEMORIZING_FACTOR
                     DAY
                    /;

1;
