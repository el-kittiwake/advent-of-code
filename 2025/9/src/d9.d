/*
    Advent of code 2025, day 9, D

    Resources:
            https://tour.dlang.org/
            https://dlang.org/spec/intro.html
            https://dlang.org/phobos/
            Programming in D by Ali Çehreli

    Part 1: 4745816424
    Part 2: 1351617690
*/

import std.stdio;
import std.array;
import std.string : chomp;
import std.conv : to;
import std.math.algebraic : abs;
import std.typecons : Tuple;
import std.algorithm : swap, sort, min, max, map, uniq;
import std.range : assumeSorted;
import std.container : DList;

/*  ====    Read file, fill input array, convert to numbers    ====
    try/catch to ensure file errors are handled.
    D style is to foreach through each line of the file.
        This handles EOF and trailing newlines internally.
        foreach: perform the same operation to every element of a range
            foreach (names; container_or_range)
                names: arbitrary by programmer
        chomp() removes trailing whitespace - result in new array
        split() breaks each line by given character (here ,) - result in new array
        to!long() conversion of each value into long - added to vector
            ! template argument, call left with right
            to!: to(T), template for type conversion. to!int, to!string, etc.
        inputCoords grows by longPair each line
            The binary operator ~ is the cat operator.
*/
long[][] fillArray(string fileName)
{
    File file;
    try {
        file = File(fileName, "r");
    } catch (Exception e) {
        writeln("Input file ", fileName, " Error: ", e.msg);
        return null;
    }

    long[][] inputCoords;
    foreach (line; file.byLine())
    {
        auto chomped = chomp(line);
        auto stringPair = split(chomped, ',');
        long[] longPair = [ to!long(stringPair[0]), to!long(stringPair[1]) ];
        inputCoords ~= longPair;
    }

    return inputCoords;
}

/*     ====     Calculate Part 1 solution     ====
    Using long due to an overflow issue with int. Part 1 at least returns
        greater than INT_MAX.
    Looping through each combination of coordinates.
    Multiplication of the absolute value of the sum of each coordinate's axis.
        +1 because tile count is inclusive: tiles from x1 to x2 = |x2−x1|+1
*/
long partOneCalc(const long[][] inputData)
{
    long maxArea = 0;
    foreach (i; 0 .. inputData.length)
    {
        foreach (j; i + 1 .. inputData.length)
        {
            long currArea = (abs(inputData[j][0] - inputData[i][0]) + 1)
                            * (abs(inputData[j][1] - inputData[i][1]) + 1);
            if (currArea > maxArea)
                maxArea = currArea;
        }
    }

    return maxArea;
}

//  ==== Part 2 solution functions below ====
//
/* ====    Break coordinates into sorted, unique, vectors per axis    ====
    Return type is Tuple. Although a simple struct would be better, I am trying
        new things :)
        Tuple: "these values are needed together temporarily"
        Struct: "these values are a meaningful grouping worth naming"
    Tuple alternates type and name. Or only types.
        Essentially a struct under the covers, addressed like a struct.
        tuple.name vs. tuple[index]
    inputData.map!(v => v[E]).array.sort.uniq.array;
        - .map: each pair (v) extract element [E]. Returns lazy range of long.
            lazy in this context is akin to a promise (js) or generator (py)
            v could be anything I chose. Lambda parameter.
        - .array: force lazy value to become concrete (thunk like)
        - .sort: sort ascending
        - .uniq: On a sorted array, return only elements that are different to
            previous. Lazy.
*/
Tuple!(long[], "xVals", long[], "yVals") getAxes(long[][] inputData)
{
    auto xVec = inputData.map!(v => v[0]).array.sort.uniq.array;
    auto yVec = inputData.map!(v => v[1]).array.sort.uniq.array;

    return Tuple!(long[], "xVals", long[], "yVals")(xVec, yVec);
}

/*  ====  Build a parallel lookup table of compressed indices  ====
    Compressed space of 500 x 500. Actual space over 100000^2.
    For each vertex in inputData, find its position in xVals/yVals vectors via
        binary search (assumeSorted + lowerBound). Plus 1 for padding offset.
    For each compressed coordinates' x/y values find the range of elements less
        than the value. 
        .lowerBound(<value>) returns all elements less than <value>.
        .length counts them, giving the index of <value> in the sorted array.
        Plus 1 to account for the zero buffer around the whole field.
    Returns a parallel array: coordinateLookup is the compressed (x,y)
        index pair for inputData.
    Avoids repeating binary searches later.
*/
ulong[][] inputToCompressed(long[][] inputData,
                            Tuple!(long[], "xVals", long[], "yVals") axesTuple)
{
    ulong[][] coordinateLookup = new ulong[][](inputData.length, 2);

    foreach (vertex; 0 .. inputData.length)
    {
        auto i1 = inputData[vertex];

        ulong ci1 = assumeSorted(axesTuple.xVals).lowerBound(i1[0]).length + 1;
        ulong cj1 = assumeSorted(axesTuple.yVals).lowerBound(i1[1]).length + 1;

        coordinateLookup[vertex] = [ci1, cj1];
    }

    return coordinateLookup;
}

