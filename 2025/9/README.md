# Day 9 (D)

I am given a line delimited list of coordinates representing red tiles on a floor. Straight lines between red tiles are marked by green tiles. Together they represent the perimeter of an axis aligned polygon.

Input files are wrapped so the last tile is connected to the first tile.

Example input:

``` text
7,1
11,1
11,7
9,7
9,5
2,5
2,3
7,3
```

Represents this floor (#: red, X: green):

``` text
..............
.......#XXX#..
.......X...X..
..#XXXX#...X..
..X........X..
..#XXXXXX#.X..
.........X.X..
.........#X#..
..............

```

My answers are: 4745816424 and 1351617690 for parts 1 and 2 respectively.

## Input parsing

The input file needs to be placed in memory in its entirety before working on the data.

This is done using the D standard library. The file is read linewise and trailing whitespace removed using `chomp()`. The line is then split by commas and the pair of values converted to longs using `to!long()` and added to a vector of the two coordinates.
This pair vector is then concatenated to the input coordinates array using the binary concatenate operator `~`.

The end result is a vector of vectors containing two long values: `long[][]`.
Long is chosen to make the arithmetic easy when calculating and comparing total sizes.

## Part 1

Find the rectangle with the largest area possible. The rectangle must have two of its opposite corners being two of the given coordinates (red tiles).

### Part 1 solution

The solution is the naive approach.

Loop through each combination of coordinates and calculate its area, save and return the largest area found.

Using two foreach loops on the parsed input was the quick and easy way to go about it in D. Initially I was not getting the correct value for the example (I was getting 36) this was because the tile count is inclusive, adding one to each side of the rectangle fixed this.

My initial result with my input was 2147458464, which was too low. The value is suspiciously close to INT_MAX and that was because I was using int type for maxArea and connected variables. Leading to overflow.

## Part 2

Ostensibly the idea is the same as for part 1. However the largest rectangle must now fit within the perimeter of the polygon (perimeter inclusive).

The example has `9,5` and `2,3` resulting in 24 required tiles.

### Part 2 solution

Initially I thought to stay naive, checking for every rectangle like part 1 but adding a further check of each vertex to ensure it is not inside my rectangle. This would be a fairly massive undertaking.

This was the most algorithm-heavy puzzle so far. It took me almost a week and a lot of searching for ideas. This is not something I am very familiar with, so it was education heavy. Ray-casting was my first non-naive thought, I didn't go that route because initially it seemed like the method I chose would be easier. It ultimately wasn't, but that was on me.

The approach I went for consisted of marking all external cells, building a prefix sum array and finally iterating over all coordinate combinations as with part 1. After some wrestling, asking questions and thinking, a coordinate compression step was added.

Break coordinates into sorted, unique, vectors per axis. This reduces the ~500 input coordinate pairs down to ~250 unique values per axis after removing duplicates (at least for my input). This only works because the polygon is axis aligned.

Example input gives (`axesTuple` array):

``` text
xVals = [2, 7, 9, 11]     (compressed columns 0,1,2,3)
yVals = [1, 3, 5, 7]      (compressed rows 0,1,2,3)
```

[Coordinate compression](https://phuongdinh1411.github.io/cses-analyses/problem_soulutions/graph_algorithms/coordinate_compression_analysis), reduces the 100,000^2 space down to at most 500^2 (the number of coordinates in the input file). Because all polygon edges fall on vertices, long edges of the same horizontal or vertical position can be compressed down to one cell.

Use binary search to find the position in the x/y vectors. Mark this position in the `coordinateLookup` array, this is the coordinate compressed array which maps to the input data via their index.

Add 1 to each value to account for a zero buffer added around the grid. This is to enable the filling method used later.

In the example this would look like (`coordinateLookup` array):

``` text
Vertex    ci  cj
(7,1)      2   1
(11,1)     4   1
(11,7)     4   4
(9,7)      3   4
(9,5)      3   3
(2,5)      1   3
(2,3)      1   2
(7,3)      2   2
```

Mark the perimeter of the polygon in a 2D boolean array (6x6 including padding).

Each pair of input vertices makes an edge, going from first to last should make a complete closed polygon. Compression removed the implied points. Example shown below:

``` text
(7,1)  -> (11,1)  horizontal cj=1  mark [2][1],[3][1],[4][1]
(11,1) -> (11,7)  vertical   ci=4  mark [4][1],[4][2],[4][3],[4][4]
(11,7) -> (9,7)   horizontal cj=4  mark [3][4],[4][4]
(9,7)  -> (9,5)   vertical   ci=3  mark [3][3],[3][4]
(9,5)  -> (2,5)   horizontal cj=3  mark [1][3],[2][3],[3][3]
(2,5)  -> (2,3)   vertical   ci=1  mark [1][2],[1][3]
(2,3)  -> (7,3)   horizontal cj=2  mark [1][2],[2][2]
(7,3)  -> (7,1)   vertical   ci=2  mark [2][1],[2][2]
```

Example boolean array (`compressedField` array):

``` text
j\i:  0  1  2  3  4  5
  0:  .  .  .  .  .  .
  1:  .  .  #  #  #  .   <- y=1
  2:  .  #  #  .  #  .   <- y=3
  3:  .  #  #  #  #  .   <- y=5
  4:  .  .  .  #  #  .   <- y=7
  5:  .  .  .  .  .  .

     x=  2  7  9  11
```

Now the perimeter is marked, internal cells are not. Either internal or external cells now need marking in order to calculate the prefix sums. I chose to mark external cells, cells that are outside the perimeter.

For this I thought to flood fill using recursion. However I was dissuaded from attempting this and told to attempt using BFS [Breadth-first search](https://en.wikipedia.org/wiki/Breadth-first_search), another new concept to me.

Starting at the top left in my case:

  1. Add the first cell to the queue and mark it as true.
  1. Loop through the queue.
     * Take the front item from the queue.
     * Check each cardinal direction (n/s/e/w) for validity (inside the grid, not part of the shape or already marked external).
     * If valid mark as true and add to the back of the queue.
     * Remove the current cell from the queue and continue looping.
  1. End loop once the queue is empty.

The example looks something like below. Left: once external cells are marked (`exterior` array), Right: the valid shape area (shown here for clarity, no array is ever made that looks exactly like this):

``` text
j\i:  0  1  2  3  4  5   |   j\i:  0  1  2  3  4  5
  0:  E  E  E  E  E  E   |     0:  .  .  .  .  .  .
  1:  E  E  #  #  #  E   |     1:  .  .  1  1  1  .
  2:  E  #  #  .  #  E   |     2:  .  1  1  1  1  .
  3:  E  #  #  #  #  E   |     3:  .  1  1  1  1  .
  4:  E  E  E  #  #  E   |     4:  .  .  .  1  1  .
  5:  E  E  E  E  E  E   |     5:  .  .  .  .  .  .

E = exterior             |    . = exterior
# = perimeter            |    1 = polygon (13 cells)
. = interior
```

[Prefix sum](https://leetcopilot.dev/leetcode-pattern/prefix-sum/guide). We now know where the shape isn't and we can use this to make the prefix sum array.

Iterating through the entire `exterior` array.
If a cell is not marked true then its value is 1, add that value to the value of the cells immediately above and to the left of it.
Subtract the value of the cell diagonally up and to the left to account for [shared cells](https://en.wikipedia.org/wiki/Inclusion%E2%80%93exclusion_principle).

Once done, the top left should be 0 and the bottom right should be the total number of valid shape cells in the grid.

Example (`prefixSumArray`):

``` text
j\i:  0  1  2  3  4  5
  0:  0  0  0  0  0  0
  1:  0  0  1  2  3  3
  2:  0  1  3  5  7  7
  3:  0  2  5  8 11 11
  4:  0  2  5  9 13 13
  5:  0  2  5  9 13 13
```

Finally comes checking and validating rectangles. The order we go through the input is the same as part 1, each combination of vertices is checked.

We perform the same compressed coordinate lookup we did for marking the perimeter. This time starting by checking the relative values of each i and j coordinate to ensure that the smallest is ordered first. Inclusion-exclusion is used again because in the `prefixSumArray` (called P in the examples below) a location is the sum of everything from 0,0 to that location (P[i][j]). To find a rectangle (ci1,cj1)x(ci2,cj2) the parts that are not part of it need to be removed.

Example input with largest rectangle at input (2,3)x(9,5) or (1,2) to (3,3) in the `prefixSumArray`.

``` text
sum = P[3][3] - P[0][3] - P[3][1] + P[0][1]
    = 8 - 0 - 2 + 0
    = 6

P[3][3] = 8    everything  (0,0) to (3,3)
P[0][3] = 0    strip above (0,0) to (0,3) : subtract.
P[3][1] = 2    strip left  (0,0) to (3,1) : subtract.
P[0][1] = 0    top-left    (0,0) to (0,1) : add back because it was subtracted twice.

expected = (3-1+1) * (3-2+1) = 3 * 2 = 6
```

Below is the same as above, but with the original coordinates from the input:

``` text
width  = xVals[2] - xVals[0] + 1 = 9 - 2 + 1 = 8
height = yVals[2] - yVals[1] + 1 = 5 - 3 + 1 = 3
area   = 8 * 3 = 24
```

## Notes

First time using D. I would say I am most familiar with C, so the syntax is quite familiar. The differences are mostly in the standard library's offerings rather than in how the language feels.

It was very useful to be able to chain `map`, `sort` and `uniq` and use `array` to force evaluation. Major quality of life bonus right there. Lazy ranges are interesting, conceptually similar to Python generators or JavaScript promises in that nothing is computed until forced. The `!` template syntax (`to!long`, `map!(v => v[0])`) is also another oddity that I quickly grew to like.

`Tuple` is quite a neat way of making a multi-return. I would normally make a struct to do that, but this wraps all the struct work up in a simple to use mechanism. Although, if I were to use D more, likely I would revert back to structs.

The `rdmd` companion to the main `dmd` compiler is really useful for speeding up the run-edit-run cycle.

This was the most algorithm-heavy puzzle so far. New to me were the concepts of:

* Coordinate compression
* Breadth-first search
* Prefix sums

Working through slowly and methodically worked for me. As long as I had at least a cursory understanding of what I was doing the task was completely manageable.

Sources I found helpful:

* Competitive Programmer's Handbook by Antti Laaksonen.
* [Algorithms for Competitive Programming](https://cp-algorithms.com/)
