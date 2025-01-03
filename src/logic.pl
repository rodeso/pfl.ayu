% File general game logic functions
:- consult(move).              % Functions to move a piece

    
%  This predicate receives the current game state and returns the move chosen by the computer player. 
    % Level 1 should return a random valid move. 
    % Level 2 should return the best play at the time (using a greedy algorithm), considering the evaluation of the game state as determined by the value/3 predicate. 
    % For human players, it should interact with the user to read the move.
% choose_move(+GameState, +Level, -Move)
% OBRIGATORIO
% Predicate to choose a move for a human player
choose_move([Board, CurrentPlayer, _], 0, move(FromX, FromY, ToX, ToY)) :-
    length(Board, S),

    repeat,

    display_game([Board, CurrentPlayer, _]), nl, nl,

    write('Enter the coordinates of the piece you want to move (X Y):'), nl, nl,
    get_take_piece(S, FromX, FromYProv),

    write('Enter the coordinates of the destination (X Y):'), nl, nl,
    get_take_piece(S, ToX, ToYProv),

    FromY is S-FromYProv+1, 
    ToY is S-ToYProv+1,

    valid_move_final([Board, CurrentPlayer, _], move(FromX, FromY, ToX, ToY)), 
    !.
% Easy Computer
choose_move([Board, CurrentPlayer, T], 1, Move):- 
    length(Board, S),
    repeat,
    display_game([Board, CurrentPlayer, _]), nl, nl,
    nl, write('The Computer is Thinking...'), nl, nl,
    valid_moves_final([Board, CurrentPlayer, T], ListOfMoves),
    random_member(Move, ListOfMoves),

    !.
% Hard Computer
% choose_move([Board, CurrentPlayer, T], 2, Move):- 
    % TODO