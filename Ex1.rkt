#| Exercise 1 - Getting started with Racket (due Jan 17, noon)

General exercise instructions:
- Exercises must be done *individually*.
- You may not import any Racket libraries, unless explicitly told to.
- You may not use mutation or any iterative constructs (for/*).
- You may write helper functions freely; in fact, you are encouraged
  to do so to keep your code easy to understand.
- Your grade will be determined by our automated testing.
  You can find some sample tests on the course webpage.
- Submit early and often! MarkUs is rather slow when many people
  submit at once. It is your responsibility to make sure your work is
  submitted on time.
- No late submissions will be accepted!

Implement the two functions below to get some experience programming in Racket.
You may use either explicit recursion, or higher-order list functions.
(For extra practice, try both!)
|#
#lang racket

; This line exports the required functions. Don't change it!
(provide search-table search-table-2 max-sublist)

#|
(search-table table item)
  table: a list of lists
  item: some value

  Returns a list containing the lists in 'table' which contain 'item'.
  The lists must appear in the same order they appear in 'table'.

> (search-table '((1 2 3) (4 2) (3 3 4) (5 3 2 1)) 1)
'((1 2 3) (5 3 2 1))
> (search-table '((1 2 3) (4 2) (3 3 4) (5 3 2 1)) 10)
'()
|#
; Feel free to change this signature to use the shorthand for defining functions
; (define (search-table ...) (...))
(define (search-table-helper lst val) ; is val in a non nested list
    (if (empty? lst)
        #f
        (if (equal? (first lst) val)
            #t
            (or #f (search-table-helper (rest lst) val)))))

(define (search-table lst val) 
    (if (empty? lst) 
        '()
        (if (equal? #t (search-table-helper (first lst) val))
            (cons (first lst) (search-table (rest lst) val))
            (search-table (rest lst) val))))

#|
(search-table-2 table item [pos])
  table: a list of lists
  item: any value
  pos: (*optional* parameter) an index in a list. Default value is 0. 
  
  Returns a list containing the lists in 'table' which have 'item' 
  at position 'pos'.
  Lists with length <= 'pos' should, of course, not be included.
  The lists must appear in the same order they appear in 'table'.

> (search-table-2 '((1 2 3) (4 2) (3 3 4) (5 3 2 1)) 1 3)
'((5 3 2 1))
> (search-table-2 '((1 2 3) (4 2) (3 3 4) (5 3 2 1)) 1)
'((1 2 3))

Hint: look up "declaring optional arguments in Racket". The syntax is
pretty straight-forward. Note that optional arguments must appear
*after* all the required ones.
|#
(define (helper-2 table item pos)
    (if (or (empty? table) (< (- (length table) 1) pos))
        #f
        (if (equal? (list-ref table pos) item)
            #t
            #f)))
     
(define (search-table-2 table item [pos 0]) 
    (if (empty? table)
        '()
        (if (equal? #t (helper-2 (first table) item pos))
            (cons (first table) (search-table-2 (rest table) item pos))
            (search-table-2 (rest table) item pos))))

#|
(max-sublist lst)
  lst: a list of numbers

  Returns the maximum sum of a sublist of numbers in 'lst'.
  A *sublist* of a list is a series of consecutive numbers in the list.

  Note that the *empty list* is a valid sublist of every list,
  and has a sum of 0.

  You may choose to use a brute-force O(n^3) algorithm for this question.
  However, for extra learning you're encouraged to try to find a O(n) algorithm.
  (Personally, I think the linear algorithm is actually easier to implement.)

> (max-sublist '(-1 10 -4 5 3 -100 6))
14  ; sum of '(10 -4 5 3)
> (max-sublist '(-4 -1 -2 -3))
0   ; sum of '()

Hint: you may find the "apply" function helpful.
|#
(define (sublist-helper lst) ; find max element in list
    (if (equal? (length lst) 1)
        (first lst)
        (if (equal? (max (sublist-helper (take lst (round (/ (length lst) 2))))
                         (sublist-helper (drop lst (round (/ (length lst) 2)))) 
                         0) 0)
            '()
            (list (max (sublist-helper (take lst (round (/ (length lst) 2))))
            (sublist-helper (drop lst (round (/ (length lst) 2))))))
            )))
        
(define (max-sublist lst)
    (if (equal? (length lst) 2)
        (sublist-helper lst)
        (void)))