:- consult(board). % Functions to create and display the board
:- consult(input). % Functions to receive all the inputs

% GameState = [Board, CurrentPlayer,..] - ir escrevendo aqui para sabermos 

% Recebe as coordenadas XT e YT for the pice to take out e as coordenadas XI e YI for were to insert the pice
choose_move(B, S, XT, YT, XI, YI, CurrentPlayer):- % mudar para choose_move(+GameState, +Level, -Move) (ver descrição do prof)
    write('Take piece from'), nl,
    get_take_piece(S, XT, YT), nl,
    % Validar se é uma peça do current player, se n mensagem de erro e voltar a pedir
    check_piece(B, S, XT, YT, CurrentPlayer),
    write('Add piece to:'), nl,
    get_take_piece(S, XI, YI), nl
    % Validar se n existe nenhuma peça neste spot e validar que é uma valid move para o current player
    .

% Main game loop - recursive
%game_loop:-
    % TODO game_over(+GameState, -Winner) - se der gameover ent print do winner e termina o jogo, se n vai para o outro game_loop
    % game_over(+GameState, -Winner), !,
    % display_game(+GameState),
    % show_winner(+GameState, +Winner).
% Game Loop
game_loop(game_state(T, S, B)):-
    % Display the board
    display_game(B), nl,

    % Check for type of game / if someone won
    % Check if the game is over
    (T = -1 -> write('Player 1 won!'), nl;
     T = -2 -> write('Player 2 won!'), nl;
     T = -3 -> write('Computer 1 won!'), nl;
     T = -4 -> write('Computer 2 won!'), nl;
     % Otherwise, process the turn
     (T = 1 -> 
         write('Player 1\'s' turn'), nl,
         choose_move(B, S, XT, YT, XI, YI, x), nl,
         write('Player 2\'s turn'), nl,
         choose_move(B, S, XT, YT, XI, YI, o), nl;
      T = 2 -> 
         write('Player\'s turn'), nl,
         choose_move(B, S, XT, YT, XI, YI, o), nl;
      T = 3 ->
         write('Computer 1\'s turn'), nl,
         choose_move(B, S, XT, YT, XI, YI, x), nl,
         write('Computer 2\'s turn'), nl,
         choose_move(B, S, XT, YT, XI, YI), nl), 
     
     % Update the game state
     check_gameover(B, T, NewT),
     NewGameState = game_state(B, NewT),

     % Recursive call
     game_loop(NewGameState)
    ).

% Placeholder for check_gameover/3
check_gameover(B, T, NewT):-
    % Logic to determine if the game is over
    % Update NewT accordingly (-1, -2, or continue with 1, 2, 3)
    NewT = -1.

set_up(T, S, B):-
    get_type_game(T), nl,
    get_size_game(S), nl,
    board(S, B).             % Creates the board

% Main
% T -> type of game being played (1-H/H, 2-H/C, 3-C/C)
% S -> size of the board (5, 11, 13 or 15)
% Main Function
play:-
    % Set up the game
    set_up(T, S, B),

    % Initialize the game state
    GameState = game_state(T, S, B),

    % Start the game loop
    game_loop(GameState).
