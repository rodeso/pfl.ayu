:- consult(board). % Functions to create and display the board
:- consult(input). % Functions to receive all the inputs

% next -> create game state to then create the initial_state(+GameConfig, -GameState).

% Main game loop
% T -> type of game being played (1-H/H, 2-H/C, 3-C/C)
% S -> size of the board (5, 11, 13 or 15)
play:-
    get_type_game(T), nl,
    get_size_game(S), nl,
    board(S, B),          % Creates the board
    display_general(B).   % Displays created board
    
