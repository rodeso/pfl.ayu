% This file is for small auxiliar functions that can be generaly used

% my_min_list(+List, -Min)
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

% piece_at(+Board, +X, +Y, +Player)
% Check if a piece exists at a specific position for a given player
piece_at(Board, X, Y, Player) :-
    piece_player(Player, Piece),
    nth1(Y, Board, Row),
    nth1(X, Row, Piece).

% which_piece_at(+Board, +X, +Y, -Piece)
% Returns the piece in that place
which_piece_at(Board, X, Y, Piece) :-
    nth1(Y, Board, Row),
    nth1(X, Row, Piece).

% empty_at(+Board, +X, +Y)
% Check if a specific position is empty
empty_at(Board, X, Y) :-
    nth1(Y, Board, Row),
    nth1(X, Row, empty).

% same_type(+Piece1, +Piece2)
% Checks if the pieces are the same
same_type(Piece, Piece).

% get_board(+GameState, -Board)
% Get the board from the game state
get_board([Board, _, _, _, _], RetBoard):-
    Board = RetBoard.

% get_piece(+Board, +Row, +Col, -Piece)
% Get the piece at a specific cell
get_piece(Board, Row, Col, Piece) :-
    nth1(Row, Board, RowList),
    nth1(Col, RowList, Piece).

% within_bounds(+Board, +Row, +Col)
% Check if a cell is within bounds
within_bounds(Board, Row, Col) :-
    length(Board, N),
    Row > 0, Row =< N,
    nth1(Row, Board, RowList),
    length(RowList, M),
    Col > 0, Col =< M.

% valid_one_move(+FromX, +FromY, +ToX, +ToY)
% Ensure that the move for an isolated piece is exactly 1 square away
valid_one_move(FromX, FromY, ToX, ToY) :-
    DX is abs(ToX - FromX),
    DY is abs(ToY - FromY),
    (DX =:= 1, DY =:= 0;     % Move 1 square left or right
     DX =:= 0, DY =:= 1).    % Move 1 square up or down

% all_elements(+List1, +List2)
% Check if every pair in the first list exists in the second list
all_elements([], _).
all_elements([Pair|Rest], List2) :-
    member(Pair, List2),
    all_elements(Rest, List2).

% remove_element(+Element, +List, -NewList)
% Removes ONLY the first occurrence of the element
remove_element(_, [], []).
remove_element(Element, [Element|Rest], Rest) :- !. 
remove_element(Element, [Head|Rest], [Head|NewRest]) :-
    remove_element(Element, Rest, NewRest).

% flat_list(+List, -FlatList)
% Custom flatten predicate to handle nested lists
flat_list([], []).  % Base case: empty list is already flattened
flat_list([Head|Tail], FlatList):-
    !,
    flat_list(Head, FlatHead),
    flat_list(Tail, FlatTail),
    append(FlatHead, FlatTail, FlatList).
flat_list(NonList, [NonList]).

% has_element(+Element, +Cluster)
% Helper predicate to check if a cluster contains a specific element
has_element(Element, Cluster):-
    member(Element, Cluster).

% reverse_all(+List, -ReversedList)
% Function to reverse a list of lists
reverse_all([], []).
reverse_all([H|T], [ReversedH|ReversedT]) :-
    reverse(H, ReversedH),
    reverse_all(T, ReversedT).

% path_at_min_distance(+MinDistance, +Paths)
% Helper function to check if a path has the minimum distance
path_at_min_distance(MinDistance, Distance-_) :-
    Distance =:= MinDistance.
