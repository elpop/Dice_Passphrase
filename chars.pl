#!/usr/bin/perl
#===================================================================#
# Program => chars.pl                   (In Perl 5.0) version 1.0.0 #
#===================================================================#
# Autor         => Fernando "El Pop" Romo        (pop@cofradia.org) #
# Creation date => 23/apr/2025                                      #
#-------------------------------------------------------------------#
# Info => Roll virtual dice and choose words for dictionary to make #
#         a Passphrase.                                             #
#-------------------------------------------------------------------#
#        This code are released under the GPL 3.0 License.          #
#===================================================================#
use strict;
use DBI;
use Math::Random::Secure qw(irand);

my $work_dir = $ENV{'HOME'} . '/.passphrase'; # keys directory
# if not exists the work directory, creates and put the init_flag on
if (-e "$work_dir/passphrase.db") {

    # Open or create SQLite DB
    my $dbh = DBI->connect("dbi:SQLite:dbname=$work_dir/passphrase.db","","");
    $dbh->{PrintError} = 0; # Disable automatic  Error Handling

    # prepare query on advanced
    my $SQL_Code = "select word from dictionary where dic = ? and dice_index = ?;";
    my $sth_read = $dbh->prepare($SQL_Code);

    # Search the word on the DB
    sub read_word {
        my ($dic, $index) = @_;
        my $word = '';
        my $ret = $sth_read->execute($dic,"$index");
        while (my $read_ref = $sth_read->fetchrow_hashref) {
            $word = $read_ref->{word};
        }
        $sth_read->finish();
        return $word;
    } # en sub read_word()

    # loop the number of words to generate the passphrase
    my $number = '';
    my $dic = 3;
    
    # Roll the dice 6 times to generate the index 
    for ( my $x = 0; $x < 2; $x++ ) { 
         $number .= irand(6) + 1;
    }
    
    my $word = read_word($dic, "$number");
    #print "$dic $number $word\n";
    
    $dbh->disconnect;

    print "$word\n";
}
else {
    print "No Passphrase words db available\nLoad the words lits wit db_load_words.pl\n";
}
