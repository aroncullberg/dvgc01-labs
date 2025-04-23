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

#define char👉 char*
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
    if (t == id) {
        printf("\nSYNTAX:\tSymbol expected id found %s", get_lexeme());
    } else {
        printf("\nSYNTAX:\tSymbol expected %s found %s", tok2lex(t), get_lexeme());
        }
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
    if (lookahead == id) {
        addp_name(get_lexeme());
    } else {
        addp_name("???");
        // printf("\nSYNTAX:   ID expected found %s", get_lexeme());
        is_parse_ok = 0;
    }
    match(id);
     match('('); match(input); match(','); match(output); match(')'); match(';');

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
    char👉 lexme = get_lexeme();
    if (lookahead == id) {
        if (find_name(lexme)){
            is_parse_ok = 0; // Are we allowed to touch this?
            printf("\nSEMANTIC: ID already declared: %s", lexme);
        } else {
            addv_name(get_lexeme());
        }
        match(id);

    } else {
        is_parse_ok = 0;
        printf("\nSYNTAX:\tSymbol expected id found %s", lexme);
    }
    
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
        default:
            is_parse_ok = 0;
            printf("\nSYNTAX:\tType name expected found  %s", get_lexeme());
            setv_type(error);
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
    toktyp left_type;
    toktyp right_type;
    
    char👉 lexme = get_lexeme();
    left_type = get_ntype(lexme);
    if (!find_name(lexme) && lookahead == id) {
        printf("\nSEMANTIC: ID NOT declared: %s", lexme);
        is_parse_ok = 0;
    }
    match(id); 
    match(assign);
    if (lookahead == '+' || lookahead == '*') {
        is_parse_ok = 0;
        printf("\nSYNTAX:\tOperand expected");
    }
    right_type = expr(); 

    if (right_type == nfound) {
        is_parse_ok = 0;
        printf("\nSYNTAX:\tOperand expected");
    }
    if (left_type != right_type) {
        // is_parse_ok = 0;

        // NOTE: i want this to throw error here but we get diff to expected output if we do that.
        printf("\nSEMANTIC: Assign types: %s := %s", tok2lex(left_type), tok2lex(right_type));
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
    return left;
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
            return get_otype('*', left, right);
        }
    return left;
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
        char👉 lexme = get_lexeme();
        if (!find_name(lexme)) {
            is_parse_ok = 0;
            printf("\nSEMANTIC: ID NOT declared: %s", lexme);
            type = nfound;
        } else {
            type = get_ntype(lexme);
        }
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

    // while (isspace(lookahead)) get_token();

    if (lookahead == '$') {
        is_parse_ok = 0;
        printf("\nWARNING:  Input file is empty");
    } else {
        program_header();               // call the first grammar rule
        var_part();
        stat_part();
    }

    if (lookahead != '$') {
        printf("\nSYNTAX:\tExtra symbols after end of parse!\n          ");
        is_parse_ok = 0;
        printf("%s ", get_lexeme());
        while (get_token() != '$') printf("%s ", get_lexeme());
    }

    

    out("parser");
    printf("\n________________________________________________________ ");
    p_symtab();
    // if parseok do get_tokena na dpirint it?


    if (!is_parse_ok) printf("\n Parse Failed!");
    else printf("\n Parse Successful!");
    printf("\n________________________________________________________ \n");
    
    return is_parse_ok;             // status indicator
}

/**********************************************************************/
/* End of code                                                        */
/**********************************************************************/
