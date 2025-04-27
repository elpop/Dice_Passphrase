#!/usr/bin/perl
#===================================================================#
# Program => db_load_words.pl           (In Perl 5.0) version 1.0.2 #
#===================================================================#
# Autor         => Fernando "El Pop" Romo        (pop@cofradia.org) #
# Creation date => 22/apr/2025                                      #
#-------------------------------------------------------------------#
# Info => load the words into sqlite db to make a Passphrase.       #
#-------------------------------------------------------------------#
#        This code are released under the GPL 3.0 License.          #
#===================================================================#
use strict;
use DBI;            # Interface to Database

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

# Let ready the queries for fast execution
my $SQL_Code = "select word from dictionary where language = ? and page = ? and dice_index = ?;";
my $sth_read = $dbh->prepare($SQL_Code);

$SQL_Code = "insert into dictionary(language, page, dice_index, word) values( ?, ?, ?, ? );";
my $sth_insert = $dbh->prepare($SQL_Code);

#-------------------------------------------#
# Create the initial SQLite database schema #
#-------------------------------------------#
sub init_db {
    print "Init DB\n";
    # Create lottery products Table
    $SQL_Code = "CREATE TABLE dictionary (
            language   text not null,
            page       integer not null,
            dice_index text not null,
            word       text not null
        );";
    $dbh->do($SQL_Code);
    # Create index on products table
    $SQL_Code = "CREATE UNIQUE INDEX un_dic_index on dictionary(language, page, dice_index);";
    $dbh->do($SQL_Code);
} # End sub init_db()

#--------------------------------------#
# Search if the record already exists  #
#--------------------------------------#
sub already_on_results {
    my ($language, $page, $index) = @_;
    my $already = 0;
    my $ret = $sth_read->execute("$language", $page, "$index");
    while (my $read_ref = $sth_read->fetchrow_hashref) {
        $already++;
    }
    $sth_read->finish();
    return $already
} # End sub _already_on_results()

#----------------------------------------#
# Read the words file and insert into DB #
#----------------------------------------#
sub load_words {
    my ($language, $page, $file) = @_;
    open(DIC, "<", "words/$file") or die;
    print "load $file...\n";
    while (<DIC>) {
        chomp;
        my ($index, $word) = split(/ /,$_);
        # insert the new record if not previously exists
        unless( already_on_results("$language", $page, "$index") ) {
            $sth_insert->execute("$language", $page,"$index","$word");
        }
    }
    close(DIC);
    print "$file loaded!\n";
} # End load_words()

#-----------#
# Main body #
#-----------#

# Load the words
if ($init_flag) {
    # Spanish
    load_words('es',1,'es_words_1.txt');
    load_words('es',2,'es_words_2.txt');
    # Special characters
    load_words('special',1,'special_chars.txt');
    # English
    load_words('en',1,'en_words_1.txt');
    load_words('en',2,'en_words_2.txt');
    load_words('en',3,'en_words_3.txt');
    load_words('en',4,'en_words_4.txt');
    load_words('en',5,'en_words_5.txt');
    load_words('en',6,'en_words_6.txt');
    load_words('en',7,'en_words_7.txt');
    # clean up the DB
    $dbh->do('vacuum;');
    print "DB ready for use\n";
}

# Close DB connection
$dbh->disconnect;

