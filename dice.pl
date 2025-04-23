#!/usr/bin/perl
#===================================================================#
# Program => dice.pl                    (In Perl 5.0) version 0.0.1 #
#===================================================================#
# Autor         => Fernando "El Pop" Romo        (pop@cofradia.org) #
# Creation date => 22/apr/2025                                      #
#-------------------------------------------------------------------#
# Info => Roll virtual dice and choose words for dictionary to make #
#         a Passphrase.                                             #
#-------------------------------------------------------------------#
#        This code are released under the GPL 3.0 License.          #
#===================================================================#
use strict;
use RPG::Dice;

my $dice = RPG::Dice->new("1d6"); 

my $words = $ARGV[0];

$words = 4 unless($words);

my $passphrase = '';
my %cache = ();

print "Dic  Index  Word\n";

for ( my $i = 0; $i < $words; $i++ ) { 
    my $number = '';
    my $dic = 1;
    
    if ($i % 2 == 0) {
        $dic =1;
    }
    else {
        $dic = 2;
    }
    
    for ( my $x = 0; $x < 6; $x++ ) { 
        $number .= $dice->roll();
    }
    
    if ( !exists($cache{"$dic$number"}) ) {
        $cache{"$dic$number"} = 1;
        print " $dic - ";
        my $word = qx(grep \"^$number\" dice_words_$dic.txt);
        print "$word";
        $word =~ s/\d{6}|\n//g;
        $passphrase .= $word;
    }
    else {
        $i--;
    }
}

print "\nPassphrase:$passphrase\n";
