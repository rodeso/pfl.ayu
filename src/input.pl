% Check if the value is between two numbers
between(Min, Max, Min):- Min =< Max.
between(Min, Max, Value):-
    Min < Max,
    NextMin is Min + 1,
    between(NextMin, Max, Value).

% Receive the number
read_number(X, Acc) :- 
    get_code(C),
    between(48, 57, C), !,
    Acc1 is 10 * Acc + (C - 48),
    read_number(X, Acc1).
read_number(X, X).

% Get the input and make sure that it is between two numbers
get_number(Min, Max, Context, Value):-
    format('~a between ~d and ~d: ', [Context, Min, Max]),
    repeat,
    read_number(Value, 0),
    between(Min, Max, Value), !.

% Get the input and make sure that it is member of a especific list
get_size(List, Context, Value):-
    format('~a: ', [Context]),
    repeat,
    read_number(Value, 0),
    member(Value, List), !.

type_game(1):-
    nl, 
    write('Chosen game: Human vs Human'), nl,
    % players 1 & 2
    .
type_game(2):-
    nl,
    write('Chosen game: Human vs Computer'), nl,
    % players 1 & bot
    .
type_game(3):-
    nl,
    write('Chosen game: Computer vs Computer'), nl,
    % bot & bot
    .

% Get type of game that will be played
get_type_game(T):-
    write('Type of game: '), nl,
    write('1 - Human vs Human'), nl,
    write('2 - Human vs Computer'), nl,
    write('3 - Computer vs Computer'), nl,
    get_number(1, 3, 'Type of game', T),
    type_game(T).

% Get size of the board
get_size_game(S):-
    write('Size of board: 5, 11, 13, 15'), nl,
    get_size([5, 11, 13, 15], 'Input', S).

% Get place to add or remove piece
get_take_piece(S, X, Y):-
    get_number(1, S, 'X cordenate:', X), nl,
    get_number(1, S, 'Y cordenate:', Y), nl.