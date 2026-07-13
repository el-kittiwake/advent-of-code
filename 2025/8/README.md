# Day 8 (Ruby)

I am given a line-delimited list of 3D coordinates. Each coordinate represents a junction box in 3D space. Junction boxes can be connected by strings of lights to form circuits.

Example input:

``` text
44548,2875,53676
666,420,888
9081,4630,4555
42173,92528,45714
8737,44903,82808
4949,73100,84956
```

My answers are: 123420 and 673096646 for parts 1 and 2 respectively.

## Input parsing

The file is read in its entirety using the `File.readlines()` method. This method returns an array of lines from the file.
Alternatively `.foreach()` could have been used, however for such a small file that needs reading in its entirety, it is not ideal.

The array is processed using the `Array.map{}` method.
Each line is processed with `line.chomp()`: remove trailing newlines; `line.split()`: tokenise by the given delimiter (comma in this case); and `.map(&:<method>)`: iterates over the whole array returned by `.split()`, and calls a no-argument method on the value (in this case converts to integer).

This results in an array of `[x, y, z]` arrays, these represent the nodes (junction boxes).

Example input after this stage:

``` text
[[44548, 2875, 53676],
[666, 420, 888],
[9081, 4630, 4555],
[42173, 92528, 45714]]
```

The initial conditions for the search are set using `Array.each_with_object()`. This creates a hash where the key and value pair are the same.

Example input after this stage:

``` text
{[44548, 2875, 53676]  => [44548, 2875, 53676],
 [666, 420, 888]       => [666, 420, 888],
 [9081, 4630, 4555]    => [9081, 4630, 4555],
 [42173, 92528, 45714] => [42173, 92528, 45714]}
```

## Part 1

Calculate the product, of the sizes, of the three largest circuits. After connecting the 1000 closest pairs of junction boxes.

Example input result:

``` text
{[44548, 2875, 53676] => [44548, 2875, 53676],
[666, 420, 888]       => [9081, 4630, 4555],
[9081, 4630, 4555]    => [9081, 4630, 4555],
[42173, 92528, 45714] => [42173, 92528, 45714],
[8737, 44903, 82808]  => [4949, 73100, 84956],
[4949, 73100, 84956]  => [4949, 73100, 84956]}
```

This purely indicative example shows the connection between a junction box and its root node. From this can be seen there are two circuits of two nodes, and 2 nodes that are unconnected, single node circuits.

## Part 2

Calculate the product of the X coordinates of the last two junction boxes connected before all boxes form a single circuit.

## My solution

The first step is to generate all pairwise combinations using `Array.combination(2)`.

These combinations are now sorted by the squared [Euclidean distance](https://en.wikipedia.org/wiki/Euclidean_distance) between them. I omit the square root from the formula as it doesn't change the ordering.

For part 1, I take the first 1000 pairs and discard the rest. When processed, some of these pairs will be in a set (circuit) already and redundant.

For part 2 the entire list of pairs are processed ending only when all nodes are merged into a set. This is accomplished by adding a component counter and decrementing on each merge, ending only when it reaches 1.

Each sorted pair is passed on to ["Union-find"](https://en.wikipedia.org/wiki/Disjoint-set_data_structure). This uses the hash:`parent` with each node initialised as pointing to itself, its own root. `find` traverses parent pointers to the root. It repoints every visited node directly to the root on the way back, known as path compression. `union` calls `find` on both combined nodes and attaches one root to the other if they differ.

For part 1: After processing I call `find` on every node, group by root, extract sizes, and multiply the top three.

For part 2: I multiply the X coordinate (first element) of the final pair that caused a merge before the component counter reached 1.

## Notes

First time using Ruby. Having more experience with C, coming to higher-level languages is often quite stunning. Sometimes the range of features that are available can be quite daunting. I tried to use as many as I could as properly as I could.

The [Enumerable](https://ruby-doc.org/3.4.1/Enumerable.html) module provides the methods to sort, group, perform operations on a whole array. Most of the work is done through that module. Essentially allowing me to take the input data, and in a handful of lines do everything I needed to do to it to solve the problem.

This puzzle was much more algorithm heavy than anything so far this year. I had never heard of [Kruskal's algorithm](https://en.wikipedia.org/wiki/Kruskal's_algorithm) or Union-find and it was quite enjoyable getting my head around them.

This was difficult for me and somewhat frustrating. But of course, once I got it, it felt good.
