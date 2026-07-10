# Day 6 (Julia)

I am given a grid of numbers with an operator row at the bottom. Each column is a separate arithmetic problem, with the operator at the bottom determining whether to sum or multiply the numbers above it. There are only `*` and `+` operators.

Example input:

``` text
44 45 28  951
75 54 224 56 
34 72 429 722
+  *  +   +  
```

My input has 4 rows of operands and a single row of operators and each row is 3700+ characters long.

My answers are: 5784380717354 and 7996218225744 for parts 1 and 2 respectively.

## Input handling

The input is opened and read in a do block. Julia does not always need a explicit return as the implicit return mechanism is to return the last evaluated expression in a function.

Once end-of-file is reached, `read()` returns the data it read, this propagates through the `do` block's return, to the `open()`'s return and finally is returned by the `readFile()` function to the caller.

This string has its empty lines removed using the `filter()` function, this operates on the fed from the `split()` function which is used to split the string by newlines. This creates a vector of string substrings. split() always returns strings as substrings.

>A SubString in Julia is a struct containing a reference to the original string, an offset to the beginning of the substring, and the length of the substring. Analogous to C++'s `std::string_view`.

The string is checked to ensure all lines are of equal length (important for part 2). It is now ready for part 2. However part 1 needs this data broken up a little more.

splitString = `["44 45 28  951", "75 54 224 56 ", "34 72 429 722", "+  *  +   +  "]`

Each line is collected into a vector using a comprehension [ ... ]. Within this a whitespace directed `split()` is called on the result of `strip()`. `strip()` defaults to stripping whitespace. The result is a vector of vectors of string substrings.

rows = `[["44", "45", "28", "951"], ["75", "54", "224", "56"], ["34", "72", "429", "722"], ["+", "*", "+", "+"]]`

## Part 1

The solution is the sum of all column results, processed left to right.

### Part 1 solution

I iterate columnwise. The bottom row determines the operator. I convert each of the columnar rows into numbers and apply `prod()` or `sum()` functions depending on the final row's operator. I add each column's result to a running total.

## Part 2

Each numbers' digits are now read top to bottom. Each column within a block (these blocks are the same as in part 1) is one operand, with digits running top to bottom from most to least significant. The column with the operator in the last row is the leftmost column of the block. Blocks are separated by an aligned column of spaces, everything reads right to left.

Taking the example from the top of the page:

``` text
blocks:
1      2      3       4
┌─┐    ┌─┐    ┌──┐    ┌──┐
44│    45│    28 │    951│
75│    54│    224│    56 │
34│    72│    429│    722│
+ │    * │    +  │    +  │
```

1. Block 4: 12 + 562 + 957 = 1531
1. Block 3: 49 + 822 + 224 = 1095
1. Block 2: 542 * 457 = 247694
1. Block 1: 454 + 473 = 927

Total: 251247

### Part 2 solution

Working on the split but otherwise unprocessed input file (splitString), I loop right to left across the columns, helped by `reverse()`.

Each column is looped through top to bottom, saving the individual digits in order to a variable (`newNum`). If newNum has a value then push that value as an integer to a vector (`currentSet`). The operator is then checked and `prod()` or `sum()` applied to currentSet, this result is added to the running total.

Finally, newNum is checked for emptiness, if found empty then we were at a block separating column of spaces. If so, currentSet is emptied and the loop continues.

## Notes

This is one of those puzzles that is trivially easy to understand in wetware, but causes trouble getting a computer to do it. Especially while learning the basics of a new language at the same time.

Part 2 required not only a different approach to part 1, it also required a lot more time. Using the operator row to identify block boundaries and adding the parsed numbers as we went along was the key here.

First time using Julia, not super enjoyable in this format. I feel that this language needs more time in order to truly get to appreciate its quirks. Lazy iterators and the concept of broadcasting are interesting. Using Unicode operators like `∈` potentially make for clean reading code. I can see it being well loved by people who work with large sets of numbers a lot.

My initial solution for part 2 was a little longer. Using `all()`, `any()` and `join()` each fed a lazy iterator/generator expression. That version was looping through the column three times. The current version only once. Initially I continued using `all()` and `any()`, this resulted in them only operating on one index's character, not the whole column. It took me a while to figure out why the result was wrong.
