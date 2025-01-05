:- use_module(library(lists)).

% ------------------------------------------------------------------------------------------------
% Boards

% 5x5 board
board(5, [[empty, x, empty, x, empty], 
          [o, empty, o, empty, o], 
          [empty, x, empty, x, empty], 
          [o, empty, o, empty, o], 
          [empty, x, empty, x, empty]]).

/*board(5, [[empty, empty, o, empty, empty],  % exemplo 1 - X automatic winner, O perfect to test connections between a big cluster and a isolated piece
          [o, o, o, x, o], 
          [empty, empty, o, x, empty], 
          [o, o, o, o, empty], 
          [o, x, empty, o, empty]]).*/

/*board(5, [[x, empty, empty, empty, x],  % exemplo 2 - X in a line, O in a square (Problem 1)
          [empty, empty, empty, o, empty], 
          [empty, empty, o, empty, empty], 
          [empty, empty, empty, empty, empty], 
          [empty, empty, empty, empty, empty]]).*/
          
/*board(5, [[x, empty, empty, empty, x],  % exemplo 3 - X in a line, O 2 + clusters diagonally (Problem 2)
          [empty, empty, empty, o, o], 
          [empty, o, o, empty, empty], 
          [empty, empty, empty, empty, empty], 
          [empty, empty, empty, empty, empty]]).*/

/*board(5, [[x, x, x, empty, empty], % exemplo 4
          [x, o, empty, o, x], 
          [x, empty, x, empty, empty], 
          [empty, o, empty, o, empty], 
          [x, empty, x, empty, empty]]).*/

/*board(5, [[x, empty, empty, empty, empty],  % exemplo 5 - versão basica do exemplo 4
          [x, empty, x, empty, empty], 
          [empty, empty, empty, empty, empty], 
          [empty, x, x, empty, empty], 
          [empty, empty, empty, empty, empty]]).*/
/*board(5, [[empty, empty, empty, x, empty], 
          [o, x, o, o, o], 
          [empty, x, o, x, empty], 
          [empty, empty, empty, x, o], 
          [empty, empty, empty, x, empty]]).*/


% 11x11 board
board(11, [[empty, x, empty, x, empty, x, empty, x, empty, x, empty], 
          [o, empty, o, empty, o, empty, o, empty, o, empty, o], 
          [empty, x, empty, x, empty, x, empty, x, empty, x, empty], 
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

% ------------------------------------------------------------------------------------------------
% Board display

% display_general_board(+Board, +Style)
% Displays the board in the chosen style
display_general_board(Board, 1):-
    display_board(Board).
display_general_board(Board, 2):-
    display_board_2(Board).


% ------------------------------------------------------------------------------------------------
% Style 1

% char(+Item, -Char)
% Converts the item into a char
char(x, 'X').
char(o, 'O').
char(empty, ' ').

% Displays an item
display_item(Item):- 
    char(Item, C),
    write(C),
    write(' | ').

% display_line_division(+NT, +N)
% Displays line division between information lines
display_line_division(NT, NT):- write('|---|'), !.
display_line_division(NT, N):-
    write('|---'),
    M is N+1,
    display_line_division(NT, M).

% display_column_number(+NT, +N)
% Displays the number of the column (its a row)
display_column_number(NT, NT):- write('  '), write(NT), write(' '), !.
display_column_number(NT, N):-
    N > 9,
    write('  '),
    write(N),
    write(''),
    P is N+1,
    display_column_number(NT, P), !.
display_column_number(NT, N):-
    write('  '),
    write(N),
    write(' '),
    P is N+1,
    display_column_number(NT, P).

% display_line(+Line)
% Displays one line (information line)
display_line([]):- nl, !.
display_line([Item | Other]):-
    display_item(Item),
    display_line(Other).

% display_row_number(+N)
% Displays the number of the row (its a column)
display_row_number(N):-
    N > 9,
    write(N),
    write(' | '), !.
display_row_number(N):-
    write(N),
    write('  | ').

% display_partial_board(+Board, +N, +NT)
% Displays the board (without the columsnumbers)
display_partial_board([], _, NT):- write('   '), display_line_division(NT, 1) , !.
display_partial_board([Line | Others], N, NT):-
    write('   '),
    display_line_division(NT, 1), nl,
    display_row_number(N),
    display_line(Line),
    X is N-1,
    display_partial_board(Others, X, NT).

% display_board(+B)
% Displays the whole board in one style
display_board(B):- 
    length(B, N),
    display_partial_board(B, N, N), nl,
    write('   '),
    display_column_number(N, 1), nl.

% ------------------------------------------------------------------------------------------------
% Style 2

% char_2(+Item, -Char)
% Transforms the item into a char
char_2(x, 'X').
char_2(o, 'O').
char_2(empty, '+').

% Displays the cell content
display_cell_content_2(Item):-
    char_2(Item, Char),
    write(Char).

% Displays empty row spacing
display_empty_row_2([], _):- nl, !.
display_empty_row_2([_ | Rest], []):- !.
display_empty_row_2([_ | Rest], V):-
    write('|   '),
    display_empty_row_2(Rest, V).

% Displays a row with borders
display_row_with_borders_2([], _):-
    write(''), nl.
display_row_with_borders_2([Item | Rest], 1):-
    display_cell_content_2(Item),
    display_row_with_borders_2(Rest, 0), !.
display_row_with_borders_2([Item | Rest], NumberRows):-
    display_cell_content_2(Item),
    write('---'),
    NumberRows1 is NumberRows - 1,
    display_row_with_borders_2(Rest, NumberRows1).

% Writes the row number
write_row_number_2(RowNumber):-
    format('~|~t~d~2+  ', [RowNumber]).

% Displays the full board including rows and dividers
display_full_board_2([], _, _):- !.
display_full_board_2([Row | Rest], CurrentRow, TotalRows):-
    write_row_number_2(CurrentRow),
    NumberRows is TotalRows,
    display_row_with_borders_2(Row, NumberRows),
    write('    '),
    display_empty_row_2(Row, Rest),
    NextRow is CurrentRow - 1,
    display_full_board_2(Rest, NextRow, TotalRows).

% Displays the column numbers at the bottom
display_column_number_2(N, N):-
    write(N), !.
display_column_number_2(N, Current):-
    Current > 8,
    write(Current), write('  '),
    Next is Current + 1,
    display_column_number_2(N, Next), !.
display_column_number_2(N, Current):-
    write(Current), write('   '),
    Next is Current + 1,
    display_column_number_2(N, Next).

% Displays the whole board in another style
display_board_2(Board):-
    length(Board, N),
    display_full_board_2(Board, N, N),
    display_column_number_2(N, 1), nl.