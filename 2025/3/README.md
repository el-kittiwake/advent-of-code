# Day 3 (Fortran)

You are given a line-delimited list of numbers. Each number corresponds to a battery.

You must turn on a given number of batteries in order to produce the maximum joltage.

Basically, find the largest number of a certain length within the given number.
You cannot rearrange and must go from left to right.

My answers are: 16946 and 168627047606506 for parts 1 and 2 respectively.

## Part 1

Find the largest 2-digit battery in each given line and return the sum of all batteries.

eg. 818181911112111 = 82

## Part 2

Find the largest 12-digit battery.

eg. 818181911112111 = 888911112111

### My solution

Pretty straightforward. Starting from the left, advance along the number (not going to the end until the last digit) and find the largest number that can be found.

Do this for the required number of digits.

## Notes

First time messing with Fortran. Quite different to what I am used to but actually quite easy to use.

Used the [Intel fortran manual](https://www.intel.com/content/www/us/en/docs/fortran-compiler/developer-guide-reference/2023-0/language-reference.html) quite a lot as well as [Oracle's manual](https://docs.oracle.com/cd/E19957-01/805-4939/index.html), however Intel's is easier to follow and reference.
