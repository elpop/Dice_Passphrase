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

my $passphrase = '';

my $number = '';

for ( my $x = 0; $x < 2; $x++ ) { 
     $number .= $dice->roll();
}

my $char = qx(grep \"^$number\" dice_special.txt);
$char =~ s/^\d\d\s|\n//g;

print "Character: $char\n";
