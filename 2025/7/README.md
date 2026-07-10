# Day 7 (Racket)

I am presented with a "tachyon manifold" consisting of "empty spaces" `.`, a "beam emitter" `S`, and an expanding array of "beam splitters" `^`. The beam moves downward from `S` until it meets a splitter `^`, it then splits into two beams offset one to the left and one to the right of the splitter.

Example input:

``` text
......S......
.............
......^......
.............
.....^.^.....
.............
....^.^.^....
.............
...^...^.^...
.............
..^...^...^..
.............
.^.^...^.^.^.
.............
```

My answers are: 1630 and 47857642990160 for parts 1 and 2 respectively.

## Input parsing

The file is read linewise, its characters formed into a list and that list formed into a vector.

The `(list->vector (sequence->list (in-lines)))` sequence is wrapped in a `(thunk)`, a function that takes no arguments and delays the execution of the block until the slower system call has completed. In particular, `with-input-from-file` needs time to open the file before the read can happen.

## Part 1

Count the number of times a beam hits a splitter within the whole manifold.

### Part 1 solution

I have a set `active-cells` which is used to store the position of each active beam in the row (the result of a beam hitting a `^` on the previous row). This is seeded with the position of the `S` on the first row. There is also a running count of each time a `^` is hit by a beam.

How `active-cells` evolves partially for the example:

``` text
row 0:  {7}          S is at x=7
row 1:  {7}          empty space, beam continues
row 2:  {6,8}        ^ at x=7, splits to 6 and 8, count=1
row 3:  {6,8}        empty spaces, beams continue
row 4:  {5,7,9}      ^ at x=6 and x=8, splits both, count=3
...
```

>A set is a container type that does not permit duplicates. This leads to beams that split to the same location being automatically deduplicated.

I use a nested pair of `for/fold` (state-carrying loops) to propagate the beam row by row.

The outer loop iterates over rows, carrying two accumulators: the set of active column indices and a running split count.

The inner loop iterates over the active set, building the next row's active set: a '^' adds x-1 and x+1 to the next set and increments the count; anything else carries x forward.

## Part 2

Count the number of unique paths from `S` to the bottom of the manifold. If the beam hits a splitter is splits one way and that counts as one of two possible paths from that splitter.

### Part 2 solution

The part 1 structure is reused almost entirely. The `active-cells` set becomes a hash-table of column:timeline count, initialised as `{start-x: 1}`. Hash-tables (like sets) do not allow duplicate keys, thus adding a value replaces the previous value.

How `active-cells` evolves partially for the example:

``` text
row 0:  {7: 1}              single route at S.
row 2:  {6: 1, 8: 1}        single splitter: one route left, one right.
row 4:  {5: 1, 7: 2, 9: 1}  two splitters: routes at x=7 merge,
                            but represent 2 distinct possible routes.
...
```

The inner loop iterates over key-value pairs, propagating counts through splits and additions. When beams arrive at the same column from different histories their counts add.

The final answer is the sum of all values in the hash map after the last row.

## Notes

First time using Racket (or any Lisp family language). Lisp and many of its cohorts are based around [s-expressions](https://en.wikipedia.org/wiki/S-expression) (aka. Polish notation) and immutable data structures. This requires quite some different thinking compared to C-style imperative thinking. The immutability in particular can cause some friction.

The `#lang` line is particularly interesting. It would be quite fun to take sometime to play with what I can do with it, as I have not even scratched the surface of what is possible. I only used `#lang racket`, which is the default.

Runtime does feel somewhat sluggish and startup lag is noticeable, similar to what I experienced with Julia.

Part 2 was a nice change using this language. It encouraged me to make a simple change to my original concept (swapping a set for a hash-table) and summing the final values rather than counting splits. Resulting in a short script that calculated the result of both parts without the need for separate functions or code blocks per part.

Overall I quite enjoyed using Racket. I am not sure I will ever get to use it again, but if I do I hope I have the time to get to know it a bit better and start to take full advantage of its features.

The following resources were helpful:

* [Learn Racket in Y minutes.](https://learnxinyminutes.com/racket/) Essentially a cheat sheet of useful concepts and functions.
* [The official Racket guide.](https://docs.racket-lang.org/guide/) Read about the language and its quirks.
* [The official Racket reference.](https://docs.racket-lang.org/reference/) Function and terse language reference.

### Other potential solutions

* Depth first search (DFS): Drill down marking splits on the way. Once at the bottom go back to the last unexplored split. Repeat until no unexplored splits remain.
* DFS with memoisation: Cache how many routes are reachable from each specific cell. Every subsequent visit to that cell needs only read the cached count. Linearises the problem.
* Matrix multiplication: Rows as vectors, each one generates the next when multiplied by a transformation matrix. This matrix encodes how each column's value changes for . or ^ cells. Way too convoluted for this. Better suited when the transition is the same each time.
