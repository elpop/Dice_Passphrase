#!/usr/bin/perl
use strict;
use DBI;            # Interface to Database

my $words = $ARGV[0];
$words = 4 unless($words);

my $passphrase = '';
my %cache = ();

my $work_dir = $ENV{'HOME'} . '/.passphrase'; # keys directory
# if not exists the work directory, creates and put the init_flag on
if (-e "$work_dir/passphrase.db") {

    # Open or create SQLite DB
    my $dbh = DBI->connect("dbi:SQLite:dbname=$work_dir/passphrase.db","","");
    $dbh->{PrintError} = 0; # Disable automatic  Error Handling

    my $SQL_Code = "select word from dictionary where dic = ? and dice_index = ?;";
    my $sth_read = $dbh->prepare($SQL_Code);

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
            $number .= int( rand( 6 ) ) + 1;
        }
    
        if ( !exists($cache{"$dic$number"}) ) {
            $cache{"$dic$number"} = 1;
            my $word = read_word($dic, "$number");
            $word =~ s/\n//g;
            $passphrase .= ' ' . $word;
        }
        else {
            $i--;
        }
    }
    $dbh->disconnect;

    print "Passphrase:$passphrase\n";
}
else {
    print "No Passphrase words db available\nLoad the words lits wit db_load_words.pl\n";
}
