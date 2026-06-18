# Day 4 (Go)

You are given a field of '.' and '@'. Each @ corresponds to a roll of paper.
You must access and remove rolls of paper, but only rolls of paper that have fewer than 4 rolls of paper surrounding it can be accessed.
So, the solution is the number of rolls you can access.

Example input:

``` text
..@@.@@@@.
@@@.@.@.@@
@@@@@.@.@@
@.@@@@..@.
@@.@@@@.@@
.@@@@@@@.@
.@.@.@.@@@
@.@@@.@@@@
.@@@@@@@@.
@.@.@@@.@.
```

My answers are: 1416 and 9086 for parts 1 and 2 respectively.

## Part 1

Find the number of accessible rolls on the given input.

In the example above there are 13.

## Part 2

Find the number of accessible rolls in the given input. After checking, change all accessible '@' to '.' and check again. Continue until no more rolls are accessible. That is the solution to this part.

In the example above there are 43.

### My solution

Running from the top left to bottom right, checking each cell around the base cell, skipping any cell that would go under 0 or above the size of the field.

For part 1 there is only one pass. However for the combined solution I needed to copy the field at the start of the run and change the copy in relation to what rolls are accessible. Then make that copy the main field for the next iteration.

## Notes

I spent a long time trying to work around Go being unable to edit the original array directly, leaving me having to copy a couple of other's array handling solutions to this problem.

Initially with the combined part 1 and 2 solution I struggled to get the correct 1st iteration value. This was because I was editing the field that was being looped over at the time. This meant that when going to the next line the previous line was changed. The answer was always correct because the previous lines had already been counted.
