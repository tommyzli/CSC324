:- module(ex6,
          [sublist/2,
           with/3,
           shuffled/2]).

% sublist(S, L) : S is a sublist of list L. 
head(S, L) :- append(S, A, L).
rest(S, L) :- append(A, S, L).
sublist(S, L) :- head(T, L), rest(S, T).

% with(L, E, LE) : LE is the the list L with the item E inserted somewhere.
%with([], E, _).
with([], _, []).
with([], E, [E]).
with([X|Y], E, [E|Z]) :- with([X|Y], E, Z).
with([X|Y], E, [X|Z]) :- with(Y, E, Z).


% shuffled(L, S) : S is list L in some order.
% You may assume both L and S are fully instantiated.
shuffled([], []).
shuffled([X|Y], [X|Z]).