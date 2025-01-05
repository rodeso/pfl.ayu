% File general game logic functions
:- consult(move).              % Functions to move a piece

    
%  This predicate receives the current game state and returns the move chosen by the computer player. 
    % Level 1 should return a random valid move. 
    % Level 2 should return the best play at the time (using a greedy algorithm), considering the evaluation of the game state as determined by the value/3 predicate. 
    % For human players, it should interact with the user to read the move.



% value(+GameState, +Player, -Value)
% OBRIGATORIO
% Predicate to evaluate the value of a game state for a given player
value([Board, CurrentPlayer, _], Player, Value) :-
    switch_player(Player, Opponent),                % Get the opponent player
    valid_moves_final([Board, Opponent, _], OpponentMoves), % Get valid moves for the opponent
    length(OpponentMoves, OpponentMoveCount),       % Count opponent moves
    Value is OpponentMoveCount.            % Calculate the value


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

    valid_move_final([Board, CurrentPlayer, _], move(FromX, FromY, ToX, ToY)), !.

% Easy Computer - Level 1
choose_move([Board, CurrentPlayer, _], 1, Move):- 
    length(Board, S),
    repeat,
    display_game([Board, CurrentPlayer, _]), nl, nl,
    nl, write('The Computer is Thinking...'), nl, nl,
    valid_moves_final([Board, CurrentPlayer, _], ListOfMoves),
    random_member(Move, ListOfMoves), !,
    write_move(Move, S).

% Hard Computer - Level 2
choose_move([Board, CurrentPlayer, _], 2, Move) :-
    length(Board, S),
    display_game([Board, CurrentPlayer, _]), nl, nl,
    nl, write('The Computer is Thinking...'), nl, nl,
    valid_moves_final([Board, CurrentPlayer, _], ListOfMoves), % Get the list of moves
    evaluate_moves([Board, CurrentPlayer, _], ListOfMoves, Move, S), !.

% Evaluate moves and apply cutoff for early exit
evaluate_moves(GameState, [Move | Moves], BestMove, S) :-
    move(GameState, Move, TempGameState),        % Simulate the move
    value(TempGameState, CurrentPlayer, Value),  % Evaluate the move
    Cutoff is 12,                                % Define the cutoff
    nl, write('Evaluating move: '), write(Move), write(' -> Value: '), write(Value), nl,
    (Value > Cutoff ->
        nl, write('Great move found, executing immediately: '), write(Move), nl,
        BestMove = Move                          % Early exit if the move is great
    ;
        evaluate_moves(GameState, Moves, BestMove, S) % Otherwise, keep looking
    ).
evaluate_moves(_, [], BestMove, S) :- 
    nl, write('No move exceeded cutoff, choosing the best available.'), nl,
    fail. % This ensures we fall back to the max score logic if needed

% Finds the moves with the maximum score
max_score_moves(ScoredMoves, MaxValue, BestMoves) :-
    % Find the maximum value
    max_member(MaxValue-_, ScoredMoves),
    % Collect all moves with this maximum value
    findall(Move, member(MaxValue-Move, ScoredMoves), BestMoves).

% write the move
write_move(move(FromX, FromY, ToX, ToY), S) :-
    NewFromY is S-FromY+1,
    NewToY is S-ToY+1,
    write('Moved piece from '), write(FromX), write(', '), write(NewFromY), write(' to '), write(ToX), write(', '), write(NewToY), nl.
