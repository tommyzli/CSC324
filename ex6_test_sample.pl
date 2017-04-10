:- use_module(library(plunit)).

:- begin_tests(ex6_tests).
:- use_module(ex6).

% Three different kinds of tests:
% 1. Expect success
% 2. Expect failure
% 3. Collect all possible instantiations
test(sub1, nondet) :- sublist([], [a]).
test(sub2, fail) :- sublist([c,d,a], [d,a,c]).
test(sub3) :- setof(S, sublist(S, [1,2,3]), Ss),
              Ss = [[], [1], [1,2], [1,2,3], [2], [2,3], [3]].

test(with1, nondet) :- with([a,b,c], 1, [a,b,1,c]).
test(with2, fail) :- with([], 1, [2, 3]).
test(with3) :- setof(S, E^with(S, E, [1,2,3,4]), Ss),
               Ss = [[1,2,3], [1,2,4], [1,3,4], [2,3,4]].

test(shuffled1, nondet) :- shuffled([a,b,c], [a,c,b]).
test(shuffled2, fail) :- shuffled([a,b,c], []).

:- end_tests(ex6_tests).

main(_) :- run_tests.
