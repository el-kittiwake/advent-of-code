# Day 3 (Fortran)

I am given a line-delimited list of numbers. Each number corresponds to a battery, each line a bank of batteries.

Example input:

``` text
987654321111111
422223232222299
818181911113222
```

My input consists of 200 lines, each 100 characters long.

You must turn on a given number of batteries in order to produce the maximum "joltage" for that line.

Basically, find the largest number of a certain length within the given line. You cannot rearrange numbers and must go from left to right.

My answers are: 16946 and 168627047606506 for parts 1 and 2 respectively.

## Part 1

Find the largest 2-digit joltage in each given line, when done return the sum of all batteries.

eg. 818181911113222 = 93

## Part 2

Same as part 1, except find the largest 12-digit joltage.

eg. 818181911113222 = 888911113222

### My solution

The solution is a [greedy scan](https://en.wikipedia.org/wiki/Greedy_algorithm) of each line.

Starting from the left, advance along the line charwise, and pick the largest digit found. Remembering to leave enough trailing characters for the number of picks remaining. Do this for the number of required digit picks.

The implementation operates in three loops.

* `file_loop` loops through each line in the input.
* `convert_loop` loops through the current character line converting to an array of integers.
* `battery_loop` loops until the joltage has been filled.

Visualised in ASCII:

``` text
file_loop           (once per line)
│  read line, reset: marker=0, bat_count=batteries-1, bat_tot=0
│
├─ convert_loop     (once per line: convert line -> digits array)
│    digits(i) = ichar(line(i:i)) - ichar('0')   for i = 1..line_len
│
└─ battery_loop     (once per digit to choose, bat = 1..batteries)
   │  window = digits(marker+1 .. line_len-bat_count)
   │  i = marker + MAXLOC(window, dim=1) <- one call, no inner scan loop
   │
   │  bat_tot = bat_tot * 10 + digits(i)
   │  bat_count -= 1   (window shrinks for next pass)
   ▼
   next battery_loop pass, window shifted/shrunk
```

Simple worked example:

``` text
line: 5 2 9 2 6 1
batteries: 3

pass 1  bat_count=2   window=[1..4]
        5  2  9  2  6  1
        └──┴──┴──┘
        MAXLOC → pos3 (val 9)   marker=3

pass 2  bat_count=1   window=[4..5]
        5  2  9  2  6  1
                 └──┘
        MAXLOC → pos5 (val 6)   marker=5

pass 3  bat_count=0   window=[6..6]
        5  2  9  2  6  1
                       └
        MAXLOC → pos6 (val 1)   marker=6

chosen: 9, 6, 1 → 961
```

The maxloc() function returns the index of the largest value in an array.

## Notes

First time messing with Fortran. A little different to what I am used to but actually quite easy to use and enjoyable to figure out.

This was the easiest puzzle so far and somewhat of a joy considering the struggles I have later.

Sources I found helpful:

* The [Intel Fortran manual](https://www.intel.com/content/www/us/en/docs/fortran-compiler/developer-guide-reference/2023-0/language-reference.html).
* [Oracle's FORTRAN 77 manual](https://docs.oracle.com/cd/E19957-01/805-4939/index.html).
* "Modern Fortran" by Milan Curcic.

### Other potential solutions

Brute force, attempting every combination of 2 and 12 batteries. Likely OK for 2, but for 12 it would be unsuitable.

A classic approach to this kind of [remove k digit to maximise result](https://neetcode.io/solutions/remove-k-digits) problem is to use a stack (or stack like) structure. Fortran does not have a native stack, but this could be worked around.

The advantage of this method over my choice is that it only requires one pass O(n) rather than O(nk). This is because the stack has only the larger numbers pushed, so by the end, the first n digits will comprise the largest number of n length.
