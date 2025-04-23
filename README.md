# Spanish passphrase generator

## Description

Based on the idea from Arnold G. Reinhold ([https://theworld.com/~reinhold/diceware.html](https://theworld.com/~reinhold/diceware.html)), to choose random words ussing a dice to create a really random passphrase.

I create a list of words (in spanish) with the values of the roll of a six faces dice. The vaules are form 1 to 6 and represent the index of a word in the list. The file contains 46,656 words representing 6 values of six dice rolls.

The spanish languaje has about 107,920 words, but if i put 7 values, we have more posible index than words (279,936 vs 107,920 spanish words). Then i adjust and choose 46,656 to match with the 6 digits index, but use two files to bring 93,312 possible words to the passphrase. odd and even words use the first and second list in alternate order.

The source of the Spanish words come from [https://github.com/JorgeDuenasLerin/diccionario-espanol-txt](https://github.com/JorgeDuenasLerin/diccionario-espanol-txt)

For example:

```
212114 cabalista
624346 sesquióxido
655221 urticación
216425 cañinque
124665 alegadora
426415 inconcluso
```

Each number in the index, is the result of a dice roll, to obtain the index you must roll the dice six times peer word, if you want a four word passphrase, you need to roll the dice 24 times.

But i make a little program (passphrase.pl) to emulate the dice roll and generate the passphrase.

```
$ ./passphrase.pl 
juncino talacho amicísimo compaña
```

If you want a 12 word passphrase you only put the number of words on the program. the default is 4 words.

```
$ ./passphrase.pl 12
presentismo patuleca victorear fenazo mortera transgénica rebrincado aspearse
 hosca chaquetón cerra chascar

```

## Install

1. Download file
  
    ```
    git clone https://github.com/elpop/Dice_Spanish_Passphrase.git
    ```  

2. Install SQLite:

   The programs use SQLite. This is available for Mac OS and the most popular Linux distros.
   
    for Debian/Ubuntu Linux systems:
    
    ```
    sudo apt-get install sqlite3 libsqlite3-dev
    ```
    
    Fedora/Red-Hat Linux systems:
    
    ```
    sudo dnf install sqlite sqlite-devel
    ```
    
    Mac OS
    
    SQLite is available by default. 
    
3. Perl Dependencies
    
    [DBI](https://metacpan.org/pod/DBI)

    [DBD::SQLite](https://metacpan.org/pod/DBD::SQLite)

    [Math::Random::Secure](https://metacpan.org/pod/Math::Random::Secure)

    All the Perl Modules are available via [metacpan](https://metacpan.org) or install them via the "cpan" program in your system. Debian/Ubuntu and Fedora have packages for the required perl modules.
    
    for Fedora/Redhat:
    
    ```
    sudo dnf install perl-DBI perl-DBD-SQLite perl-Math-Random-Secure
    ```
    
    for Debian/Ubuntu:
    
    ```
    sudo apt-get install libdbi-perl libdbd-sqlite3-perl libmath-random-secure-perl
    ```
    
    On Mac OS:

    To compile some Perl modules, you need to install the 
    Xcode Command Line Tools:
 
    ```
    xcode-select --install
    ```

    Install with CPAN:
    
    ```
    sudo cpan -i DBI DBD::SQLite Math::Random::Secure
    ```
    
4. Put it on your search path
    
    Copy the passphrase.pl program somewhere in your search path:
    
    ```
    sudo cp passphrase.pl /usr/local/bin/.
    ```
    
## Initial run

The **db\_load\_words.pl** program create a hidden directory ".passphrase" in your HOME path.

Into the directory create the sqlite DB called "passphrase.db".

when you run it for the first time you see the following:

```
$ ./db_load_words.pl 
Init DB
load dice_words_1.txt...
dice_words_1.txt loaded!
load dice_words_2.txt...
dice_words_2.txt loaded!
load dice_special.txt...
dice_special.txt loaded!
DB ready for use
```
The files **dice\_words\_1.txt**, **dice\_words\_2.txt** and **dice\_special.txt** must be in the same path of the **db\_load\_words.pl** program.

The load of the data can take about 3 minutes or less, depending your computer and disk. 
     
Now, you can use the program :)
    
## Words reference

The file **spanish_words.txt** has the original 107,920 words for your future use o for  create a random subset.
          
## Author

   Fernando Romo (pop@cofradia.org)

## License
     
```
GNU GENERAL PUBLIC LICENSE Version 3
https://www.gnu.org/licenses/gpl-3.0.en.html
See LICENSE.txt
```

## Sponsor the project

Please [sponsor this project](https://github.com/sponsors/elpop) to pay my high debt on credit cards :)
