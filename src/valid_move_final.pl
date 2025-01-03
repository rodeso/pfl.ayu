% valid_one_move(FromX, FromY, ToX, ToY)
% Ensure that the move for an isolated piece is exactly 1 square away
valid_move_final([Board, CurrentPlayer, T], move(FromX, FromY, ToX, ToY)):-

    % Validate the source position
    (piece_at(Board, FromX, FromY, CurrentPlayer) ->
        true;
        write('Error: Source position is invalid.'), nl, nl, fail),

    % Validate the destination position
    (empty_at(Board, ToX, ToY) ->
        true;
        write('Error: Destination position is not empty.'), nl, nl, fail),


    count_clusters(Board, CurrentPlayer, CountNoChange),                          % Count the clusters
    
    move([Board, CurrentPlayer, T], move(FromX, FromY, ToX, ToY), TempGameState), % Do the move in the temp board
    get_board(TempGameState, TempBoard),
    count_clusters(TempBoard, CurrentPlayer, CountChange),                        % Count the clusters WITH the change
    
    
    final_cluster_elements(Board, CurrentPlayer, Count, Elements),                % Find all the clusters
    find_cluster_with_element(Elements, FromX, FromY, Cluster),                   % Find the cluster that contains the piece
    length(Cluster, ClusterSize),

    final_cluster_elements(TempBoard, CurrentPlayer, CountTemp, ElementsTemp),    % Find all the clusters WITH the change
    find_cluster_with_element(ElementsTemp, ToX, ToY, ClusterTemp),               % Find the cluster that contains the piece WITH the change
    length(ClusterTemp, ClusterSizeTemp),

    
    remove_element(FromX-FromY, Cluster, ClusterMenos),
    
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
    (CountChange =< CountNoChange -> % AUMENTA O NUMERO DE ALGOMERADOS É PROIBIDO
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

    % Se o cluster for sozinho perceber se está numa zona só com espaço vazio
    (ClusterSize == 1 ->
        ( Dif == 1 ->   % If the cluster size is not 1, it's an error
            write('Error: This piece is isolated so it can not move.'), nl, nl, fail
        ;
            true 
        );
        true
    ).

% ------------------------------------------------------------------------------------------------

% Same as valid_move_final, but without the error messages
valid_move_final_no_errors([Board, CurrentPlayer, T], move(FromX, FromY, ToX, ToY)):-

    (piece_at(Board, FromX, FromY, CurrentPlayer) ->
        true;
        fail),

    (empty_at(Board, ToX, ToY) ->
        true;
        fail),


    count_clusters(Board, CurrentPlayer, CountNoChange),
    
    move([Board, CurrentPlayer, T], move(FromX, FromY, ToX, ToY), TempGameState),
    get_board(TempGameState, TempBoard),
    count_clusters(TempBoard, CurrentPlayer, CountChange),
    
    
    final_cluster_elements(Board, CurrentPlayer, Count, Elements),
    find_cluster_with_element(Elements, FromX, FromY, Cluster),
    length(Cluster, ClusterSize),

    final_cluster_elements(TempBoard, CurrentPlayer, CountTemp, ElementsTemp),
    find_cluster_with_element(ElementsTemp, ToX, ToY, ClusterTemp),
    length(ClusterTemp, ClusterSizeTemp),

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
    (CountChange =< CountNoChange ->
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

    (ClusterSize == 1 ->
        ( Dif == 1 ->
            fail
        ;
            true 
        );
        true
    ).

% ------------------------------------------------------------------------------------------------
    
% valid_moves([Board, CurrentPlayer, _], ListOfMoves)
% Generates a list of all possible valid moves for the CurrentPlayer on the Board
valid_moves_final([Board, CurrentPlayer, T], UniqueListOfMoves) :-
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
            valid_move_final_no_errors([Board, CurrentPlayer, T], move(FromX, FromY, ToX, ToY))
        ),
        ListOfMoves),
    sort(ListOfMoves, UniqueListOfMoves).

% ------------------------------------------------------------------------------------------------

% valid_moves_bool([Board, CurrentPlayer, _], ListOfMoves)
% Returns true if there is at least one valid move for the CurrentPlayer on the Board
% Used to check if the game is over
valid_moves_bool([Board, CurrentPlayer, T]) :-
    length(Board, Size),
    between(1, Size, FromX),
    between(1, Size, FromY),
    piece_at(Board, FromX, FromY, CurrentPlayer),
    between(1, Size, ToX),
    between(1, Size, ToY),
    (FromX \= ToX; FromY \= ToY),
    empty_at(Board, ToX, ToY),
    valid_move_final_no_errors([Board, CurrentPlayer, T], move(FromX, FromY, ToX, ToY)),
    !.



    