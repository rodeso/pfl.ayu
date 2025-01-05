% valid_move(+GameState, +Move)
% Ensure that the move for an isolated piece is exactly 1 square away
valid_move([Board, CurrentPlayer, T, Names, BoardType], move(FromX, FromY, ToX, ToY)):-

    % Validate the source position
    (piece_at(Board, FromX, FromY, CurrentPlayer) ->
        true;
        write('Error: Source position is invalid.'), nl, nl, fail),

    % Validate the destination position
    (empty_at(Board, ToX, ToY) ->
        true;
        write('Error: Destination position is not empty.'), nl, nl, fail),


    move([Board, CurrentPlayer, T, Names, BoardType], move(FromX, FromY, ToX, ToY), TempGameState), % Do the move in the temp board
    get_board(TempGameState, TempBoard),

    list_cluster_elements(Board, CurrentPlayer, Count, Elements),                % Find all the clusters
    find_cluster_with_element(Elements, FromX, FromY, Cluster),                   % Find the cluster that contains the piece
    length(Cluster, ClusterSize),                                                 % Size of the cluster before the move
    length(Count, NumberClustersNoChange),                                        % Number of clusters before the move

    list_cluster_elements(TempBoard, CurrentPlayer, CountTemp, ElementsTemp),    % Find all the clusters WITH the change
    find_cluster_with_element(ElementsTemp, ToX, ToY, ClusterTemp),               % Find the cluster that contains the piece WITH the change
    length(ClusterTemp, ClusterSizeTemp),                                         % Size of the cluster after the move
    length(CountTemp, NumberClustersChange),                                      % Number of clusters after the move

    remove_element(FromX-FromY, Cluster, ClusterMenos), % Remove the element from the cluster
    
    % Ensure that all the elements from the initial cluster are in the changed cluster (except the position we are changing)
    (all_elements(ClusterMenos, ClusterTemp) ->
        true;
        write('Error: You can not separate clusters.'), nl, nl, fail),

    shortest_paths_between_clusters(Board, FromX, FromY, Elements, AllShortestPaths), % X-Y
    filter_minimum_distance_paths(AllShortestPaths, FilteredPaths),

    (path_includes_point([FilteredPaths], ToY, ToX) ->
        true;
        write('Error: You can not move to a not optimal path.'), nl, nl, fail
    ),

    % Ensure that after the move the cluster it takes part does not decrease in size
    (ClusterSize =< ClusterSizeTemp -> 
        true;
        write('Error: Clusters can never decrease size.'), nl, nl, fail),

    % Ensure after that the list of clusters is smaller or the same size
    (NumberClustersChange =< NumberClustersNoChange -> % AUMENTA O NUMERO DE ALGOMERADOS É PROIBIDO
        true;
        write('Error: This move separates a cluster.'), nl, nl, fail),
    

    (ClusterSize == 1 -> % Isolated piece can only move 1 distance spot (no diagonals)
        (valid_one_move(FromX, FromY, ToX, ToY) ->
            true
        ; 
            write('Error: Isolated elements can only move 1 spot.'), nl, nl, fail 
        );
        true
    ),

    find_piece_cluster_with_spaces(Board, FromY-FromX, ClusterWithSpaces, EspaceCount), %Y-X
    length(ClusterWithSpaces, EspaceTotalCount),
    Dif is EspaceTotalCount - EspaceCount,

    % If  dif is the same as the cluster size, it means that the cluster is isolated
    ( Dif == ClusterSize -> 
        write('Error: This piece is isolated so it can not move.'), nl, nl, fail;
        true ).


% ------------------------------------------------------------------------------------------------

% valid_move_no_errors(+GameState, +Move)
% Same as valid_move, but without the error messages
valid_move_no_errors([Board, CurrentPlayer, T, Names, BoardType], move(FromX, FromY, ToX, ToY)):-

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
            valid_move_no_errors([Board, CurrentPlayer, T, Names, BoardType], move(FromX, FromY, ToX, ToY))
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
    valid_move_no_errors([Board, CurrentPlayer, T, Names, BoardType], move(FromX, FromY, ToX, ToY)), !.
