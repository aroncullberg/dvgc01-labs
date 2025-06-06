:- ensure_loaded('parser.pl').
:- ensure_loaded('lexer.pl').

/******************************************************************************/
/* From Programming in Prolog (4th Ed.) Clocksin & Mellish, Springer (1994)   */
/* Chapter 5, pp 101-103 (DFR (140421) modified for input from a file)        */
/******************************************************************************/

read_in(File,[W|Ws]) :- see(File), get0(C), 
                        readword(C, W, C1), restsent(W, C1, Ws), nl, seen.

/******************************************************************************/
/* Given a word and the character after it, read in the rest of the sentence  */
/******************************************************************************/

restsent(W, _, [])         :- W = -1.                /* added EOF handling */
restsent(W, _, [])         :- lastword(W).
restsent(_, C, [W1 | Ws ]) :- readword(C, W1, C1), restsent(W1, C1, Ws).

/******************************************************************************/
/* Read in a single word, given an initial character,                         */
/* and remembering what character came after the word (NB!)                   */
/******************************************************************************/

                  /*  is this C a ascii code?? */
readword(C, W, _)  :- C = -1, W = C.                    /* added EOF handling */

% C = first character in word
% W = rest of word(?)         (probably empty on call i.e needs to be populated)
% C2 = Character AFTER word   (empty on call i.e needs to be populated)
readword(C, ':=', C2) :- 
   C = 58,     % ':'
   get0(C1), 
   C1 = 61,     % '='
   get0(C2).

readword(C, W, C1) :- single_character( C ), name(W, [C]), get0(C1).

readword(C, W, C2) :-
   in_number(C, NewC),
   get0(C1),
   restnumber(C1, Cs, C2),
   name(W, [NewC|Cs]).

readword(C, W, C2) :-
   in_word(C, NewC),
   get0(C1),
   restword(C1, Cs, C2),
   name(W, [NewC|Cs]).

readword(_, W, C2) :- get0(C1), readword(C1, W, C2).

% checks if character is part of word, if yes then check next character
restword(C, [NewC|Cs], C2) :-
   in_word(C, NewC),
   get0(C1),
   restword(C1, Cs, C2).

% terminating rule
restword(C, [ ], C).

restnumber(C, [NewC|Cs], C2) :-
   in_number(C, NewC),
   get0(C1),
   restnumber(C1, Cs, C2).
restnumber(C, [ ], C).
/******************************************************************************/
/* These characters form words on their own                                   */
/******************************************************************************/

single_character(40).                  /* ( */
single_character(41).                  /* ) */
single_character(42).                  /* + */
single_character(43).                  /* * */
single_character(44).                  /* , */
single_character(59).                  /* ; */
single_character(58).                  /* : */
single_character(61).                  /* = */
single_character(46).                  /* . */

/******************************************************************************/
/* These characters can appear within a word.                                 */
/* The second in_word clause converts character to lower case                 */
/******************************************************************************/

in_word(C, C) :- C>96, C<123.             /* a b ... z */
in_word(C, L) :- C>64, C<91, L is C+32.   /* A B ... Z */
in_word(C, C) :- C>47, C<58.              /* 1 2 ... 9 */

in_number(C, C) :- C>47, C<58.              /* 1 2 ... 9 */


/******************************************************************************/
/* These words terminate a sentence                                           */
/******************************************************************************/

lastword('.').

/******************************************************************************/
/* added for demonstration purposes 140421, updated 150301                    */
/* testa  - file input (characters + Pascal program)                          */
/* testb  - file input as testa + output to file                              */
/* ttrace - file input + switch on tracing (check this carefully)             */
/******************************************************************************/

testa   :- testread(['testfiles/fun2.pas']).
testb   :- tell('cmreader.out'), testread(['cmreader.txt', 'testok1.pas']), told.

ttrace  :- trace, testread(['cmreader.txt']), notrace, nodebug.


testread([]).
testread([H|T]) :- nl, write('Testing '), write(H), nl,
                   read_in(H,Tokens),
                   write(Tokens), nl,
                   tokenize(Tokens, Magic),
                   write(Magic), nl,
                   (  phrase(program, Tokens, [])
                    ->  write('Parse OK!'), nl
                     ;   write('Parse Fail!'), nl
                   ),
                   write(H), write(' end of parse'), nl,
                   testread(T).
                   
                   
testall   :- tell('cmreader.out'), pas_files('testfiles'), told.
pas_files(Dir) :- 
   directory_files(Dir, Entires),
   process_group('testok', Dir, Entires),
   process_group('test', Dir, Entires),
   process_group('fun', Dir, Entires),
   process_group('sem', Dir, Entires).

process_group(Base, Dir, Data) :-
   write('Testing '), label(Base, Label), write(Label), writeln(' programs'),
   include(
      [Filename] >> in_group(Base, Filename), 
      Data, 
      FilenameList),

   maplist(
      [Filename, Path] >> concat_dir_fucn(Dir, Filename, Path), 
      FilenameList,  % in, maplist takes 
      Paths),        % out

   testread(Paths), nl.



label('testok', 'OK').
label('test', 'a-z').
label(A, A).

concat_dir_fucn(Dir, Filename, Path) :- atomic_list_concat([Dir, '/', Filename], Path).

% https://imgur.com/a/CI5iVAR
in_group(Base, Filename) :-
   atom_concat(Base, Rest, Filename),
   atom_concat(Magic, '.pas', Rest),
   atom_chars(Magic, [_]).


has_prefix(Prefix, File) :-
    atom_concat(Prefix, _, File).



/******************************************************************************/
/* end of program                                                             */
/******************************************************************************/