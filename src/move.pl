% File of all the functions that actual move a pice

% Helper to replace the row at the Y-th index
replace_row_in_board(1, NewRow, RestRows, [NewRow | RestRows]).
replace_row_in_board(Y, NewRow, [Row | RestRows], [Row | NewBoard]) :-
    Y > 1,
    Y1 is Y - 1,
    replace_row_in_board(Y1, NewRow, RestRows, NewBoard).

% replace_piece(+Board, +X, +Y, +NewValue, -NewBoard)
% Replaces the value at position (X, Y) on the board with NewValue.
replace_piece(Board, X, Y, NewValue, NewBoard) :-
    nth1(Y, Board, Row, RestRows),                            % Extract the row at index Y
    nth1(X, Row, OldValue, RestCols),                         % Extract the column at index X in the row
    nth1(X, NewRow, NewValue, RestCols),                      % Replace the value in the row
    replace_row_in_board(Y, NewRow, RestRows, NewBoard).      % Ensure the row is correctly replaced in the board


  
% Validates and executes a move
% move(+GameState, +Move, -NewGameState)
move([Board, CurrentPlayer, TypeOfGame, Names], move(FromX, FromY, ToX, ToY), [NewBoard, CurrentPlayer, TypeOfGame, Names]) :-
    replace_piece(Board, FromX, FromY, empty, TempBoard),     % Remove the piece from the source position
    piece_player(CurrentPlayer, Piece),
    replace_piece(TempBoard, ToX, ToY, Piece, NewBoard).      % Place the piece at the destination position
    write('Move made successfully!'), nl.
