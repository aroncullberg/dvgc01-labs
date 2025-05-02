token_code(program, 256).
token_code(testok1, 1).
token_code(begin, 2).

convert_token(Token, Code) :- token_code(Token, Code), !.

% see how 'testread([H|T])' works, its a predicate(?) that can take a list, store the first element in H and the rest of the list in T

tokenize([], []). % anyways here we have the terminator (it stops the ruekntison)
tokenize([Token|Tokens], [Code|Codes]) :- convert_token(Token, Code), tokenize(Tokens, Codes). 
% same thing here we separate the first one in the list and call call tokenize again with the rest.