from tokens import TokenType


class OpTab:
    def __init__(self):
        self.table = {
            ('+', TokenType.integer, TokenType.integer): TokenType.integer,
            ('+', TokenType.real, TokenType.real): TokenType.real,
            ('+', TokenType.integer, TokenType.real): TokenType.real,
            ('+', TokenType.real, TokenType.integer): TokenType.real,
            ('*', TokenType.integer, TokenType.integer): TokenType.integer,
            ('*', TokenType.real, TokenType.real): TokenType.real,
            ('*', TokenType.integer, TokenType.real): TokenType.real,
            ('*', TokenType.real, TokenType.integer): TokenType.real,
        }

    def get_otype(self, op, arg1, arg2):
        return self.table.get((op, arg1, arg2), TokenType.undef)
