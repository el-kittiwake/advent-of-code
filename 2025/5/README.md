# Day 5 (Javascript)

You are given a list of ID ranges, followed by a list of individual ingredient IDs.
An ingredient is considered "fresh" if its ID falls within at least one of the given ranges.

Example input:

``` text
3-5
10-14
16-20

1
5
8
11
32
```

My answers are: 868 and 354143734113772 for parts 1 and 2 respectively.

## Part 1

The solution is the count of listed ingredient IDs that are fresh, i.e. fall within at least one of the given ranges. We do not count appearance in multiple ranges.

### Part 1 solution

I split the input at the blank line separating ranges from ingredients. Each range is parsed into a `[start, end]` pair. I then loop through every ingredient ID and check it against every range, incrementing a counter whenever a match is found.

## Part 2

The solution is the total number of unique IDs that are covered by at least one range. The size of the union of all ranges.

### Part 2 solution

I sort the ranges by their start value and sweep through them left to right, tracking the furthest endpoint seen so far (`currentMax`). For each range:

- If it starts beyond the current furthest endpoint, it is entirely new territory and the full range is added to the count.
- If it overlaps with (or is adjacent to) the current furthest endpoint, only the portion extending beyond that endpoint is added.

## Notes

Part 1 initially gave 867 because I was slicing the input array with an off-by-one error, dropping the first ingredient ID.

Part 2 required careful handling of the overlap check. For conditions of partially overlapping range I at first used less than (`<`), instead of less-than-or-equal (`<=`), meaning any range whose start exactly equalled the current furthest endpoint was silently skipped. This resulted in my first result being 339868252840898, off by 14 trillion. I also had an off-by-one in the count (`element[1] - currentMax + 1` instead of `element[1] - currentMax`).

First time using Node.js / CommonJS for AoC. Fairly straightforward to work with for this kind of numerical problem. Lots of methods to make the job easier and a relaxed syntax.
