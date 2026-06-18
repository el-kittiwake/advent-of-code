# Day 2 (Dodgy CPP)

You are given a comma-separated string of numeric ranges, such as: 13-30,6859-7000,42382932-42449104
Within these ranges are several invalid IDs.

My answers are: 13919717792 and 14582313461 for parts 1 and 2 respectively.

## Part 1

The solution to this part is the sum of "invalid IDs". Invalid IDs are numbers within the ranges that contain a numeric pattern repeated twice. For example: in 13-30 there is 22 and in 6859-7000 there is 6868 and 6969. So the solution in this case would be 13859.

### Part 1 solution

First I split the input into a vector of pairs containing each range start and end value.

I then discount any odd length number ranges.

Then I go through each number in the range, splitting it in half and comparing the 2 halves.

## Part 2

The solution to this part is the sum of "invalid IDs". Invalid IDs are numbers within the ranges that contain a numeric pattern repeated any number of times. For example: 123123123, 1111, 454545 would all be considered invalid IDs.

### Part 2 solution

This one solves easier as there is no need to discount odd length strings.

I used the idea from [this page](https://algo.monster/liteproblems/459).

By combining the string and a copy of itself and starting the search from index 1 the search algorithm will only hit the original string if it indeed is a repeating pattern. The doubled string essentially creates a loop that will be found if it is a repeating pattern.

## Notes

Other than the quite bloaty file handling and string splitting part 1 at least has quite a bit of inefficient conversion between numbers and strings. Part 2 is quite clean and intuitive. I am not really taking advantage of CPP's features here, other than some library functions.
