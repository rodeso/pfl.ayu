% All the functions associated with finding and managing all the clusters

:- dynamic visited/2.

% ------------------------------------------------------------------------------------------------
% General functions

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

% Define neighbor positions (only horizontal and vertical)
neighbor(Row, Col, Row1, Col) :- Row1 is Row - 1.
neighbor(Row, Col, Row1, Col) :- Row1 is Row + 1.
neighbor(Row, Col, Row, Col1) :- Col1 is Col - 1.
neighbor(Row, Col, Row, Col1) :- Col1 is Col + 1.


% ------------------------------------------------------------------------------------------------

% List cluster sizes and their elements for a player
list_clusters_with_elements(Board, Player, Sizes, Elements) :-
    piece_player(Player, Piece),
    findall(Row-Col, (nth1(Row, Board, RowList), nth1(Col, RowList, Piece)), AllPieces),
    list_clusters_with_elements_aux(Board, Piece, AllPieces, [], [], [], Sizes, Elements).

list_clusters_with_elements_aux(_, _, [], Visited, AccSizes, AccElements, AccSizes, AccElements).
list_clusters_with_elements_aux(Board, Piece, [Row-Col | Rest], Visited, AccSizes, AccElements, Sizes, Elements) :-
    (member(Row-Col, Visited) ->
        % If already visited, skip
        list_clusters_with_elements_aux(Board, Piece, Rest, Visited, AccSizes, AccElements, Sizes, Elements)
    ;
        % Start BFS for a new cluster, count its size, and collect its elements
        bfs_size_and_elements(Board, Piece, [Row-Col], Visited, 0, Size, [], ClusterElements, NewVisited),
        % Sort cluster elements for consistent ordering
        sort(ClusterElements, SortedClusterElements),
        list_clusters_with_elements_aux(Board, Piece, Rest, NewVisited, [Size|AccSizes], [SortedClusterElements|AccElements], Sizes, Elements)
    ).

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
    get_piece(Board, StartRow, StartCol, Piece),
    bfs_piece_cluster(Board, Piece, [StartRow-StartCol], [], [], 0, PieceCluster, EspaceCount, SpaceCluster),
    append(PieceCluster, SpaceCluster, Cluster).

% BFS implementation for finding cluster and counting empty spaces
bfs_piece_cluster(_, _, [], ClusterAcc, EmptyAcc, _, Cluster, EspaceCount, SpaceCluster) :-
    reverse(ClusterAcc, Cluster), % Finalize cluster list
    reverse(EmptyAcc, SpaceCluster),
    length(EmptyAcc, EspaceCount). % Count unique empty spaces
bfs_piece_cluster(Board, Piece, [Row-Col | Queue], ClusterAcc, EmptyAcc, AccVisited, Cluster, EspaceCount, SpaceCluster) :-
    (member(Row-Col, AccVisited) ->
        % Skip already visited cells
        bfs_piece_cluster(Board, Piece, Queue, ClusterAcc, EmptyAcc, AccVisited, Cluster, EspaceCount, SpaceCluster)
    ;
        % Mark current cell as visited
        NewVisited = [Row-Col | AccVisited],
        get_piece(Board, Row, Col, CellPiece),
        (CellPiece = Piece ->
            % Add to cluster if it matches the target piece
            find_neighbors_space(Board, Piece, Row, Col, Neighbors, NewVisited),
            append(Queue, Neighbors, NewQueue),
            bfs_piece_cluster(Board, Piece, NewQueue, [Row-Col | ClusterAcc], EmptyAcc, NewVisited, Cluster, EspaceCount, SpaceCluster)
        ; CellPiece = empty ->
            % Count empty spaces
            find_neighbors_space(Board, Piece, Row, Col, Neighbors, NewVisited),
            append(Queue, Neighbors, NewQueue),
            (member(Row-Col, EmptyAcc) ->
                % Avoid duplicate empty spaces
                NewEmptyAcc = EmptyAcc
            ;
                NewEmptyAcc = [Row-Col | EmptyAcc]
            ),
            bfs_piece_cluster(Board, Piece, NewQueue, ClusterAcc, NewEmptyAcc, NewVisited, Cluster, EspaceCount, SpaceCluster)
        ;
            % Skip other cells
            bfs_piece_cluster(Board, Piece, Queue, ClusterAcc, EmptyAcc, NewVisited, Cluster, EspaceCount, SpaceCluster)
        )
    ).

