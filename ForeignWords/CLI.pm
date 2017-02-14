package ForeignWords::CLI;
use strict;
use warnings FATAL => 'all';
use utf8;
use open ':std', ':encoding(UTF-8)';

use Exporter qw/ import /;
our @EXPORT_OK = qw/ cli_main /;

use Term::ReadLine;

use ForeignWords::Utils qw/ assert trim slow_print /;
use ForeignWords::Words;

my $db = ForeignWords::Words->new();

sub cli_main {
    my $term = Term::ReadLine->new('foreign words', \*STDIN, \*STDOUT);
    while (defined(my $input = $term->readline('> '))) {
        $input = trim $input;
        if ($input eq 'learn') {
            learn();
        } elsif ($input eq 'help') {
            show_help();
        } elsif ($input eq 'add') {
            _add_word($term);
        } elsif ($input eq '') {
            # NOP
        } else {
            slow_print "Command not found\n";
        }
    }
}

sub learn {
    my $words = $db->get_batch;
    # TODO What if there not enough words to make a batch?
    my %score;
    for my $word (keys %$words) {
        $score{$word} = 0;
    }
    ask_translation_to_word($words, \%score);
    ask_word_to_translation($words, \%score);
    for my $word (keys %score) {
        if ($score{$word} == 2) {
            $db->update_word_progress($word);
        } else {
            $db->reset_word_progress($word);
        }
    }
}

sub ask_word_to_translation {
    my ($words, $score) = @_;
    my $right_choice_number;
    for my $word (keys %$words) {
        slow_print "$word\n\n";
        my %choices = $db->get_choices($words, $word);
        my @keys = keys(%choices);
        while (my ($i, $key) = each @keys) {
            my $translations = $choices{$key};
            printf "%d. %s\n", $i+1, "@$translations";
            $right_choice_number = $i+1 if $key eq $word;
        }

        assert(defined $right_choice_number, '$right_choice_number IS UNDEFINED');

        my $choice = _get_numerical_choice();
        my $success = _check_numerical_answer($choice, $right_choice_number, $word);
        $score->{$word} += 1 if $success;
    }
}

sub ask_translation_to_word {
    my ($words, $score) = @_;
    my $right_choice_number;
    for my $word (keys %$words) {
        my $translations = $words->{$word};
        slow_print "@$translations\n\n";
        my %choices = $db->get_choices($words, $word);
        my @keys = keys(%choices);
        while (my ($i, $key) = each @keys) {
            printf "%d. %s\n", $i+1, "$key";
            $right_choice_number = $i+1 if $key eq $word;
        }

        assert(defined $right_choice_number, '$right_choice_number IS UNDEFINED');

        my $choice = _get_numerical_choice();
        my $success = _check_numerical_answer($choice, $right_choice_number, $word);
        $score->{$word} += 1 if $success;
    }
}

sub _add_word {
    my ($term) = @_;
    slow_print "Enter word in foreign language\n";
    my $word = $term->readline('. ');

    slow_print "Enter translations (comma separated)\n";
    my $translation = $term->readline('. ');
    $db->add_word($word, $translation);
}

sub show_help {
    slow_print <<"DOC"
help:   show this message
learn:  learn words
add:    add word
DOC
}

sub _get_numerical_choice {
    my $choice;
    slow_print "Enter a number\n";
    while (1) {
        exit 0 unless defined($choice = <STDIN>);
        $choice = trim $choice;
        if ($choice =~ m/^\d+$/) {
            last;
        } else {
            slow_print "Enter a number\n";
            next;
        }
    }
    return $choice;
}

sub _check_numerical_answer {
    my ($user_number, $right_number, $answer) = @_;
    my $success = $user_number == $right_number;
    if ($success) {
        slow_print "CORRECT!\n\n";
    } else {
        slow_print "INCORRECT! RIGHT ANSWER IS:\n";
        slow_print "$answer\n\n";
    }
    return $success;
}

1;
