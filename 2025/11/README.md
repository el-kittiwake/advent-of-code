# Day 11 (Haskell)

Today's puzzle involves finding routing solutions in a line delimited list of devices and addresses.

``` text
aaa: you hhh
you: bbb ccc
bbb: ddd eee
ccc: ddd eee fff
ddd: ggg
eee: out
fff: out
ggg: out
hhh: ccc fff iii
iii: out
```

The format of each line is: `device: connected devices`. For example line 4 refers to device `ccc` which has connections to devices `ddd`, `eee` and `fff`.

Starting from `you` and exiting at each `out`, find every path through the system.

Example: `you` -> `ccc` -> `fff` -> `out`.

My answers are: 613 and 372918445876116 for parts 1 and 2 respectively.

## Input handling

The input file is read using `readFile` and parsed into an adjacency list (`Map String [String]`). Under the covers `readFile` is lazy, so the file is read as the code requires it.

Each line is split at the `:` using `break (== ':')`, this is the device name and the list's key. The remaining part has its leading colon removed with `drop 1`, then split on whitespace by `words` to produce the neighbour list as the value. This is processed over all lines right to left using `foldr`, inserting one entry per line into `Map.empty` to build the complete graph.

`foldr` is the [idiomatic right choice](https://wiki.haskell.org/Foldr_Foldl_Foldl%27) compared to `foldl'` and certainly `foldl`. Mainly `foldr` is used here for code clarity because the argument order of `insertLine` matches that of `foldr` naturally, enabling [point-free style](https://wiki.haskell.org/Pointfree). `foldl'` would be a better performer, but for my list of 604 lines, that is not a concern. Additionally, the order of lines in the input do not matter, so `foldr` is fine to use here regardless.

Due to quirks of the language, a new map has to be created every line, because maps (and all data objects) are immutable.

## Part 1

Find the total number of distinct paths in the system from "you" to "out". The example input has 5 total paths.

### Part 1 solution

Brute force always comes to mind for part 1, but I think it might be a trap. I have 604 lines in my input, the maximum number of locations per device is 21 and there are potentially as many jumps for each path if not more. Complexity could be <devices>^<jumps> per path, which could get slow, fast.

I've already used BFS this year so it comes to mind, but that is ideally suited to finding the shortest path, it can be used to find multiple paths, but then I am not using it to its advantages.

The puzzle input is in the form of a [Directed Acyclic Graph (DAG)](https://en.wikipedia.org/wiki/Directed_acyclic_graph). Directed because there is only one direction of flow (outputs to devices) and acyclic because there is no return or looping, it is one directional.

These sorts of problems seem to be solved optimally by using dynamic programming methods. Dynamic programming on the DAG as it is known.

The number of paths from any node to `out` equals the sum of paths from each of its neighbours to `out`. There are overlapping solutions, which benefit from caching (when working with graphs, this is known as memoisation). Memoisation is the mechanism of dynamic programming. Because of memoisation, as the puzzle progresses results are cached so shared subproblems are never recomputed.

Example input memoisation tree:

``` text
paths(ggg) = 1
paths(ddd) = paths(ggg) = 1
paths(eee) = 1
paths(fff) = 1
paths(ccc) = paths(ddd) + paths(eee) + paths(fff) = 3
paths(bbb) = paths(ddd) + paths(eee) = 2
paths(you) = paths(bbb) + paths(ccc) = 5
```

Each paths(device) indicates the number of routes to `out` from that device.

`ddd` and `eee` are both reachable from `bbb` and `ccc`, without memoisation these sub-routes would get walked over twice. This is not a big deal for the example, but for my input devices could be reachable hundreds of times. Re-walking those would be a massive inefficiency.

The above in tree form:

``` text
you
├── bbb
│   ├── ddd
│   │   └── ggg
│   │       └── out
│   └── eee
│       └── out
└── ccc
    ├── ddd
    │   └── ggg
    │       └── out
    ├── eee
    │   └── out
    └── fff
        └── out
```

To solve we recursively call `pathsOne <device> <adjacency list> <memoisation table>` which returns: the current number of paths counted and the new memoisation table. `pathsOne` has three possible branches:

* Current device is "out".
  * return 1, and the current memoisation table (memo).
* Current device is already cached.
  * return the contents of the memo at key = device, and the current memo.
* Neither of the above, so current device is new.
  * iterate over neighbours with `foldl'`, passing the memo through each recursive call, update the total, insert the result into the memo and return total and new memo.

Once the recursive stack collapses we should have the total number of paths in the total.

## Part 2

Part 2 is mostly the same as part 1. The only difference being the starting point is now "svr" and each viable path has to pass through both "dac" and "fft".

### Part 2 solution

Part 2's solution is ostensibly the same as part 1's.

Structural changes needed:

1. Two extra Bool parameters: visitDAC, visitFFT.
1. Memo key: (String, Bool, Bool) instead of just String.
1. Base case "out": return 1 only if both bools true, else 0.
1. Before recursing into neighbours: update bools if currDev is "dac" or "fft".
1. Starting call: pathsTwo "svr" False False graph Map.empty.

After the last two days it was nice to have a straightforward part 2 solution.

## Notes

First time using Haskell. The paradigm shift from what I am used to was painful. I can't say I enjoyed the experience but it was eye opening to struggle and cobble my way through this day. My biggest lament is the rather terse official documentation. I also struggled to gel with the few third party sources there are available.

Being unable to loop or mutate values was quite hard to get used to. Not to mention thinking recursively, which is not my strongest ability as I usually want to avoid recursion.

Indentation as syntax reminds of Python and is mostly quite easy to handle, but sometimes you miss something and then you have to figure out what went wrong and Haskell sometimes gives less than ideal error messages.

Keywords `do` and `where` are quite nice sprinklings of syntactic sugar. `do` is used to enforce imperative execution for IO actions, which is useful in a language where order is not important.  `where` is somewhat like { ... } in C and other curly-bracket languages. However in a where block, the order of expressions and functions is not important and the compiler figures out the order.

The lack of mutability is weird. Having to pass the `memo` map through the recursive calls seems somewhat backwards. However I believe the reasons for this quirk are well founded. These include not having to wonder about a value while reading code, preventing data races, consistency of function output and allowing for laziness without concern.

Dynamic programming initially sounded like yesterday's new concept of branch and bound. They share the similarity in that they do not naively explore everything, however they are fundamentally different.

Branch and bound avoids unnecessary computation by pruning choices from a tree of choices when it is clear that those choices cannot win against others. Dynamic programming avoids waste by spotting that two branches converge on identical subproblems and exploiting that overlap.

I'm not trying to find a best solution here, so there is no bad choice to prune. I will be traversing many similar paths, so DP is the way to go.

``` text
DP:                                    Branch-and-bound:

   you                                      root
  /   \                                    /    \
ccc   bbb                              choice A  choice B
 |     |                                  |         |
ddd   ddd   <- SAME subproblem,      (bound: 50)  (bound: 12, current
 |     |       compute once,             |          best is already 40)
...   ...      reuse answer            explore        -> PRUNE, never
                                        further          explore further
```

New concepts:

* Purely functional programming.
  * No side effects and no mutation.
* Monads and `do` notation.
  * Structuring sequential actions in a normally unstructured language.
* Lazy evaluation.
  * Computation of expressions on demand, inference of dependency order. I have come across this concept a little before, but this puzzle and Haskell forced me to understand it more.
* Parametric polymorphism.
  * Allows for functions to be type agnostic. Type variables such as `a` and `[b]` enabling C++ like template functions.
* Partial application and currying.
  * Supplying fewer arguments to a function and returning a new function waiting for the rest.
* Immutable state threading.
  * Explicitly passing updated maps through recursion rather than mutating them in place.

Sources I found useful:

* [Learn You a Haskell for Great Good](http://learnyouahaskell.com). A well regarded and free online book. It covers the basics, however I did find its style hard to follow at times.
* [Hoogle](https://hoogle.haskell.org). Official standard library function search.
* Lots of Wikipedia articles for concepts.
