% valid_one_move(FromX, FromY, ToX, ToY)
% Ensure that the move for an isolated piece is exactly 1 square away
valid_move_final([Board, CurrentPlayer, T], move(FromX, FromY, ToX, ToY)):-

    % Validate the source position
    (piece_at(Board, FromX, FromY, CurrentPlayer) ->
        true;
        write('Error: Source position is invalid.'), nl, nl, nl, nl, fail),

    % Validate the destination position
    (empty_at(Board, ToX, ToY) ->
        true;
        write('Error: Destination position is not empty.'), nl, nl, nl, nl, fail),


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

    % Ensure that after the move the cluster it takes part does not decrease in size
    (ClusterSize =< ClusterSizeTemp -> 
        true;
        write('Error: Clusters can never decrease size.'), nl, nl, nl, nl, fail),

    % Ensure after that the list of clusters is smaller or the same size
    (CountChange =< CountNoChange -> % AUMENTA O NUMERO DE ALGOMERADOS É PROIBIDO
        true;
        write('Error: This move separates a cluster.'), nl, nl, nl, nl, fail),
    

    (ClusterSize == 1 -> % Isolated piece can only move 1 distance spot (no diagonals)
        (valid_one_move(FromX, FromY, ToX, ToY) ->
            true
        ; 
            write('Error: Isolated elements can only move 1 spo.'), nl, nl, nl, nl, fail 
        );
        true
    ),

    % Se o cluster não for isolado ent o numero que aglomerados tem sempre de diminuir
    (ClusterSize =\= 1 ->
        (CountChange == CountNoChange ->   % If the cluster size is not 1, it's an error
            write('Error: Not isolated cluster cannot do this movement.'), nl, nl, display_board(Board), nl, nl, fail
        ; 
            true 
        );
        true
    ),

    % Se o cluster não for isolado ent o tamanho do cluster onde ele está n pode manter
    (ClusterSize =\= 1 ->
        (ClusterSize == ClusterSizeTemp ->   % If the cluster size is not 1, it's an error
            write('Error: Not isolated cluster cannot do this movement.'), nl, nl, display_board(Board), nl, nl, fail
        ; 
            true 
        );
        true
    ),

    find_piece_cluster_with_spaces(Board, FromY-FromX, ClusterWithSpaces, EspaceCount), %Y-X
    length(ClusterWithSpaces, EspaceTotalCount),
    Dif is EspaceTotalCount - EspaceCount,

    % Se o cluster for sozinho perceber se está numa zona só com espaço vazio
    (ClusterSize == 1 ->
        ( Dif == 1 ->   % If the cluster size is not 1, it's an error
            write('Error: This piece is isolated so it can not move.'), nl, nl, display_board(Board), nl, nl, fail
        ; 
            true 
        );
        true
    ).

    /*
        Basic rules:
        - clusters of more than one an only move to increase the number of pices in sayed cluster
        - isolated clusters can move whoever they want  (move any way there is a cluster)
    */


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

    (ClusterSize =\= 1 ->
        (CountChange == CountNoChange ->
            fail
        ; 
            true 
        );
        true
    ),

    (ClusterSize =\= 1 ->
        (ClusterSize == ClusterSizeTemp ->
            fail
        ; 
            true 
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

    
% valid_moves([Board, CurrentPlayer, _], ListOfMoves)
% Generates a list of all possible valid moves for the CurrentPlayer on the Board
valid_moves_final([Board, CurrentPlayer, T], ListOfMoves) :-
    length(Board, N),  % Get the size of the board (assuming it's a square)
    findall(move(FromX, FromY, ToX, ToY),
        (
            between(1, N, FromX),
            between(1, N, FromY),
            piece_at(Board, FromX, FromY, CurrentPlayer),
            between(1, N, ToX),
            between(1, N, ToY),
            (FromX \= ToX; FromY \= ToY),
            empty_at(Board, ToX, ToY),
            valid_move_final_no_errors([Board, CurrentPlayer, T], move(FromX, FromY, ToX, ToY))
        ),
        ListOfMoves).




    

    