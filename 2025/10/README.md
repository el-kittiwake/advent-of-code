# Day 10 (Python)

For day 10, I am given the partially destroyed remnants of a factory's machine manuals. All that remains is a list of indicator light diagrams, arranged in lines as below:

``` text
[.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}
[...#.] (0,2,3,4) (2,3) (0,4) (0,1,2) (1,2,3,4) {7,5,12,7,2}
[.###.#] (0,1,2,3,4) (0,3,4) (0,1,2,4,5) (1,2) {10,11,11,5,10,5}
```

Each line consists of:

* Indicator lights `[...]`: a string of `.` (off) and `#` (on) characters representing the target light state.
* Button wiring schematics `(...)`: one or more strings of comma separated values, each denoting which lights a particular button toggles.
* Joltage requirements `{...}`: a comma-separated list of integers, one per light.

My answers are: 517 and 21469 (1.4 seconds) for parts 1 and 2 respectively.

## Input handling

The file is read linewise and the current line is processed before the next line is read. Lines are parsed using Python's regex module `re`.

The target light string is converted into a bitmask. States `#` and `.` are translated into 1 and 0 respectively using `str.maketrans` and `str.translate`. The resulting binary string is then interpreted as base 2 and converted to an integer via `int(string, 2)`, equivalent to `strtol(str, NULL, 2)` in C.

State `.##.` translates to binary `0110` which is converted to integer `6`.

Light index 0 (leftmost) maps to the most significant bit, preserving the left-to-right visual ordering. The formula for light index `i` in an `n`-light machine is `1 << (n - 1 - i)`.

The button schematics are converted to a list of bitmasks. Each number in a button schematic is a light index corresponding to a bit position going left to right.

Input `(3) (1,3) (2) (2,3) (0,2) (0,1)` becomes binary `[0001, 0101, 0010, 0011, 1010, 1100]`, stored as integers `[1, 5, 2, 3, 10, 12]`.

For part 2, the button schematics are instead stored as a list of lists of integers, the light indices. This is a requirement of the tool used for part 2.

Joltage is only required for part 2. The input list of strings is simply converted to a list of integers.

## Part 1

Find the minimum number of button presses to match the target light configuration for each machine. Return the cumulative total across all machines.

### Part 1 solution

Each button press toggles a set of lights, meaning the minimum solution never presses any button more than once. The solution is the minimum-size subset of buttons whose combined XOR matches the target.

The naive brute force solution is adequate. My input has 200 machines, a maximum of 10 lights, and a maximum of 13 buttons per machine. The worst case is 2^13 = 8,192 subsets per machine, approximately 1.6 million total operations. In practice this runs in tens of milliseconds.

Iterate through combinations of buttons using `itertools.combinations`, starting with single buttons and increasing the combination size. For each combination, XOR (`^=`, same operator as C) all of the button masks together. If the result matches the target, return the size of the combination. The first match found is guaranteed to be the minimum since combinations are tried in order of increasing size.

## Part 2

Find the minimum number of button presses resulting in the total number of toggles on each light exactly matching the corresponding joltage value. Buttons may now be pressed multiple times. Return the cumulative total across all machines.

### Part 2 solution

Joltage values in the input get up to 265 on some lines. Because of this, button counts could reach into the hundreds, making brute force somewhat time consuming. A machine with 13 buttons and an average bound of 50 presses per button gives 50^13 ≈ 10^22 possibilities. This would make the puzzle a lifetime endeavour!

The puzzle resembles a system of linear equations with a non-negative integer constraint. The method used is known as [Integer Linear Programming (ILP)](https://en.wikipedia.org/wiki/Integer_programming).

Once again with our example first line:

`(3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}`

The buttons activate the lights inside them. These correspond to the joltages in the curly brackets. So the solution will consist of each button `bn` pressed a certain number of times (multiplied by a coefficient `xn`).

General equation:

`x0 * b0 + x1 * b1 + x2 * b2 + x3 * b3 + x4 * b4 + x5 * b5 = joltage`

Optimal solution below. The first equation has all expressions in the system, the rest omit all expressions that evaluate to 0. As can be seen, the first line is solved in 10 button presses:

``` text
j0 = 3 = 0 * (3) + 0 * (1,3) + 0 * (2) + 0 * (2,3) + 3 * (0,2) + 0 * (0,1)
j1 = 5 = 5 * (1,3)
j2 = 4 = 3 * (2,3)
j3 = 7 = 5 * (1,3) + 3 * (2,3)
```

My first thought was brute force, quickly replaced by my second thoughts; to use something like numpy or scipy. However [PuLP](https://coin-or.github.io/pulp/) came up, as it is designed specifically for this kind of work, it seemed ideal.

The problem is initialised with `pulp.LpProblem`. Integer variables are created using the `pulp.LpVariable.dicts` method, one variable per button.

Constraints are added next using `pulp.lpSum`, one per light. Only add to the expression buttons that affect the current light. The constraint is completed with the joltage equality.

The objective is to minimise the total press count. `minimise: x0 + x1 + x2 + x3 + x4 + x5`.

The final step is to call the CBC solver (PuLP's default, branch-and-cut method).

Considering the ridiculous brute force complexity, this problem is tiny for more advanced methods like ILP. Solution is found within 1.5 seconds.

## Notes

I have used Python a little before, but this was the most complicated task I have used it for so far.

Regex really helped make the parsing stage easy, grabbing what I need with minimal effort. Regex is often a lifesaver, regardless of language though. Proper time savers were the string translate and itertools.combinations.

PuLP was the star of the show though. Just declare variables, constraints and set up the problem. It solves the problem in a way that feels mathematical, which is ideal for its intended use. Regardless, PuLP does in a matter of a few lines what would take other methods quite a lot more code complexity. Not to mention time complexity.

Like the previous day, part 1 and 2 required very different approaches. On to the next....

New concepts encountered:

* ILP
  * The crux of the part 2 solution, crudely described above.
* The [simplex method](https://en.wikipedia.org/wiki/Simplex_algorithm)
  * Reminded me a little of conjugate-gradient. Essentially a geometric abstraction where an optimal value is lying at a vertex of a multidimensional shape.
* [LP relaxation](https://en.wikipedia.org/wiki/Linear_programming_relaxation)
  * Temporarily ignoring the integer constraint. Much faster, but if the result is not integer, branch and bound is needed to find the true integer optimum.
* [branch-and-bound](https://en.wikipedia.org/wiki/Branch_and_bound) and [branch-and-cut](https://en.wikipedia.org/wiki/Branch_and_cut)
  * Breaking problems into smaller subproblems.

Sources I found helpful:

* [Real Python](https://realpython.com)
* [PuLP documentation](https://coin-or.github.io/pulp/)
* [Real Python - Hands-On Linear Programming: Optimization With Python](https://realpython.com/linear-programming-python/)
* Competitive Programmer's Handbook by Antti Laaksonen.