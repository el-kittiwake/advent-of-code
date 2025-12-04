# advent-of-code-2025
[Details here (adventofcode.com).](https://adventofcode.com/)

## Day 1
You are given a series of combination safe lock "clicks" in the form XY, where X is either R or L (right, left) and Y is the number of clicks in that direction.

The lock has 100 positions on the dial, ranging from 0 to 99 and starting at position 50.

My answers are: 1139 and 6684 for part 1 and 2 respectively.

#### Part 1
The solution to this part is the number of times the position of the dial equals 0.

###### My solution
I loop through my input file line by line, each line is a separate direction and click count (XY value).

While there are lines to read I extract the direction (R or L, which I save as a sign value 1 and -1 respectively), and number of clicks.

I then calculate the modulo of the rotations to 100, this eliminates any 100 click rotations as they cancel.

Then adding current position to the calculated modulo gives me a rotation offset. If this value is 0, then I increment a zero counter. If it is greater than 99 I subtract 100 and if it is less than 0 I subtract it from 100.

Any value between 0 and 99 is taken as the new position.

Once end of file is reached I output the number of zeroes.

#### Part 2
The solution to this part is the number of times the position of the dial equals 0 as well as the number of times the dial passes 0 during a rotation.

###### My solution
I loop through my input file line by line, each line is a separate direction and click count (XY value).

While there are lines to read I extract the direction (R or L, which I save as a sign value 1 and -1 respectively), and number of clicks.

I then calculate the modulo of the rotations to 100, this eliminates any 100 click rotations as they cancel. Then add the current position to the calculated modulo to find my rotation offset.

I increment the zero counter by the value of rotations / 100. This counts all full rotations as they will by definition pass by 0.

I then check the rotation offset for various values. 

If this value is 0 or 100 I increment a zero counter and make the current position 0. If it is greater than 100 I subtract 100 and increment the zeroes. If it is less than 0 I subtract it from 100 and increment the zeroes if the previous position was not 0.

Any value between 0 and 99 is taken as the new position.

Once end of file is reached I output the number of zeroes stopped at and passed through.

#### Notes
Part 1 was relatively quick for me, within an hour maybe. Part 2 took me quite a bit longer, I struggled to find why I was getting too large values. Turns out I was counting 0 twice if the current position was 0.
