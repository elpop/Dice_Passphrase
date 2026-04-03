#!/usr/bin/perl
#===================================================================#
# Program => db_load_words_postgresql.pl              version 1.0.0 #
#===================================================================#
# Autor         => Fernando "El Pop" Romo        (pop@cofradia.org) #
# Creation date => 28/apr/2025                                      #
#-------------------------------------------------------------------#
# Info => load the words into PostgreSQL db to make a Passphrase.   #
#-------------------------------------------------------------------#
#        This code are released under the GPL 3.0 License.          #
#===================================================================#
use strict;
use utf8;
use DBI;            # Interface to Database

# Postgres SQL connection parms
my $db_name = "dbi:Pg:dbname=DB_NAME;host=127.0.0.1";
my $db_user = "DB_USER";
my $db_pass = "DB_PASS";

# Connect to the Database Server
my $dbh = DBI->connect($db_name, $db_user, $db_pass);
$dbh->{PrintError} = 0; # Disable automatic  Error Handling

init_db();

# Let ready the queries for fast execution
my $SQL_Code = "select word from dice_passphrase where language = ? and page = ? and dice_index = ?;";
my $sth_read = $dbh->prepare($SQL_Code);

$SQL_Code = "insert into dice_passphrase(language, page, dice_index, word) values( ?, ?, ?, ? );";
my $sth_insert = $dbh->prepare($SQL_Code);

#---------------------------------#
# Create the initial Table schema #
#---------------------------------#
sub init_db {
    print "Init DB\n";
    $SQL_Code = "DROP TABLE IF EXISTS dice_passphrase;";
    $dbh->do($SQL_Code);
    # Create lottery products Table
    $SQL_Code = "CREATE TABLE dice_passphrase (
            language   varchar(8)  not null,
            page       integer     not null,
            dice_index varchar(8)  not null,
            word       varchar(20) not null
        );";
    $dbh->do($SQL_Code);
    # Create index on products table
    $SQL_Code = "CREATE UNIQUE INDEX un_dice_passphrase on dice_passphrase(language, page, dice_index);";
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
            utf8::decode($word);
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

# Spanish
load_words('es',1,'es_dic_01.txt');
load_words('es',2,'es_dic_02.txt');
load_words('es',3,'es_dic_03.txt');
load_words('es',4,'es_dic_04.txt');
load_words('es',5,'es_dic_05.txt');
load_words('es',6,'es_dic_06.txt');
load_words('es',7,'es_dic_07.txt');
load_words('es',8,'es_dic_08.txt');
load_words('es',9,'es_dic_09.txt');
load_words('es',10,'es_dic_10.txt');
load_words('es',11,'es_dic_11.txt');
load_words('es',12,'es_dic_12.txt');
load_words('es',13,'es_dic_13.txt');
# English
load_words('en',1,'en_dic_01.txt');
load_words('en',2,'en_dic_02.txt');
load_words('en',3,'en_dic_03.txt');
load_words('en',4,'en_dic_04.txt');
load_words('en',5,'en_dic_05.txt');
load_words('en',6,'en_dic_06.txt');
load_words('en',7,'en_dic_07.txt');
load_words('en',8,'en_dic_08.txt');
load_words('en',9,'en_dic_09.txt');
# French
load_words('fr',1,'fr_dic_01.txt');
load_words('fr',2,'fr_dic_02.txt');
load_words('fr',3,'fr_dic_03.txt');
load_words('fr',4,'fr_dic_04.txt');
load_words('fr',5,'fr_dic_05.txt');
load_words('fr',6,'fr_dic_06.txt');
# Portuguese
load_words('pt',1,'pt_dic_01.txt');
load_words('pt',2,'pt_dic_02.txt');
load_words('pt',3,'pt_dic_03.txt');
load_words('pt',4,'pt_dic_04.txt');
load_words('pt',5,'pt_dic_05.txt');
# Special characters
load_words('special',1,'special_chars.txt');
    
# clean up the DB
$dbh->do('vacuum;');
print "DB ready for use\n";

# Close DB connection
$dbh->disconnect;

