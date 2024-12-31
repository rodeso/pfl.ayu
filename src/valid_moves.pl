:- use_module(library(lists)).

% valid_moves(+GameState, -ListOfMoves)
% Returns a list of all possible valid moves for the current player in the given game state.
valid_moves([Board, CurrentPlayer, _], ListOfMoves) :-
    % Find all the player's pieces (both singletons and groups)
    findall((X, Y), piece_at(Board, X, Y, CurrentPlayer), PlayerPieces),

    % Manually separate singletons and groups
    separate_singletons_and_groups(Board, CurrentPlayer, PlayerPieces, [], [], Singletons, Groups),  % This is the corrected call

    % Generate all valid moves for singletons and groups
    findall(move(FromX, FromY, ToX, ToY), (
        % Singleton moves
        member((FromX, FromY), Singletons),
        adjacent_empty_point(Board, FromX, FromY, ToX, ToY),
        valid_move([Board, CurrentPlayer, _], move(FromX, FromY, ToX, ToY))
    ), SingletonMoves),

    findall(move(FromX, FromY, ToX, ToY), (
        % Group moves
        member((FromX, FromY), Groups),
        adjacent_empty_point(Board, FromX, FromY, ToX, ToY),
        group_move_is_valid(Board, FromX, FromY, ToX, ToY, CurrentPlayer),
        valid_move([Board, CurrentPlayer, _], move(FromX, FromY, ToX, ToY))
    ), GroupMoves),

    % Combine the moves
    append(SingletonMoves, GroupMoves, ListOfMoves).

% separate_singletons_and_groups(+Board, +Player, +PlayerPieces, +SingletonsAcc, +GroupsAcc, -Singletons, -Groups)
% Manually separate singletons and groups based on adjacency.
separate_singletons_and_groups(_, _, [], SingletonsAcc, GroupsAcc, SingletonsAcc, GroupsAcc).  % Base case: all pieces processed
separate_singletons_and_groups(Board, Player, [(X, Y) | Rest], SingletonsAcc, GroupsAcc, Singletons, Groups) :-
    (is_singleton(Board, Player, (X, Y)) ->
        % If it's a singleton, add to the Singletons list
        separate_singletons_and_groups(Board, Player, Rest, [(X, Y) | SingletonsAcc], GroupsAcc, Singletons, Groups)
    ;
        % Otherwise, add to the Groups list
        separate_singletons_and_groups(Board, Player, Rest, SingletonsAcc, [(X, Y) | GroupsAcc], Singletons, Groups)
    ).

% is_singleton(+Board, +Player, +(X, Y))
% Returns true if the piece at (X, Y) is a singleton (i.e., no adjacent like-colored pieces).
is_singleton(Board, Player, (X, Y)) :-
    % Check if all adjacent positions are either empty or occupied by the opponent
    findall((AdjX, AdjY), adjacent(AdjX, AdjY, X, Y), AdjacentPositions),
    check_all_adjacent(Board, Player, AdjacentPositions).

% check_all_adjacent(+Board, +Player, +AdjacentPositions)
% Helper predicate to check all adjacent positions for emptiness or being occupied by the opponent.
check_all_adjacent(_, _, []).
check_all_adjacent(Board, Player, [(AdjX, AdjY) | Rest]) :-
    (empty_at(Board, AdjX, AdjY) ; \+ piece_at(Board, AdjX, AdjY, Player)),
    check_all_adjacent(Board, Player, Rest).

% adjacent_empty_point(+Board, +X, +Y, -ToX, -ToY)
% Finds adjacent empty points around (X, Y)
adjacent_empty_point(Board, X, Y, ToX, ToY) :-
    adjacent(ToX, ToY, X, Y),
    empty_at(Board, ToX, ToY).

% adjacent(+ToX, +ToY, +X, +Y)
% Returns orthogonally adjacent positions.
adjacent(X1, Y, X, Y) :- X1 is X + 1.
adjacent(X1, Y, X, Y) :- X1 is X - 1.
adjacent(X, Y1, X, Y) :- Y1 is Y + 1.
adjacent(X, Y1, X, Y) :- Y1 is Y - 1.

% group_move_is_valid(+Board, +FromX, +FromY, +ToX, +ToY, +Player)
% Checks if moving a piece from a group is valid (doesn't split the group).
group_move_is_valid(Board, FromX, FromY, ToX, ToY, Player) :-
    % Ensure group stays connected
    group_remains_connected(Board, FromX, FromY, ToX, ToY, Player).

% update_board(+Board, +FromX, +FromY, +ToX, +ToY, +Player, -TempBoard)
% Updates the board by moving a piece from (FromX, FromY) to (ToX, ToY).
update_board(Board, FromX, FromY, ToX, ToY, Player, TempBoard) :-
    % Remove the piece from the source position
    replace_piece(Board, FromX, FromY, empty, TempBoard1),
    % Get the player's piece symbol (x for Player 1, o for Player 2)
    piece_player(Player, Piece),
    % Place the piece at the destination position
    replace_piece(TempBoard1, ToX, ToY, Piece, TempBoard).


% group_remains_connected(+Board, +FromX, +FromY, +ToX, +ToY, +Player)
% Ensures that moving a piece from a group doesn't disconnect it.
group_remains_connected(Board, FromX, FromY, ToX, ToY, Player) :-
    % Temporarily move the piece on the board
    update_board(Board, FromX, FromY, ToX, ToY, Player, TempBoard),
    % Check if all groups remain connected after the move
    all_groups_connected(TempBoard, Player).

% all_groups_connected(+Board, +Player)
% Ensures all pieces of a player are part of a single connected group.
all_groups_connected(Board, Player) :-
    findall((X, Y), piece_at(Board, X, Y, Player), Pieces),
    Pieces = [(StartX, StartY) | _],
    flood_fill(Board, StartX, StartY, Player, [Visited]),
    length(Pieces, TotalPieces),
    length(Visited, TotalVisited),
    TotalPieces =:= TotalVisited.

% flood_fill(+Board, +X, +Y, +Player, -Visited)
% Flood fill algorithm to find all connected pieces of the player starting from (X, Y).
flood_fill(Board, X, Y, Player, Visited) :-
    flood_fill(Board, X, Y, Player, [], Visited).

flood_fill(_, X, Y, _, Visited, Visited) :-
    member((X, Y), Visited),  % Already visited this position
    !.

flood_fill(Board, X, Y, Player, Acc, Visited) :-
    piece_at(Board, X, Y, Player),  % Ensure the position belongs to the player
    \+ member((X, Y), Acc),         % Ensure this position hasn't been visited yet
    NewAcc = [(X, Y) | Acc],        % Add this position to the visited list
    % Generate adjacent positions
    AdjX1 is X - 1, AdjX2 is X + 1,
    AdjY1 is Y - 1, AdjY2 is Y + 1,
    Adjacent = [(AdjX1, Y), (AdjX2, Y), (X, AdjY1), (X, AdjY2)],
    % Filter valid positions within the board bounds
    include(valid_position(Board), Adjacent, ValidAdjacent),
    maplist(flood_fill(Board, _, Player), ValidAdjacent, NewAcc, Visited).

% Check if a position is valid within the board dimensions
valid_position(Board, (X, Y)) :-
    X > 0, Y > 0, nth1(Y, Board, Row), nth1(X, Row, _).
