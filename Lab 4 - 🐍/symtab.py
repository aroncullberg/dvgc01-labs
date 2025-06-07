from tokens import TokenType, tok2lex


class SymEntry:
    def __init__(self, name, role, typ, size, addr):
        self.name = name
        self.role = role
        self.type = typ
        self.size = size
        self.addr = addr


class SymTab:
    def __init__(self):
        self.entries = []
        self.program_size = 0

    def addp_name(self, name):
        self.entries.append(SymEntry(
            name,
            TokenType.program,
            TokenType.program,
            0,
            0))

    def addv_name(self, name):
        self.entries.append(SymEntry(name, TokenType.var, None, 0, 0))

    def find_name(self, name):
        return any(e.name == name for e in self.entries)

    def setv_type(self, typ):
        for e in reversed(self.entries):
            if e.type is not None:
                break
            e.type = typ
            if typ in (TokenType.integer, TokenType.boolean):
                e.size = 4
            elif typ == TokenType.real:
                e.size = 8
            else:
                e.size = 0
            self.program_size += e.size
        addr = 0
        for e in self.entries[1:]:
            e.addr = addr
            addr += e.size
        self.program_size = addr
        if self.entries:
            self.entries[0].size = self.program_size

    def get_ntype(self, name):
        for e in self.entries:
            if e.name == name:
                return e.type if e.type is not None else TokenType.nfound
        return TokenType.nfound

    def p_symtab(self):
        print("________________________________________________________")
        print(" THE SYMBOL TABLE")
        print("________________________________________________________")
        print(f"{'NAME':>11}{'ROLE':>11}{'TYPE':>11}{'SIZE':>10}{'ADDR':>10}")
        print("________________________________________________________")
        for e in self.entries:
            tlex = tok2lex(e.type) if e.type is not None else 'undef'
            print(f"{e.name:>11}{tok2lex(e.role):>11}{tlex:>11}{e.size:10d}{e.addr:10d}")
        print("________________________________________________________")
        print(f" STATIC STORAGE REQUIRED is {self.program_size} BYTES")
        print("________________________________________________________")