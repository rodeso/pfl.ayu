% All the functions associated with finding and managing all the clusters

:- dynamic visited/2.

% ------------------------------------------------------------------------------------------------

% Entry point to count clusters for a player
count_clusters(Board, Player, Count) :-
    piece_player(Player, Piece),
    retractall(visited(_, _)), % Clear visited cells
    findall(Row-Col, (nth1(Row, Board, RowList), nth1(Col, RowList, Piece)), AllPieces),
    count_clusters_aux(Board, Piece, AllPieces, 0, Count).

% Helper to traverse all pieces
count_clusters_aux(_, _, [], Count, Count).
count_clusters_aux(Board, Piece, [Row-Col | Rest], Acc, Count) :-
    (visited(Row, Col) ->
        % If already visited, skip
        count_clusters_aux(Board, Piece, Rest, Acc, Count)
    ;
        % Start BFS for a new cluster
        bfs(Board, Piece, [Row-Col], []),
        NewAcc is Acc + 1,
        count_clusters_aux(Board, Piece, Rest, NewAcc, Count)
    ).

% BFS implementation
bfs(_, _, [], _).
bfs(Board, Piece, [Row-Col | Queue], VisitedNodes) :-
    (visited(Row, Col) ->
        bfs(Board, Piece, Queue, VisitedNodes)
    ;
        assert(visited(Row, Col)),
        find_neighbors(Board, Piece, Row, Col, Neighbors),
        append(Queue, Neighbors, NewQueue),
        bfs(Board, Piece, NewQueue, [Row-Col | VisitedNodes])
    ).

% Find valid neighbors for BFS
find_neighbors(Board, Piece, Row, Col, Neighbors) :-
    findall(
        R-C,
        (
            neighbor(Row, Col, R, C),
            within_bounds(Board, R, C),
            get_piece(Board, R, C, Piece),
            \+ visited(R, C)
        ),
        Neighbors
    ).

% Define neighbor positions (only horizontal and vertical)
neighbor(Row, Col, Row1, Col) :- Row1 is Row - 1.
neighbor(Row, Col, Row1, Col) :- Row1 is Row + 1.
neighbor(Row, Col, Row, Col1) :- Col1 is Col - 1.
neighbor(Row, Col, Row, Col1) :- Col1 is Col + 1.

% Check if a cell is within bounds
within_bounds(Board, Row, Col) :-
    length(Board, N),
    Row > 0, Row =< N,
    nth1(Row, Board, RowList),
    length(RowList, M),
    Col > 0, Col =< M.

% Get the piece at a specific cell
get_piece(Board, Row, Col, Piece) :-
    nth1(Row, Board, RowList),
    nth1(Col, RowList, Piece).

% ------------------------------------------------------------------------------------------------

% List cluster sizes and their elements for a player
list_clusters_with_elements(Board, Player, Sizes, Elements) :-
    piece_player(Player, Piece),
    retractall(visited(_, _)), % Clear visited cells
    findall(Row-Col, (nth1(Row, Board, RowList), nth1(Col, RowList, Piece)), AllPieces),
    list_clusters_with_elements_aux(Board, Piece, AllPieces, [], [], Sizes, Elements).

% Helper to traverse all pieces and list sizes and elements
list_clusters_with_elements_aux(_, _, [], Sizes, Elements, Sizes, Elements).
list_clusters_with_elements_aux(Board, Piece, [Row-Col | Rest], AccSizes, AccElements, Sizes, Elements) :-
    (visited(Row, Col) ->
        % If already visited, skip
        list_clusters_with_elements_aux(Board, Piece, Rest, AccSizes, AccElements, Sizes, Elements)
    ;
        % Start BFS for a new cluster, count its size, and collect its elements
        bfs_size_and_elements(Board, Piece, [Row-Col], [], 0, Size, [], ClusterElements),
        list_clusters_with_elements_aux(Board, Piece, Rest, [Size|AccSizes], [ClusterElements|AccElements], Sizes, Elements)
    ).

% BFS implementation that calculates cluster size and collects elements
bfs_size_and_elements(_, _, [], _, Size, Size, Cluster, Cluster).
bfs_size_and_elements(Board, Piece, [Row-Col | Queue], VisitedNodes, AccSize, Size, AccCluster, Cluster) :-
    (visited(Row, Col) ->
        bfs_size_and_elements(Board, Piece, Queue, VisitedNodes, AccSize, Size, AccCluster, Cluster)
    ;
        assert(visited(Row, Col)),
        find_neighbors(Board, Piece, Row, Col, Neighbors),
        append(Queue, Neighbors, NewQueue),
        NewAccSize is AccSize + 1,
        NewAccCluster = [Row-Col|AccCluster],
        bfs_size_and_elements(Board, Piece, NewQueue, [Row-Col | VisitedNodes], NewAccSize, Size, NewAccCluster, Cluster)
    ).


