:- use_module(library(lists)).
% 5x5 board (for testing)
/*board(5, [[empty, x, empty, x, empty], 
          [o, empty, o, empty, o], 
          [empty, x, empty, x, empty], 
          [o, empty, o, empty, o], 
          [empty, x, empty, x, empty]]).*/
board(5, [[empty, empty, x, x, empty], 
          [o, o, o, empty, o], 
          [empty, empty, o, x, empty], 
          [o, o, o, o, empty], 
          [o, x, empty, o, empty]]).

% 11x11 board
board(11, [[empty, x, x, x, empty, empty, empty, x, empty, x, empty], 
          [x, empty, o, empty, o, empty, o, empty, o, empty, o], 
          [o, x, empty, x, empty, x, empty, x, empty, x, empty], 
          [o, empty, o, empty, o, empty, o, empty, o, empty, o],
          [empty, x, empty, x, empty, x, empty, x, empty, x, empty], 
          [o, empty, o, empty, o, empty, o, empty, o, empty, o],
          [empty, x, empty, x, empty, x, empty, x, empty, x, empty], 
          [o, empty, o, empty, o, empty, o, empty, o, empty, o],
          [empty, x, empty, x, empty, x, empty, x, empty, x, empty], 
          [o, empty, o, empty, o, empty, o, empty, o, empty, o],
          [empty, x, empty, x, empty, x, empty, x, empty, x, empty]
]).

% 13x13 board
board(13, [[empty, x, empty, x, empty, x, empty, x, empty, x, empty, x, empty], 
          [o, empty, o, empty, o, empty, o, empty, o, empty, o, empty, o], 
          [empty, x, empty, x, empty, x, empty, x, empty, x, empty, x, empty], 
          [o, empty, o, empty, o, empty, o, empty, o, empty, o, empty, o], 
          [empty, x, empty, x, empty, x, empty, x, empty, x, empty, x, empty], 
          [o, empty, o, empty, o, empty, o, empty, o, empty, o, empty, o], 
          [empty, x, empty, x, empty, x, empty, x, empty, x, empty, x, empty], 
          [o, empty, o, empty, o, empty, o, empty, o, empty, o, empty, o], 
          [empty, x, empty, x, empty, x, empty, x, empty, x, empty, x, empty], 
          [o, empty, o, empty, o, empty, o, empty, o, empty, o, empty, o], 
          [empty, x, empty, x, empty, x, empty, x, empty, x, empty, x, empty], 
          [o, empty, o, empty, o, empty, o, empty, o, empty, o, empty, o], 
          [empty, x, empty, x, empty, x, empty, x, empty, x, empty, x, empty]          
]).

% 15x15 board
board(15, [[empty, x, empty, x, empty, x, empty, x, empty, x, empty, x, empty, x, empty], 
          [o, empty, o, empty, o, empty, o, empty, o, empty, o, empty, o, empty, o], 
          [empty, x, empty, x, empty, x, empty, x, empty, x, empty, x, empty, x, empty], 
          [o, empty, o, empty, o, empty, o, empty, o, empty, o, empty, o, empty, o], 
          [empty, x, empty, x, empty, x, empty, x, empty, x, empty, x, empty, x, empty], 
          [o, empty, o, empty, o, empty, o, empty, o, empty, o, empty, o, empty, o], 
          [empty, x, empty, x, empty, x, empty, x, empty, x, empty, x, empty, x, empty], 
          [o, empty, o, empty, o, empty, o, empty, o, empty, o, empty, o, empty, o], 
          [empty, x, empty, x, empty, x, empty, x, empty, x, empty, x, empty, x, empty], 
          [o, empty, o, empty, o, empty, o, empty, o, empty, o, empty, o, empty, o], 
          [empty, x, empty, x, empty, x, empty, x, empty, x, empty, x, empty, x, empty], 
          [o, empty, o, empty, o, empty, o, empty, o, empty, o, empty, o, empty, o], 
          [empty, x, empty, x, empty, x, empty, x, empty, x, empty, x, empty, x, empty], 
          [o, empty, o, empty, o, empty, o, empty, o, empty, o, empty, o, empty, o], 
          [empty, x, empty, x, empty, x, empty, x, empty, x, empty, x, empty, x, empty]
]).

% chars to print better
char(x, 'X').
char(o, 'O').
char(empty, ' ').

% Displays line division between information lines
display_line_div(NT, NT):- write('|---|'), !.
display_line_div(NT, N):-
    write('|---'),
    M is N+1,
    display_line_div(NT, M).

% Displays the number of the column (its a row)
display_col_num(NT, NT):- write('  '), write(NT), write(' '), !.
display_col_num(NT, N):-
    N > 9,
    write('  '),
    write(N),
    write(''),
    P is N+1,
    display_col_num(NT, P), !.
display_col_num(NT, N):-
    write('  '),
    write(N),
    write(' '),
    P is N+1,
    display_col_num(NT, P).

% Displays an item
display_item(Item):- 
    char(Item, C),
    write(C),
    write(' | ').

% Displays one line (information line)
display_line([]):- nl, !.
display_line([Item | Other]):-
    display_item(Item),
    display_line(Other).

% Displays the number of the row (its a column)
display_row_number(N):-
    N > 9,
    write(N),
    write(' | '), !.
display_row_number(N):-
    write(N),
    write('  | ').

% Displays the board (without the numbers)
display_partial_board([], _, NT):- write('   '), display_line_div(NT, 1) , !.
display_partial_board([Line | Others], N, NT):-
    write('   '),
    display_line_div(NT, 1), nl,
    display_row_number(N),
    display_line(Line),
    X is N-1,
    display_partial_board(Others, X, NT).

% Displays the whole board
display_board(B):- 
    length(B, N),
    display_partial_board(B, N, N), nl,
    write('   '),
    display_col_num(N, 1), nl.