# Day 1
You are given a series of combination safe lock "clicks" in the form XY, where X is either R or L (right, left) and Y is the number of clicks in that direction.

The lock has 100 positions on the dial, ranging from 0 to 99 and starting at position 50.

My answers are: 1139 and 6684 for part 1 and 2 respectively.

### Part 1
The solution to this part is the number of times the position of the dial equals 0.

##### My solution
I loop through my input file line by line, each line is a separate direction and click count (XY value).

While there are lines to read I extract the direction (R or L, which I save as a sign value 1 and -1 respectively), and number of clicks.

I then calculate the modulo of the rotations to 100, this eliminates any 100 click rotations as they cancel.

Then adding current position to the calculated modulo gives me a rotation offset. If this value is 0, then I increment a zero counter. If it is greater than 99 I subtract 100 and if it is less than 0 I subtract it from 100.

Any value between 0 and 99 is taken as the new position.

Once end of file is reached I output the number of zeroes.

### Part 2
The solution to this part is the number of times the position of the dial equals 0 as well as the number of times the dial passes 0 during a rotation.

##### My solution
I loop through my input file line by line, each line is a separate direction and click count (XY value).

While there are lines to read I extract the direction (R or L, which I save as a sign value 1 and -1 respectively), and number of clicks.

I then calculate the modulo of the rotations to 100, this eliminates any 100 click rotations as they cancel. Then add the current position to the calculated modulo to find my rotation offset.

I increment the zero counter by the value of rotations / 100. This counts all full rotations as they will by definition pass by 0.

I then check the rotation offset for various values. 

If this value is 0 or 100 I increment a zero counter and make the current position 0. If it is greater than 100 I subtract 100 and increment the zeroes. If it is less than 0 I subtract it from 100 and increment the zeroes if the previous position was not 0.

Any value between 0 and 99 is taken as the new position.

Once end of file is reached I output the number of zeroes stopped at and passed through.

### Notes
Part 1 was relatively quick for me, within an hour maybe. Part 2 took me quite a bit longer, I struggled to find why I was getting too large values. Turns out I was counting 0 twice if the current position was 0.

# Day 2
You are given a comma separated string of numeric ranges, such as: 13-30,6859-7000,42382932-42449104

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
Other than the quite bloaty file handling and string splitting part 1 at least has quite a bit of inefficient conversion between numbers and strings. Part 2 is quite clean and intuitive.
