package cli;
use strict;
use warnings FATAL => 'all';
use utf8;
use open ':std', ':encoding(UTF-8)';

use Exporter qw/ import /;
our @EXPORT_OK = qw/ cli_main /;

use Term::ReadLine;

use utils qw/ assert /;
use words qw/ get_choices get_words /;

# TODO duplication
my $NUMBER_OF_CHOICES_IN_QUESTION = 4;

sub cli_main {
    my %words = get_words;
    my $term = Term::ReadLine->new('foreign words');
    while (defined(my $input = $term->readline('> '))) {
        if ($input eq 'learn') {
            ask_translation_to_word(%words);
        } else {
            print "Command not found\n";
        }
    }
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

1;
