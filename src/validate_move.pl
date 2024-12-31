% This file is for all the functions that make sure the move is valid

:- consult(utils).  % Auxiliars

% Checks if a move is valid in the current game state
valid_move([Board, CurrentPlayer, _], move(FromX, FromY, ToX, ToY)) :-
    write('Checking valid_move for Player: '), write(CurrentPlayer), nl,
    write('From: ('), write(FromX), write(', '), write(FromY), write(') '),
    write('To: ('), write(ToX), write(', '), write(ToY), write(')'), nl, nl,
    
    % Validate the source position
    (piece_at(Board, FromX, FromY, CurrentPlayer) ->
        true;
        write('Error: Source position is invalid.'), nl, fail),

    % Validate the destination position
    (empty_at(Board, ToX, ToY) ->
        true;
        write('Error: Destination position is not empty.'), nl, fail),

    % Ensure the move reduces the distance to the closest friendly unit
    (distance_rule_satisfied(Board, FromX, FromY, ToX, ToY, CurrentPlayer) ->
        true;
        write('Error: Distance rule not satisfied.'), nl, fail).

    % USAR O valid_moves ??????????????????????????????????????????????????????????????

    % Ensure that groups remain connected after the move
    /*(group_remains_connected(Board, FromX, FromY, ToX, ToY, CurrentPlayer) ->
        write('Group connectivity preserved.'), nl
    ;
        write('Error: Group connectivity would be broken.'), nl, fail).*/




% Check if the distance rule is satisfied
distance_rule_satisfied(Board, FromX, FromY, ToX, ToY, Player) :-
    closest_friendly_distance(Board, FromX, FromY, Player, OldDistance),
    closest_friendly_distance(Board, ToX, ToY, Player, NewDistance),
    NewDistance =< OldDistance.

% Calculate the distance to the closest friendly unit
closest_friendly_distance(Board, X, Y, Player, Distance) :-
    findall(D, (
        piece_at(Board, FX, FY, Player),
        \+ (FX = X, FY = Y),  % Exclude the source position itself
        manhattan_distance(X, Y, FX, FY, D)
    ), Distances),
    my_min_list(Distances, Distance).

% Calculate the Manhattan distance between two positions
manhattan_distance(X1, Y1, X2, Y2, Distance) :-
    Distance is abs(X1 - X2) + abs(Y1 - Y2).

