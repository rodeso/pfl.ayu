% File general game logic functions
:- consult(move).              % Functions to move a piece

    
%  This predicate receives the current game state and returns the move chosen by the computer player. 
    % Level 1 should return a random valid move. 
    % Level 2 should return the best play at the time (using a greedy algorithm), considering the evaluation of the game state as determined by the value/3 predicate. 
    % For human players, it should interact with the user to read the move.
% choose_move(+GameState, +Level, -Move)
% OBRIGATORIO
% Predicate to choose a move for a human player
choose_move([Board, CurrentPlayer, _], 0, move(FromX, FromY, ToX, ToY)) :-
    length(Board, S),

    repeat,

    display_game([Board, CurrentPlayer, _]), nl, nl,

    write('Enter the coordinates of the piece you want to move (X Y):'), nl, nl,
    get_take_piece(S, FromX, FromYProv),

    write('Enter the coordinates of the destination (X Y):'), nl, nl,
    get_take_piece(S, ToX, ToYProv),

    FromY is S-FromYProv+1, 
    ToY is S-ToYProv+1,

    valid_move_final([Board, CurrentPlayer, _], move(FromX, FromY, ToX, ToY)), 
    !.
% Easy Computer
choose_move([Board, CurrentPlayer, _], 1, Move):- 
    length(Board, S),
    repeat,
    display_game([Board, CurrentPlayer, _]), nl, nl,
    nl, write('The Computer is Thinking...'), nl, nl,
    valid_moves_final([Board, CurrentPlayer, _], ListOfMoves),
    random_member(Move, ListOfMoves),
    !.

% Hard Computer
choose_move([Board, CurrentPlayer, _], 2, Move):-
    length(Board, S),
    repeat,
    display_game([Board, CurrentPlayer, _]), nl, nl,
    nl, write('The Computer is Thinking...'), nl, nl,
    valid_moves_final([Board, CurrentPlayer, _], ListOfMoves), % Get the list of moves
    hard_bot([Board, CurrentPlayer, _], ListOfMoves, ListOfBestMoves),
    random_member(Move, ListOfBestMoves),
    !.

% Go through all the moves (ListOfMoves) possible boards
    % see valid_moves para o oponente
    % selecionar apenas os que tem o maior numero de moves para o oponente
% hard_bot(GameState, ListOfMoves, ListOfBestMoves)
% This function evaluates all possible moves for the current player and chooses the ones that minimize the opponent's valid moves.
hard_bot([Board, CurrentPlayer, _], ListOfMoves, ListOfBestMoves) :-
    % Get the opponent player
    switch_player(CurrentPlayer, Opponent),
    
    % Evaluate each move in ListOfMoves, generating a score based on the number of valid moves the opponent has
    findall(Score-Move, (
        member(Move, ListOfMoves),                                 % For each move
        move([Board, CurrentPlayer, _], Move, TempGameState),      % Simulate the move
        change_player(TempGameState, OpponentGameState),
        valid_moves_final(OpponentGameState, OpponentMoves),           % Find valid moves for the opponent on the new board
        length(OpponentMoves, Score)                               % The score is the number of opponent moves (fewer is better)
    ), ScoredMoves),

    % Find the minimum score
    min_score_moves(ScoredMoves, MinScore, ListOfBestMoves),
    !.

% min_score_moves(ScoredMoves, MinScore, BestMoves)
% This helper function finds the moves with the minimum score from the list of scored moves.
min_score_moves(ScoredMoves, MinScore, BestMoves) :-
    % Find the minimum score
    min_member(MinScore-_, ScoredMoves),

    % Collect all moves with this minimum score
    findall(Move, member(MinScore-Move, ScoredMoves), BestMoves).



