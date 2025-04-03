/**********************************************************************/
/* lab 1 DVG C01 - Driver OBJECT                                      */
/**********************************************************************/

/**********************************************************************/
/* Include files                                                      */
/**********************************************************************/
#include <stdio.h>
#include <ctype.h>
#include <string.h>

/**********************************************************************/
/* Other OBJECT's METHODS (IMPORTED)                                  */
/**********************************************************************/
#include "keytoktab.h"

/**********************************************************************/
/* OBJECT ATTRIBUTES FOR THIS OBJECT (C MODULE)                       */
/**********************************************************************/
/**********************************************************************/
/* type definitions                                                   */
/**********************************************************************/
typedef struct tab {
	char 	* text;
	int 	token;
}tab;

#define EQUAL 0

/**********************************************************************/
/* data objects (tables)                                              */
/**********************************************************************/
static tab tokentab[ ] = {
    {"id", 	            id},
    {"number",      number},
    {":=", 	        assign},
    {"undef", 	     undef},
    {"predef",      predef},
    {"tempty",      tempty},
    {"error",        error},
    {"type",           typ},
    {"$",              '$'},
    {"(",              '('},
    {")",              ')'},
    {"*",              '*'},
    {"+",              '+'},
    {",",              ','},
    {"-",              '-'},
    {".",              '.'},
    {"/",              '/'},
    {":",              ':'},
    {";",              ';'},
    {"=",              '='},
    {"TERROR", 	    nfound}
};


static tab keywordtab[ ] = {
	{"program", 	program},
	{"input", 	      input},
	{"output", 	     output},
	{"var", 	        var},
	{"begin", 	      begin},
	{"end", 	        end},
	{"boolean", 	boolean},
	{"integer", 	integer},
	{"real", 	       real},
	{"KERROR", 	     nfound}
};

/**********************************************************************/
/*  PUBLIC METHODS for this OBJECT  (EXPORTED)                        */
/**********************************************************************/
/**********************************************************************/
/* Display the tables                                                 */
/**********************************************************************/
void p_toktab()
{
    int len;
    printf("________________________________________________________\n");
    printf(" THE PROGRAM KEYWORDS\n");
    printf("________________________________________________________\n");
    
    len = sizeof(keywordtab) / sizeof(keywordtab[0]) - 1;
    for (int i = 0; i < len; i++) 
    {
        printf("%11s  %d\n", keywordtab[i], keywordtab[i]);
    }
    printf("________________________________________________________\n");
    printf(" THE PROGRAM TOKENS\n");
    printf("________________________________________________________\n");
    len = sizeof(tokentab) / sizeof(tokentab[0]) - 1;
    for (int i = 0; i < len; i++) 
    {
        printf("%11s  %d\n", tokentab[i], tokentab[i]);
    }
    
    printf("________________________________________________________\n");

}

/**********************************************************************/
/* lex2tok - convert a lexeme to a token                              */
/**********************************************************************/
toktyp lex2tok(char * fplex)
{
    printf("\n *** TO BE DONE");  return 0;
}

/**********************************************************************/
/* key2tok - convert a keyword to a token                             */
/**********************************************************************/
toktyp key2tok(char * fplex)
{
    int len = sizeof(keywordtab) / sizeof(keywordtab[0]) - 1;
    for (int i = 0; i < len; i++) 
    {
        if (strcmp(fplex, keywordtab[i].text)  == EQUAL) {
            return keywordtab[i].token;
        }
        
    }
}

/**********************************************************************/
/* tok2lex - convert a token to a lexeme                              */
/**********************************************************************/
char * tok2lex(toktyp ftok)
{
    int len = sizeof(tokentab) / sizeof(tokentab[0]) - 1;
    for (int i = 0; i < len; i++) 
    {
        if (tokentab[i].token == ftok) {
            return tokentab[i].text;
        }
        
    }
}

/**********************************************************************/
/* End of code                                                        */
/**********************************************************************/
