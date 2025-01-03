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
change_player([B, CurrentPlayer, T], [B, NewPlayer, T]):-
    switch_player(CurrentPlayer, NewPlayer).

% display_player(+Player)
% Displays the current player
display_player(Type, Player):-
    (Type = 1 -> format('Player ~d turn: ', [Player]), nl;
    Type = 2 -> (Player = 1 -> write('Player turn'), nl; write('Computer turn'), nl);
    Type = 3 -> format('Computer ~d turn: ', [Player]), nl).