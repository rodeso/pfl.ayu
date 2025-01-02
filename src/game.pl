:- use_module(library(lists)).
:- consult(board).    % Functions to create and display the board
:- consult(input).    % Functions to receive all the inputs
:- consult(player).   % Functions of all player related
:- consult(end_game). % Functions to end game
:- consult(logic).    % Functions of the game's logic
:- consult(clusters).
:- consult(valid_move_final).
:- consult(utils).


% GameState = [Board, CurrentPlayer,TypeOfGame,...] - ir escrevendo aqui para sabermos 
% GameConfig = [SizeBoard ,TypeOfGame, ...]

% OBRIGATORIO
% display_game(+GameState)
% Displays the current board and the current player
display_game([Board, CurrentPlayer, _]):-
    display_board(Board), nl,
    display_player(CurrentPlayer).


% game_loop(+GameState)
% This is the main game loop
game_loop([Board, Player, T]):- % If the game is over
    game_over([Board, Player, T], Winner),
    Winner \= none,
    display_board(Board),
    format('Game over! Winner: ~d', [Winner]). % AQUI TINHA DE MORRER, AINDA N MORRE
game_loop([Board, CurrentPlayer, T]):- % New turn

    display_game([Board, CurrentPlayer, T]), nl,

    /*valid_moves_final([Board, CurrentPlayer, T], List),
    write('Moves: '), write(List), nl,*/

    choose_move([Board, CurrentPlayer, T], 0, Move),

    move([Board, CurrentPlayer, T], Move, NewGameState),

    change_player(NewGameState, NextGameState),

    game_loop(NextGameState). % Recursive


% set_up(-T, -S, -P)
% Function to do the initial set up
set_up(T, S, P):-
    get_type_game(T), nl,      % input.pl
    get_size_game(S), nl,      % input.pl
    get_player_starts(P), nl.  % input.pl

% OBRIGATORIO
% initial_state(+GameConfig, -GameState).
% This predicate receives a desired game configuration and returns the corresponding initial game state. 
% Game configuration includes the type of each player and other parameters such as board size, use of optional rules, 
% player names, or other information to provide more flexibility to the game. 
% The game state describes a snapshot of the current game state, including board configuration 
% (typically using list of lists with different atoms for the different pieces), identifies the current player (the one playing next),
% and possibly captured pieces and/or pieces yet to be played, or any other information that may be required, depending on the game.
initial_state([T, S, P], GameState):-
    board(S, B),               % board.pl
    % other things...
    [B, P, T] = GameState.

% OBRIGATORIO
% T -> type of game being played (1-H/H, 2-H/C, 3-C/C)
% S -> size of the board (5, 11, 13 or 15)
% P -> first player (1 or 2)
% Main function that starts the game
play:-
    % Set up the game
    set_up(T, S, P),
    % Initial state
    initial_state([T,S,P], GameState),
    % Start the game loop
    game_loop(GameState).