/*  ====  Mark perimeter cells on compressed coordinate array  ====
    Data in input file traces a shape, in order, vertex by vertex.
    bool[][]: dynamic is required as the x and y lengths are not known until runtime.
        new: allocates memory, but does not need delete/free in D.
    foreach vertex in the coordinateLookup table
        collect 2 adjacent vertices.
            index vertex 2 to module of total number of vertexes in order to be
                able to wrap around to the start of the list.
    If the x (i) indexes are the same these vertices make a vertical edge.
        Vice versa for horizontal edges and y (j) indexes.
        Fill the cells from lowest to highest compressed index with `true`.
*/
bool[][] markPerim(Tuple!(long[], "xVals", long[], "yVals") axesTuple,
                   ulong[][] coordinateLookup)
{
    bool[][] compressedField = new bool[][](axesTuple.xVals.length + 2, axesTuple.yVals.length + 2);

    foreach (vertex; 0 .. coordinateLookup.length)
    {
        auto c1 = coordinateLookup[vertex];
        auto c2 = coordinateLookup[(vertex + 1) % coordinateLookup.length];

        if (c1[0] == c2[0])  // vertical edge
            foreach (j; min(c1[1],c2[1]) .. max(c1[1],c2[1]) + 1)
                compressedField[c1[0]][j] = true;
        else             // horizontal edge
            foreach (i; min(c1[0],c2[0]) .. max(c1[0],c2[0]) + 1)
                compressedField[i][c1[1]] = true;
    }

    return compressedField;
}

/*  ====    Check if a given cell is within the bounds of the field    ====
    Helper for floodFill.
*/
bool inBounds(long iNext, long jNext, long iMax, long jMax)
{
    return iNext >= 0 && jNext >= 0 && iNext < iMax && jNext < jMax;
}

/*  ====   Fill all cells external to the shape with true   ====
    DList: doubly linked list, 2 longs (coords). Queue of coordinates to check.
        insertBack(<values>): inserts <values> at the back
        cast(<type>): casts values to <type>
    exterior: an empty bool array the size of compressedField
    cardinals: an array of offsets, used to check neighbour cells for validity.
    while() there are some cells to check, check each of 4 neighbours (n/s/e/w):
        .front: fetches the current front value from the DList.
        if: inside grid and both compressedField and exterior are false
            set exterior to true and insertBack current neighbour cell
        .removeFront: removes the front value of the DList before looping
    return the array of exterior cells once queue is empty.
*/
bool[][] floodFill(bool[][] compressedField)
{
    DList!(long[2]) queue;
    queue.insertBack(cast(long[2])[0, 0]);

    immutable long yMax = compressedField[0].length;
    immutable long xMax = compressedField.length;
    bool[][] exterior = new bool[][](xMax, yMax);
    exterior[0][0] = true;

    immutable long[2][4] cardinals = [[0,1],[0,-1],[1,0],[-1,0]];

    while (!queue.empty)
    {
        auto currCell = queue.front;
        foreach (c; cardinals)
        {
            long ni = currCell[0] + c[0];
            long nj = currCell[1] + c[1];
            if (inBounds(ni, nj, xMax, yMax) && !compressedField[ni][nj] && !exterior[ni][nj])
            {
                exterior[ni][nj] = true;
                queue.insertBack(cast(long[2])[ni, nj]);
            }
        }
        queue.removeFront();
    }

    return exterior;
}

/*  ====   Create prefix sum array for given compressed coordinates   ====
    Sums all non-exterior cells (marked false) starting from the top left.
        Results in a cumulative count of all valid cells in the field.
    foreach through the whole field
        To the current cell value (1 if not exterior) add the values of the 
            upper and left neighbours. Subtract the diagonal to account for
            shared cells above and to the left.
            https://en.wikipedia.org/wiki/Inclusion%E2%80%93exclusion_principle
*/
int[][] prefixSum(bool[][] exterior)
{
    long yMax = exterior[0].length;
    long xMax = exterior.length;
    int[][] prefixSumArray = new int[][](xMax, yMax);

    foreach (i; 0 .. exterior.length)
    {
        foreach (j; 0 .. exterior[0].length)
        {
            int val = !exterior[i][j] ? 1 : 0;
            int above = (i > 0) ? prefixSumArray[i-1][j] : 0;
            int left  = (j > 0) ? prefixSumArray[i][j-1] : 0;
            int diag  = (i > 0 && j > 0) ? prefixSumArray[i-1][j-1] : 0;
            prefixSumArray[i][j] = val + above + left - diag;
        }
    }

    return prefixSumArray;
}

