package ForeignWords::Words;
use strict;
use warnings FATAL => 'all';
use utf8;

use DBI;
use JSON qw/ encode_json decode_json /;

use ForeignWords::Utils qw/ assert trim current_time parse_time /;

use Exporter qw/ import /;
our @EXPORT_OK = qw/ get_choices
                     get_batch
                     get_words
                     add_word
                     update_word_progress
                     NUMBER_OF_CHOICES_IN_QUESTION
                     NUMBER_OF_WORDS_IN_BATCH /;

use constant {
    NUMBER_OF_CHOICES_IN_QUESTION => 4,
    NUMBER_OF_WORDS_IN_BATCH => 5,
};
use constant LANGUAGE => 'English';

assert(NUMBER_OF_WORDS_IN_BATCH >= NUMBER_OF_CHOICES_IN_QUESTION, "CHOICES > BATCH");

sub get_words {
    # TODO make class from in order to reuse connection
    my $dbh = DBI->connect('DBI:SQLite:dbname=words.db', '', '');
    my $table = LANGUAGE;
    my $rows = $dbh->selectall_arrayref("SELECT word, translation, progress, last_success_time FROM $table");
    my %words;
    for my $row (@$rows) {
        $words{$row->[0]} = decode_json($row->[1]);
    }
    return \%words;
}

sub get_batch {
    my $dbh = DBI->connect('DBI:SQLite:dbname=words.db', '', '');
    my $table = LANGUAGE;
    my $rows = $dbh->selectall_arrayref("SELECT word, translation, progress, last_success_time FROM $table ORDER BY progress, last_success_time LIMIT ?", undef, NUMBER_OF_WORDS_IN_BATCH);
    my %words;
    for my $row (@$rows) {
        $words{$row->[0]} = decode_json($row->[1]);
    }
    return \%words;
}

sub add_word {
    my ($word, $translation) = @_;
    $translation = _make_json_array_from_translation($translation);

    my $dbh = DBI->connect('DBI:SQLite:dbname=words.db', '', '');
    my $table = LANGUAGE;
    $DBI::err && die $DBI::errstr;
    $dbh->do("INSERT INTO $table (word, translation, progress, last_success_time) VALUES (?, ?, 0, ?)",
        undef, $word, $translation, current_time());
}

sub update_word_progress {
    my ($word) = @_;
    my $dbh = DBI->connect('DBI:SQLite:dbname=words.db', '', '');
    my $table = LANGUAGE;
    $dbh->do("UPDATE $table SET progress = progress + 1, last_success_time = ? WHERE word = ?", undef, current_time(), $word);
}

sub reset_word_progress {
    my ($word) = @_;
    my $dbh = DBI->connect('DBI:SQLite:dbname=words.db', '', '');
    my $table = LANGUAGE;
    $dbh->do("UPDATE $table SET progress = 0, last_success_time = ? WHERE word = ?", undef, current_time(), $word);
}

sub _make_json_array_from_translation {
    my ($translation_raw) = @_;
    my @translations = map {trim $_} split(',', $translation_raw);
    return encode_json \@translations;
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
