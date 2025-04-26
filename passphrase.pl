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
           'languaje=s',
           'words=i',
           'times=i',
           'verbose',
           'help|?',
);

# Languaje paramters
my %dic = (
    # Spanish
    'es' => {
        'initial' => 1,
        'pages'   => 2,
        'rolls'   => 6,
        'max'     => 100,
        'words'   => 4,
    },
    # English
    'en' => { 
        'initial' => 4,
        'pages'   => 7,
        'rolls'   => 6,
        'max'     => 100,
        'words'   => 4,
    },
    # Special chars
    'special' => {
        'initial' => 3,
        'pages'   => 1,
        'rolls'   => 2,
        'max'     => 10,
        'words'   => 1,
    }
);

my $languaje = 'es';
if ( exists($dic{$options{'languaje'}}) ) {
    $languaje = $options{'languaje'};
}

my $words = 1;
if ( exists($options{'words'}) ) {
    if ( $options{'words'} <= $dic{$languaje}{max} ) {
        $words = $options{'words'};
    }
    else {
        $words = $dic{$languaje}{words};
    }
}
else {
    $words = $dic{$languaje}{words};
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
                my $dic = $dic{$languaje}{initial};
                if ( $dic{$languaje}{pages} > 1 ) {
                    $dic = irand($dic{$languaje}{pages}) + $dic{$languaje}{initial};
                }

                # Roll the dice to generate the index
                for ( my $x = 0; $x < $dic{$languaje}{rolls}; $x++ ) {
                    $number .= irand(6) + 1;
                }

                # Check cache to avoid repeat the same word on the passphrase
                if ( !exists($cache{"$dic$number"}) ) {
                    $cache{"$dic$number"} = 1;

                    # search the word
                    my $word = read_word($dic, "$number");
                    print sprintf("%2s %6s %-20s\n",$dic, $number, $word) if ($options{'verbose'});
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

This program generate a passphrase based on languaje word list

=head1 SYNOPSIS

passphrase.pl [options]

=head1 OPTIONS

=over 8

=item B<-languaje or -l>

The -languaje or -l option show the passphrase on the given languaje:

    passphrase.pl -languaje es

    or

    passphrase.pl -l es

    Example:

        $ passphrase.pl -l es
        allanabarrancos sochantre melgar prensero

    The values can be "es" for espanish, "en" for english or "special" to generate special random char.

    The default value is "es".

=item B<-words or -w>

generate the passphrase with number of words:

    passphrase.pl -languaje en -words 5

    or

    passphrase.pl -l en -w 5

    Example:

        $ passphrase.pl -l en -w 5
        interpolation stylelessness pussycats tythed typhlocele

    The default value on spanish and english languajes is 4.

=item B<-times or -t>

Generate multiple passphrase

    passphrase.pl -languaje en -words 5 -times 3

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

    passphrase.pl -languaje en -words 3 -times 2 -verbose

    or

    passphrase.pl -l en -w 3 -t 2 -v

    Example:

        $ passphrase.pl -l en -w 3 -t 2 -v
         9 626655 trephines
         9 255425 faultier
         4 253613 exostoses
        trephines faultier exostoses
         6 543425 scrupulous
        10 423641 niobiums
         8 353266 laptop
        scrupulous niobiums laptop

=item B<-help or -h or -?>

Show this help

=back

=cut
