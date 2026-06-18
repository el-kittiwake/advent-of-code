# Day 7 (Racket)

You are given a "tachyon manifold" consisting of "empty spaces" `.`, a "beam emitter" `S`, and an expanding array of "beam splitters" `^`. The beam moves downward from `S` until it meets a splitter `^`, it then splits into two beams offset one to the left and one to the right of the splitter.

Example input:

``` text
.......S.......
...............
.......^.......
...............
......^.^......
...............
.....^.^.^.....
...............
....^.^...^....
...............
...^.^...^.^...
...............
..^...^.....^..
...............
.^.^.^.^.^...^.
...............
```

My answers are: 1630 and 47857642990160 for parts 1 and 2 respectively.

## Part 1

Count the number of times a beam hits a splitter within the whole manifold.

### Part 1 solution

I have a set `active-cells` which is used to store the position of each active beam in the row (the result of a beam hitting a `^` on the previous row). I also have a running count of each time a `^` is hit by a beam.

I use a nested `for/fold` (a state-carrying loop) to propagate the beam row by row.

The outer loop iterates over rows, carrying two accumulators: a set of active column indices and a running split count.

The inner loop iterates over the active set, building the next row's active set: a '^' adds x-1 and x+1 to the next set and increments the count; anything else carries x forward. A set is used rather than a list as it does not allow duplicates, thus it automatically deduplicates merged beams.

## Part 2

Count the number of unique paths from `S` to the bottom of the manifold. If the beam hits a splitter is splits one way and that counts as one of two possible paths from that splitter.

### Part 2 solution

The part 1 structure is reused almost entirely. The `active-cells` set becomes a hash-table of column:timeline count, initialised as `{start-x: 1}`. Hash-tables do not allow duplicate keys, thus adding a value replaces the previous value.

The inner loop iterates over key-value pairs, propagating counts through splits and additions. When beams arrive at the same column from different histories their counts add. The final answer is the sum of all values in the hash map after the last row.

## Notes

First time using Racket (or any Lisp family language). Lisp and many of its cohorts are based around [s-expressions](https://en.wikipedia.org/wiki/S-expression) (aka. Polish notation) and immutable data structures. This requires quite some different thinking compared to C-style imperative thinking.

The `#lang` line is particularly interesting. It would be quite fun to take sometime to play with what I can do with it, as I have not even scratched the surface of what is possible. I only used `#lang racket`, which is the default.

Runtime does feel somewhat sluggish and startup lag is noticeable, similar to what I experienced with Julia.

Part 2 was a nice change using this language. It encouraged me to make a simple change to my original concept (swapping a set for a hash-table) and and summing the final values rather than counting splits. Resulting in a short script that calculated the result of both parts without the need for separate functions or code blocks per part.

Overall I quite enjoyed using Racket. I am not sure I will ever get to use it again, but if I do I hope I have the time to get to know it a bit better and start to take full advantage of its features.
