/**********************************************************************/
/* lab 1 DVG C01 - Parser OBJECT                                      */
/**********************************************************************/

/**********************************************************************/
/* Include files                                                      */
/**********************************************************************/
#include <stdio.h>
#include <ctype.h>
#include <string.h>
// #include "parser.h"



/**********************************************************************/
/* Other OBJECT's METHODS (IMPORTED)                                  */
/**********************************************************************/
#include "keytoktab.h"          /* when the keytoktab is added   */
#include "lexer.h"              /* when the lexer     is added   */
#include "symtab.h"             /* when the symtab    is added   */
#include "optab.h"             /* when the optab     is added   */

/**********************************************************************/
/* OBJECT ATTRIBUTES FOR THIS OBJECT (C MODULE)                       */
/**********************************************************************/
#define DEBUG 0
static int  lookahead=0;
static int  is_parse_ok=1;

/**********************************************************************/
/* RAPID PROTOTYPING - simulate the token stream & lexer (get_token)  */
/**********************************************************************/
/* define tokens + keywords NB: remove this when keytoktab.h is added */
/**********************************************************************/
//enum tvalues { program = 257, id, input, output, var, begin, end, number, integer, boolean, real, coleq};
/**********************************************************************/
/* Simulate the token stream for a given program                      */
/**********************************************************************/
// static int tokens[] = { program, id, '(', input, ',', output, ')', ';', 
//     var, id, ',', id, ',', id, ':', integer, ';', begin, 
//     id, assign, id, '+', id, '*', number, end, '.', 
//     '$'};

/**********************************************************************/
/*  Simulate the lexer -- get the next token from the buffer          */
/**********************************************************************/
// static int pget_token()
// {
//     static int i=0;
//     if (tokens[i] != '$') return tokens[i++]; else return '$';
// }

/**********************************************************************/
/*  PRIVATE METHODS for this OBJECT  (using "static" in C)            */
/**********************************************************************/
static void in(char* s)
{
    if(DEBUG) printf("\n *** In  %s", s);
}
static void out(char* s)
{
    if(DEBUG) printf("\n *** Out %s", s);
}
/**********************************************************************/
/* The Parser functions                                               */
/**********************************************************************/
static void match(int t)
{
    if(DEBUG) printf("\n ------ In  match		expected %s found %s",
                    tok2lex(t), tok2lex(lookahead));
    if (lookahead == t) lookahead = get_token();
    else {
    is_parse_ok=0;
    // printf("\n *** Unexpected Token: expected: %s found: %s (in match)",
    //           tok2lex(t), tok2lex(lookahead));
    printf("\n SYNTAX: %s found: %s",
        tok2lex(t), tok2lex(lookahead));
    }
}

/**********************************************************************/
/* The grammar functions                                              */
/**********************************************************************/

static void var_part();
static void var_dec_list();
static void var_dec();
static void id_list();
static void type();
static void stat_part();
static void stat_list();
static void stat();
static void assign_stat();
static toktyp expr();
static toktyp term();
static toktyp factor();
static toktyp operand();

static void program_header()
{
    in("program_header");
    match(program);
    addp_name(get_lexeme());
    match(id); match('('); match(input); match(','); match(output); match(')'); match(';');

    out("program_header");
}

static void var_part()
{
    in("var_part");
    match(var); var_dec_list();
    out("var_part");
}

static void var_dec_list()
{
    in("var_dec_list");
    var_dec();
    if (lookahead == id)
        {
            var_dec_list();
        }
    out("var_dec_list");
}

static void var_dec()
{
    in("var_dec");
    id_list(); match(':'); type(); match(';');
    out("var_dec");
}

static void id_list()
{
    in("id_list");
    addv_name(get_lexeme());
    match(id);
    if (lookahead == ',')
        {
            match(','); id_list();
        }
    out("id_list");
}

static void type()
{
    in("type");
    switch(lookahead)
    {
        case integer:
            match(integer);
            setv_type(integer);
            break;
        case real:
            match(real);
            setv_type(real);
            break;
        case boolean:
            match(boolean);
            setv_type(boolean);
            break;
    }
    out("type");
}

static void stat_part()
{
    in("static_part");
    match(begin); stat_list(); match(end); match('.');
    out("static_part");
}

static void stat_list()
{
    in("stat_list");
    stat();
    if (lookahead == ';')
    {
        match(';'); stat_list();
    }
    out("stat_list");
}

static void stat()
{
    in("stat");
    assign_stat();
    out("stat");
}

static void assign_stat()
{
    in("assign_stat");
    printf("\n<<<<<<<<<<<%s>>>>>>>>>>>\n\n", get_lexeme());
    toktyp idtype = get_ntype(get_lexeme());
    printf("\nid Type: %s - %d\n", tok2lex(idtype), idtype);
    match(id); match(assign); 
    toktyp exprtype = expr();
    printf("\nexpr Type: %s - %d\n", tok2lex(exprtype), exprtype);

    if (idtype != exprtype) {
        printf("SEMANTIC: Assign types: %s := %s", tok2lex(idtype), tok2lex(exprtype));
    }
    out("assign_stat");
}

static toktyp expr()
{
    in("expr");
    toktyp left = term();
    if (lookahead == '+')
        {
            match('+');
            toktyp right = expr();
            return get_otype('+', left, right);
        }
    return nfound;
    out("expr");
}

static toktyp term()
{
    in("term");
    // factor();
    toktyp left = factor();
    if (lookahead == '*')
        {
            match('*'); 
            toktyp right = term();
            return get_otype('*', left, term());
        }
    return nfound;
    out("term");
}

static toktyp factor()
{
    in("factor");
    toktyp type;
    if (lookahead == '(')
        {
            match('('); type = expr(); match(')');
        }
    else
        type = operand();
    return type;
    out("factor");
}

static toktyp operand()
{
    in("operand");
    toktyp type = nfound;
    if (lookahead == id)
    {
        type = get_ntype(get_lexeme());
        match(id);
    }
    else if(lookahead == number)
    {
        type = integer;
        match(number);
    }
    return type;
    out("operand");
}



/**********************************************************************/
/*  PUBLIC METHODS for this OBJECT  (EXPORTED)                        */
/**********************************************************************/

int parser()
{
    in("parser");
    lookahead = get_token();       // get the first token
    program_header();               // call the first grammar rule
    var_part();
    stat_part();
    out("parser");
    p_symtab();
    return is_parse_ok;             // status indicator
}

/**********************************************************************/
/* End of code                                                        */
/**********************************************************************/
