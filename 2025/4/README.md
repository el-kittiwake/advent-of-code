# Day 4 (Go)

I am presented with a field of '.' and '@'. Each @ corresponds to a roll of paper stacked in a warehouse.
Rolls of paper must be accessed and removed, but the only rolls that can be accessed are ones that have fewer than 4 rolls of paper surrounding them in all eight cardinal + ordinal directions.
The solution to both parts today is the number of rolls you can access.

Example input:

``` text
...@@@.@@@
@@@.@@@.@@
@.@@@@@.@.
.@@...@..@
..@..@@@@@
@@@..@@@..
@.@@..@@@@
@.@@.@@@@.
@@@.@..@@@
.@..@.@@@.

```

My input is 137 x 137 characters in size.

My answers are: 1416 and 9086 for parts 1 and 2 respectively.

## Part 1

Find the number of accessible rolls in the given input. This number is the solution.

In the example above there are 19.

## Part 2

Find the number of accessible rolls in the given input. After checking, change all accessible rolls from '@' to '.' and check again. Continue until no more rolls are accessible while accumulating the total accessible roll count. The solution is the accumulated number of accessible roles over all passes.

In the example above there are 63.

## Input parsing

The whole input needs to be available to the program for this puzzle.

The file is opened using the Open() function from the `os` module. Go's buffered IO module `bufio` and the scanner type are used for processing the file. `bufio.NewScanner()` creates a new scanner reading from the opened input file.

A scanner is a Golang type which acts as a tokeniser. The shape of data that is recognised as a token is by default delimited by a new line. When `.Scan()` is called the scanner reads the next token and buffers it. It stops once an IO error occurs, this includes end of file.

The input file is transferred to a [][]byte array using `.Bytes()`, each line's bytes are cloned and appended as a row.

### My solution

Loop over the field from the top-left to bottom-right, checking each of the eight cells around the base cell. Any cells that would go outside of the field are considered as "no rolls". This serves to open up the edge rolls and make them more likely to be accessible.

For part 1, only the total for one pass over the field is counted. The accessible roll count of this is printed once ready, and the loop carries on for part 2's solution.

Part 2's solution requires repeated looping over the field, until it is no longer possible to access any rolls.

It is necessary to keep track of the new field state as we progress. It is also necessary to not interfere with the currently in progress field. This is achieved by making an empty field (nextIter) and populating its cells with the state of the current field (inputLines) as the iteration progresses.

Once the bottom-right of the field has been reached, the number of accessible rolls from the pass is added to the accumulated total rolls. The inputLines array is made equal to the nextIter array and the loop is restarted.

If no rolls were accessible the loop ends and the total is printed.

## Notes

I spent some time trying to work around my inability to get Go to edit the original array.

The way I understand it is that my problem was similar to common pointer mistakes when learning C. I was trying to mutate the array as a whole rather than directly indexing where I wanted the data to go. The former edits the copy, the latter edits through the shared pointer contained in the slice header. [Explained much better here.](https://luizparente.substack.com/p/arrays-and-slices-in-go-the-memory)

Initially with the combined solution I struggled to get the correct value for part 2. This was because I was editing the field that was being looped over for checking. This meant that when moving to the next line, the previous line had already been changed. This was fixed by copying the field into a new value.

### Other potential solutions

This puzzle is a form of k-core peeling problem where k = 4. What graph people call "degree of less than 4", is what this puzzle calls "accessible".

A k = 2 k-core peeling example on a small graph:

``` text
Start:
    A - B - C -- D
            |  \ |
            E -- F

degree:  A=1  B=2  C=3  D=3  E=2  F=2
```

Process:

``` text
Step 1: A has degree 1 (< 2) and is removed.
        B loses its edge to A, degree decreases to 1.

    (A)  B - C -- D
             |  \ |
             E -- F
degree now:  B=1  C=3  D=3  E=2  F=2

Step 2: B now has degree 1 (< 2) and is removed.
        C loses its edge to B, degree decreases to 2.

    (A) (B)   C -- D
              |  \ |
              E -- F
degree now:  C=2  D=3  E=2  F=2

Step 3: No points have degree < 2. End.
```

As my input file is quite small the naive peeling I chose does the job just fine. However, there is a more efficient way.

Part 2 of this puzzle bears close similarity to what is known as the ["Rotting oranges"](https://www.geeksforgeeks.org/dsa/minimum-time-required-so-that-all-oranges-become-rotten/) problem. As such, BFS is probably a valid way to solve it. 

A more efficient queue driven solution would consist of a queue that contains cells with fewer than 4 neighbours. The field would be a grid of neighbourly values (number of neighbours to that cell). Once a removal happens, reduce its neighbours' count by 1 and add any less than 4s to the queue.

