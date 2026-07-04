# Day 1 (C)

I am given a series of combination safe lock "clicks" in the form XY, where X is either R or L (right, left) and Y is the number of clicks in that direction.

Example input:

``` text
L666
L39
L1
R13
L5
R69
```

The lock has 100 positions on the dial, ranging from 0 to 99 and starting at position 50. My input has 4577 lines and a maximum rotation of 998.

## Puzzle

The answer to part 1 is the number of times the position of the dial equals 0.

The answer to part 2 is the number of times the position of the dial equals 0 as well as the number of times the dial passes 0 during a rotation.

My answers are: 1139 and 6684 for part 1 and 2 respectively.

### Solution

The input file is read linewise until EOF in a while loop. Each line is `sscanf`ed into direction and rotation variables. The sign is set from the char found in direction (R: 1, L: -1).

Taking `rotation modulo 100` extracts partial rotations from full rotations.

The offset (position relative to 0) is calculated from the current position with the sign corrected modulo added to it.

#### Part 1 specifics

If the offset value is greater than 99 I subtract 100 to cancel the full rightward rotation. If the offset value is less than 0 I subtract its absolute value from 100 to cancel the full leftward rotation.

Any value between 0 and 99 is taken as the new position.

The current position is checked, and if it is 0 the zero counter is incremented and the loop continues.

Once end of file is reached the loop exits and I output the number of zeroes.

#### Part 2 specifics

Any full rotations are accounted for before moving on to partial rotations. As my input's largest rotation value is 998, this is important for part 2.

Offsets of 100 and 0 are counted as they land on zero.

Offsets greater than 100 and less than 0 are counted and handled in the same way as for part 1.

Any value between 0 and 99 is taken as the new position.

Once end of file is reached the loop exits and I output the number of zero touches.

## Notes

Part 1 was relatively quick for me, within an hour maybe.

Part 2 took me quite a bit longer. I had a couple of struggles. I was getting values that were too large. Turns out I was counting 0 twice if the current position was 0.
