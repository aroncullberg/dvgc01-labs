/******************************************************************************/
/* Prolog Lab 2 example - Grammar test bed                                    */
/******************************************************************************/

/******************************************************************************/
/* Grammar Rules in Definite Clause Grammar form                              */
/* This the set of productions, P, for this grammar                           */
/* This is a slightly modified from of the Pascal Grammar for Lab 2 Prolog    */
/******************************************************************************/

/* program       --> prog_head, var_part, stat_part. */
program       --> prog_head, var_part, stat_part.

/******************************************************************************/
/* Program Header                                                             */
/******************************************************************************/
prog_head     --> [program], id, ['('], [input], [','], [output], [')'], [';'].
id            --> [a]|[b]|[c].

/******************************************************************************/
/* Var_part                                                                   */
/******************************************************************************/
var_part        --> 
        [var], var_dec_list.

var_dec_list    --> 
        var_dec ; 
        var_dec, var_dec_list.

var_dec         --> 
        id_list, [':'], typ, [';'].

id_list         --> 
        id;
        id, [','], id_list.

typ             -->
        [integer];
        [real];
        [boolean].


/******************************************************************************/
/* Stat part                                                                  */
/******************************************************************************/

stat_part --> [begin], stat_list, [end], ['.'].

stat_list --> 
        stat;
        stat, [';'], stat_list.

stat -->
    assign_stat.

assign_stat -->
    id, [':='], expr.

expr -->
    term;
    expr, op, term.

term -->
    factor;
    term, op, factor.

factor -->
    ['('], expr, [')'];
    operand.

operand -->
    id;
    number.

op --> 
    addop;
    mulop.


addop --> ['+']; ['-'].
mulop --> ['*']; ['/'].


number --> [N], { number(N) }.

compound_stat -->
    [begin], stat_list, [end].


/******************************************************************************/
/* Testing the system: this may be done stepwise in Prolog                    */
/* below are some examples of a "bottom-up" approach - start with simple      */
/* tests and buid up until a whole program can be tested                      */
/******************************************************************************/
/* Stat part                                                                  */
/******************************************************************************/
/*  op(['+'], []).                                                            */
/*  op(['-'], []).                                                            */
/*  op(['*'], []).                                                            */
/*  op(['/'], []).                                                            */
/*  addop(['+'], []).                                                         */
/*  addop(['-'], []).                                                         */
/*  mulop(['*'], []).                                                         */
/*  mulop(['/'], []).                                                         */
/*  factor([a], []).                                                          */
/*  factor(['(', a, ')'], []).                                                */
/*  term([a], []).                                                            */
/*  term([a, '*', a], []).                                                    */
/*  expr([a], []).                                                            */
/*  expr([a, '*', a], []).                                                    */
/*  assign_stat([a, assign, b], []).                                          */
/*  assign_stat([a, assign, b, '*', c], []).                                  */
/*  stat([a, assign, b], []).                                                 */
/*  stat([a, assign, b, '*', c], []).                                         */
/*  stat_list([a, assign, b], []).                                            */
/*  stat_list([a, assign, b, '*', c], []).                                    */
/*  stat_list([a, assign, b, ';', a, assign, c], []).                         */
/*  stat_list([a, assign, b, '*', c, ';', a, assign, b, '*', c], []).         */
/*  stat_part([begin, a, assign, b, '*', c, end, '.'], []).                   */
/******************************************************************************/
/* Var part                                                                   */
/******************************************************************************/
/* typ([integer], []).                                                        */
/* typ([real], []).                                                           */
/* typ([boolean], []).                                                        */
/* id([a], []).                                                               */
/* id([b], []).                                                               */
/* id([c], []).                                                               */
/* id_list([a], []).                                                          */
/* id_list([a, ',', b], []).                                                  */
/* id_list([a, ',', b, ',', c], []).                                          */
/* var_dec([a, ':', integer], []).                                            */
/* var_dec_list([a, ':', integer], []).                                       */
/* var_dec_list([a, ':', integer, b, ':', real], []).                         */
/* var_part([var, a, ':', integer], []).                                      */
/******************************************************************************/
/* Program header                                                             */
/******************************************************************************/
/* prog_head([program, c, '(', input, ',', output, ')', ';'], []).            */
/******************************************************************************/

/******************************************************************************/
/* Whole program                                                              */
/******************************************************************************/
/* program([program, c, '(', input, ',', output, ')', ';',                    */
/*          var, a,    ':', integer, ';',                                     */
/*               b, ',', c, ':', real,    ';',                                */
/*          begin,                                                            */
/*             a, assign, b, '*', c, ';',                                     */  
/*             a, assign, b, '+', c,                                          */
/*          end, '.'], []).                                                   */
/******************************************************************************/

testtyp1 :- typ([integer], []).
testtyp2 :- typ([real], []).
testtyp3 :- typ([boolean], []).
testid1 :- id([a], []).
testid2 :- id([b], []).
testid3 :- id([c], []).
testid_list1 :- id_list([a], []).
testid_list2 :- id_list([a, ',', b], []).
testid_list3 :- id_list([a, ',', b, ',', c], []).
testvar_dec :- var_dec([a, ':', integer, ';'], []).
                                    /* added a ';' to test so it passes and matches above program*/
testvar_dec_list1 :- var_dec_list([a, ':', integer, ';'], []).
                                    /* added a ';' to test so it passes and matches above program*/
testvar_dec_list2 :- var_dec_list([a, ':', integer, ';', b, ':', real, ';'], []).
                                    /* added a ';' to test so it passes and matches above program*/
testvar_part :- var_part([var, a, ':', integer, ';'], []). 
                                    /* added a ';' to test so it passes and matches above program*/
                                    /* This should be false, according to grammar??? */


testop1 :- op(['+'], []).
testop2 :- op(['-'], []).
testop3 :- op(['*'], []).
testop4 :- op(['/'], []).
testaddop1 :- addop(['+'], []).
testaddop2 :- addop(['-'], []).
testmulop1 :- mulop(['*'], []).
testmulop2 :- mulop(['/'], []).
testfactor1 :- factor([a], []).
testfactor2 :- factor(['(', a, ')'], []).
testterm1 :- term([a], []).
testterm2 :- term([a, '*', a], []).
testexpr1 :- expr([a], []).
testexpr2 :- expr([a, '*', a], []).
testassign_stat1 :- assign_stat([a, assign, b], []).
testassign_stat2 :- assign_stat([a, assign, b, '*', c], []).
teststat1 :- stat([a, assign, b], []).
teststat2 :- stat([a, assign, b, '*', c], []).
teststat_list1 :- stat_list([a, assign, b], []).
teststat_list2 :- stat_list([a, assign, b, '*', c], []).
teststat_list3 :- stat_list([a, assign, b, ';', a, assign, c], []).
teststat_list4 :- stat_list([a, assign, b, '*', c, ';', a, assign, b, '*', c], []).
teststat_list5 :- stat_part([begin, a, assign, b, '*', c, end, '.'], []).

/******************************************************************************/
/* Define the above tests                                                     */
/******************************************************************************/

testph :- prog_head([program, c, '(', input, ',', output, ')', ';'], []).
testpr :-   program([program, c, '(', input, ',', output, ')', ';'], []).


/******************************************************************************/
/* End of program                                                             */
/******************************************************************************/
