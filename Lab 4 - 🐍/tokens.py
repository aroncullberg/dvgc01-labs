#*********************************
# Aron Cullberg    -   aroncull100                                    
# Viktor Hajto     -   vikthajt100                                    
#*********************************

from enum import IntEnum


class TokenType(IntEnum):
    nfound = -1
    tstart = 257
    id = 258
    number = 259
    assign = 260
    predef = 261
    tempty = 262
    undef = 263
    error = 264
    typ = 265
    tend = 266
    kstart = 267
    program = 268
    input = 269
    output = 270
    var = 271
    begin = 272
    end = 273
    boolean = 274
    integer = 275
    real = 276
    kend = 277


TOKEN_TABLE = {
    "id": TokenType.id,
    "number": TokenType.number,
    ":=": TokenType.assign,
    "undef": TokenType.undef,
    "predef": TokenType.predef,
    "tempty": TokenType.tempty,
    "error": TokenType.error,
    "type": TokenType.typ,
    "$": '$',
    "(": '(',
    ")": ')',
    "*": '*',
    "+": '+',
    ",": ',',
    "-": '-',
    ".": '.',
    "/": '/',
    ":": ':',
    ";": ';',
    "=": '=',
}

KEYWORD_TABLE = {
    "program": TokenType.program,
    "input": TokenType.input,
    "output": TokenType.output,
    "var": TokenType.var,
    "begin": TokenType.begin,
    "end": TokenType.end,
    "boolean": TokenType.boolean,
    "integer": TokenType.integer,
    "real": TokenType.real,
}


def lex2tok(lexeme: str):
    return TOKEN_TABLE.get(lexeme, TokenType.nfound)


def key2tok(lexeme: str):
    return KEYWORD_TABLE.get(lexeme, TokenType.id)


def tok2lex(tok):
    for text, t in TOKEN_TABLE.items():
        if t == tok:
            return text
    for text, t in KEYWORD_TABLE.items():
        if t == tok:
            return text
    if isinstance(tok, str):
        return tok
    return "error"