% Define neighbors (horizontal and vertical only)
find_neighbors_space(Board, Piece, Row, Col, Neighbors, Visited) :-
    findall(
        R-C,
        (
            neighbor(Row, Col, R, C),
            within_bounds(Board, R, C),
            get_piece(Board, R, C, NeighborPiece),
            (NeighborPiece = Piece ; NeighborPiece = empty), % Include target piece and empty spaces
            \+ member(R-C, Visited)
        ),
        Neighbors
    ).


% ------------------------------------------------------------------------------------------------

% Function to find the shortest path between two pieces - Just distance
shortest_path(Board, StartRow-StartCol, EndRow-EndCol, Distance) :-
    bfs_shortest_path(Board, [(StartRow-StartCol,0)], [], EndRow-EndCol, Distance).

bfs_shortest_path(_, [], _, _, -1). % No path found
bfs_shortest_path(_, [(Row-Col, Dist) | _], _, EndRow-EndCol, Distance):- % Found the end
    neighbor(Row, Col, EndRow, EndCol),
    Distance is Dist + 1, !.

bfs_shortest_path(Board, [(Row-Col, Dist) | Queue], VisitedPieces, EndRow-EndCol, Distance):- % Continue search
    find_neighbors_path(Board, Row, Col, Dist, VisitedPieces, Neighbors),
    append(Queue, Neighbors, NewQueue),
    bfs_shortest_path(Board, NewQueue, [(Row-Col, Dist) | VisitedPieces], EndRow-EndCol, Distance).

find_neighbors_path(Board, Row, Col, Dist, VisitedPieces, Neighbors) :-
    findall(
        (R-C, D),
        ( % Confirm its a neighbor, within bounds, not visited and not ocupied
            neighbor(Row, Col, R, C), 
            within_bounds(Board, R, C), 
            \+ member((R-C, _), VisitedPieces),
            get_piece(Board, R, C, empty),
            D is Dist + 1
        ), 
        Neighbors
    ).

% ------------------------------------------------------------------------------------------------

% Function to find the shortest path between two pieces - Distance and path
shortest_paths(Board, StartRow-StartCol, EndRow-EndCol, Distance, Paths) :-
    bfs_shortest_paths(Board, [(StartRow-StartCol, 0, [StartRow-StartCol])], [], EndRow-EndCol, Distance, Paths).

bfs_shortest_paths(_, [], _, _, -1, []):- !. % No path found
bfs_shortest_paths(_, [(Row-Col, Dist, Path) | _], _, EndRow-EndCol, Distance, [FullPath]) :- % Found the end
    neighbor(Row, Col, EndRow, EndCol),
    Distance is Dist + 1,
    reverse([EndRow-EndCol | Path], FullPath), !.

bfs_shortest_paths(Board, [(Row-Col, Dist, Path) | Queue], VisitedPieces, EndRow-EndCol, Distance, Paths) :- % Continue search
    find_neighbors_paths(Board, Row, Col, Dist, Path, VisitedPieces, Neighbors),
    append(Queue, Neighbors, NewQueue),
    bfs_shortest_paths(Board, NewQueue, [(Row-Col, Dist) | VisitedPieces], EndRow-EndCol, Distance, Paths).

find_neighbors_paths(Board, Row, Col, Dist, Path, VisitedPieces, Neighbors) :-
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

% Helper to collect all paths at the minimum distance
bfs_shortest_paths(_, [], _, _, Distance, Paths) :-
    Distance > 0, % Distance exists, ensure paths are finalized
    aggregate_all(set(Path), member(Path, Paths), UniquePaths),
    reverse_all(UniquePaths, Paths).

reverse_all([], []).
reverse_all([H|T], [ReversedH|ReversedT]) :-
    reverse(H, ReversedH),
    reverse_all(T, ReversedT).

% ------------------------------------------------------------------------------------------------

