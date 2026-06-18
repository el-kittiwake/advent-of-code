# Day 6 (Julia)

You are given a grid of numbers with an operator row at the bottom. Each column is a separate arithmetic problem, with the operator at the bottom determining whether to sum or multiply the numbers above it.

Example input:

``` text
123 328  51 64 
 45 64  387 23 
  6 98  215 314
*   +   *   + 
```

My answers are: 5784380717354 and 7996218225744 for parts 1 and 2 respectively.

## Part 1

The solution is the sum of all column results, processed left to right.

### Part 1 solution

I convert the input file into a matrix, then iterate columnwise. The bottom row determines the operator. I convert each of the columnar rows into numbers and apply `prod()` or `sum()` functions depending on the final row's operator. I add each column's result to a running total.

## Part 2

Each numbers' digits are now read top to bottom. Each column within a block (these blocks are the same as in part 1) is one operand, with digits running top to bottom from most to least significant. The column with the operator in the last row is the leftmost column of the block. Blocks are separated by an aligned column of spaces, everything reads right to left.

### Part 2 solution

Working on the unprocessed input file contents rather than a parsed matrix, I run right to left across the columns. Each column's digits are read vertically and concatenated to form a number, each number is added to a vector. When the operator is met it marks the leftmost column of the current block. I then apply the operation to the vector of numbers and add the result to the running total.

## Notes

Part 2 required not only a different approach to part 1, it also required a lot more time. Using the operator row to identify block boundaries and adding the parsed numbers as we went along was the key here.

First time using Julia, not super enjoyable in this format. I feel that this language needs more time in order to truly get to appreciate its quirks. Lazy iterators and the concept of broadcasting are interesting. Using Unicode operators like `∈` potentially make for clean reading code. I can see it being well loved by people who work with large sets of numbers a lot.
