 #| Assignment 1 - Racket Query Language (due February 11, noon)

***Write the names and CDF accounts for each of your group members below.***
Michael Li g4limich
Tommy Li g3tommyl
|#
#lang racket

; Function versions for common syntactic forms.
; *Use these in your queries instead of the syntactic forms!!!*
(define (And x y) (and x y))
(define (Or x y) (or x y))
(define (If x y z) (if x y z))

; TODO: After you have defined your macro(s), make sure you add each one
; to the provide statement.
(provide attributes
         tuples
         size
         SELECT)

; Part 0: Semantic aliases

#|
(attributes table)
  table: a valid table (i.e., a list of lists as specified by assigment)

  Returns a list of the attributes in 'table', in the order they appear.
|#
(define (attributes table)
  (if (equal? table '())
      '()
      (first table)))

#|
(tuples table)
  table: a valid table

  Returns a list of all tuples in 'table', in the order they appear.
  Note: it is possible for 'table' to contain no tuples.
|#
(define (tuples table)
  (if (equal? table '())
      '()
      (rest table)))

#|
(size table)
  table: a valid table

  Returns the number of tuples in 'table'.
|#
(define (size table)
  (length (tuples table)))

#|
Basic SELECT helper functions

(select-helper attr table)
   attr: a list of the requested attributes
   table: a valid table

   Returns the columns that correspond to attr in the table
|#
(define (select-helper attr table)
  (if (equal? attr *)
      table
      (cons attr
            (map (lambda (x) 
                   (multi-ref (attr-pos attr (attributes table)) x)) (tuples table)))))
#| (multi-ref pos lst)
   pos - list of integers indicating list indexes
   lst - a list of attributes

   Returns a list of values corresponding to the pos indexes of lst

> (multi-ref '(2 0) '("Hello" "Goodbye" "Ha"))
'("Ha" "Hello")
|#
(define (multi-ref pos lst)
  (map (lambda (y) (list-ref lst y)) pos))
  

#|(attr-pos attr table)
   attr - list of requested attributes
   table - list of all attributes

   Returns a list of ints containing indexes of requested attributes in table

> (attr-pos '("name" "hello") '("hello" "goodbye" "name" "lol"))
 '(2 0)
|#  
(define (attr-pos attr table)
  (map (lambda (x) (get-index table x)) attr))


; FROM helper functions  

#| (from-helper tables names attrs)
   tables - list of valid tables
   names - list of names of tables
   attrs - list of all the attributes of all of the tables

   Returns the cartesian product of all given tables along with naming duplicate attributes
|#
(define (from-helper tables names attrs)
  (cons (flatten (attr-namer attrs names))
        (multi-product (length tables) (first tables) (rest tables))))


#| (attr-namer attributes names)
   attributes - list of lists of attributes
   names - list of strings that represent the name of a table
   Returns a list of attributes where the duplicates have their identifier from names
   prefixed onto them

> (attr-namer '(("Hello" "Goodbye")("Age" "Hello") ("Hello" "Age")) '("A" "B" "C"))
               
'(("A.Hello" "Goodbye") ("B.Age" "B.Hello") ("C.Hello" "C.Age"))
   
|#
(define (attr-namer attributes names)
  (let ([all (flatten attributes)])
        (map (lambda (x y) 
               (attr-func x y all)) attributes names)))


#| (attr-func lst name all)
   lst - list of attributes for current table 
   name - string name of current table
   all - list of all attributes from all tables

   Returns attribute names for a single table 

> (attr-func '("name") "Phil" '("name" "age" "name" "Hi" "name"))
'("Phil.name")
|# 
(define (attr-func lst name all)
  (if (equal? lst '())
      '()
      (if (member (first lst) (remove (first lst) all ))
          (cons (string-append name "." (first lst)) (attr-func (rest lst) name all))
          (cons (first lst) (attr-func (rest lst) name all))))) 

#| (multi-product size table1 table2)
   size - number of tables left to cartesian-product together 
   table1 - a valid table 
   table2 - list of valid tables

   Returns the cartesian-product of all tables
|#

(define (multi-product size table1 table2)
  (if (equal? size 2)
      (cartesian-product (tuples table1) (tuples (first table2))) ; remove extraenous brackets the list creates
      (cartesian-product (tuples table1) (multi-product (- size 1) (first table2) (rest table2)))))


#| (cartesian-product table1 table2)
   table1 - a valid  table 
   table2 - another valid table

   Returns the cartesian-product of the two tables
|#
(define (cartesian-product table1 table2)
  (foldl (lambda (x r) (append r (cartesian-helper x table2))) '() table1))

#| (cartesian-product table1 table2)
   table1 - a valid  list 
   table2 - a valid list

   Returns cartesian-product of the two lists
|#
(define (cartesian-helper table1 table2)
  (map (lambda (x) (append table1 x)) table2))


#| (get-index lst val)
   lst - lst of values
   val - valid value sought after in lst

   Returns the index of a value in a list, or false if the value not located in lst
|#
(define (get-index lst val)
  (if (member val lst)
      (if (equal? (first lst) val)
          0
          (+ 1 (get-index (rest lst) val)))
      #f))


; WHERE helper functions 


#| (check-attr attributes name tup)
    attributes - a list of attributes
    name - a string (representing an attribute)
    tup - a tuple

    Returns the value of the tuple corresponding to that attribute.
|#
(define (check-attr attributes name tup)
  (list-ref tup (get-index attributes name)))


#| (filter-helper f table)
    f: a unary function that takes a tuple and returns a boolean value
    table: a valid table

    Returns a new table containing only the tuples in 'table'
    that satisfy 'f'.

|#
(define (filter-helper f table)
  (cons (attributes table)
          (filter f (tuples table)))) 


#| (replace-attr x attr)
    x - a possible element of attr
    attr - a list of attributes for the predicate

    Returns a function 'f' which takes a tuple and does the following:
    - If 'x' is in the list of attributes, return the corrresponding value 
      in the tuple.
    - Otherwise, just ignore the tuple and return 'x'.
|#
(define (replace-attr x attr)
  (lambda (y)
    (if (member x attr)
        (check-attr attr x y)
        x)))



#| (order-by-helper f table)
    f - funcion to sort tuples by
    table - a valid table

    Return the table sorted by the order indicated by f in non-increasing order
|#
(define (order-by-helper f table)
  (cons (attributes table) 
        (sort (tuples table)
              #:key f >))) 


; Macro for SELECT operations
(define-syntax SELECT 
  (syntax-rules (SELECT FROM WHERE ORDER BY)
    ; Basic select with no other operations
    [(SELECT want FROM table)
     (select-helper want table)]
    
    ; Select with one operation
    [(SELECT want FROM [table1 name1] ...)
     (let ([tables (list table1 ... )]
           [names (list name1 ... )]
           [attrs (list  (attributes table1) ...)])
       (select-helper want (from-helper tables names attrs)))]
    
    [(SELECT want FROM table WHERE (cond ...) )
      (select-helper want
                     (filter-helper (replace (cond ...) table) table))]
    
   [(SELECT want FROM table WHERE cond)
    (select-helper want
                     (filter-helper (replace cond table) table))]
    
    [(SELECT want FROM table ORDER BY expr)
     (select-helper want
                    (order-by-helper (replace expr table) table))]
  
    
    [(SELECT want FROM table ORDER BY (expr ...))
     (select-helper want
                    (order-by-helper (replace (expr ...) table) table))]
           
       
    ; Select with two operations
    [(SELECT want FROM [table1 name1] ... WHERE (cond ...))
     (let ([tables (list table1 ... )]
           [names (list name1 ... )]
           [attrs (list  (attributes table1) ...)])
       (let ([final (from-helper tables names attrs)])
         (select-helper want (filter-helper (replace (cond ...) final ) final ))))]
    
    [(SELECT want FROM [table1 name1] ... WHERE cond)
     (let ([tables (list table1 ... )]
           [names (list name1 ... )]
           [attrs (list  (attributes table1) ...)])
       (let ([final (from-helper tables names attrs)])
         (select-helper want (filter-helper (replace cond final ) final ))))]    
   
    
    [(SELECT want FROM [table1 name1] ... ORDER BY (expr ...))
     (let ([tables (list table1 ... )]
           [names (list name1 ... )]
           [attrs (list  (attributes table1) ...)])
       (let ([final (from-helper tables names attrs)])
         (select-helper want
                    (order-by-helper (replace (expr ...) final) final))))]
    
    [(SELECT want FROM [table1 name1] ... ORDER BY expr)
     (let ([tables (list table1 ... )]
           [names (list name1 ... )]
           [attrs (list  (attributes table1) ...)])
       (let ([final (from-helper tables names attrs)])
         (select-helper want
                    (order-by-helper (replace expr final) final))))]
    
    [(SELECT want FROM table WHERE (cond ...) ORDER BY (expr ...))
     (let ([final (filter-helper (replace (cond ...) table ) table )])
       (select-helper want
                      (order-by-helper (replace (expr ...) final) final)))]
   
    [(SELECT want FROM table WHERE cond ORDER BY (expr ...))
     (let ([final (filter-helper (replace cond table ) table )])
       (select-helper want
                      (order-by-helper (replace (expr ...) final) final)))]
    
    [(SELECT want FROM table WHERE (cond ...) ORDER BY expr)
     (let ([final (filter-helper (replace (cond ...) table ) table )])
       (select-helper want
                      (order-by-helper (replace expr final) final)))]
    
    [(SELECT want FROM table WHERE cond ORDER BY expr)
     (let ([final (filter-helper (replace cond table ) table )])
       (select-helper want
                      (order-by-helper (replace expr final) final)))]

    
    ; Select with every operation
    [(SELECT want FROM [table1 name1] ... WHERE (cond ...) ORDER BY (expr ...))
     (let ([tables (list table1 ... )]
           [names (list name1 ... )]
           [attrs (list  (attributes table1) ...)])
       (let ([intermediate (from-helper tables names attrs)])
         (let ([final (filter-helper (replace (cond ...) intermediate ) intermediate )])
         (select-helper want (order-by-helper (replace (expr ...) final ) final )))))]
    
    [(SELECT want FROM [table1 name1] ... WHERE cond ORDER BY (expr ...))
     (let ([tables (list table1 ... )]
           [names (list name1 ... )]
           [attrs (list  (attributes table1) ...)])
       (let ([intermediate (from-helper tables names attrs)])
         (let ([final (filter-helper (replace cond intermediate ) intermediate )])
         (select-helper want (order-by-helper (replace (expr ...) final ) final )))))]
    
    [(SELECT want FROM [table1 name1] ... WHERE (cond ...) ORDER BY expr)
     (let ([tables (list table1 ... )]
           [names (list name1 ... )]
           [attrs (list  (attributes table1) ...)])
       (let ([intermediate (from-helper tables names attrs)])
         (let ([final (filter-helper (replace (cond ...) intermediate) intermediate )])
         (select-helper want (order-by-helper (replace expr final ) final )))))]
    
    [(SELECT want FROM [table1 name1] ... WHERE cond ORDER BY expr)
     (let ([tables (list table1 ... )]
           [names (list name1 ... )]
           [attrs (list  (attributes table1) ...)])
       (let ([intermediate (from-helper tables names attrs)])
         (let ([final (filter-helper (replace cond intermediate) intermediate )])
         (select-helper want (order-by-helper (replace expr final ) final )))))]))
         

; Starter for Part 4; feel free to ignore!

; What should this macro do?
(define-syntax replace
  (syntax-rules ()
    ; The recursive step, when given a compound expression
    [(replace (expr ...) table)
     ; Change this!
      (lambda (x) (((replace expr table) x) ... ))]
    ; The base case, when given just an atom. This is easier!
    [(replace atom table)
    (replace-attr atom (attributes table))]))
        
  
  
  
  
  