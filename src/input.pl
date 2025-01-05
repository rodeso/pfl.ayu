% between(+Min, +Max, +Value)
% Check if the value is between two numbers
between(Min, Max, Min):- Min =< Max.
between(Min, Max, Value):-
    Min < Max,
    NextMin is Min + 1,
    between(NextMin, Max, Value).

% receive_number(-X, +Acc)
% Receive the number
receive_number(X, Acc):- 
    get_code(C),
    between(48, 57, C), !,
    Acc1 is 10 * Acc + (C - 48),
    receive_number(X, Acc1).
receive_number(X, X).

% get_number(+Min, +Max, +Context, -Value)
% Get the input and make sure that it is between two numbers
get_number(Min, Max, Context, Value):-
    write(Context), write(' between '), write(Min), write(' and '), write(Max), write(': '),
    repeat,
    receive_number(Value, 0),
    between(Min, Max, Value), !.

% get_size(+List, +Context, -Value)
% Get the input and make sure that it is member of a especific list
get_size(List, Context, Value):-
    write(Context), write(': '),
    repeat,
    receive_number(Value, 0),
    member(Value, List), !.

% type_game(+T)
% Get the type of game
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

% get_type_game(-T)
% Get type of game that will be played
get_type_game(T):-
    write('Type of game: '), nl,
    write('1 - Human vs Human'), nl,
    write('2 - Human vs Computer'), nl,
    write('3 - Computer vs Computer'), nl,
    get_number(1, 3, 'Type of game', D),
    type_game_bots(D, T),
    type_game(T).

% type_game_bots(+D, -T)
% Get type of game from input
type_game_bots(2, T):-
    get_bot_difficulty(T), !.
type_game_bots(3, T):-
    get_bots_difficulty(T), !.
type_game_bots(D, T):-
    T is D, !.

% get_bot_difficulty(-T)
% Get bot difficulty
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

% get_bots2_type(+Difficulty1, +Difficulty2, -T)
% Get bot type
get_bots2_type(1, 1, T):-
    T is 3.
get_bots2_type(1, 2, T):-
    T is 5.
get_bots2_type(2, 1, T):-
    T is 5.
get_bots2_type(2, 2, T):-
    T is 6.

% read_line(-L)
% Read a line of input as an atom in SICStus
read_line_as_atom(Atom) :-
    read_line(Input),         % Read the line as a list of ASCII codes
    atom_codes(Atom, Input).  % Convert the list of codes to an atom

% get_player_names(+T, -Names)
% Get player names based on game type
get_player_names(1, [Name1, Name2]) :-  % Human vs Human
    write('Enter name for Player 1: '), read_line_as_atom(Name1), nl,
    write('Enter name for Player 2: '), read_line_as_atom(Name2), nl.
get_player_names(2, [Name, 'Computer (Easy)']) :-  % Human vs Easy Computer
    write('Enter name for Player 1: '), read_line_as_atom(Name), nl.
get_player_names(4, [Name, 'Computer (Hard)']) :-  % Human vs Hard Computer
    write('Enter name for Player 1: '), read_line_as_atom(Name), nl.
get_player_names(3, ['Computer 1 (Easy)', 'Computer 2 (Easy)']).  % Easy vs Easy
get_player_names(5, ['Computer 1 (Easy)', 'Computer 2 (Hard)']).  % Easy vs Hard
get_player_names(6, ['Computer 1 (Hard)', 'Computer 2 (Hard)']).  % Hard vs Hard

% get_size_game(-S)
% Get size of the board
get_size_game(S):-
    write('Size of board: 5, 11, 13, 15'), nl,
    get_size([5, 11, 13, 15], 'Input', S).

% get_player_starts(+T, -P)
% Get the player that will start
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

% get_place(-X, -Y)
% Get place to add or remove piece
get_take_piece(S, X, Y):-
    get_number(1, S, 'X cordenate:', X), nl,
    get_number(1, S, 'Y cordenate:', Y), nl.

% get_board_type(-BoardType)
% Get board type (Style 1 or 2)
get_board_type(BoardType):-
    write('Which Board style do you prefer? (1 or 2)'), nl, nl,
    board_styles(3, B),
    write('Style 1: '), nl,
    display_board(B), nl, nl,
    write('Style 2: '), nl,
    display_board_2(B), nl, nl,
    get_size([1, 2], 'Board', BoardType).