:- module(ex8,
          [change/4,
           changeList/3]).

% change(M, P, N, D)
change(0, 0, 0, 0).
change(M, P, 0, 0) :- changeP(M, P).
change(M, 0, N, 0) :- changeN(M, N).
change(M, 0, 0, D) :- changeD(M, D).
change(M, P, N, 0) :- changePN(M, P, N).
change(M, P, 0, D) :- changePD(M, P, D).
change(M, 0, N, D) :- changeND(M, N, D).
change(M, P, N, D) :- changePND(M, P, N, D).



% -- Some helpers you may want to implement --

% changeP(M, P) : Succeeds if and only if M = P.
changeP(X, X).
changeN(M, N) :- M is (5 * N).
changeD(M, D) :- M is (10 * D).

% changePN(M, P, N) : Succeeds if M = P + 5N.
changePN(M, P, N) :- M is (5 * N) + P.
changePD(M, P, D) :- M is (10 * D) + P. 
changeND(M, N, D) :- M is (10 * D) + (5 * N).

changePND(M, N, D, P) :- M is (10 * D) + (5 * N) + P.



% changeList(M, Denoms, Counts)
changeList(0, [], []).
changeList(M, [X|Xs], [Y|Ys]) :- Z is M - (X * Y), changeList(Z, Xs, Ys).
