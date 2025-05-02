/* Identifiers and literals */
token_value(id,           270).
token_value(':=',         271).
token_value(number,       272).

/* Keywords */
token_value(program,      256).
token_value(input,        257).
token_value(output,       258).
token_value(var,          259).
token_value(integer,      260).
token_value(begin,        261).
token_value(end,          262).

/* Special compound tokens */
token_value(assign,       271).

/* Symbols - using ASCII values or custom token codes */
token_value('(',          40).
token_value(')',          41).
token_value(',',          44).
token_value(';',          59).
token_value(':',          58).
token_value('.',          46).
token_value('+',          43).
token_value('*',          42).
token_value('=',          61).

/* Special values */
token_value(undef,        273).
token_value(eof,          275).
token_value(nfound,       -1).

convert_token(Token, Code) :- token_value(Token, Code), !.

% see how 'testread([H|T])' works, its a predicate(?) that can take a list, store the first element in H and the rest of the list in T

tokenize([], []). % anyways here we have the terminator (it stops the ruekntison)
tokenize([Token|Tokens], [Code|Codes]) :- convert_token(Token, Code), tokenize(Tokens, Codes). 
% same thing here we separate the first one in the list and call call tokenize again with the rest.