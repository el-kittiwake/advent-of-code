# Day 12 (COBOL)

I am presented with six numbered Christmas present shapes, numbered from 0 to 5. Example of the first two below:

``` text
0:
###
##.
##.

1:
###
##.
.##
```

These need to be placed under the Christmas trees around the North Pole. To aid with this we are given a list of under-tree regions with a count of the number of different shaped presents that need to fit into those regions. Example below:

``` text
42x42: 32 31 30 40 41 42
68x48: 42 37 58 42 46 69
```

So, for the region of 42x42 in area we must fit: 32 type 0 presents, 31 type 1, 30 type 2, 40 type 3 and so on. It is permitted to flip and rotate presents.

This is a [polyomino packing problem](https://www.isnphard.com/i/polyomino-packing/), which is [NP-hard](https://en.wikipedia.org/wiki/NP-hardness).

The shortcut solution to the puzzle is the number of regions inside which every assigned present will fit.

My answer is: 587.

## Solution

As usual, my mind immediately jumps to brute force. As much as I enjoy researching and learning new things, I am a creature of habit at heart. The problem is that brute force is completely off the table here.

I have 1000 lines in my input, each line is something like: `52x48: 42 73 58 42 55 69`. This is 339 shapes needing placing, in a 2496 cell grid. Each shape can be rotated 4 ways and flipped 2 ways. The time to complete a task like this is age of the universe scale. I simply do not have the patience for that.

The three best possible solutions smarter people than me were talking about were:

* Bitmask backtracking
* Dancing Links / Algorithm X
* ILP solvers (OR-Tools, Z3)

Honestly, I do not have the mathematics chops to be able to snappily define and talk about these, so I will leave that for more experienced people.

As it turns out, and as was widely discussed, there is a shortcut solution. This is probably the go to solution for quite a few who attempt this. So I don't feel too guilty.

I followed a yes, no, maybe set of checks in my solution, a somewhat belt and braces approach but it felt wrong to just take the shortcut as given.

* Yes.
  * When considering presents as 3x3 tiles: the present total is less than or equal to the region's tile capacity.
* No.
  * Considering presents' actual `#` count: the present area total is greater than the region's area.
* Maybe.
  * Any other condition.

And that's it for 2025. My first AoC year ... I only finished half a year late!

## Notes

COBOL would not have been my choice if there wasn't the shortcut solution available. However for a relatively simple solution, it seemed like a nice prologue to 2025.

It is a very verbose language, with lots of window dressing and formality, but it is immensely readable and quite pleasant to write. I chose the fixed-form discipline rather than free-form because it seemed like it could be more fun to work around the limits of the language of old.

There are quite a lot of reserved words in COBOL that I bumped into a few times. `CAPACITY`, `COUNT`, `LINE` and `SIZE` are all reserved words I commonly use as variable names.

It actually seemed pretty suited to this job. In particular it was quite painless to work with the strings. The `INSPECT ... TALLYING ... FOR ALL` and `UNSTRING ... DELIMITED BY` functions took a lot of the hard work out of string manipulation and parsing.

All in all a quite relaxing and pleasant end to the event.
