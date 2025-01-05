% All the functions associated with finding and managing all the clusters

% ------------------------------------------------------------------------------------------------
% General functions

% find_neighbors(+Board, +Piece, +Row, +Col, -Neighbors, +Visited)
% Find valid neighbors for BFS
find_neighbors(Board, Piece, Row, Col, Neighbors, Visited) :-
    findall(
        R-C,
        (
            neighbor(Row, Col, R, C),
            within_bounds(Board, R, C),
            get_piece(Board, R, C, Piece),
            \+ member(R-C, Visited)
        ),
        Neighbors
    ).

% neighbor(+Row, +Col, -Row1, -Col1)
% Define neighbor positions, only horizontal and vertical, no diagonals are allowed in this game
neighbor(Row, Col, Row1, Col) :- Row1 is Row - 1.
neighbor(Row, Col, Row1, Col) :- Row1 is Row + 1.
neighbor(Row, Col, Row, Col1) :- Col1 is Col - 1.
neighbor(Row, Col, Row, Col1) :- Col1 is Col + 1.


% ------------------------------------------------------------------------------------------------

% list_clusters_with_elements(+Board, +Player, -Sizes, -Elements)
% List cluster sizes and their elements for a especific player
list_clusters_with_elements(Board, Player, Sizes, Elements) :-
    piece_player(Player, Piece),
    findall(Row-Col, (nth1(Row, Board, RowList), nth1(Col, RowList, Piece)), AllPieces),
    list_clusters_with_elements_aux(Board, Piece, AllPieces, [], [], [], Sizes, Elements).

% list_clusters_with_elements_aux(+Board, +Piece, +Pieces, +Visited, +AccSizes, +AccElements, -Sizes, -Elements)
% Helper function to list clusters with elements
list_clusters_with_elements_aux(_, _, [], Visited, AccSizes, AccElements, AccSizes, AccElements).
list_clusters_with_elements_aux(Board, Piece, [Row-Col | Rest], Visited, AccSizes, AccElements, Sizes, Elements) :-
    (member(Row-Col, Visited) ->
        list_clusters_with_elements_aux(Board, Piece, Rest, Visited, AccSizes, AccElements, Sizes, Elements)
    ;
        bfs_size_and_elements(Board, Piece, [Row-Col], Visited, 0, Size, [], ClusterElements, NewVisited),
        sort(ClusterElements, SortedClusterElements),
        list_clusters_with_elements_aux(Board, Piece, Rest, NewVisited, [Size|AccSizes], [SortedClusterElements|AccElements], Sizes, Elements)
    ).

% bfs_size_and_elements(+Board, +Piece, +Queue, +Visited, +AccSize, -Size, +AccCluster, -Cluster, -FinalVisited)
% BFS implementation for finding cluster size and elements
bfs_size_and_elements(_, _, [], Visited, Size, Size, Cluster, Cluster, Visited).
bfs_size_and_elements(Board, Piece, [Row-Col | Queue], Visited, AccSize, Size, AccCluster, Cluster, FinalVisited) :-
    (member(Row-Col, Visited) ->
        bfs_size_and_elements(Board, Piece, Queue, Visited, AccSize, Size, AccCluster, Cluster, FinalVisited)
    ;
        find_neighbors(Board, Piece, Row, Col, Neighbors, Visited),
        append(Queue, Neighbors, NewQueue),
        NewAccSize is AccSize + 1,
        NewAccCluster = [Row-Col|AccCluster],
        bfs_size_and_elements(Board, Piece, NewQueue, [Row-Col|Visited], NewAccSize, Size, NewAccCluster, Cluster, FinalVisited)
    ).

% reverse_cluster_elements(+Clusters, -ReversedClusters)
% Function to reverse pairs in the list of clusters
reverse_cluster_elements([], []).
reverse_cluster_elements([Cluster|Rest], [ReversedCluster|ReversedRest]) :-
    maplist(swap_row_col, Cluster, ReversedCluster),
    reverse_cluster_elements(Rest, ReversedRest).

% swap_row_col(+Row-Col, -Col-Row)
% Swap Row-Col format to Col-Row
swap_row_col(Row-Col, Col-Row).

% list_cluster_elements(+Board, +CurrentPlayer, +Size, -NewElments)
% List cluster sizes and their elements for a especific player in the correct order
list_cluster_elements(Board, CurrentPlayer, Size, NewElments):-
    list_clusters_with_elements(Board, CurrentPlayer, Size, Elements),
    reverse_cluster_elements(Elements, NewElments).

% ------------------------------------------------------------------------------------------------

% find_cluster_with_element(+Elements, +X, +Y, -Cluster)
% Function to find the cluster containing the element X-Y
find_cluster_with_element(Elements, X, Y, Cluster) :-
    member(Cluster, Elements),    % Iterate over each cluster in Elements
    member(X-Y, Cluster),         % Check if X-Y is a member of the current cluster
    !.                            % Stop as soon as the cluster is found


