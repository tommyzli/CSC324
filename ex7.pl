:- module(ex7,
          [contains/2,
           preorder/2,
           insert/3]).

% contains(T, Elem)
contains(node(Elem, _, _), Elem).
contains(node(X, Left, Right), Elem) :- contains(Left, Elem); contains(Right, Elem).

% preorder(T, List)
preorder(empty, []).
preorder(node(N, Left, Right), [N|Ns]) :- preorder(Left, LList), preorder(Right, RList), append(LList, RList, Ns).

% insert(T1, Elem, T2)
% You may asume that T1 and Elem are fully instantiated.
insert(empty, Elem, empty).
insert(empty, Elem, node(empty, Elem, empty)).
insert(node(_, Left, Right), Elem, node(Y, Left2, Right2)) :- insert(Left, Elem, Left2), insert(Right, Elem, Right2).