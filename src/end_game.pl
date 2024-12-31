% This file is for all the ending related functions

% game_over(+GameState, -Winner)
% This functions determines if the current player won, if not returns none
game_over([Board, CurrentPlayer, T], Winner):-
    valid_moves([Board, CurrentPlayer, T], ListOfMoves),
    ( ListOfMoves = [] ->
        Winner = CurrentPlayer
    ; 
        Winner = none
    ).