/*  ====  Query prefix sum for rectangle validity  ====
    Inclusion-exclusion over the prefix sum array to count valid cells in the
        rectangle (ci1,cj1)->(ci2,cj2).
    Returns true if every cell is valid (sum equals total cell count), meaning
        the rectangle fits inside the polygon.
*/
bool findPrefixSum(int[][] prefixSumArray,
                   ulong ci1, ulong ci2, ulong cj1, ulong cj2)
{
    long sum = prefixSumArray[ci2][cj2] - prefixSumArray[ci1 - 1][cj2]
          - prefixSumArray[ci2][cj1 - 1] + prefixSumArray[ci1 - 1][cj1 - 1];

    long expected = (ci2 - ci1 + 1) * (cj2 - cj1 + 1);

    return sum == expected;
}

/*  ====    Find possible rectangles and check for validity   ====
    Iterate over all vertex pairs. For each pair, retrieve compressed indices,
        normalise order, query prefix sum for validity, then calculate area
        in original coordinates using xVals/yVals. Replace maxArea if larger
        than current maxArea.
        +1 on each axis because tile counts are inclusive.
*/
long findRectangle(long[][] inputData,
                   Tuple!(long[], "xVals", long[], "yVals") axesTuple,
                   ulong[][] coordinateLookup,
                   int[][] prefixSumArray)
{
    long maxArea = 0;

    foreach (i; 0 .. inputData.length)
    {
        foreach (j; i + 1 .. inputData.length)
        {
            ulong ci1 = coordinateLookup[i][0];
            ulong cj1 = coordinateLookup[i][1];
            ulong ci2 = coordinateLookup[j][0];
            ulong cj2 = coordinateLookup[j][1];

            if (ci1 > ci2) swap(ci1, ci2);
            if (cj1 > cj2) swap(cj1, cj2);

            if (!findPrefixSum(prefixSumArray, ci1, ci2, cj1, cj2))
                continue ;

            long width = axesTuple.xVals[ci2 - 1] - axesTuple.xVals[ci1 - 1] + 1;
            long height = axesTuple.yVals[cj2 - 1] - axesTuple.yVals[cj1 - 1] + 1;
            long currArea = width * height;

            if (currArea > maxArea)
                maxArea = currArea;
        }
    }

    return maxArea;
}

/*     ====     Calculate Part 2 solution     ====
    1. Collect all unique coords into sorted individual vectors for x and y.
        - xVals and yVals.
    2. Compressed cell (ci,cj) represents original tiles (coordinateLookup)
        - x∈[xs[i], xs[i+1]-1], y∈[ys[j], ys[j+1]-1]
    3. Trace polygon edges by marking perimeter cells in compressed space.
        - compressedField
    4. Flood fill exterior cells from a known-outside corner, added buffer.
        - Buffer is +1 around the whole field.
        - Remaining cells = interior (perimeter + interior = "valid")
        - exterior
    5. Calculate 2D prefix sum over valid cells.
        - Sum of all cells accumulated from top left to bottom right.
    6. Same combination pair loop as for Part 1:
        - Find compressed indices for each vertex pair.
        - Prefix sum query to check rectangle validity.
        - If valid, compute original-space area with part 1.
*/
long partTwoCalc(long[][] inputData)
{
    auto axesTuple = getAxes(inputData);
    auto coordinateLookup = inputToCompressed(inputData, axesTuple);
    auto compressedField = markPerim(axesTuple, coordinateLookup);
    auto exterior = floodFill(compressedField);
    auto prefixSumArray = prefixSum(exterior);
    auto maxArea = findRectangle(inputData, axesTuple, coordinateLookup, prefixSumArray);
    return maxArea;
}

/*  ====    MAIN    ====
    string type is immutable(char)[]  internally
        immutable: compiler guarantees nobody has a mutable reference;
                any attempted modification is a compile error.
        const:     compiler won't let you modify it via this reference,
                but can be modified by a mutable reference to the same data.
*/
void main()
{
    immutable string fileName = "../d9_input";

    long[][] inputData = fillArray(fileName);
    if (inputData is null)
        return;

    long partOne = partOneCalc(inputData);
    writeln("Part 1: ", partOne);

    long partTwo = partTwoCalc(inputData);
    writeln("Part 2: ", partTwo);
}
