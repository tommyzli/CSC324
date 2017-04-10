#| Assignment 1 - Racket Query Language Tests (due February 11, noon)

***Write the names and CDF accounts for each of your group members below.***
Tommy Li, g3tommyl
Michael Li, g4limich
|#

; Note the use of plai here; this is required for "test"
#lang plai
(abridged-test-output #t)

; This imports your file; do not change this line!
(require "database.rkt")

; Test helpers - use these instead of the built-in syntactic forms.
; DON'T export them from database.rkt!
(define (And x y) (and x y))
(define (Or x y) (or x y))
(define (If x y z) (if x y z))

; Sample tables - add more tables!
; Ideas: empty table; table with just 1 attribute; 0 attributes; duplicates
(define Person
  '(("Name" "Age" "LikesChocolate") 
    ("David" 20 #t) 
    ("Jen" 30 #t) 
    ("Paul" 100 #f)))

(define Teaching
  '(("Name" "Course")
    ("David" "CSC324")
    ("Paul" "CSC108")
    ("David" "CSC343")
    ))


#|
All tests go below. 
We have divided our tests into five sections:
- No WHERE/ORDER BY
- WHERE clause, but no ORDER BY
- ORDER BY clause, but no WHERE
- Both WHERE and ORDER BY
- Nested queries

Please respect this categorization when you add your tests,
and your TAs will appreciate it!
|#


; ---- SELECT/FROM tests ----
; Select all
(test (SELECT * FROM Person)
      '(("Name" "Age" "LikesChocolate")
        ("David" 20 #t) 
        ("Jen" 30 #t) 
        ("Paul" 100 #f)))

; Reordering columns
(test (SELECT '("Age" "LikesChocolate" "Name") FROM Person)
      '(("Age" "LikesChocolate" "Name")
        (20 #t "David") 
        (30 #t "Jen") 
        (100 #f "Paul")))

; Select creates duplicates
(test (SELECT '("Name") FROM Teaching)
      '(("Name")
        ("David")
        ("Paul")
        ("David")))

; Select given a literal table
(test
 (SELECT '("A" "B")
   FROM '(("C" "A" "B" "D")
          (1 "Hi" 5 #t)
          (2 "Bye" 5 #f)
          (3 "Hi" 10 #t)))
 '(("A" "B")
   ("Hi" 5)
   ("Bye" 5)
   ("Hi" 10)))

; Select all from two product of two tables
(test (SELECT * FROM [Person "P"] [Teaching "T"])
      '(("P.Name" "Age" "LikesChocolate" "T.Name" "Course")
        ("David" 20 #t "David" "CSC324")
        ("David" 20 #t "Paul" "CSC108")
        ("David" 20 #t "David" "CSC343")
        ("Jen" 30 #t "David" "CSC324")
        ("Jen" 30 #t "Paul" "CSC108")
        ("Jen" 30 #T "David" "CSC343")
        ("Paul" 100 #f "David" "CSC324")
        ("Paul" 100 #f "Paul" "CSC108")
        ("Paul" 100 #f "David" "CSC343")))

; Select some from two tables
(test (SELECT '("P.Name" "Course" "Age") FROM [Person "P"] [Teaching "T"])
      '(("P.Name" "Course" "Age")
        ("David" "CSC324" 20)
        ("David" "CSC108" 20)
        ("David" "CSC343" 20)
        ("Jen" "CSC324" 30)
        ("Jen" "CSC108" 30)
        ("Jen" "CSC343" 30)
        ("Paul" "CSC324" 100)
        ("Paul" "CSC108" 100)
        ("Paul" "CSC343" 100)))

; Take the product of a table with itself
(test (SELECT '("E.Course" "E1.Course") FROM [Teaching "E1"] [Teaching "E"])
      '(("E.Course" "E1.Course")
        ("CSC324" "CSC324")
        ("CSC108" "CSC324")
        ("CSC343" "CSC324")
        ("CSC324" "CSC108")
        ("CSC108" "CSC108")
        ("CSC343" "CSC108")
        ("CSC324" "CSC343")
        ("CSC108" "CSC343")
        ("CSC343" "CSC343")))

; Take the product of a literal table with an identifier
(test
 (SELECT *
   FROM ['(("Age" "A" "Name" "D")
           (1 "Hi" 5 #t)
           (2 "Bye" 5 #f)
           (3 "Hi" 10 #t))
         "T1"]
        [Person "T2"])
 '(("T1.Age" "A" "T1.Name" "D" "T2.Name" "T2.Age" "LikesChocolate")
   (1 "Hi" 5 #t "David" 20 #t)
   (1 "Hi" 5 #t "Jen" 30 #t)
   (1 "Hi" 5 #t "Paul" 100 #f)
   (2 "Bye" 5 #f "David" 20 #t)
   (2 "Bye" 5 #f "Jen" 30 #t)
   (2 "Bye" 5 #f "Paul" 100 #f)
   (3 "Hi" 10 #t "David" 20 #t)
   (3 "Hi" 10 #t "Jen" 30 #t)
   (3 "Hi" 10 #t "Paul" 100 #f)))

; Part 2

; Take the product of two tables without their overlapping attribute
(test (SELECT '("LikesChocolate" "Course") FROM [Person "P"] [Teaching "T"])
      '(("LikesChocolate" "Course")
        (#t "CSC324")
        (#t "CSC108")
        (#t "CSC343")
        (#t "CSC324")
        (#t "CSC108")
        (#t "CSC343")
        (#f "CSC324")
        (#f "CSC108")
        (#f "CSC343")))

; Take nothing from a table
(test (SELECT '() FROM Person)
      '(() () () ()))

; Take nothing from the product of two tables
(test (SELECT '() FROM [Person "P"] [Teaching "T"])
      '(() () () () () () () () () ()))

; Reordering columns from two tables
(test (SELECT '("T.Name" "P.Name" "Course" "Age") FROM [Person "P"] [Teaching "T"])
      '(("T.Name" "P.Name" "Course" "Age")
        ("David" "David" "CSC324" 20)
        ("Paul" "David" "CSC108" 20)
        ("David" "David" "CSC343" 20)
        ("David" "Jen" "CSC324" 30)
        ("Paul" "Jen" "CSC108" 30)
        ("David" "Jen" "CSC343" 30)
        ("David" "Paul" "CSC324" 100)
        ("Paul" "Paul" "CSC108" 100)
        ("David" "Paul" "CSC343" 100)))

; The product of a table with itself three times
(test (SELECT '("P1.Name" "P2.Name") FROM [Person "P1"] [Person "P2"] [Person "P3"])
     '(("P1.Name" "P2.Name")
       ("David" "David")
       ("David" "David")
       ("David" "David")
       ("David" "Jen")
       ("David" "Jen")
       ("David" "Jen")
       ("David" "Paul")
       ("David" "Paul")
       ("David" "Paul")
       ("Jen" "David")
       ("Jen" "David")
       ("Jen" "David")
       ("Jen" "Jen")
       ("Jen" "Jen")
       ("Jen" "Jen")
       ("Jen" "Paul")
       ("Jen" "Paul")
       ("Jen" "Paul")
       ("Paul" "David")
       ("Paul" "David")
       ("Paul" "David")
       ("Paul" "Jen")
       ("Paul" "Jen")
       ("Paul" "Jen")
       ("Paul" "Paul")
       ("Paul" "Paul")
       ("Paul" "Paul")))

; select all from empty table
(test (SELECT * FROM '())
      '())

; Select none from empty table
(test (SELECT '() FROM '())
      '(()))

; Select from table joined with empty table on left side
(test (SELECT * FROM ['() "A"] [Person "P"])
      '(("Name" "Age" "LikesChocolate")))
      
; Select from table joined with empty table on right side
(test (SELECT * FROM [Person "P"] ['() "A"])
      '(("Name" "Age" "LikesChocolate")))

; Select from two joined empty tables
(test (SELECT * FROM ['() "A"] ['() "B"])
      '(()))

; ---- WHERE ----
; Attribute as condition, select all
(test (SELECT *
        FROM Person
        WHERE "LikesChocolate")
      '(("Name" "Age" "LikesChocolate")
        ("David" 20 #t)
        ("Jen" 30 #t)))

; Attribute as condition, select subset
(test (SELECT '("LikesChocolate" "Name")
        FROM Person
        WHERE "LikesChocolate")
      '(("LikesChocolate" "Name")
        (#t "David")
        (#t "Jen")))

; Condition as function of one attribute, select all
(test (SELECT *
        FROM Person
        WHERE (< 50 "Age"))
      '(("Name" "Age" "LikesChocolate")
        ("Paul" 100 #f)))

; Condition as function of one attribute, select none
(test (SELECT '()
        FROM Teaching
        WHERE (equal? "Name" "David"))
      '(()
        ()
        ()))

; Constant true condition
(test (SELECT *
        FROM Person
        WHERE #t)
      Person)

; Constant false compound condition
(test (SELECT *
        FROM Person
        WHERE (> (string-length "David") 20))
      '(("Name" "Age" "LikesChocolate")))

; Condition on a literal table
(test (SELECT '("C" "B")
        FROM '(("A" "B" "C") 
               (1 2 3)
               (3 10 40)
               (4 4 4)
               (2 3 -1))
        WHERE (odd? "A"))
      '(("C" "B")
        (3 2)
        (40 10)))

; Simple condition on joined tables
(test (SELECT *
        FROM [Person "P"] [Teaching "T"]
        WHERE (equal? "P.Name" "T.Name"))
      '(("P.Name" "Age" "LikesChocolate" "T.Name" "Course")
        ("David" 20 #t "David" "CSC324")
        ("David" 20 #t "David" "CSC343")
        ("Paul" 100 #f "Paul" "CSC108")))

; Compound condition on three joined tables
(test (SELECT '("P1.Name" "P1.LikesChocolate" "P.Age" "Course")
        FROM [Person "P"] [Teaching "T"] [Person "P1"]
        WHERE (And "P.LikesChocolate" (equal? "P1.Name" "T.Name")))
      '(("P1.Name" "P1.LikesChocolate" "P.Age" "Course")
        ("David" #t 20 "CSC324")
        ("Paul" #f 20 "CSC108")
        ("David" #t 20 "CSC343")
        ("David" #t 30 "CSC324")
        ("Paul" #f 30 "CSC108")
        ("David" #t 30 "CSC343")))

; Part 2

; Constant false condition
(test (SELECT * FROM Person WHERE #f)
      '(("Name" "Age" "LikesChocolate")))
      
; Constant true compound condition
(test (SELECT * FROM Person WHERE (< (string-length "David") 20))
      Person)

; Constant false condition on joined tables
(test (SELECT * FROM [Person "P"] [Teaching "T"] WHERE #f)
      '(("P.Name" "Age" "LikesChocolate" "T.Name" "Course")))
      
; Constant true condition on joined tables
(test (SELECT * FROM [Person "P"] [Teaching "T"] WHERE #t)
      '(("P.Name" "Age" "LikesChocolate" "T.Name" "Course")
        ("David" 20 #t "David" "CSC324")
        ("David" 20 #t "Paul" "CSC108")
        ("David" 20 #t "David" "CSC343")
        ("Jen" 30 #t "David" "CSC324")
        ("Jen" 30 #t "Paul" "CSC108")
        ("Jen" 30 #T "David" "CSC343")
        ("Paul" 100 #f "David" "CSC324")
        ("Paul" 100 #f "Paul" "CSC108")
        ("Paul" 100 #f "David" "CSC343")))

; Constant false compound condition on joined tables
(test (SELECT * FROM [Person "P"] [Teaching "T"] WHERE (And (> (string-length "David") 20) #f))
      '(("P.Name" "Age" "LikesChocolate" "T.Name" "Course")))

; Constant true compound condition on joined tables
(test (SELECT * FROM [Person "P"] [Teaching "T"] WHERE (And (< (string-length "David") 20) #t))
      '(("P.Name" "Age" "LikesChocolate" "T.Name" "Course")
        ("David" 20 #t "David" "CSC324")
        ("David" 20 #t "Paul" "CSC108")
        ("David" 20 #t "David" "CSC343")
        ("Jen" 30 #t "David" "CSC324")
        ("Jen" 30 #t "Paul" "CSC108")
        ("Jen" 30 #T "David" "CSC343")
        ("Paul" 100 #f "David" "CSC324")
        ("Paul" 100 #f "Paul" "CSC108")
        ("Paul" 100 #f "David" "CSC343")))

; Condition as function of one attribute, select subset
(test (SELECT '("Name" "Age") FROM Person WHERE (equal? "LikesChocolate" #t))
      '(("Name" "Age")
        ("David" 20)
        ("Jen" 30)))

; Condition on two attributes with matches, select some
(test (SELECT '("Name") FROM Person WHERE (And (< "Age" 50) (equal? "LikesChocolate" #t)))
      '(("Name")
        ("David")
        ("Jen")))

; Condition on two attributes with matches, select all
(test (SELECT * FROM Person WHERE (And (< "Age" 50) (equal? "LikesChocolate" #t)))
      '(("Name" "Age" "LikesChocolate")
        ("David" 20 #t)
        ("Jen" 30 #t)))

; Condition on two attributes with no matches, select some
(test (SELECT '("Name") FROM Person WHERE (And (> "Age" 50) (equal? "LikesChocolate" #t)))
      '(("Name")))

; Condition on two attributes with no matches, select all
(test (SELECT * FROM Person WHERE (And (> "Age" 50) (equal? "LikesChocolate" #t)))
      '(("Name" "Age" "LikesChocolate")))

; Condition on two attributes, select none
(test (SELECT '() FROM Person WHERE (And (> "Age" 50) (equal? "LikesChocolate" #f)))
      '(()
        ()))

; Select none from attribute as condition
(test (SELECT '() FROM Person WHERE "LikesChocolate")
      '(()
        ()
        ()))

; Select from empty table with true condition
(test (SELECT * FROM '() WHERE #t)
      '(()))

; Select from empty table with false condition
(test (SELECT * FROM '() WHERE #f)
      '(()))


; ---- ORDER BY ----
; Order by attribute
(test (SELECT *
        FROM Person
        ORDER BY "Age")
      '(("Name" "Age" "LikesChocolate")
        ("Paul" 100 #f)
        ("Jen" 30 #t)
        ("David" 20 #t)))

; Order by attribute, not selected
(test (SELECT '("Name")
        FROM Person
        ORDER BY "Age")
      '(("Name")
        ("Paul")
        ("Jen")
        ("David")))

; Order by a function of an attribute
(test (SELECT *
        FROM Person
        ORDER BY (string-length "Name"))
      '(("Name" "Age" "LikesChocolate")
        ("David" 20 #t)
        ("Paul" 100 #f)
        ("Jen" 30 #t)))

; Order with duplicate
(test (SELECT *
        FROM Teaching
        ORDER BY (+ (string-length "Name") (string-length "Course")))
      '(("Name" "Course")
        ("David" "CSC324")
        ("David" "CSC343")
        ("Paul" "CSC108")))

; Order on a literal table
(test (SELECT *
        FROM '(("A" "B" "C") 
               (1 2 3)
               (3 10 40)
               (4 4 4)
               (2 3 -1))
        ORDER BY "C")
      '(("A" "B" "C")
        (3 10 40)
        (4 4 4)
        (1 2 3)
        (2 3 -1)))

; Order on two tables
(test (SELECT *
        FROM [Person "P"] [Teaching "T"]
        ORDER BY "Age")
      '(("P.Name" "Age" "LikesChocolate" "T.Name" "Course")
        ("Paul" 100 #f "David" "CSC324")
        ("Paul" 100 #f "Paul" "CSC108")
        ("Paul" 100 #f "David" "CSC343")
        ("Jen" 30 #t "David" "CSC324")
        ("Jen" 30 #t "Paul" "CSC108")
        ("Jen" 30 #t "David" "CSC343")
        ("David" 20 #t "David" "CSC324")
        ("David" 20 #t "Paul" "CSC108")
        ("David" 20 #t "David" "CSC343")))

; Part 2

; Order by function of attribute, not selected
(test (SELECT '("Name")
        FROM Person
        ORDER BY (string-length "Name"))
      '(("Name")
        ("David")
        ("Paul")
        ("Jen")))

; Order by attribute, select none
(test (SELECT '() FROM Person ORDER BY "Age")
      '(() () () ()))

; Order by function of attribute, select none
(test (SELECT '() FROM Person ORDER BY (string-length "Name"))
      '(() () () ()))

; Order by function of attribute on two tables
(test (SELECT * FROM [Person "P"] [Teaching "T"] ORDER BY (string-length "P.Name"))
      '(("P.Name" "Age" "LikesChocolate" "T.Name" "Course")
        ("David" 20 #t "David" "CSC324")
        ("David" 20 #t "Paul" "CSC108")
        ("David" 20 #t "David" "CSC343")
        ("Paul" 100 #f "David" "CSC324")
        ("Paul" 100 #f "Paul" "CSC108")
        ("Paul" 100 #f "David" "CSC343")
        ("Jen" 30 #t "David" "CSC324")
        ("Jen" 30 #t "Paul" "CSC108")
        ("Jen" 30 #t "David" "CSC343")))

; Order by function of attribute on two tables, select some
(test (SELECT '("P.Name" "Age" "T.Name") FROM [Person "P"] [Teaching "T"] ORDER BY "Age")
      '(("P.Name" "Age" "T.Name")
        ("Paul" 100 "David")
        ("Paul" 100 "Paul")
        ("Paul" 100 "David")
        ("Jen" 30 "David")
        ("Jen" 30 "Paul")
        ("Jen" 30 "David")
        ("David" 20 "David")
        ("David" 20 "Paul")
        ("David" 20 "David")))

; Order by function of attribute on two tables, select none
(test (SELECT '() FROM [Person "P"] [Teaching "T"] ORDER BY (string-length "P.Name"))
      '(() () () () () () () () () ()))


; ---- ORDER BY and WHERE ----
; Use attributes, select all
(test
 (SELECT * 
   FROM Person 
   WHERE "LikesChocolate" 
   ORDER BY "Age")
 '(("Name" "Age" "LikesChocolate")
   ("Jen" 30 #t)
   ("David" 20 #t)))

; Use attributes, select one unused attribute
(test
 (SELECT '("Name") 
   FROM Person 
   WHERE "LikesChocolate" 
   ORDER BY "Age")
 '(("Name")
   ("Jen")
   ("David")))

; Two joined tables, select all
(test
 (SELECT * 
   FROM [Person "P"] [Teaching "T"] 
   WHERE (equal? "P.Name" "T.Name")
   ORDER BY "Age")
 '(("P.Name" "Age" "LikesChocolate" "T.Name" "Course")
   ("Paul" 100 #f "Paul" "CSC108")
   ("David" 20 #t "David" "CSC324")
   ("David" 20 #t "David" "CSC343")))

; Two joined tables, select some attributes
(test
 (SELECT '("P.Name" "Course" "LikesChocolate")
   FROM [Person "P"] [Teaching "T"] 
   WHERE (equal? "P.Name" "T.Name")
   ORDER BY "Age")
 '(("P.Name" "Course" "LikesChocolate")
   ("Paul" "CSC108" #f)
   ("David" "CSC324" #t)
   ("David" "CSC343" #t)))

; Part 2

; Use attributes, select one used attribute
(test
 (SELECT '("Age") 
   FROM Person 
   WHERE "LikesChocolate" 
   ORDER BY "Age")
 '(("Age")
   (30)
   (20)))

; Use attributes, select none
(test (SELECT '() FROM Person WHERE "LikesChocolate" ORDER BY "Age")
      '(() () ()))

; Two joined tables, select none
(test (SELECT '() FROM [Person "P"] [Teaching "T"] WHERE (equal? "P.Name" "T.Name") 
              ORDER BY "Age")
      '(() () () ()))

; One table, false where condition
(test (SELECT * FROM Person WHERE #f ORDER BY "Age")
      '(("Name" "Age" "LikesChocolate")))

; One table, true where condition
(test (SELECT * FROM Person WHERE #t ORDER BY "Age")
      '(("Name" "Age" "LikesChocolate") 
        ("Paul" 100 #f) 
        ("Jen" 30 #t) 
        ("David" 20 #t)))

; Two joined tables, true where condition
(test (SELECT * FROM [Person "P"] [Teaching "T"] WHERE #t ORDER BY "Age")
      '(("P.Name" "Age" "LikesChocolate" "T.Name" "Course")
        ("Paul" 100 #f "David" "CSC324")
        ("Paul" 100 #f "Paul" "CSC108")
        ("Paul" 100 #f "David" "CSC343")
        ("Jen" 30 #t "David" "CSC324")
        ("Jen" 30 #t "Paul" "CSC108")
        ("Jen" 30 #t "David" "CSC343")
        ("David" 20 #t "David" "CSC324")
        ("David" 20 #t "Paul" "CSC108")
        ("David" 20 #t "David" "CSC343")))
      
; Two joined tables, false where condition
(test (SELECT * FROM [Person "P"] [Teaching "T"] WHERE #f ORDER BY "Age")
      '(("P.Name" "Age" "LikesChocolate" "T.Name" "Course")))

; Two joined tables with where and order by
(test (SELECT * FROM [Person "P"] [Teaching "T"] WHERE (< "Age" 50) 
              ORDER BY "Age")
      '(("P.Name" "Age" "LikesChocolate" "T.Name" "Course")
        ("Jen" 30 #t "David" "CSC324")
        ("Jen" 30 #t "Paul" "CSC108")
        ("Jen" 30 #t "David" "CSC343")
        ("David" 20 #t "David" "CSC324")
        ("David" 20 #t "Paul" "CSC108")
        ("David" 20 #t "David" "CSC343")))

; Select some from two joined tables with where and order by
(test (SELECT '("P.Name" "Course") FROM [Person "P"] [Teaching "T"] 
              WHERE (> "Age" 50) ORDER BY (string-length "T.Name"))
      '(("P.Name" "Course")
        ("Paul" "CSC324")
        ("Paul" "CSC343")
        ("Paul" "CSC108")))

; Order by with nested where conditions
(test (SELECT * FROM Person WHERE (And (< "Age" 50) (equal? "LikesChocolate" #t)) 
              ORDER BY "Age")
      '(("Name" "Age" "LikesChocolate")
        ("Jen" 30 #t)
        ("David" 20 #t)))
      


; ---- Nested queries ----                                              
(test 
 (SELECT * 
   FROM (SELECT '("Age" "Name") FROM Person))
 '(("Age" "Name")
   (20 "David")
   (30 "Jen")
   (100 "Paul")))

(test
 (SELECT '("Person.Name" "Course")
   FROM [(SELECT '("Name") FROM Person) "Person"]
        [(SELECT * FROM Teaching WHERE (Or (equal? "Course" "CSC343")
                                           (equal? "Course" "CSC108")))
         "Teaching"])
 '(("Person.Name" "Course")
   ("David" "CSC108")
   ("David" "CSC343")
   ("Jen" "CSC108")
   ("Jen" "CSC343")
   ("Paul" "CSC108")
   ("Paul" "CSC343")))

; Nested query containing a literal
(test
 (SELECT *
   FROM [(SELECT '("A") 
           FROM '(("A" "B") 
                  (1)
                  (10)))
         "Table1"]
        [(SELECT *
           FROM '(("C" "A")
                  ("Hi" "Bye")
                  ("Dog" "Cat")
                  ("Red" "Blue")))
         "Table2"]
   WHERE (And (equal? (string-length "Table2.A") 3) (< 0  "Table1.A")))
 '(("Table1.A" "C" "Table2.A")
   (1 "Hi" "Bye")
   (1 "Dog" "Cat")
   (10 "Hi" "Bye")
   (10 "Dog" "Cat")))

; Part 2

; Select all from select from where true
(test (SELECT * FROM (SELECT '("Name") FROM Person WHERE (< "Age" 101)))
      '(("Name")
        ("David")
        ("Jen")
        ("Paul")))

; Select some from select from where true
(test (SELECT '("Name") FROM (SELECT * FROM Person WHERE (< "Age" 101)))
      '(("Name")
        ("David")
        ("Jen")
        ("Paul")))

; Select all from select from where false
(test (SELECT * FROM (SELECT '("Name") FROM Person WHERE #f))
      '(("Name")))

; Select some from select from where false
(test (SELECT '("Name") FROM (SELECT '("Name" "Age") FROM Person WHERE #f))
      '(("Name")))

; Select all from select from order by attribute
(test (SELECT * FROM (SELECT '("Name") FROM Person ORDER BY "Age"))
      '(("Name")
        ("Paul")
        ("Jen")
        ("David")))

; Select all from select from where order by attribute
(test (SELECT * FROM (SELECT * FROM Person WHERE (< "Age" 50)) ORDER BY "Age")
      '(("Name" "Age" "LikesChocolate")
        ("Jen" 30 #t)
        ("David" 20 #t)))

; Select some from select from where order by attribute
(test (SELECT '("Name" "Age") FROM (SELECT * FROM Person WHERE "LikesChocolate") ORDER BY "Age")
      '(("Name" "Age")
        ("Jen" 30)
        ("David" 20)))

; Select all from select from where false order by attribute
(test (SELECT * FROM (SELECT * FROM Person WHERE #f) ORDER BY "Age")
      '(("Name" "Age" "LikesChocolate")))

; Select none from select from where
(test (SELECT '() FROM (SELECT * FROM Person WHERE (equal? "LikesChocolate" #t))) 
      '(() () ()))                                             

; Select all from select none
(test (SELECT * FROM (SELECT '() FROM Person))
      '(() () () ()))

; Select all from two joined queries
(test (SELECT * FROM 
              [(SELECT '("Name") FROM Person) "P"]
              [(SELECT '("Course") FROM Teaching) "T"])
      '(("Name" "Course")
        ("David" "CSC324")
        ("David" "CSC108")
        ("David" "CSC343")
        ("Jen" "CSC324")
        ("Jen" "CSC108")
        ("Jen" "CSC343")
        ("Paul" "CSC324")
        ("Paul" "CSC108")
        ("Paul" "CSC343")))


; Select from one of two joined queries
(test (SELECT '("P.Name") FROM 
              [(SELECT * FROM Person) "P"]
              [(SELECT * FROM Teaching) "T"])
      '(("P.Name")
        ("David")
        ("David")
        ("David")
        ("Jen")
        ("Jen")
        ("Jen")
        ("Paul")
        ("Paul")
        ("Paul")))

; Select none from two joined queries
(test (SELECT '() FROM 
              [(SELECT * FROM Person) "P"]
              [(SELECT * FROM Teaching) "T"])
      '(() () () () () () () () () ()))

; Select all from two joined queries order by function of attribute
(test (SELECT * FROM 
              [(SELECT '("Age") FROM Person) "P"]
              [(SELECT '("Course") FROM Teaching) "T"] ORDER BY (string-length "P.Name"))
      '(("Age" "Course")
        (20 "CSC324")
        (20 "CSC108")
        (20 "CSC343")
        (30 "CSC324")
        (30 "CSC108")
        (30 "CSC343")
        (100 "CSC324")
        (100 "CSC108")
        (100 "CSC343")))

; Select from one of two joined queries order by function of attribute
(test (SELECT '("Name") FROM
              [(SELECT '("Name") FROM Person) "P"]
              [(SELECT '("Course") FROM Teaching) "T"] ORDER BY (string-length "Name"))
      '(("Name")
        ("David")
        ("David")
        ("David")
        ("Paul")
        ("Paul")
        ("Paul")
        ("Jen")
        ("Jen")
        ("Jen")))

; Select from joined queries with where condition and order by function of attribute
(test (SELECT * FROM 
              [(SELECT * FROM Person WHERE (equal? "LikesChocolate" #t)) "P"]
              [Teaching "T"] ORDER BY (string-length "P.Name"))
      '(("P.Name" "Age" "LikesChocolate" "T.Name" "Course")
        ("David" 20 #t "David" "CSC324")
        ("David" 20 #t "Paul" "CSC108")
        ("David" 20 #t "David" "CSC343")
        ("Jen" 30 #t "David" "CSC324")
        ("Jen" 30 #t "Paul" "CSC108")
        ("Jen" 30 #t "David" "CSC343")))

