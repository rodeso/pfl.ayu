% File for all the player related things

% player(+PlayerNumber, -Player)
% Player
player(1, player1).
player(2, player2).

% piece_player(+Player, -Piece)
% Associate player to the pice
piece_player(1, x).
piece_player(2, o).

% switch_player(+CurrentPlayer, -NewPlayer)
% Switch the player
switch_player(1, 2).
switch_player(2, 1).

% change_player(+GameState, +NewGameState)
% Switch the player inside of the GameState
change_player([B, CurrentPlayer, T, Names], [B, NewPlayer, T, Names]):-
    switch_player(CurrentPlayer, NewPlayer).

% display_player(+Player)
% Displays the current player
display_player(Type, Player, Names):-
    (Type = 1 -> 
        nth1(Player, Names, Name), % Get the player's name from the list
        format('~w\'s turn: ', [Name]), nl;
    Type = 2 -> 
        (Player = 1 -> 
            nth1(1, Names, Name), % Get the human player's name
            format('~w\'s turn: ', [Name]), nl;
            write('Computer turn'), nl);
    Type = 3 -> 
        format('Computer ~d turn: ', [Player]), nl).


% Function to get the player from the type of game
% type_to_player(+T, +CurrentPlayer, -Player)
type_to_player(1, _, 0).
type_to_player(2, 1, 0).
type_to_player(2, 2, 1).
type_to_player(3, _, 1).
type_to_player(4, 1, 0).
type_to_player(4, 2, 2).
type_to_player(5, 1, 1).
type_to_player(5, 2, 2).
type_to_player(6, _, 2).