% ------------------------------------------------------------------------------------------------

% find_piece_cluster(+Board, +X, +Y, -Cluster)
% Finds the cluster of a specified piece and counts adjacent empty spaces row Y and col X
find_piece_cluster_with_spaces(Board, StartRow-StartCol, Cluster, EspaceCount) :-
    get_piece(Board, StartRow, StartCol, Piece),
    bfs_piece_cluster(Board, Piece, [StartRow-StartCol], [], [], 0, PieceCluster, EspaceCount, SpaceCluster),
    append(PieceCluster, SpaceCluster, Cluster).

% bfs_piece_cluster(+Board, +Piece, +Queue, +ClusterAcc, +EmptyAcc, +Visited, -Cluster, -EspaceCount, -SpaceCluster)
% BFS implementation for finding cluster and counting empty spaces
bfs_piece_cluster(_, _, [], ClusterAcc, EmptyAcc, _, Cluster, EspaceCount, SpaceCluster) :-
    reverse(ClusterAcc, Cluster), % Finalize cluster list
    reverse(EmptyAcc, SpaceCluster),
    length(EmptyAcc, EspaceCount). % Count unique empty spaces
bfs_piece_cluster(Board, Piece, [Row-Col | Queue], ClusterAcc, EmptyAcc, AccVisited, Cluster, EspaceCount, SpaceCluster) :-
    (member(Row-Col, AccVisited) ->
        bfs_piece_cluster(Board, Piece, Queue, ClusterAcc, EmptyAcc, AccVisited, Cluster, EspaceCount, SpaceCluster)
    ;
        NewVisited = [Row-Col | AccVisited],
        get_piece(Board, Row, Col, CellPiece),
        (CellPiece = Piece ->
            find_neighbors_space(Board, Piece, Row, Col, Neighbors, NewVisited),
            append(Queue, Neighbors, NewQueue),
            bfs_piece_cluster(Board, Piece, NewQueue, [Row-Col | ClusterAcc], EmptyAcc, NewVisited, Cluster, EspaceCount, SpaceCluster)
        ; CellPiece = empty ->
            find_neighbors_space(Board, Piece, Row, Col, Neighbors, NewVisited),
            append(Queue, Neighbors, NewQueue),
            (member(Row-Col, EmptyAcc) ->
                NewEmptyAcc = EmptyAcc
            ;
                NewEmptyAcc = [Row-Col | EmptyAcc]
            ),
            bfs_piece_cluster(Board, Piece, NewQueue, ClusterAcc, NewEmptyAcc, NewVisited, Cluster, EspaceCount, SpaceCluster)
        ;
            bfs_piece_cluster(Board, Piece, Queue, ClusterAcc, EmptyAcc, NewVisited, Cluster, EspaceCount, SpaceCluster)
        )
    ).

% find_neighbors_space(+Board, +Piece, +Row, +Col, -Neighbors, +Visited)
% Find neighbors for the shortest path (counting the spaces)
find_neighbors_space(Board, Piece, Row, Col, Neighbors, Visited) :-
    findall(
        R-C,
        (
            neighbor(Row, Col, R, C),
            within_bounds(Board, R, C),
            get_piece(Board, R, C, NeighborPiece),
            (NeighborPiece = Piece ; NeighborPiece = empty),
            \+ member(R-C, Visited)
        ),
        Neighbors
    ).

% find_neighbors_path(+Board, +Row, +Col, +Dist, +Path, +VisitedPieces, -Neighbors)
% Find neighbors for the shortest paths
find_neighbors_path(Board, Row, Col, Dist, Path, VisitedPieces, Neighbors) :-
    findall(
        (R-C, D, [R-C | Path]),
        ( % Confirm it's a neighbor, within bounds, and not visited
            neighbor(Row, Col, R, C), 
            within_bounds(Board, R, C), 
            \+ member((R-C, _), VisitedPieces),
            get_piece(Board, R, C, empty),
            D is Dist + 1
        ), 
        Neighbors
    ).


% ------------------------------------------------------------------------------------------------

% shortest_paths(+Board, +StartRow-StartCol, +EndRow-EndCol, -Distance, -Paths)
% Finds all shortest paths between two points - Distance and all paths
shortest_paths(Board, StartRow-StartCol, EndRow-EndCol, Distance, Paths) :-
    bfs_all_shortest_paths(Board, [(StartRow-StartCol, 0, [StartRow-StartCol])], [], EndRow-EndCol, AllPaths),
    % Extract the minimum distance paths
    maplist(arg(1), AllPaths, Distances), 
    my_min_list(Distances, Distance),
    include(path_at_min_distance(Distance), AllPaths, MinDistancePaths),
    findall(Path, member(Distance-Path, MinDistancePaths), ReversedPaths),
    reverse_all(ReversedPaths, Paths).

