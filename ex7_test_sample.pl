:- use_module(library(plunit)).

:- begin_tests(trees).
:- use_module(ex7).

test(contains, nondet) :- 
    contains(node(bob, empty, 
                       node(10, node(alice, empty, empty), empty)), alice).

test(preorder, nondet) :- preorder(empty, []).

test(insert, nondet) :- 
    insert(node(100,
                  node(50,
                       node(20,
                            node(10,
                                 node(5,
                                      empty,
                                      empty),
                                 empty),
                            empty),
                       empty),
                  empty),
           25,
           node(100,
                  node(50,
                       node(20,
                            node(10,
                                 node(5,
                                      empty,
                                      empty),
                                 empty),
                            node(25, empty, empty)),
                       empty),
                  empty)).

:- end_tests(trees).

main(_) :- run_tests.
