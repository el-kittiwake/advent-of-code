# Day 5 (Javascript)

I am given a list of fresh ingredient ID ranges, followed by a list of individual ingredient IDs.
An ingredient is considered "fresh" if its ID falls within at least one of the given ranges.

Example input:

``` text
112-140
2-7
13285185-119326613

1
5
200
118
328518
```

My input has 190 ID ranges and 1000 ingredient IDs.

My answers are: 868 and 354143734113772 for parts 1 and 2 respectively.

## Input parsing

For this puzzle the whole input file is needed in memory, or at least this is the easiest way to handle it. The file is read synchronously into a variable and that is saved as an array, example `console.table` below:

``` text
idx
0   '112-140'
1   '2-7'
2   '13285185-119326613'
3   ''
4   '1'
5   '5'
6   '200'
7   '118'
8   '328518'
```

From this, the length of the range section of the file is calculated as well as the start and end of the ingredient section of the file. This is not done particularly robustly. Additional trailing new lines and additional newlines in-between the ingredient ranges and ingredient IDs would cause silent parsing errors. However, my input is what it is and is not going to change, I am not concerned.

Individual arrays are now made for the ID ranges and the individual ingredient IDs. ID ranges are split into `[start, end]` pairs of numbers, example below:

``` text
idx
0   112         140
1   2           7
2   13285185    119326613
```

Ingredient IDs are converted into numbers, example below:

``` text
idx
0   1
1   5
2   200
3   118
4   328518
```

## Part 1

The solution is the count of listed ingredient IDs that are fresh, i.e. fall within at least one of the given ranges. We do not count appearance in multiple ranges.

### Part 1 solution

I loop through every ingredient ID and check it against every range, incrementing a counter whenever a match is found.

## Part 2

The solution is the total number of unique IDs that are covered by at least one range. The size of the union of all ranges.

### Part 2 solution

For part 2 a solution is required that does not involve running through the entire actual ID space. The range of IDs possible is quite sizeable and would be a potentially slow prospect.

The solution I chose was to sort the list of ranges ascending. Then loop through from top to bottom. I track the furthest endpoint seen so far (`currentMax`). For each range:

- If it starts beyond the current largest endpoint, it is entirely new territory and the full range is added to the count.
- If it overlaps with (or is adjacent to) the current furthest endpoint, only the portion extending beyond that endpoint is added.
- If it is entirely contained in what has currently been counted, nothing happens.

## Notes

Part 1 initially gave 867 because I was slicing the input array with an off-by-one error, dropping the first ingredient ID.

Part 2 required careful handling of the overlap check. For conditions of partially overlapping range I at first used less than (`<`), instead of less-than-or-equal (`<=`), meaning any range whose start exactly equalled the current furthest endpoint was silently skipped. This resulted in my first result being 339868252840898, off by 14 trillion. I also had an off-by-one in the count (`element[1] - currentMax + 1` instead of `element[1] - currentMax`).

As the numbers involved here are quite large, I did consider that the `Number` type would not be adequate. If this was the case I could have called on the `BigInt` type. As it happened, this did not turn out to be a problem.

First time using Node.js / CommonJS for AoC. Fairly straightforward to work with for this kind of numerical problem. Lots of methods to make the job easier and a relaxed syntax.

### Other potential solutions

Part 2's `countTotalFresh` function could be adapted to output a merged array of ranges, helping to solve part 1 in a more efficient way. The merged array could be searched for the last range with a start less than the ingredient ID. If the ingredient is less than that range's end, then increment the counter.

The most ... canonical way to solve problems like this would be to use an [interval tree](https://en.wikipedia.org/wiki/Interval_tree). These start off being built like a [binary search tree](https://www.geeksforgeeks.org/dsa/binary-search-tree-data-structure/).

Example:

``` text
insert:
 [15,20]:  root
 [5,20]:   5 < 15  -> goes left of [15,20]
 [1,3]:    1 < 15  -> left; 1 < 5    -> left of [5,20]
 [6,10]:   6 < 15  -> left; 6 > 5    -> right of [5,20]
 [17,19]:  17 > 15 -> right of [15,20]
 [22,23]:  22 > 15 -> right; 22 > 17 ->right of [17,19]

                [15,20]
                /      \
           [5,20]      [17,19]
           /    \             \
       [1,3]  [6,10]        [22,23]
```

In addition, though, they have a `max` addition in each record. This is added to the node on the way back up after building. Bottom nodes with no children get a max that is their own highest value. All others get `max = maximum(own high, left child's max, right child's max)`

Example:

``` text
                [ 15, 20 ]
                [max = 23]
                /      \
        [  5, 20 ]      [ 17, 19 ]
        [max = 20]      [max = 23]
           /    \             \
    [  1, 3 ]  [  6, 10 ]     [ 22, 23 ]
    [max = 3]  [max = 10]     [max = 23]
```

The maximum value serves to give advance warning of an inappropriate branch. The search starts from the root and follows the following rules:

- Does the current node's range contain the search value? If yes: done.
- If not: If the left child exists and its maximum is greater than or equal to the search value: go left.
- Otherwise: go right.

This style of augmented interval tree search will find one overlapping range, if one exists. If not, it will return that no matches exist. It doesn't find every match if more than one overlapping range exists.
