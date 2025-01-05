:- use_module(library(lists)).
:- use_module(library(random)).
:- consult(board).    % Functions to create and display the board
:- consult(input).    % Functions to receive all the inputs
:- consult(player).   % Functions of all player related
:- consult(end_game). % Functions to end game
:- consult(logic).    % Functions of the game's logic
:- consult(clusters).
:- consult(valid_move).
:- consult(utils).

% ------------------------------------------------------------------------------------------------

% GameState = [Board, Player, TypeGame, Names, BoardType]

% TypeGame -> Type of game being played (1-H/H, 2-H/C Easy, 3-C/C Easy/Easy, 4-H/C Hard, 5-C/C Easy/Hard and 6-C/C Hard/Hard)
% SizeBoard -> Size of the board (5, 11, 13 or 15)
% StartingPlayer -> First player (1 or 2)
% Names -> List with the names of the players
% BoardType -> Style of the board (1 or 2)

% ------------------------------------------------------------------------------------------------

% display_game(+GameState)
% Displays the current board and the current player
display_game([Board, CurrentPlayer, TypeGame, Names, BoardType]) :-
    display_general_board(Board, BoardType), nl,
    display_player(TypeGame, CurrentPlayer, Names).

% ------------------------------------------------------------------------------------------------

% game_loop(+GameState)
% This is the main game loop
game_loop([Board, Player, TypeGame, Names, BoardType]):- % Game loop - End of the game 
    game_over([Board, Player, TypeGame, Names, BoardType], Winner), !,
    display_general_board(Board, BoardType),
    nth1(Winner, Names, WinnerName),
    format('Game over! Winner: ~s', [WinnerName]), nl.

game_loop([Board, CurrentPlayer, TypeGame, Names, BoardType]):- % Game loop - Continue the game
    valid_moves([Board, CurrentPlayer, TypeGame, Names, BoardType], ListOfMoves),
    type_to_player(TypeGame, CurrentPlayer, PlayerType),
    choose_move([Board, CurrentPlayer, TypeGame, Names, BoardType], PlayerType, Move),
    move([Board, CurrentPlayer, TypeGame, Names, BoardType], Move, NewGameState),
    change_player(NewGameState, NextGameState),
    game_loop(NextGameState).

% ------------------------------------------------------------------------------------------------

% set_up(-TypeGame, -SizeBoard, -StartingPlayer, -Names)
% Function to do the initial set up. The user can choose the style of the boards, the type of game, the size of the board, the starting player and the names of the players
set_up(TypeGame, SizeBoard, StartingPlayer, Names, BoardType) :-
    get_board_type(BoardType), nl,      % Get the style of the board
    get_type_game(TypeGame), nl,               % Get the game type
    get_player_names(TypeGame, Names),         % Get player names based on the type of game
    get_size_game(SizeBoard), nl,               % Get the size of the board
    get_player_starts(TypeGame, StartingPlayer), nl.        % Get the starting player


% initial_state(+GameConfig, -GameState)
% This predicate receives a desired game configuration and returns the corresponding initial game state. 
initial_state([TypeGame, SizeBoard, StartingPlayer, Names, BoardType], GameState) :-
    board(SizeBoard, Board),         % Generate the board
    GameState = [Board, StartingPlayer, TypeGame, Names, BoardType].  


% ------------------------------------------------------------------------------------------------

% play
% Main function that starts the game
play:-
    
    set_up(TypeGame, SizeBoard, StartingPlayer, Names, BoardType),                    % Set up the game
    
    initial_state([TypeGame,SizeBoard,StartingPlayer, Names, BoardType], GameState),  % Initial state
    
    game_loop(GameState).                                                             % Start the game loop
