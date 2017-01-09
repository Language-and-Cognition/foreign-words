package words;
use strict;
use warnings FATAL => 'all';

use DBI;
use JSON qw/ encode_json decode_json /;

use utils qw/ assert /;

use Exporter qw/ import /;
our @EXPORT_OK = qw/ get_choices get_words /;

my $NUMBER_OF_CHOICES_IN_QUESTION = 4;
my $NUMBER_OF_WORDS_IN_BATCH = 5;

assert($NUMBER_OF_WORDS_IN_BATCH >= $NUMBER_OF_CHOICES_IN_QUESTION, "CHOICES > BATCH");


sub get_words {
    my $dbh = DBI->connect('DBI:SQLite:dbname=words.db', '', '');
    my $language = 'English';
    # TODO SQL injection
    my $rows = $dbh->selectall_arrayref("SELECT word, translation FROM $language;");
    my %words;
    for my $row (@$rows) {
        $words{$row->[0]} = decode_json($row->[1]);
    }
    return %words;
}

sub get_choices {
    my ($words, $right_word, $how_many) = @_;

    assert($how_many <= keys %$words, "NOT ENOUGH WORDS");
    assert(exists $words->{$right_word}, "RIGHT WORD IS NOT IN WORDS");

    my %result;

    $result{$right_word} = $words->{$right_word};

    my $count = 1;

    for my $word (keys %$words) {
        my $translations = $words->{$word};
        next if $word eq $right_word;

        $result{$word} = $translations;
        $count++;

        last if $count == $how_many;
    }

    return %result;
}

1;