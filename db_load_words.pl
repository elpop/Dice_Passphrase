#!/usr/bin/perl
use strict;
use DBI;            # Interface to Database

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

if ($init_flag) {
    # init the db schema
    init_db();
}

my $SQL_Code = "select word from dictionary where dic = ? and dice_index = ?;";
my $sth_read = $dbh->prepare($SQL_Code);

$SQL_Code = "insert into dictionary(dic, dice_index, word) values( ?, ?, ? );";
my $sth_insert = $dbh->prepare($SQL_Code);

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

sub load_words {
    my ($dic, $file) = @_;
    open(DIC, "<", "$file") or die;
    print "load $file...\n";
    while (<DIC>) {
        chomp;
        my ($index, $word) = split(/ /,$_);
        # insert the new record if not previously exists
        unless( already_on_results($dic, "$index") ) {
            $sth_insert->execute($dic,"$index","$word");
        }
    }
    close(DIC);
    print "$file loaded!\n";
}

# if not exists the db schema, creates and star a initial load of the words
if ($init_flag) {
    # Load the words
    load_words(1,'dice_words_1.txt');
    load_words(2,'dice_words_2.txt');
    load_words(3,'dice_special.txt');
    # clean up the DB
    $dbh->do('vacuum;');
    print "DB ready for use\n";
}

$dbh->disconnect;

