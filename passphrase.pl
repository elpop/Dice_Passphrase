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
use DBI;                            # Interface to Database
use Math::Random::Secure qw(irand); #Cryptographically-secure replacement for rand()
use Getopt::Long;                   # Handle the arguments passed to the program
use Pod::Usage;     # Perl documentation for help

# Command Line options
my %options = ();
GetOptions(\%options,
           'language=s',
           'words=i',
           'times=i',
           'verbose',
           'help|?',
);

# Language parameters
my %dic = (
    # Spanish
    'es' => {
        'pages'   => 2,
        'rolls'   => 6,
        'max'     => 100,
        'words'   => 4,
    },
    # English
    'en' => {
        'pages'   => 7,
        'rolls'   => 6,
        'max'     => 100,
        'words'   => 4,
    },
    # Special chars
    'special' => {
        'pages'   => 1,
        'rolls'   => 2,
        'max'     => 10,
        'words'   => 1,
    }
);

my $language = 'es';
if ( exists($dic{$options{'language'}}) ) {
    $language = $options{'language'};
}

my $words = 1;
if ( exists($options{'words'}) ) {
    if ( $options{'words'} <= $dic{$language}{max} ) {
        $words = $options{'words'};
    }
    else {
        $words = $dic{$language}{words};
    }
}
else {
    $words = $dic{$language}{words};
}

my $times = 1;
if ( exists($options{'times'}) ) {
    if ( $options{'times'} <= 1000 ) {
        $times = $options{'times'};
    }
}

#-----------#
# Main body #
#-----------#

# Process options
if ($options{'help'}) {
    pod2usage(-exitval => 0, -verbose => 1);
    pod2usage(2);
}
else {
    my $work_dir = $ENV{'HOME'} . '/.passphrase'; # keys directory
    # if not exists the work directory, creates and put the init_flag on
    if (-e "$work_dir/passphrase.db") {

        # Open or create SQLite DB
        my $dbh = DBI->connect("dbi:SQLite:dbname=$work_dir/passphrase.db","","");
        $dbh->{PrintError} = 0; # Disable automatic  Error Handling

        # prepare query on advanced
        my $SQL_Code = "select word from dice_passphrase where language = ? and page = ? and dice_index = ?;";
        my $sth_read = $dbh->prepare($SQL_Code);

        # Search the word on the DB
        sub read_word {
            my ($language, $page, $index) = @_;
            my $word = '';
            my $ret = $sth_read->execute("$language", $page, "$index");
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
            print "Page Index  Word\n" if ($options{'verbose'});
            for ( my $i = 0; $i < $words; $i++ ) {
                my $number = '';

                # Choose the dictionary to use and alternate in each word
                my $page = $dic{$language}{pages};
                if ( $dic{$language}{pages} > 1 ) {
                    $page = irand($dic{$language}{pages}) + 1;
                }

                # Roll the dice to generate the index
                for ( my $x = 0; $x < $dic{$language}{rolls}; $x++ ) {
                    $number .= irand(6) + 1;
                }

                # Check cache to avoid repeat the same word on the passphrase
                if ( !exists($cache{"$language$page$number"}) ) {
                    $cache{"$language$page$number"} = 1;

                    # search the word
                    my $word = read_word("$language", $page, "$number");
                    print sprintf(" %2s  %6s %-20s\n",$page, $number, $word) if ($options{'verbose'});
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
}

# End Main Body #

#-----------------------------------#
# Help info for use with Pod::Usage #
#-----------------------------------#
__END__

=head1 NAME

melate.pl

=head1 DESCRIPTION

This program generate a passphrase based on language word list

=head1 SYNOPSIS

passphrase.pl [options]

=head1 OPTIONS

=over 8

=item B<-language or -l>

The -language or -l option show the passphrase on the given language:

    passphrase.pl -language es

    or

    passphrase.pl -l es

Example:

    $ passphrase.pl -l es
    allanabarrancos sochantre melgar prensero

The values can be "es" for espanish, "en" for english or "special" to generate special random char.

The default value is "es".

=item B<-words or -w>

generate the passphrase with number of words:

    passphrase.pl -language en -words 5

    or

    passphrase.pl -l en -w 5

Example:

    $ passphrase.pl -l en -w 5
    interpolation stylelessness pussycats tythed typhlocele

The default value on spanish and english languages is 4.

=item B<-times or -t>

Generate multiple passphrase

    passphrase.pl -language en -words 5 -times 3

    or

    passphrase.pl -l en -w 5 -t 3

Example:

    $ passphrase.pl -l en -w 5 -t 3
    stinkstone doeskins colorcaster stir chiricahua
    overbulk doughtiness myoedema dallyingly inequidistant
    lollops defrayers carcinomas experimentor fligger

The Default is 1 and the max value is 1,000.

=item B<-verbose or -v>

show the generation and word selection process:

    passphrase.pl -language en -words 3 -times 2 -verbose

    or

    passphrase.pl -l en -w 3 -t 2 -v

Example:

    $ passphrase.pl -l en -w 3 -t 2 -v
    Page Index  Word
      5  656323 verricule           
      2  534155 rightish            
      7  431225 nonpoet             
    verricule rightish nonpoet 
    Page Index  Word
      7  122164 ancylopod           
      5  442464 overdeal            
      4  353135 landlordly          
    ancylopod overdeal landlordly 

=item B<-help or -h or -?>

Show this help

=back

=cut
