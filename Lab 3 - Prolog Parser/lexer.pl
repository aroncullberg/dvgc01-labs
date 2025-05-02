token_value('(',          40).
token_value(')',          41).
token_value(',',          44).
token_value(';',          59).
token_value(':',          58).
token_value('.',          46).
token_value('+',          43).
token_value('*',          42).
token_value('=',          61).
token_value(id,           270).
token_value(':=',         271).
token_value(number,       272).
token_value(program,      256).
token_value(input,        257).
token_value(output,       258).
token_value(var,          259).
token_value(integer,      260).
token_value(begin,        261).
token_value(end,          262).
token_value(undef,        273).
token_value(eof,          275).
token_value(nfound,       -1).

convert_token(Token, Code) :- token_value(Token, Code), !.
convert_token(Token, Code) :- number(Token), token_value(number, Code). 
convert_token(Token, Code) :- atom(Token), token_value(id, Code).
convert_token(_, Code) :- token_value(nfound, Code).


tokenize([], []). 
tokenize([Token|Tokens], [Code|Codes]) :- convert_token(Token, Code), tokenize(Tokens, Codes). 