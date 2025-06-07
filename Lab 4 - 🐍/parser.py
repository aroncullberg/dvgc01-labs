#!/usr/bin/env python3
from lexer import Lexer
from symtab import SymTab
from opttab import OpTab
from tokens import TokenType, tok2lex


class Parser:
    def __init__(self):
        self.lexer = Lexer()
        self.symtab = SymTab()
        self.optab = OpTab()
        self.lookahead = None
        self.is_parse_ok = True

    def match(self, t):
        if self.lookahead == t:
            self.lookahead = self.lexer.get_token()
        else:
            self.is_parse_ok = False
            if t == TokenType.id:
                print(f"SYNTAX:\tSymbol expected id found {self.lexer.get_lexeme()}")
            else:
                print(f"SYNTAX:\tSymbol expected {tok2lex(t)} found {self.lexer.get_lexeme()}")

    def program_header(self):
        self.match(TokenType.program)
        if self.lookahead == TokenType.id:
            self.symtab.addp_name(self.lexer.get_lexeme())
        else:
            self.symtab.addp_name("???")
            self.is_parse_ok = False
        self.match(TokenType.id)
        self.match('(')
        self.match(TokenType.input)
        self.match(',')
        self.match(TokenType.output)
        self.match(')')
        self.match(';')

    def var_part(self):
        self.match(TokenType.var)
        self.var_dec_list()

    def var_dec_list(self):
        self.var_dec()
        if self.lookahead == TokenType.id:
            self.var_dec_list()

    def var_dec(self):
        self.id_list()
        self.match(':')
        self.type_rule()
        self.match(';')

    def id_list(self):
        lexme = self.lexer.get_lexeme()
        if self.lookahead == TokenType.id:
            if self.symtab.find_name(lexme):
                self.is_parse_ok = False
                print(f"SEMANTIC: ID already declared: {lexme}")
            else:
                self.symtab.addv_name(lexme)
            self.match(TokenType.id)
        else:
            self.is_parse_ok = False
            print(f"SYNTAX:\tSymbol expected id found {lexme}")
        if self.lookahead == ',':
            self.match(',')
            self.id_list()

    def type_rule(self):
        if self.lookahead == TokenType.integer:
            self.match(TokenType.integer)
            self.symtab.setv_type(TokenType.integer)
        elif self.lookahead == TokenType.real:
            self.match(TokenType.real)
            self.symtab.setv_type(TokenType.real)
        elif self.lookahead == TokenType.boolean:
            self.match(TokenType.boolean)
            self.symtab.setv_type(TokenType.boolean)
        else:
            self.is_parse_ok = False
            print(f"SYNTAX:\tType name expected found  {self.lexer.get_lexeme()}")
            self.symtab.setv_type(TokenType.error)

    def stat_part(self):
        self.match(TokenType.begin)
        self.stat_list()
        self.match(TokenType.end)
        self.match('.')

    def stat_list(self):
        self.stat()
        if self.lookahead == ';':
            self.match(';')
            self.stat_list()

    def stat(self):
        self.assign_stat()

    def assign_stat(self):
        lexme = self.lexer.get_lexeme()
        left_type = self.symtab.get_ntype(lexme)
        if not self.symtab.find_name(lexme) and self.lookahead == TokenType.id:
            print(f"SEMANTIC: ID NOT declared: {lexme}")
            self.is_parse_ok = False
        self.match(TokenType.id)
        self.match(TokenType.assign)
        if self.lookahead in ('+', '*'):
            self.is_parse_ok = False
            print("SYNTAX:\tOperand expected")
        right_type = self.expr()
        if right_type == TokenType.nfound:
            self.is_parse_ok = False
            print("SYNTAX:\tOperand expected")
        if left_type != right_type:
            print(f"SEMANTIC: Assign types: {tok2lex(left_type)} := {tok2lex(right_type)}")

    def expr(self):
        left = self.term()
        if self.lookahead == '+':
            self.match('+')
            right = self.expr()
            return self.optab.get_otype('+', left, right)
        return left

    def term(self):
        left = self.factor()
        if self.lookahead == '*':
            self.match('*')
            right = self.term()
            return self.optab.get_otype('*', left, right)
        return left

    def factor(self):
        if self.lookahead == '(':
            self.match('(')
            t = self.expr()
            self.match(')')
            return t
        else:
            return self.operand()

    def operand(self):
        if self.lookahead == TokenType.id:
            lexme = self.lexer.get_lexeme()
            if not self.symtab.find_name(lexme):
                print(f"SEMANTIC: ID NOT declared: {lexme}")
                self.is_parse_ok = False
                t = TokenType.nfound
            else:
                t = self.symtab.get_ntype(lexme)
            self.match(TokenType.id)
            return t
        elif self.lookahead == TokenType.number:
            self.match(TokenType.number)
            return TokenType.integer
        else:
            return TokenType.nfound

    def parse(self):
        self.lookahead = self.lexer.get_token()
        if self.lookahead == '$':
            self.is_parse_ok = False
            print("WARNING:  Input file is empty")
        else:
            self.program_header()
            self.var_part()
            self.stat_part()
        if self.lookahead != '$':
            print("SYNTAX:\tExtra symbols after end of parse!")
            self.is_parse_ok = False
            print(self.lexer.get_lexeme(), end=' ')
            while self.lexer.get_token() != '$':
                print(self.lexer.get_lexeme(), end=' ')
            print()
        print("________________________________________________________ ")
        self.symtab.p_symtab()
        if not self.is_parse_ok:
            print("\n Parse Failed!")
        else:
            print("\n Parse Successful!")
        print("________________________________________________________ ")
        return self.is_parse_ok


if __name__ == "__main__":
    Parser().parse()