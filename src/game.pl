:- consult(board). % Functions to create and display the board
:- consult(input). % Functions to receive all the inputs

% GameState = [Board, CurrentPlayer,..] - ir escrevendo aqui para sabermos 

% Recebe as coordenadas XT e YT for the pice to take out e as coordenadas XI e YI for were to insert the pice
choose_move(S, XT, YT, XI, YI):- % mudar para choose_move(+GameState, +Level, -Move) (ver descrição do prof)
    write('Take piece from'), nl,
    get_take_piece(S, XT, YT), nl,
    % Validar se é uma peça do current player, se n mensagem de erro e voltar a pedir
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
game_loop(GameState):-
    % TODO basicamente o geral de uma rodada
    % Tirar uma peça e por noutro spot
    display_game(B), % display - TODO mudar a função display_game para como os profs querem
    choose_move(S, XT, YT, XI, YI), % neste momento esta função apenas retorna a peça a tirar e a peça a por
    % TODO move -> The actual move
    % TODO troca o player para o proximo
    game_loop(NewGameState). % recursão - mandar o NewGameState que é o GameState inicial mas adaptado

set_up(T, S, B):-
    get_type_game(T), nl,
    get_size_game(S), nl,
    board(S, B),             % Creates the board
    display_game(B), nl.     % Displays created board

% Main
% T -> type of game being played (1-H/H, 2-H/C, 3-C/C)
% S -> size of the board (5, 11, 13 or 15)
play:-
    % TODO - initial_state(+GameConfig, -GameState).
    set_up(T, S, B)
    % TODO - chamar o game_loop - só quando as varias partes estiverem prontas
    .
