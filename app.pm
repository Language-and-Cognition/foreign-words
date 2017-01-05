use strict;
use warnings;
use utf8;
use open ':std', ':encoding(UTF-8)';

use DBI;
use JSON qw/ encode_json decode_json /;

my $DEBUG = 1;

my $NUMBER_OF_CHOICES_IN_QUESTION = 4;
my $NUMBER_OF_WORDS_IN_BATCH = 5;


sub assert {
    return unless $DEBUG;

    my ($condition, $error_text) = @_;
    unless ($condition) {
        my (undef, undef, $line) = caller;
        print STDERR "WRONG ASSERTION ON LINE $line\n";
        die $error_text;
    }
}

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

sub ask_word_to_translation {
    my %words = @_;
    my $right_choice_number;
    for my $word (keys %words) {
        print "$word\n\n";
        my %choices = get_choices(\%words, $word, $NUMBER_OF_CHOICES_IN_QUESTION);
        my @keys = keys(%choices);
        while (my ($i, $key) = each @keys) {
            my $translations = $choices{$key};
            printf "%d. %s\n", $i+1, "@$translations";
            $right_choice_number = $i+1 if $key eq $word;
        }

        assert(defined $right_choice_number, '$right_choice_number IS UNDEFINED');

        my $choice;
        chomp($choice = <STDIN>);

        if ($choice == $right_choice_number) {
            print "CORRECT!\n\n";
        } else {
            print "INCORRECT! RIGHT ANSWER IS:\n";
            print "@{ $choices{$word} }\n\n";
        }
    }
}

sub ask_translation_to_word {
    my %words = @_;
    my $right_choice_number;
    for my $word (keys %words) {
        my $translations = $words{$word};
        print "@$translations\n\n";
        my %choices = get_choices(\%words, $word, $NUMBER_OF_CHOICES_IN_QUESTION);
        my @keys = keys(%choices);
        while (my ($i, $key) = each @keys) {
            printf "%d. %s\n", $i+1, "$key";
            $right_choice_number = $i+1 if $key eq $word;
        }

        assert(defined $right_choice_number, '$right_choice_number IS UNDEFINED');

        my $choice;
        chomp($choice = <STDIN>);

        if ($choice == $right_choice_number) {
            print "CORRECT!\n\n";
        } else {
            print "INCORRECT! RIGHT ANSWER IS:\n";
            print "$word\n\n";
        }
    }
}

my %words = get_words;
ask_translation_to_word(%words);
