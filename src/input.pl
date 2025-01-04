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

% Get the type of game
% type_game(+T)
type_game(1):- % players 1 & 2
    nl, 
    write('Chosen game: Human vs Human'), nl.
type_game(2):- % players 1 & bot
    nl,
    write('Chosen game: Human vs Easy Computer'), nl.
type_game(3):- % bot & bot
    nl,
    write('Chosen game: Easy Computer vs Easy Computer'), nl.
type_game(4):- % players 1 & bot
    nl,
    write('Chosen game: Human vs Hard Computer'), nl.
type_game(5):- % bot & bot
    nl,
    write('Chosen game: Easy Computer vs Hard Computer'), nl.
type_game(6):- % bot & bot
    nl,
    write('Chosen game: Hard Computer vs Hard Computer'), nl.

% Get type of game that will be played
% get_type_game(-T)
get_type_game(T):-
    write('Type of game: '), nl,
    write('1 - Human vs Human'), nl,
    write('2 - Human vs Computer'), nl,
    write('3 - Computer vs Computer'), nl,
    get_number(1, 3, 'Type of game', D),
    type_game_bots(D, T),
    type_game(T).

% Get type of game from input
% type_game_bots(+D, -T)
type_game_bots(2, T):-
    get_bot_difficulty(T), !.
type_game_bots(3, T):-
    get_bots_difficulty(T), !.
type_game_bots(D, T):-
    T is D, !.

% Get bot difficulty
% get_bot_difficulty(-T)
get_bot_difficulty(T):-
    write('Bot Opponent difficulty: '), nl,
    write('1 - Easy'), nl,
    write('2 - Hard'), nl,
    get_number(1, 2, 'Bot difficulty', Difficulty),
    T is 2 * Difficulty.
get_bots_difficulty(T):-
    write('Bot 1 difficulty: '), nl,
    write('1 - Easy'), nl,
    write('2 - Hard'), nl,
    get_number(1, 2, 'Bot 1 difficulty', Difficulty1),
    write('Bot 2 difficulty: '), nl,
    write('1 - Easy'), nl,
    write('2 - Hard'), nl,
    get_number(1, 2, 'Bot 2 difficulty', Difficulty2),
    get_bots2_type(Difficulty1, Difficulty2, T).

% Get bot type
% get_bots2_type(+Difficulty1, +Difficulty2, -T)
get_bots2_type(1, 1, T):-
    T is 3.
get_bots2_type(1, 2, T):-
    T is 5.
get_bots2_type(2, 1, T):-
    T is 5.
get_bots2_type(2, 2, T):-
    T is 6.


% Get size of the board
% get_size_game(-S)
get_size_game(S):-
    write('Size of board: 5, 11, 13, 15'), nl,
    get_size([5, 11, 13, 15], 'Input', S).

% Get the player that will start
% get_player_starts(+T, -P)
get_player_starts(1, P):-
    write('Which Player starts the game? (1 or 2)'), nl,
    get_size([1, 2], 'Player', P), !.
get_player_starts(2, P):-
    write('Who starts first? (1 - Human, 2 - Computer)'), nl,
    get_size([1, 2], 'Starter', P), !.
get_player_starts(4, P):-
    write('Who starts first? (1 - Human, 2 - Computer)'), nl,
    get_size([1, 2], 'Starter', P), !.
get_player_starts(5, P):-
    write('Who starts first? (1 - Easy Computer, 2 - Hard Computer)'), nl,
    get_size([1, 2], 'Starter', P), !.
get_player_starts(_, P):-
    P is 1, !.

% Get place to add or remove piece
% get_place(-X, -Y)
get_take_piece(S, X, Y):-
    get_number(1, S, 'X cordenate:', X), nl,
    get_number(1, S, 'Y cordenate:', Y), nl.