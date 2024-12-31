check_piece(B, S, X, Y, CurrentPlayer):-
    between(1, S, X),
    between(1, S, Y),
    (CurrentPlayer = x, % implementar a verificação de peça
     CurrentPlayer = o). % implementar a verificação de peça