#*********************************
# Aron Cullberg    -   aroncull100                                    
# Viktor Hajto     -   vikthajt100                                    
#*********************************
import sys
from tokens import TokenType, lex2tok, key2tok


class Lexer:
    def __init__(self):
        self.buffer = ""
        self.pbuf = 0
        self.lexeme = ""
        self.initialized = False

    def get_prog(self):
        self.buffer = sys.stdin.read()
        self.buffer += '$'
        self.initialized = True

    def pbuffer(self):
        print("\n________________________________________________________")
        print(" THE PROGRAM TEXT")
        print("________________________________________________________")
        print(self.buffer)
        print("________________________________________________________")

    def get_char(self):
        self.lexeme += self.buffer[self.pbuf]
        self.pbuf += 1

    def get_token(self):
        if not self.initialized:
            self.get_prog()
            self.pbuffer()

        self.lexeme = ""
        while self.buffer[self.pbuf].isspace():
            self.pbuf += 1

        ch = self.buffer[self.pbuf]

        if ch == ':':
            self.get_char()
            if self.buffer[self.pbuf] == '=':
                self.get_char()
                return lex2tok(self.lexeme)
            return lex2tok(self.lexeme)

        if ch.isdigit():
            self.get_char()
            while self.buffer[self.pbuf].isdigit():
                self.get_char()
            return TokenType.number

        if 33 <= ord(ch) <= 64:
            self.get_char()
            return lex2tok(self.lexeme)

        while ch.isalnum():
            self.get_char()
            ch = self.buffer[self.pbuf]
        return key2tok(self.lexeme)

    def get_lexeme(self):
        return self.lexeme
    