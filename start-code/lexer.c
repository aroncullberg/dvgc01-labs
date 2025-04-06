/**********************************************************************/
/* lab 1 DVG C01 - Lexer OBJECT                                       */
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
#define BUFSIZE 1024
#define LEXSIZE   30
static char buffer[BUFSIZE];
static char lexbuf[LEXSIZE];
static int  pbuf  = 0;               /* current index program buffer  */
static int  plex  = 0;               /* current index lexeme  buffer  */

/**********************************************************************/
/*  PRIVATE METHODS for this OBJECT  (using "static" in C)            */
/**********************************************************************/
/**********************************************************************/
/* buffer functions                                                   */
/**********************************************************************/
/**********************************************************************/
/* Read the input file into the buffer                                */
/**********************************************************************/

static void get_prog()
{
    // while (fgets(buffer, BUFSIZ, stdin) != NULL) {
    //     printf("Läst in: %s", buffer);
    // }
    int i = 0;
    while ((buffer[i] = fgetc(stdin)) != EOF) {
        i++;
    }
    buffer[i] = '$';
    buffer[++i] = '\0';
}

/**********************************************************************/
/* Display the buffer                                                 */
/**********************************************************************/

static void pbuffer()
{
    // for (int i = 0; i < 100; i++) {
    //     printf("\'%c\' - %d\n", buffer[i], buffer[i]);
    // }
    printf("\n________________________________________________________");
    printf("\n THE PROGRAM TEXT");
    printf("\n________________________________________________________");
    printf("\n%s", buffer);
    printf("\n________________________________________________________");
}

/**********************************************************************/
/* Copy a character from the program buffer to the lexeme buffer      */
/**********************************************************************/

static void get_char()
{
    lexbuf[plex] = buffer[pbuf];
    pbuf++;
    plex++;
}

/**********************************************************************/
/* End of buffer handling functions                                   */
/**********************************************************************/

/**********************************************************************/
/*  PUBLIC METHODS for this OBJECT  (EXPORTED)                        */
/**********************************************************************/
/**********************************************************************/
/* Return a token                                                     */
/**********************************************************************/
int get_token()
{
    if (pbuf == 0) {
        get_prog();
        pbuffer();
    }

    memset(lexbuf, '\0', LEXSIZE);
    plex=0;

    while(isspace(buffer[pbuf])) pbuf++;

    if (buffer[pbuf] == ':') {
        get_char();

        if (buffer[pbuf] == '=') {
            get_char();
            lexbuf[plex++] = '\0';

            return lex2tok(lexbuf);
        }

        lexbuf[plex++] = '\0';

        return lex2tok(lexbuf);
    }

    if (isdigit(buffer[pbuf])) {
        get_char();

        while (isdigit(buffer[pbuf])) {
            get_char();
        }

        lexbuf[plex++] = '\0';

        return number;
    }

    if (buffer[pbuf] >= 33 && buffer[pbuf] <= 64) {
        get_char();
        lexbuf[plex++] = '\0';

        return lex2tok(lexbuf);
    }

    while (isalnum(buffer[pbuf])) {
        get_char();
    }
    lexbuf[plex++] = '\0';
    return key2tok(lexbuf); // Changed this to be key2tok had an issue where it would trigger failt to identify number as a id instead of numerical
}

/**********************************************************************/
/* Return a lexeme                                                    */
/**********************************************************************/
char * get_lexeme()
{
    return lexbuf;
}

/**********************************************************************/
/* End of code                                                        */
/**********************************************************************/
