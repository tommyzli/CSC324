{- Exercise 4, due Feb 28, noon

General exercise instructions:
- Exercises must be done *individually*.
- You may not import any Haskell libraries, unless explicitly told to.
- You may write helper functions freely; in fact, you are encouraged
  to do so to keep your code easy to understand.
- Your grade will be determined by our automated testing.
  You can find some sample tests on the course webpage.
- Submit early and often! MarkUs is rather slow when many people
  submit at once. It is your responsibility to make sure your work is
  submitted on time.
- No late submissions will be accepted!

This exercise is mainly a chance to practice writing code in Haskell,
although we'll take advantage of lazy evaluation to create some nice
infinite data structures. :)
-}

-- This line creates a module to allow exporting of functions.
module Ex4 (primes, Tree(Empty, Node), infinitree) where

-- Question 1
-- Define 'primes', an infinite list of primes (in ascending order).
-- Remember that 1 is not a prime, but 2 is a prime.
-- You may want to follow the same strategy you used in Lab 2.
-- Also, you should use the definition of nats given in lecture.
plus1 x = x + 1
nat_from_2 = 2: map plus1 nat_from_2
lst = nat_from_2
prime_helper :: [Integer] -> [Integer]
prime_helper (x:xs) = x : prime_helper (filter (\y -> y `mod` x /= 0) xs)
primes :: [Integer]
primes = prime_helper lst



-- This is a datatype to define a binary tree. It follows the
-- recursive definition of a binary tree, which is:
--   - an empty tree
--   - a node containing a value with a left and right subtree
-- For this exercise, we'll stick with binary trees of integers.
-- In the second constructor, the first 'Tree' represents the left
-- subtree, and the second represents the right subtree.
data Tree = Empty | Node Integer Tree Tree deriving Show

-- An example of a tree.
tree :: Tree
tree = Node 5 (Node 3 Empty
                      (Node 3 Empty Empty))
              (Node 5 (Node 1 Empty Empty)
                      (Node (-10) Empty Empty))


-- Question 2
-- Define an infinite tree 'infinitree' as follows:
--   - the root has value 0
--   - for every non-root node, its value is one greater than
--     the value of its parent
--
-- So the two nodes at the second level have value 1,
-- the four nodes at the third level have value 2, etc.
--
-- Note: you'll probably want a helper function to do this.
tree_helper :: Tree -> Tree
tree_helper (Node val left right) = Node (val + 1) (tree_helper left) (tree_helper right)
infinitree :: Tree
infinitree = Node 0 (tree_helper infinitree) (tree_helper infinitree)