% Function to reverse pairs in the list of clusters
reverse_cluster_elements([], []).
reverse_cluster_elements([Cluster|Rest], [ReversedCluster|ReversedRest]) :-
    maplist(swap_row_col, Cluster, ReversedCluster),
    reverse_cluster_elements(Rest, ReversedRest).

% Swap Row-Col format to Col-Row
swap_row_col(Row-Col, Col-Row).

% Result of : List cluster sizes and their elements for a player
final_cluster_elements(Board, CurrentPlayer, Size, NewElments):-
    list_clusters_with_elements(Board, CurrentPlayer, Size, Elements),
    reverse_cluster_elements(Elements, NewElments).

% ------------------------------------------------------------------------------------------------

% Function to find the cluster containing the element X-Y
find_cluster_with_element(Elements, X, Y, Cluster) :-
    member(Cluster, Elements),    % Iterate over each cluster in Elements
    member(X-Y, Cluster),         % Check if X-Y is a member of the current cluster
    !.                            % Stop as soon as the cluster is found


% ------------------------------------------------------------------------------------------------

% Finds the cluster of a specified piece and counts adjacent empty spaces row Y and col X
find_piece_cluster_with_spaces(Board, StartRow-StartCol, Cluster, EspaceCount) :-
    retractall(visited(_, _)), % Clear visited nodes
    get_piece(Board, StartRow, StartCol, Piece),
    % write('Starting piece: '), write(Piece), nl,
    bfs_piece_cluster(Board, Piece, [StartRow-StartCol], [], [], 0, PieceCluster, EspaceCount, SpaceCluster),
    append(PieceCluster, SpaceCluster, Cluster).

% BFS implementation for finding cluster and counting empty spaces
bfs_piece_cluster(_, _, [], ClusterAcc, EmptyAcc, _, Cluster, EspaceCount, SpaceCluster) :-
    reverse(ClusterAcc, Cluster), % Finalize cluster list
    reverse(EmptyAcc, SpaceCluster),
    length(EmptyAcc, EspaceCount). % Count unique empty spaces
bfs_piece_cluster(Board, Piece, [Row-Col | Queue], ClusterAcc, EmptyAcc, AccEspaceCount, Cluster, EspaceCount, SpaceCluster) :-
    (visited(Row, Col) ->
        % Skip already visited cells
        bfs_piece_cluster(Board, Piece, Queue, ClusterAcc, EmptyAcc, AccEspaceCount, Cluster, EspaceCount, SpaceCluster)
    ;
        assert(visited(Row, Col)), % Mark current cell as visited
        get_piece(Board, Row, Col, CellPiece),
        % write('Visiting Y: '), write(Row), write(' X: '), write(Col), nl,
        (CellPiece = Piece ->
            % Add to cluster if it matches the target piece
            find_neighbors_space(Board, Piece, Row, Col, Neighbors),
            append(Queue, Neighbors, NewQueue),
            bfs_piece_cluster(Board, Piece, NewQueue, [Row-Col | ClusterAcc], EmptyAcc, AccEspaceCount, Cluster, EspaceCount, SpaceCluster)
        ; CellPiece = empty ->
            % Count empty spaces
            find_neighbors_space(Board, Piece, Row, Col, Neighbors),
            append(Queue, Neighbors, NewQueue),
            (member(Row-Col, EmptyAcc) ->
                % Avoid duplicate empty spaces
                NewEmptyAcc = EmptyAcc
            ;
                NewEmptyAcc = [Row-Col | EmptyAcc]
            ),
            bfs_piece_cluster(Board, Piece, NewQueue, ClusterAcc, NewEmptyAcc, AccEspaceCount, Cluster, EspaceCount, SpaceCluster)
        ;
            % Skip other cells
            bfs_piece_cluster(Board, Piece, Queue, ClusterAcc, EmptyAcc, AccEspaceCount, Cluster, EspaceCount, SpaceCluster)
        )
    ).

% Define neighbors (horizontal and vertical only)
find_neighbors_space(Board, Piece, Row, Col, Neighbors) :-
    findall(
        R-C,
        (
            neighbor(Row, Col, R, C),
            within_bounds(Board, R, C),
            get_piece(Board, R, C, NeighborPiece),
            (NeighborPiece = Piece ; NeighborPiece = empty), % Include target piece and empty spaces
            \+ visited(R, C)
        ),
        Neighbors
    ).
