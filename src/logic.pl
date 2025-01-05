% File general game logic functions
:- consult(move).              % Functions to move a piece

    

% value(+GameState, +Player, -Value)
% Predicate to evaluate the value of a game state for a given player
value([Board, CurrentPlayer, _, Names, BoardType], Player, Value) :-
    switch_player(Player, Opponent),                % Get the opponent player
    valid_moves_final([Board, Opponent, _, Names, BoardType], OpponentMoves), % Get valid moves for the opponent
    length(OpponentMoves, OpponentMoveCount),       % Count opponent moves
    Value is OpponentMoveCount.            % Calculate the value

% -----------------------------------------------------

% choose_move(+GameState, +Level, -Move)
%  This predicate receives the current game state and returns the move chosen by the computer player. 
    % Level 1 should return a random valid move. 
    % Level 2 should return the best play at the time (using a greedy algorithm), considering the evaluation of the game state as determined by the value/3 predicate. 
    % For human players, it should interact with the user to read the move.

% Move for a human player
choose_move([Board, CurrentPlayer, _, Names, BoardType], 0, move(FromX, FromY, ToX, ToY)) :-
    length(Board, S),

    repeat,

    display_game([Board, CurrentPlayer, _, Names, BoardType]), nl, nl,

    write('Enter the coordinates of the piece you want to move (X Y):'), nl, nl,
    get_take_piece(S, FromX, FromYProv),

    write('Enter the coordinates of the destination (X Y):'), nl, nl,
    get_take_piece(S, ToX, ToYProv),

    FromY is S-FromYProv+1, 
    ToY is S-ToYProv+1,

    valid_move_final([Board, CurrentPlayer, _, Names, BoardType], move(FromX, FromY, ToX, ToY)), !.

%  Move for Easy Computer - Level 1
choose_move([Board, CurrentPlayer, _, Names, BoardType], 1, Move):- 
    length(Board, S),
    repeat,
    display_game([Board, CurrentPlayer, _, Names, BoardType]), nl, nl,
    write('The Computer is Thinking...'), nl, nl,
    valid_moves_final([Board, CurrentPlayer, _, Names, BoardType], ListOfMoves),
    random_member(Move, ListOfMoves), !,
    write_move(Move, S).


%  Move for Hard Computer - Level 2
choose_move([Board, CurrentPlayer, _, Names, BoardType], 2, Move) :-
    length(Board, S),
    display_game([Board, CurrentPlayer, _, Names, BoardType]), nl, nl,
    write('The Computer is Thinking...'), nl,
    valid_moves_final([Board, CurrentPlayer, _, Names, BoardType], ListOfMoves), % Get the list of moves
    write('Got moves'), nl,
    evaluate_moves_with_cutoff([Board, CurrentPlayer, _, Names, BoardType], ListOfMoves, S, EvaluatedMoves),
    % Select the move with the highest value from the evaluated moves
    EvaluatedMoves = [BestMove | _],
    write_move(BestMove, S),
    BestMove = Move.

% -----------------------------------------------------
% Logic for evaluating moves with cutoff - Hard Computer (Level 2)

% evaluate_moves_with_cutoff(+GameState, +Moves, +S, -OrderedMoves)
% Evaluate moves with cutoff logic
evaluate_moves_with_cutoff(GameState, [FirstMove | RemainingMoves], S, OrderedMoves) :-
    move(GameState, FirstMove, TempGameState),           % Simulate the first move
    value(TempGameState, CurrentPlayer, Value),          % Evaluate the first move
    get_cutoff_from_size(S, Cutoff),                     % Get the cutoff value based on the board size
    get_limit(Value, S, Limit),                      % Get the limit based on the value
    (Value >= Cutoff ->
        % Evaluate only 8 more moves if the first move exceeds the cutoff
        collect_and_evaluate_limited_moves(GameState, [FirstMove | RemainingMoves], Limit, EvaluatedMoves)
    ;
        % Evaluate all moves if the first move is below the cutoff
        write('CutOff not reached'), nl,
        collect_and_evaluate_limited_moves(GameState, [FirstMove | RemainingMoves], inf, EvaluatedMoves)
    ),
    order_moves_by_value(EvaluatedMoves, OrderedMoves).   % Order the moves by value

% collect_and_evaluate_limited_moves(+GameState, +Moves, +Limit, -EvaluatedMoves)
% Collect and evaluate a limited number of moves
collect_and_evaluate_limited_moves(GameState, Moves, Limit, EvaluatedMoves) :-
    (Limit == inf ->
        % Evaluate all moves if no limit
        findall(Value-Move, (
            member(Move, Moves),
            move(GameState, Move, TempGameState),
            value(TempGameState, CurrentPlayer, Value)
        ), EvaluatedMoves)
    ;
        % Evaluate only the first `Limit` moves
        length(LimitedMoves, Limit),
        append(LimitedMoves, _, Moves),
        findall(Value-Move, (
            member(Move, LimitedMoves),
            move(GameState, Move, TempGameState),
            write('Evaluating moves ...'), nl,
            value(TempGameState, CurrentPlayer, Value)
        ), EvaluatedMoves)
    ).

% order_moves_by_value(+EvaluatedMoves, -OrderedMoves)\
% Order moves by value (descending)
order_moves_by_value(EvaluatedMoves, OrderedMoves) :-
    % Negate values for descending order
    findall(NegValue-Move, (member(Value-Move, EvaluatedMoves), NegValue is -Value), NegatedMoves),
    % Use keysort to sort by negated values (ascending order of negatives = descending order of original values)
    keysort(NegatedMoves, SortedNegatedMoves),
    % Restore original values
    findall(Move, member(_-Move, SortedNegatedMoves), OrderedMoves).

% get_cutoff_from_size(+S, -Cutoff)
% Variable CutOff
get_cutoff_from_size(5, 15).
get_cutoff_from_size(11, 12).
get_cutoff_from_size(13, 10).
get_cutoff_from_size(15, 8).

% get_limit(+Value, +S, -Limit)
% Get the limit based on the value
get_limit(Value, S, Limit) :-
    TempLimit is Value // S // 3,  % Perform the initial calculation
    (TempLimit < 1 -> Limit = 1; Limit = TempLimit), % Ensure the limit is at least 1
    write('Value: '), write(Value), 
    write(' S: '), write(S), 
    write(' Limit: '), write(Limit), nl.


% -----------------------------------------------------

% write_move(+Move, +S)
% Write the move the bot made
write_move(move(FromX, FromY, ToX, ToY), S) :-
    NewFromY is S-FromY+1,
    NewToY is S-ToY+1,
    write('Moved piece from '), write(FromX), write(', '), write(NewFromY), write(' to '), write(ToX), write(', '), write(NewToY), nl.
