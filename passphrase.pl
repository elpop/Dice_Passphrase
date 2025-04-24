#!/usr/bin/perl
#===================================================================#
# Program => passphrase.pl              (In Perl 5.0) version 1.0.1 #
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
use DBI;
use Math::Random::Secure qw(irand);

my $words = $ARGV[0];
$words = 4 unless($words);
my $times = $ARGV[1];
$times = 1 unless($times);
my $debug = $ARGV[2];
$debug = 0 unless($debug);

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

    # loop the number of passphrases to generate
    for ( my $t = 1; $t <= $times; $t++ ) {
        # loop the number of words to generate the passphrase
        my $passphrase = '';
        my %cache = ();
        for ( my $i = 0; $i < $words; $i++ ) {
            my $number = '';

            # Choose the dictionary to use and alternate in each word
            my $dic = irand(2) + 1;

            # Roll the dice 6 times to generate the index
            for ( my $x = 0; $x < 6; $x++ ) {
                $number .= irand(6) + 1;
            }

            # Check cache to avoid repeat the same word on the passphrase
            if ( !exists($cache{"$dic$number"}) ) {
                $cache{"$dic$number"} = 1;

                # search the word
                my $word = read_word($dic, "$number");
                print "$dic, $number, $word\n" if ($debug);
                $passphrase .= $word . ' ';
            }
            # if exists a word collision decrement the word count
            else {
                $i--;
            }
        }
        print "$passphrase\n";
    }
    $dbh->disconnect;
}
else {
    print "No Passphrase words db available\nLoad the words lits wit db_load_words.pl\n";
}
