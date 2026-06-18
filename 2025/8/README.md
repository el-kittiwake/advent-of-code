# Day 8 (Ruby)

You are given a line-delimited list of 3D coordinates. Each coordinate represents a junction box in 3D space. Junction boxes can be connected by strings of lights to form circuits.

Example input:

``` text
162,817,812
57,618,57
906,360,560
592,479,940
```

My answers are: 123420 and 673096646 for parts 1 and 2 respectively.

## Part 1

Calculate the product of the sizes of the three largest circuits, after connecting the 1000 closest pairs of junction boxes.

## Part 2

Calculate the product of the X coordinates of the last two junction boxes connected before all boxes form a single circuit.

### My solution

I parse the input into an array of `[x, y, z]` arrays, these are the nodes (junction boxes). I then generate all pairwise combinations using `combination(2)`.

These combinations are now sorted by the squared [Euclidean distance](https://en.wikipedia.org/wiki/Euclidean_distance) between them. I omit the square root from the formula as it doesn't change the ordering.

For part 1, I take the first 1000 pairs and discard the rest. When processed, some of these pairs will be in a set (circuit) already and redundant.

For part 2 the entire list of pairs are processed ending only when all nodes are merged into a set. This is accomplished by adding a component counter and decrementing on each merge, ending when only when it reaches 1.

Each sorted pair is passed on to ["Union-find"](https://en.wikipedia.org/wiki/Disjoint-set_data_structure). This uses a hash:`parent` with each node initialised as pointing to itself, its own root. `find` traverses parent pointers to the root. It repoints every visited node directly to the root on the way back, known as path compression. `union` calls `find` on both combined nodes and attaches one root to the other if they differ.

For part 1: After processing I call `find` on every node, group by root, extract sizes, and multiply the top three.

For part 2: I multiply the X coordinate (first element) of the final pair that caused a merge before the component counter reached 1.

## Notes

First time using Ruby. Having more experience with C, coming to higher-level languages is often quite stunning. Sometimes the range of features that are available can be quite daunting. I tried to use as many as I could as properly as I could.

The Enumerable module provides the methods to sort, group, perform operations on a whole array. Most of the work is done through that module. Essentially allowing me to take the input data, and in a handful of lines do everything I needed to do to it to solve the problem.

This puzzle was much more algorithm heavy than anything so far this year. I had never heard of Kruskal's algorithm or Union-find and it was quite enjoyable getting my head around them.

This was difficult for me and somewhat frustrating. But of course, once I got it, it felt good.
