:- use_module(library(lists)).
:- use_module(library(random)).
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
display_game([Board, CurrentPlayer, T, Names]) :-
    display_general_board(Board, 2), nl,
    display_player(T, CurrentPlayer, Names).



% game_loop(+GameState)
% This is the main game loop
game_loop([Board, Player, T, Names]) :- 
    game_over([Board, Player, T, Names], Winner), !,
    display_general_board(Board, 2),
    nth1(Winner, Names, WinnerName),
    format('Game over! Winner: ~s', [WinnerName]), nl.

game_loop([Board, CurrentPlayer, T, Names]) :-
    type_to_player(T, CurrentPlayer, PlayerType),
    choose_move([Board, CurrentPlayer, T, Names], PlayerType, Move),
    move([Board, CurrentPlayer, T, Names], Move, NewGameState),
    change_player(NewGameState, NextGameState),
    game_loop(NextGameState).


% set_up(-T, -S, -P, -Names)
% Function to do the initial set up
set_up(T, S, P, Names) :-
    get_type_game(T), nl,          % Get the game type
    get_player_names(T, Names),   % Get player names based on the type of game
    get_size_game(S), nl,         % Get the size of the board
    get_player_starts(T, P), nl.  % Get the starting player


% OBRIGATORIO
% initial_state(+GameConfig, -GameState).
% This predicate receives a desired game configuration and returns the corresponding initial game state. 
% Game configuration includes the type of each player and other parameters such as board size, use of optional rules, 
% player names, or other information to provide more flexibility to the game. 
% The game state describes a snapshot of the current game state, including board configuration 
% (typically using list of lists with different atoms for the different pieces), identifies the current player (the one playing next),
% and possibly captured pieces and/or pieces yet to be played, or any other information that may be required, depending on the game.
initial_state([T, S, P, Names], GameState) :-
    board(S, Board),         % Generate the board
    GameState = [Board, P, T, Names].  


% OBRIGATORIO
% T -> type of game being played (1-H/H, 2-H/C Easy, 3-C/C Easy/Easy, 4-H/C Hard, 5-C/C Easy/Hard and 6-C/C Hard/Hard)
% S -> size of the board (5, 11, 13 or 15)
% P -> first player (1 or 2)
% Main function that starts the game
play:-
    % Set up the game
    set_up(T, S, P, Names),
    % Initial state
    initial_state([T,S,P, Names], GameState),
    % Start the game loop
    game_loop(GameState).
