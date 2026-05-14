# Day 1 (C)
You are given a series of combination safe lock "clicks" in the form XY, where X is either R or L (right, left) and Y is the number of clicks in that direction.

The lock has 100 positions on the dial, ranging from 0 to 99 and starting at position 50.

My answers are: 1139 and 6684 for part 1 and 2 respectively.

### Part 1
The solution to this part is the number of times the position of the dial equals 0.

##### My solution
I read each line and extract the direction (R or L, which I save as a sign value 1 and -1 respectively), and number of clicks.

I then calculate the modulo of the rotations to 100, this eliminates any 100 click rotations as they cancel.

Then adding current position to the calculated modulo gives me a rotation offset. If this value is 0, then I increment a zero counter. If it is greater than 99 I subtract 100 and if it is less than 0 I subtract it from 100.

Any value between 0 and 99 is taken as the new position.

Once end of file is reached I output the number of zeroes.

### Part 2
The solution to this part is the number of times the position of the dial equals 0 as well as the number of times the dial passes 0 during a rotation.

##### My solution
I read each line and extract the direction (R or L, which I save as a sign value 1 and -1 respectively), and number of clicks.

I then calculate the modulo of the rotations to 100, this eliminates any 100 click rotations as they cancel. Then add the current position to the calculated modulo to find my rotation offset.

I increment the zero counter by the value of rotations / 100. This counts all full rotations as they will by definition pass by 0.

I then check the rotation offset for various values.

If this value is 0 or 100 I increment a zero counter and make the current position 0. If it is greater than 100 I subtract 100 and increment the zeroes. If it is less than 0 I subtract it from 100 and increment the zeroes if the previous position was not 0.

Any value between 0 and 99 is taken as the new position.

Once end of file is reached I output the number of zeroes stopped at and passed through.

### Notes
Part 1 was relatively quick for me, within an hour maybe. Part 2 took me quite a bit longer, I struggled to find why I was getting values that were too large. Turns out I was counting 0 twice if the current position was 0.

---

# Day 2 (Dodgy CPP)
You are given a comma-separated string of numeric ranges, such as: 13-30,6859-7000,42382932-42449104
Within these ranges are several invalid IDs.

My answers are: 13919717792 and 14582313461 for parts 1 and 2 respectively.

### Part 1
The solution to this part is the sum of "invalid IDs". Invalid IDs are numbers within the ranges that contain a numeric pattern repeated twice. For example: in 13-30 there is 22 and in 6859-7000 there is 6868 and 6969. So the solution in this case would be 13859.

##### My solution
First I split the input into a vector of pairs containing each range start and end value.

I then discount any odd length number ranges.

Then I go through each number in the range, splitting it in half and comparing the 2 halves.

### Part 2
The solution to this part is the sum of "invalid IDs". Invalid IDs are numbers within the ranges that contain a numeric pattern repeated any number of times. For example: 123123123, 1111, 454545 would all be considered invalid IDs.

##### My solution
This one solves easier as there is no need to discount odd length strings.