% Finds all shortest paths between two points - Distance and all paths
shortest_paths_multi(Board, StartRow-StartCol, EndRow-EndCol, Distance, Paths) :-
    bfs_all_shortest_paths(Board, [(StartRow-StartCol, 0, [StartRow-StartCol])], [], EndRow-EndCol, AllPaths),
    % Extract the minimum distance paths
    maplist(arg(1), AllPaths, Distances), 
    my_min_list(Distances, Distance),
    include(path_at_min_distance(Distance), AllPaths, MinDistancePaths),
    findall(Path, member(Distance-Path, MinDistancePaths), ReversedPaths),
    reverse_all(ReversedPaths, Paths).

bfs_all_shortest_paths(_, [], _, _, []):- !.
bfs_all_shortest_paths(Board, [(Row-Col, Dist, Path) | Queue], VisitedPieces, EndRow-EndCol, AllPaths) :-
    ( neighbor(Row, Col, EndRow, EndCol) ->
        NewDist is Dist + 1,
        AllPaths = [NewDist-[EndRow-EndCol|Path]|RestPaths],
        bfs_all_shortest_paths(Board, Queue, [(Row-Col, Dist) | VisitedPieces], EndRow-EndCol, RestPaths)
    ;
        find_neighbors_paths(Board, Row, Col, Dist, Path, VisitedPieces, Neighbors),
        append(Neighbors, Queue, NewQueue),  % Breadth-first: Neighbors are prepended
        bfs_all_shortest_paths(Board, NewQueue, [(Row-Col, Dist) | VisitedPieces], EndRow-EndCol, AllPaths)
    ).

path_at_min_distance(MinDistance, Distance-_) :-
    Distance =:= MinDistance.

% ------------------------------------------------------------------------------------------------

% Main function to find shortest paths between a specific cluster and all other clusters
shortest_paths_between_clusters(Board, FromX, FromY, Elements, AllShortestPaths):-

    find_cluster_with_element(Elements, FromX, FromY, Cluster),           % Get the starting cluster

    Cluster = [FirstElement|_],
    exclude(has_element(FirstElement), Elements, OtherClusters),          % Take out the cluster

    find_shortest_paths_for_all_clusters(Board, Cluster, OtherClusters, [], AllShortestPaths).

% Helper function to find the shortest paths between Cluster and all other clusters
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


% Function to find all shortest paths between two clusters
all_shortest_paths_between_two_clusters(Board, Cluster1, Cluster2, ShortestPaths) :-
    findall(
        Distance-Path,
        (
            member(E1, Cluster1),
            member(E2, Cluster2),
            E1 = Row1-Col1,
            E2 = Row2-Col2,
            /*shortest_paths_multi(Board, Col1-Row1, Col2-Row2, Distance, Path),*/
            shortest_paths(Board, Col1-Row1, Col2-Row2, Distance, Path),
            Distance > 0
        ),
        AllPaths
    ),

    sort(AllPaths, SortedPaths),
    SortedPaths = [MinDistance-_|_],
    include(same_min_distance(MinDistance), SortedPaths, ShortestPaths).

% Helper to check if a path has the minimum distance
same_min_distance(MinDistance, Distance-_) :- Distance =:= MinDistance.

% ------------------------------------------------------------------------------------------------

% Function to filter paths with the minimum distance
filter_minimum_distance_paths(AllShortestPaths, FilteredPaths) :-

    flat_list(AllShortestPaths, FlattenedPaths),

    findall(Distance, member(Distance-_, FlattenedPaths), Distances),

    my_min_list(Distances, MinDistance),

    include(same_min_distance(MinDistance), FlattenedPaths, FilteredPaths).


% ------------------------------------------------------------------------------------------------

% Main function to check if any path in AllShortestPaths includes the point (ToX, ToY)
path_includes_point(AllShortestPaths, ToX, ToY):-
    % Iterate through all shortest paths and check if any path includes the point (ToX, ToY)
    member(ShortestPaths, AllShortestPaths),
    member(_-PathList, ShortestPaths),  % PathList is the list of paths with associated Distance (ignore Distance)
    flat_list(PathList, Path),  % Flatten any nested list structure in PathList
    path_contains_point(Path, ToX, ToY),
    !.

% Helper function to check if a specific path contains the point (ToX, ToY)
path_contains_point([ToX-ToY | _], ToX, ToY).
path_contains_point([X-Y | Rest], ToX, ToY):-
    path_contains_point(Rest, ToX, ToY).

