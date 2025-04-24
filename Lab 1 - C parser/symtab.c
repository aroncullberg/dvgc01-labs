/**********************************************************************/
/* Aron Cullberg    -   aroncull100                                   */
/* Viktor Hajto     -   vikthajt100                                   */
/**********************************************************************/

/**********************************************************************/
/* lab 1 DVG C01 - Symbol Table OBJECT                                */
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
#define TABSIZE 1024                   /* symbol table size           */
#define NAMELEN   20                   /* name length                 */

typedef char tname[NAMELEN];

static tname  name[TABSIZE];
static toktyp role[TABSIZE];
static toktyp type[TABSIZE];
static int    size[TABSIZE];
static int    addr[TABSIZE];

static int numrows=0;                  /* number of rows in the ST    */
static int startp =0;                  /* start position program in ST*/

/**********************************************************************/
/*  PRIVATE METHODS for this OBJECT  (using "static" in C)            */
/**********************************************************************/
/**********************************************************************/
/*  GET methods (one for each attribute)                              */
/**********************************************************************/
static char * get_name(int ftref)   { return name[ftref]; }
static toktyp get_role(int ftref)   { return role[ftref]; }
static toktyp get_type(int ftref)   { return type[ftref]; }
static int    get_size(int ftref)   { return size[ftref]; }
static int    get_addr(int ftref)   { return addr[ftref]; }

/**********************************************************************/
/*  SET methods (one for each attribute)                              */
/**********************************************************************/
static void set_name(int ftref, char * fpname) { strcpy(name[ftref],
                                                        fpname);}
static void set_role(int ftref, toktyp frole)  { role[ftref] = frole; }
static void set_type(int ftref, toktyp ftype)  { type[ftref] = ftype; }
static void set_size(int ftref, int    fsize)  { size[ftref] = fsize; }
static void set_addr(int ftref, int    faddr)  { addr[ftref] = faddr; }

/**********************************************************************/
/*  Add a row to the symbol table                                     */
/**********************************************************************/
static void addrow(char *fname, toktyp frole, toktyp ftype,
                   int fsize, int faddr)
{
    set_name(numrows, fname);
    set_role(numrows, frole);
    set_type(numrows, ftype);
    set_size(numrows, fsize);
    set_addr(numrows++, faddr);
}
/**********************************************************************/
/*  Initialise the symbol table                                       */
/**********************************************************************/
// static void initst()
// {
//     addrow(tok2lex(predef),  typ, predef, 0, 0);
//     addrow(tok2lex(undef),   typ, predef, 0, 0);
//     addrow(tok2lex(error),   typ, predef, 0, 0);
//     addrow(tok2lex(integer), typ, predef, 4, 0);
//     addrow(tok2lex(boolean), typ, predef, 4, 0);
//     addrow(tok2lex(real),    typ, predef, 8, 0);
// }
/**********************************************************************/
/*  return a reference to the ST (index) if name found else nfound    */
/**********************************************************************/
static int get_ref(char * fpname)
{
    for (int row = 0; row <= numrows; row++) {
        if (strcmp(get_name(row), fpname) == 0){
            return row;
        }
    }
    return nfound;
}

/**********************************************************************/
/*  PUBLIC METHODS for this OBJECT  (EXPORTED)                        */
/**********************************************************************/
/**********************************************************************/
/*  Display the symbol table                                          */
/**********************************************************************/
static void p_symrow(int ftref)
{
    printf("%11s%11s%11s%10d%10d\n", name[ftref], tok2lex(role[ftref]), tok2lex(type[ftref]), size[ftref], addr[ftref]);
}

void p_symtab()
{
    
    printf("\n________________________________________________________\n");
    printf(" THE SYMBOL TABLE\n");
    printf("________________________________________________________\n");
    printf("%11s%11s%11s%10s%10s\n", "NAME", "ROLE", "TYPE", "SIZE", "ADDR");
    printf("________________________________________________________\n");
    for (int i = 0; i <= numrows && numrows != 0; i++) {
        p_symrow(i);
    }
    printf("________________________________________________________\n");
    printf(" STATIC STORAGE REQUIRED is %d BYTES\n", get_size(0));
    printf("________________________________________________________\n");
}

/**********************************************************************/
/*  Add a program name to the symbol table                            */
/**********************************************************************/
void addp_name(char * fpname)
{

    strcpy(name[0],fpname);
    set_role(numrows, program);
    set_type(numrows, program);
    set_size(numrows, startp); // TODO: Is this what 'startp' is? is it always 0?
}

/**********************************************************************/
/*  Add a variable name to the symbol table                           */
/**********************************************************************/
void addv_name(char * fpname)
{
    numrows++;
    strcpy(name[numrows],fpname);
    set_role(numrows, var);
}

/**********************************************************************/
/*  Find a name in the the symbol table                               */
/*  return a Boolean (true, false) if the name is in the ST           */
/**********************************************************************/
int find_name(char * fpname)
{
    for (int row = 0; row <= numrows; row++) {
        if (strcmp(get_name(row), fpname) == 0){
            return 1;
        }
    }
    return 0;
}

/**********************************************************************/
/*  Set the type of an id list in the symbol table                    */
/**********************************************************************/
void setv_type(toktyp ftype)
{
    for (int row = numrows; row >= 0 ; row--) {
        if (get_type(row) >= 258 && get_type(row) <= 276) break; // TODO: FIND BETTER SOLUTION
        set_type(row, ftype);
        switch (ftype)
        {
        case integer:
            set_size(row, 4); // How to know size? (pls no your mom joke)
            set_size(0, get_size(0) + get_size(row));
            // set_addr(row+1, get_addr(row) + get_size(row));
            break;
        case real:
            set_size(row, 8);                                // Set our own size
            set_size(0, get_size(0) + get_size(row));       // incremenet program szie
            // set_addr(row+1, get_addr(row) + get_size(row)); // set next start adres
            break;
        case boolean:
            set_size(row, 4);
            set_size(0, get_size(0) + get_size(row));
            // set_addr(row+1, get_addr(row) + get_size(row));
            break;
        
        default:
            break;
        }
    }
    
    for (int row = 1; row <= numrows; row++) {
        set_addr(row+1, get_addr(row) + get_size(row));
    }
}

/**********************************************************************/
/*  Get the type of a variable from the symbol table                  */
/**********************************************************************/
toktyp get_ntype(char * fpname)
{
    for (int row = 0; row <= numrows; row++) {
        if (strcmp(get_name(row), fpname) == 0){
            return get_type(row);
        }
    }
    return nfound;
}

/**********************************************************************/
/* End of code                                                        */
/**********************************************************************/
