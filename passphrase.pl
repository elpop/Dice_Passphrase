#!/usr/bin/perl
use strict;
use DBI;            # Interface to Database
use RPG::Dice;

my $dice = RPG::Dice->new("1d6"); 

my $words = $ARGV[0];

$words = 4 unless($words);

my $passphrase = '';
my %cache = ();

my $init_flag = 0;

my $work_dir = $ENV{'HOME'} . '/.passphrase'; # keys directory
# if not exists the work directory, creates and put the init_flag on
unless (-e "$work_dir") {
    mkdir($work_dir);
    $init_flag = 1;
}

# Open or create SQLite DB
my $dbh = DBI->connect("dbi:SQLite:dbname=$work_dir/passphrase.db","","");
$dbh->{PrintError} = 0; # Disable automatic  Error Handling

# if not exists the db schema, creates and star a initial load of the results
if ($init_flag) {
    # init the db schema
    init_db();
}

my $SQL_Code = "select word from dictionary where dic = ? and dice_index = ?;";
my $sth_read = $dbh->prepare($SQL_Code);

$SQL_Code = "insert into dictionary(dic, dice_index, word) values( ?, ?, ? );";
my $sth_insert = $dbh->prepare($SQL_Code);


if ($init_flag) {
    # Load the results
    load_dic();
    # clean up the DB
    $dbh->do('vacuum;');
}

#-------------------------------------------#
# Create the initial SQLite database schema #
#-------------------------------------------#
sub init_db {
    print "Init DB\n";
    # Create lottery products Table
    $SQL_Code = "CREATE TABLE dictionary (
            dic        integer not null,
            dice_index text not null,
            word       text not null
        );";
    $dbh->do($SQL_Code);
    # Create index on products table
    $SQL_Code = "CREATE UNIQUE INDEX un_dic_index on dictionary(dic, dice_index);";
    $dbh->do($SQL_Code);
} # End sub init_db()

#--------------------------------------#
# Search if the record already exists  #
#--------------------------------------#
sub already_on_results {
    my ($dic, $index) = @_;
    my $already = 0;
    my $ret = $sth_read->execute($dic,"$index");
    while (my $read_ref = $sth_read->fetchrow_hashref) {
        $already++;
    }
    $sth_read->finish();
    return $already
} # en sub _already_on_results()

sub load_dic {
    foreach my $dic (1 .. 2) {
        open(DIC, "<", "dice_words_$dic.txt") or die;
        while (<DIC>) {
            my ($index, $word) = split(/ /,$_);
            # insert the new record if not previously exists
             unless( already_on_results($dic, "$index") ) {
                 $sth_insert->execute($dic,"$index","$word");
             }
        }
        close(DIC);
    }
}

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
        $number .= $dice->roll();
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

print "Passphrase:$passphrase\n";

$dbh->disconnect;