I used the idea from [this page](https://algo.monster/liteproblems/459).

By combining the string and a copy of itself and starting the search from index 1 the search algorithm will only hit the original string if it indeed is a repeating pattern. The doubled string essentially creates a loop that will be found if it is a repeating pattern.

### Notes
Other than the quite bloaty file handling and string splitting part 1 at least has quite a bit of inefficient conversion between numbers and strings. Part 2 is quite clean and intuitive. I am not really taking advantage of CPP's features here, other than some library functions.

---

# Day 3 (Fortran)
You are given a line-delimited list of numbers. Each number corresponds to a battery.
You must turn on a given number of batteries in order to produce the maximum joltage.
Basically, find the largest number of a certain length within the given number.
You cannot rearrange and must go from left to right.

My answers are: 16946 and 168627047606506 for parts 1 and 2 respectively.

### Part 1
Find the largest 2-digit battery in each given line and return the sum of all batteries.

eg. 818181911112111 = 82

### Part 2
Find the largest 12-digit battery.

eg. 818181911112111 = 888911112111

##### My solution
Pretty straightforward. Starting from the left, advance along the number (not going to the end until the last digit) and find the largest number that can be found.

Do this for the required number of digits.

### Notes
First time messing with Fortran. Quite different to what I am used to but actually quite easy to use.

Used the [Intel fortran manual](https://www.intel.com/content/www/us/en/docs/fortran-compiler/developer-guide-reference/2023-0/language-reference.html) quite a lot as well as [Oracle's manual](https://docs.oracle.com/cd/E19957-01/805-4939/index.html), however Intel's is easier to follow and reference.

---

# Day 4 (Go)
You are given a field of '.' and '@'. Each @ corresponds to a roll of paper.
You must access and remove rolls of paper, but only rolls of paper that have fewer than 4 rolls of paper surrounding it can be accessed.
So, the solution is the number of rolls you can access.

Example input:
```
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

### Part 1
Find the number of accessible rolls on the given input.

In the example above there are 13.

### Part 2
Find the number of accessible rolls in the given input. After checking, change all accessible '@' to '.' and check again. Continue until no more rolls are accessible. That is the solution to this part.

In the example above there are 43.

##### My solution
Running from the top left to bottom right, checking each cell around the base cell, skipping any cell that would go under 0 or above the size of the field.

For part 1 there is only one pass. However for the combined solution I needed to copy the field at the start of the run and change the copy in relation to what rolls are accessible. Then make that copy the main field for the next iteration.

### Notes
I spent a long time trying to work around Go being unable to edit the original array directly, leaving me having to copy a couple of other's array handling solutions to this problem.

Initially with the combined part 1 and 2 solution I struggled to get the correct 1st iteration value. This was because I was editing the field that was being looped over at the time. This meant that when going to the next line the previous line was changed. The answer was always correct because the previous lines had already been counted.

---

# Day 5 (Javascript)
You are given a list of ID ranges, followed by a list of individual ingredient IDs.
An ingredient is considered "fresh" if its ID falls within at least one of the given ranges.

My answers are: 868 and 354143734113772 for parts 1 and 2 respectively.

### Part 1
The solution is the count of listed ingredient IDs that are fresh, i.e. fall within at least one of the given ranges. We do not count appearance in multiple ranges.

##### My solution
I split the input at the blank line separating ranges from ingredients. Each range is parsed into a `[start, end]` pair. I then loop through every ingredient ID and check it against every range, incrementing a counter whenever a match is found.

### Part 2
The solution is the total number of unique IDs that are covered by at least one range. The size of the union of all ranges.

##### My solution
I sort the ranges by their start value and sweep through them left to right, tracking the furthest endpoint seen so far (`currentMax`). For each range:

- If it starts beyond the current furthest endpoint, it is entirely new territory and the full range is added to the count.
- If it overlaps with (or is adjacent to) the current furthest endpoint, only the portion extending beyond that endpoint is added.

### Notes
Part 1 initially gave 867 because I was slicing the input array with an off-by-one error, dropping the first ingredient ID.

Part 2 required careful handling of the overlap check. For conditions of partially overlapping range I at first used less than (`<`), instead of less-than-or-equal (`<=`), meaning any range whose start exactly equalled the current furthest endpoint was silently skipped. This resulted in my first result being 339868252840898, off by 14 trillion. I also had an off-by-one in the count (`element[1] - currentMax + 1` instead of `element[1] - currentMax`).

First time using Node.js / CommonJS for AoC. Fairly straightforward to work with for this kind of numerical problem. Lots of methods to make the job easier and a relaxed syntax.

---

# Day 6 (Julia)
You are given a grid of numbers with an operator row at the bottom. Each column is a separate arithmetic problem, with the operator at the bottom determining whether to sum or multiply the numbers above it.

My answers are: 5784380717354 and 7996218225744 for parts 1 and 2 respectively.

### Part 1
The solution is the sum of all column results, processed left to right.

##### My solution
I convert the input file into a matrix, then iterate columnwise. The bottom row determines the operator. I convert each of the columnar rows into numbers and apply `prod()` or `sum()` functions depending on the final row's operator. I add each column's result to a running total.

### Part 2
Each numbers' digits are now read top to bottom. Each column within a block (these blocks are the same as in part 1) is one operand, with digits running top to bottom from most to least significant. The column with the operator in the last row is the leftmost column of the block. Blocks are separated by an aligned column of spaces, everything reads right to left.

##### My solution
Working on the unprocessed input file contents rather than a parsed matrix, I run right to left across the columns. Each column's digits are read vertically and concatenated to form a number, each number is added to a vector. When the operator is met it marks the leftmost column of the current block. I then apply the operation to the vector of numbers and add the result to the running total.

### Notes
Part 2 required not only a different approach to part 1, it also required a lot more time. Using the operator row to identify block boundaries and adding the parsed numbers as we went along was the key here.

First time using Julia, not super enjoyable in this format. I feel that this language needs more time in order to truly get to appreciate its quirks. Lazy iterators and the concept of broadcasting are very interesting. Using Unicode operators like `∈` potentially make for clean reading code. I can see it being well loved by people who work with large sets of numbers a lot.