% bfs_all_shortest_paths(+Board, +Queue, +VisitedPieces, +EndRow-EndCol, -AllPaths)
% Function to find all shortest paths between two pieces - Distance and all paths
bfs_all_shortest_paths(_, [], _, _, []):- !.
bfs_all_shortest_paths(Board, [(Row-Col, Dist, Path) | Queue], VisitedPieces, EndRow-EndCol, AllPaths) :-
    ( neighbor(Row, Col, EndRow, EndCol) ->
        NewDist is Dist + 1,
        AllPaths = [NewDist-[EndRow-EndCol|Path]|RestPaths],
        bfs_all_shortest_paths(Board, Queue, [(Row-Col, Dist) | VisitedPieces], EndRow-EndCol, RestPaths)
    ;
        find_neighbors_path(Board, Row, Col, Dist, Path, VisitedPieces, Neighbors),
        append(Neighbors, Queue, NewQueue),  % Breadth-first: Neighbors are prepended
        bfs_all_shortest_paths(Board, NewQueue, [(Row-Col, Dist) | VisitedPieces], EndRow-EndCol, AllPaths)
    ).

% ------------------------------------------------------------------------------------------------

% shortested_paths_between_clusters(+Board, +FromX, +FromY, +Elements, -AllShortestPaths)
% Main function to find shortest paths between a specific cluster and all other clusters
% Uses shortest_paths function to find the paths between 2 pieces
shortest_paths_between_clusters(Board, FromX, FromY, Elements, AllShortestPaths):-

    find_cluster_with_element(Elements, FromX, FromY, Cluster),           % Get the starting cluster

    Cluster = [FirstElement|_],
    exclude(has_element(FirstElement), Elements, OtherClusters),          % Take out the cluster

    find_shortest_paths_for_all_clusters(Board, Cluster, OtherClusters, [], AllShortestPaths).

% find_shortest_paths_for_all_clusters(+Board, +Cluster, +OtherClusters, +Acc, -AllShortestPaths)
% Recursive function to find shortest paths between a cluster and all other clusters
    % Base case: no more clusters to process
find_shortest_paths_for_all_clusters(_, _, [], ShortestPaths, ShortestPaths).
    % Recursive case: process each cluster and accumulate results
find_shortest_paths_for_all_clusters(Board, Cluster, [OtherCluster | Rest], Acc, AllShortestPaths) :-
    (
        all_shortest_paths_between_two_clusters(Board, Cluster, OtherCluster, ShortestPathsForCluster) ->
        NewAcc = [ShortestPathsForCluster | Acc]
    ;
        NewAcc = Acc
    ),
    find_shortest_paths_for_all_clusters(Board, Cluster, Rest, NewAcc, AllShortestPaths).

% all_shortest_paths_between_two_clusters(+Board, +Cluster1, +Cluster2, -ShortestPaths)
% Function to find all shortest paths between two clusters
all_shortest_paths_between_two_clusters(Board, Cluster1, Cluster2, ShortestPaths) :-
    findall(
        Distance-Path,
        (
            member(E1, Cluster1),
            member(E2, Cluster2),
            E1 = Row1-Col1,
            E2 = Row2-Col2,
            shortest_paths(Board, Col1-Row1, Col2-Row2, Distance, Path),
            Distance > 0
        ),
        AllPaths
    ),

    sort(AllPaths, SortedPaths),
    SortedPaths = [MinDistance-_|_],
    include(path_at_min_distance(MinDistance), SortedPaths, ShortestPaths).

% ------------------------------------------------------------------------------------------------

% filter_minimum_distance_paths(+AllShortestPaths, -FilteredPaths)
% Function to filter paths with the minimum distance
filter_minimum_distance_paths(AllShortestPaths, FilteredPaths) :-

    flat_list(AllShortestPaths, FlattenedPaths),

    findall(Distance, member(Distance-_, FlattenedPaths), Distances),

    my_min_list(Distances, MinDistance),

    include(path_at_min_distance(MinDistance), FlattenedPaths, FilteredPaths).

% ------------------------------------------------------------------------------------------------

% path_includes_point(+AllShortestPaths, +ToX, +ToY)
% Main function to check if any path in AllShortestPaths includes the point (ToX, ToY)
path_includes_point(AllShortestPaths, ToX, ToY):-
    member(ShortestPaths, AllShortestPaths),
    member(_-PathList, ShortestPaths),
    flat_list(PathList, Path),
    path_contains_point(Path, ToX, ToY), !.

% path_contains_point(+Path, +ToX, +ToY)
% Recursive function to check if a path includes a specific point
path_contains_point([ToX-ToY | _], ToX, ToY).
path_contains_point([X-Y | Rest], ToX, ToY):-
    path_contains_point(Rest, ToX, ToY).

