% This file is for small auxiliar functions that can be generaly used

% Minimum of a list
my_min_list([H|T], Min) :-
    my_min_list(T, H, Min).
my_min_list([], Min, Min).
my_min_list([H|T], Acc, Min) :-
    H < Acc,
    my_min_list(T, H, Min).
my_min_list([H|T], Acc, Min) :-
    H >= Acc,
    my_min_list(T, Acc, Min).


% Check if a piece exists at a specific position for a given player
piece_at(Board, X, Y, Player) :-
    piece_player(Player, Piece),
    nth1(Y, Board, Row),
    nth1(X, Row, Piece).

% Returns the piece in that place
which_piece_at(Board, X, Y, Piece) :-
    nth1(Y, Board, Row),
    nth1(X, Row, Piece).

% Check if a specific position is empty
empty_at(Board, X, Y) :-
    nth1(Y, Board, Row),
    nth1(X, Row, empty).

% Checks if the pieces are the same
same_type(Piece1, Piece2):- Piece1 == Piece2.

get_board([Board, _, _], RetBoard):-
    Board = RetBoard.

% valid_one_move(+FromX, +FromY, +ToX, +ToY)
% Ensure that the move for an isolated piece is exactly 1 square away
valid_one_move(FromX, FromY, ToX, ToY) :-
    DX is abs(ToX - FromX),
    DY is abs(ToY - FromY),
    (DX =:= 1, DY =:= 0;     % Move 1 square left or right
     DX =:= 0, DY =:= 1).    % Move 1 square up or down

% Check if every pair in the first list exists in the second list
all_elements([], _).
all_elements([Pair|Rest], List2) :-
    member(Pair, List2),
    all_elements(Rest, List2).

remove_element(_, [], []).
remove_element(Element, [Element|Rest], Rest).
remove_element(Element, [Head|Rest], [Head|NewRest]) :-
    remove_element(Element, Rest, NewRest).
