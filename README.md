# Spanish passphrase generator

## Description

Based on the idea from Arnold G. Reinhold ([https://theworld.com/~reinhold/diceware.html](https://theworld.com/~reinhold/diceware.html)), to choose random words ussing a dice to create a really random passphrase.

I create a list of words (in spanish) with the values of the roll of a six faces dice. The vaules are form 1 to 6 and represent the index of a word in the list. The file contains 46,656 words representing 6 values of six dice rolls.

The spanish languaje has about 107,920 words, but if i put 7 values, we have more posible index than words (279,936 vs 107,920 spanish words). Then i adjust and choose 46,656 to match with the 6 digits index, but use two files to bring 93,312 possible words to the passphrase.

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

But i make a little program (dice.pl) to emulate the dice roll and generate the passphrase.

```
$ ./dice.pl 
441264 juncino
635161 talacho
132633 amicísimo
244446 compaña

Passphrase: juncino talacho amicísimo compaña
```

If you want a 12 word passphrase you only put the number of words on the program. the default is 4 words.

```
$ ./dice.pl 12
551662 presentismo
533244 patuleca
662354 victorear
354314 fenazo
511651 mortera
646552 transgénica
562533 rebrincado
146463 aspearse
423316 hosca
232564 chaquetón
231241 cerra
233132 chascar

Passphrase: presentismo patuleca victorear fenazo mortera transgénica rebrincado aspearse
 hosca chaquetón cerra chascar

```

## Install
   
1. Download file
  
    ```
    git clone https://github.com/elpop/Dice_Spanish_Passphrase.git
    ```  

2. Install dependecies:
              
    On Ubuntu/Debian, Redhat/CentOS/Fedora or Mac OS use cpan:
         
    ```
    sudo cpan -i RPG::Dice
    ```

    Put the file **dice_words.txt** in the same path of the program.
    
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
