% This file is for all the ending related functions

% game_over(+GameState, -Winner)
% This functions determines if the current player won or not
game_over([Board, CurrentPlayer, T, Names, BoardType], CurrentPlayer):-
    \+ valid_moves_bool([Board, CurrentPlayer, T, Names, BoardType]).
