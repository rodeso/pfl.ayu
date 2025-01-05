% valid_move(+GameState, +Move)
% Ensure that the move for an isolated piece is exactly 1 square away
valid_move([Board, CurrentPlayer, T, Names, BoardType], move(FromX, FromY, ToX, ToY)):-

    (piece_at(Board, FromX, FromY, CurrentPlayer) ->
        true;
        fail),

    (empty_at(Board, ToX, ToY) ->
        true;
        fail),
    
    move([Board, CurrentPlayer, T, Names, BoardType], move(FromX, FromY, ToX, ToY), TempGameState),
    get_board(TempGameState, TempBoard),
    
    list_cluster_elements(Board, CurrentPlayer, Count, Elements),
    find_cluster_with_element(Elements, FromX, FromY, Cluster),
    length(Cluster, ClusterSize),
    length(Count, NumberClustersNoChange),

    list_cluster_elements(TempBoard, CurrentPlayer, CountTemp, ElementsTemp),
    find_cluster_with_element(ElementsTemp, ToX, ToY, ClusterTemp),
    length(ClusterTemp, ClusterSizeTemp),
    length(CountTemp, NumberClustersChange),  

    remove_element(FromX-FromY, Cluster, ClusterMenos),
    
    (all_elements(ClusterMenos, ClusterTemp) ->
        true;
        fail),

    shortest_paths_between_clusters(Board, FromX, FromY, Elements, AllShortestPaths), % X-Y
    filter_minimum_distance_paths(AllShortestPaths, FilteredPaths),

    (path_includes_point([FilteredPaths], ToY, ToX) ->
        true;
        fail
    ),

    (ClusterSize =< ClusterSizeTemp -> 
        true;
        fail),
    
    (NumberClustersChange =< NumberClustersNoChange ->
        true;
        fail),
    
    (ClusterSize == 1 -> 
        (valid_one_move(FromX, FromY, ToX, ToY) ->
            true
        ; 
            fail 
        );
        true
    ),

    find_piece_cluster_with_spaces(Board, FromY-FromX, ClusterWithSpaces, EspaceCount), %Y-X
    length(ClusterWithSpaces, EspaceTotalCount),
    Dif is EspaceTotalCount - EspaceCount,

    ( Dif == ClusterSize -> 
        fail;
        true ).

% ------------------------------------------------------------------------------------------------
    
% valid_moves(+GameState, -ListOfMoves)
% Generates a list of all possible valid moves for the CurrentPlayer on the Board
valid_moves([Board, CurrentPlayer, T, Names, BoardType], UniqueListOfMoves) :-
    length(Board, Size),
    findall(move(FromX, FromY, ToX, ToY),
        (
            between(1, Size, FromX),
            between(1, Size, FromY),
            piece_at(Board, FromX, FromY, CurrentPlayer),
            between(1, Size, ToX),
            between(1, Size, ToY),
            (FromX \= ToX; FromY \= ToY),
            empty_at(Board, ToX, ToY),
            valid_move([Board, CurrentPlayer, T, Names, BoardType], move(FromX, FromY, ToX, ToY))
        ),
        ListOfMoves),
    sort(ListOfMoves, UniqueListOfMoves).

% ------------------------------------------------------------------------------------------------

% valid_moves_bool(+GameState)
% Returns true if there is at least one valid move for the CurrentPlayer on the Board
% Used to check if the game is over
valid_moves_bool([Board, CurrentPlayer, T, Names, BoardType]) :-
    length(Board, Size),
    between(1, Size, FromX),
    between(1, Size, FromY),
    piece_at(Board, FromX, FromY, CurrentPlayer),
    between(1, Size, ToX),
    between(1, Size, ToY),
    (FromX \= ToX; FromY \= ToY),
    empty_at(Board, ToX, ToY),
    valid_move([Board, CurrentPlayer, T, Names, BoardType], move(FromX, FromY, ToX, ToY)), !.
