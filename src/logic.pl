% File general game logic functions
:- use_module(library(lists)).
:- consult(move).              % Functions to move a piece
:- consult(validate_move).     % Functions to validate if a move is valid

    
%  This predicate receives the current game state and returns the move chosen by the computer player. 
    % Level 1 should return a random valid move. 
    % Level 2 should return the best play at the time (using a greedy algorithm), considering the evaluation of the game state as determined by the value/3 predicate. 
    % For human players, it should interact with the user to read the move.
% choose_move(+GameState, +Level, -Move)
% OBRIGATORIO
% Predicate to choose a move for a human player
choose_move([Board, CurrentPlayer, _], 0, move(FromX, FromY, ToX, ToY)) :-
    length(Board, S),
    
    write('Enter the coordinates of the piece you want to move (X Y):'), nl, % Prompt the user to enter the source coordinates
    get_take_piece(S, FromX, FromYProv),

    write('Enter the coordinates of the destination (X Y):'), nl, % Prompt the user to enter the destination coordinates
    get_take_piece(S, ToX, ToYProv),

    FromY is S-FromYProv+1, 
    ToY is S-ToYProv+1,

    % Validate the move
    (valid_move([Board, CurrentPlayer, _], move(FromX, FromY, ToX, ToY)) ->   % If the move is valid, exit
        true;

        (write('Invalid move! Try again.'), nl, display_game([Board, CurrentPlayer, _]), nl,  % If invalid, retry
         choose_move([Board, CurrentPlayer, _], 0, move(FromX, FromY, ToX, ToY)))
    ).

% choose_move([Board, CurrentPlayer, T], 1, Move):- 
    % TODO
% choose_move([Board, CurrentPlayer, T], 2, Move):- 
    % TODO