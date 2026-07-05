# Day 2 (Dodgy CPP)

You are given a comma-separated string of numeric ranges representing product IDs. Within these ranges are several invalid product IDs, the number and value of which differ for both parts.

Example: `13-30,6859-7000,42382932-42449104`

My input has 36 different ranges.

My answers are: 13919717792 and 14582313461 for parts 1 and 2 respectively.

## Input parsing

The input file is read and split into a vector of pairs containing each range's start and end value.

## Part 1

The solution to this part is the sum of "invalid IDs". Invalid IDs are numbers within the ranges that contain a numeric pattern repeated twice. For example: in 13-30 there is 22 and in 6859-7000 there is 6868 and 6969. So the solution in this case would be 13859.

### Part 1 solution

I first discount any odd length number ranges.

I iterate from the start until eh end value in the range, splitting that value in half and comparing the 2 halves.

If the halves match, I add the value to the total.

## Part 2

The solution to this part is the sum of "invalid IDs". Invalid IDs are numbers within the ranges that contain a numeric pattern repeated any number of times. For example: 123123123, 1111, 454545 would all be considered invalid IDs.

### Part 2 solution

This one is easier to solve as there is no need to discount odd length strings.

I used the idea from [this page](https://algo.monster/liteproblems/459).

By combining the string and a copy of itself and starting the search from index 1 the search algorithm will only hit the original string if it indeed is a repeating pattern. The doubled string essentially creates a loop that will be found if it is a repeating pattern.

## Notes

Immediately of note is the number of times I swap between types. This is not ideal and can certainly be done better with a better understanding of the language and its standard library. I am certainly not taking advantage of CPP's features here.

I could probably have improved some of the string manipulation by using std::string_view rather than having to use string.substr() so much.

I could probably have used std::ifstream + std::istreambuf_iterator to read my input into a string directly, rather than having to mess around with streams.

C++ is surely a candidate to get more in depth with and understand better.

### Other potential solutions

Thinking about the problem after the event ended and seeing what others did, raises some potentially superior solutions.

Using regex (std::regex) would have been a suitable way to not only parse the input but to check the values themselves. Check each number in the range for `^(.+)\1$` (part 1) and `^(.+)\1+$` (part 2). However, this would be quite a bit slower.

The regex breaks down thus:

1. `^` match from start of string.
1. `( ... )` denotes a capturing group.
1. `.` match any character.
1. `+` match previous token between one and unlimited times.
1. `\1` match the same text as matched by the previous capturing group. AKA. backreference.
1. `$` end of string.

The `\1+` for part 2 allows the captured pattern to repeat more than once, covering cases like three-or-more repeats (e.g. 123123123)".

Another possible solution was to compare numbers rather than strings. Halving each individual number in the range then comparing the result of division and modulo. If they are equal, the ID is invalid. This could potentially be quite quick.

I saw at least one solution where candidates were generated to test against the range, rather than iterating the range.

Lots of learning on today's.
