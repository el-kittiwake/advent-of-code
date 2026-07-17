{-
    Advent of code 2025, day 11, Haskell

    Resources:
                https://hoogle.haskell.org/
                https://learnyouahaskell.github.io/

    Part 1: 613
    Part 2: 372918445876116
-}

import qualified Data.Map as Map
import Data.Map (Map, (!))
import Data.List (foldl')

--      PARSING SECTION
-- | Reads the file and parses it into the device/address (adjacency) list in one step.
{-
    IO() is "contagious". A function performs an IO action, it must declare it in return.
    = do: sequences monadic operations on order, in this case IO side effects.
        where: sub-expressions of a single result, order not important
        do: multiple IO actions that must happen in sequential order
    <- : assignment specifically for monadic context, in this case IO
        "run this and bind"
-}
loadGraph :: FilePath -> IO (Map String [String])
loadGraph path =
  do
    contents <- readFile path
    return (parseGraph contents)

-- | Builds the full map of devices and addresses from raw file contents.
--   One Map entry per line; every key is unique, so order doesn't matter.
{-
    <return> = foldr <function> <initial> <map>: Process from right to left.
        <list> processed right to left into <initial> after being operated on by
        <function>
    foldr does a lot internally. The map that is created after each line is only
        revealed once the final insertLine happens. Intermediate maps are never
        named and only the final accumulated result is returned.
-}
parseGraph :: String -> Map String [String]
parseGraph contents = foldr insertLine Map.empty (lines contents)

-- | Inserts one parsed line into the accumulator map.
--   Used as the combining function for foldr.
{-
    Takes a string and a map as input. Outputs map filled with line from `parseGraph`
    Partially applied, as the `Map.insert key neighbours` function is already
        passed as return.
    where: indicates a local scope block of bindings
        use to avoid repetition or aid clarity
        order does not matter! Reverse the lines and it would still work!
-}
insertLine :: String -> Map String [String] -> Map String [String]
insertLine line = Map.insert key neighbours
  where
    (key, neighbours) = parseLine line

-- | Parses one line of the form "aaa: bbb ccc" into (key, neighbours).
--   Takes a string as input, outputs a tuple of String and list of Strings.
--   "aaa: bbb ccc" -> "aaa" ["bbb", "ccc"]
{-
    Top 2 lines describe types and what those types are called and their meaning.
    line is parameter string, (key, neighbours) are the returns
        corresponding with the String -> (String [String])
    <names> = break <params>:  splits a given list by given expression, puts
        result in given names. `rest` is a temporary place to store the remains
        of the string. In this example `:` is attached to the beginning of rest.
        (== ':') operator section, partial application of == to :.
    <name> = words <params>: splits lines by whitespace, placing resulting
        words into a list of strings <name>
    drop <N> <list>: removes the first `N` elements of list.
        Returns straight to words parameter. But could be <name> = drop <N> <list>
-}
parseLine :: String -> (String, [String])
parseLine line = (key, neighbours)
  where
    (key, rest) = break (== ':') line
    neighbours  = words (drop 1 rest)

--      PART ONE SOLUTION
-- | Calculate path count for part one. 
--   "out"     -> done, return 1 and existing memo
--   cache hit -> return cached val and existing memo
--   otherwise -> investigate neighbours recursively
{-
    Guards: Cool way to quickly check values, evaluated lazily. 
    Map.member: is key a member of the map
        backticks `: turn 2 argument function into an infix operator
        Essentially <pat> isMemberOf <map>
        Rather than Map.member <pat> <map>
    where block is in scope for all guards. Lazy evaluation means they're only
        computed if otherwise is reached. 
    Map.findWithDefault <default> <target> <map>: either return <target> or if
        not found <default>
    foldl' <function> <initial> <map>: left to right processing of <map> using
        <function> using <initial> accumulator.
        Strict, evaluates at each step. Unlike foldl which is lazy. 
    Map.insert <key> <val> <map>: insert key value pair to map, creates new map
        as variables are immutable. 
    step <params>: lambda like function to recurse and increase accumulator
        Run within the foldl' line. Function applied to each element. 
-}
pathsOne :: String -> Map String [String] -> Map String Integer -> (Integer, Map String Integer)
pathsOne currDev graph memo
    | currDev == "out"            = (1, memo)
    | currDev `Map.member` memo   = (memo ! currDev, memo) -- cache hit, return cached val
    | otherwise                   = (total, memo'')
  where
    neighbours       = Map.findWithDefault [] currDev graph
    (total, memo')   = foldl' step (0, memo) neighbours
    memo''           = Map.insert currDev total memo'
    step (acc, mem) neigh  = let (count, mem') = pathsOne neigh graph mem
                             in  (acc + count, mem')

-- | Calculate path count for part two. Paths must visit both "dac" and "fft".
--   visitDAC, visitFFT track which required nodes have been visited so far.
--   "out"     -> done, return 1 only if both bools True, else 0
--   cache hit -> key is (device, visitDAC, visitFFT), four distinct states
--   otherwise -> investigate neighbours recursively
{-
    Preserve existing true or set true if arriving at this device now
        visitDAC' = visitDAC || currDev == "dac"
                    ^already    ^visiting now
                    true either way if either is true
    equivalent to: visitDAC' = if currDev == "dac" then True else visitDAC
-}
pathsTwo :: String -> Bool -> Bool -> Map String [String] -> Map (String, Bool, Bool) Integer -> (Integer, Map (String, Bool, Bool) Integer)
pathsTwo currDev visitDAC visitFFT graph memo
    | currDev == "out"                                = (if visitDAC && visitFFT then 1 else 0, memo)
    | (currDev, visitDAC, visitFFT) `Map.member` memo = (memo ! (currDev, visitDAC, visitFFT), memo)
    | otherwise                                       = (total, memo'')
  where
    visitDAC' = visitDAC || currDev == "dac"
    visitFFT' = visitFFT || currDev == "fft"
    neighbours       = Map.findWithDefault [] currDev graph
    (total, memo')   = foldl' step (0, memo) neighbours
    memo''           = Map.insert (currDev, visitDAC', visitFFT') total memo'
    step (acc, mem) neigh  = let (count, mem') = pathsTwo neigh visitDAC' visitFFT' graph mem
                             in  (acc + count, mem')

-- |main
--  ├─ read input file
--  ├─ parse lines -> build Map String [String] (adjacency list)
--  ├─ paths "you" (P1), "svr" (P2) graph (recursive, memoised)
--  |  Part 2: force pass through "dac" and "fft"
--  │    Base case: node == "out" -> 1
--  │    Recursive: sum (map (\n -> paths n graph) neighbours)
--  └─ print result
{-
    let: bind a name to a value, one of the 2 allowed ways to bind in a do block. 
        The other is using <- to unwrap an IO value.
        Not a variable, not mutable. 
    putStrLn: print a string and end with a new line. 
    ++: list concatenation (string is a list of char)
    show: converts into a human readable string
        Only for types that have the Show typeclass
-}
main :: IO ()
main =
  do
    -- Load, parse and check file. Working data is: graph
    let fileName = "../d11_input"
    let lineCount = 604
    graph <- loadGraph fileName
    putStrLn (if Map.size graph == lineCount
              then "Line count OK"
              else "WARNING: expected " ++ show lineCount ++ " lines, got " ++ show (Map.size graph))

    -- Process part 1
    -- Seed pathsOne with start and empty map
    let (part_1_res, _) = pathsOne "you" graph Map.empty
    putStrLn ("Part 1: " ++ show part_1_res)

    -- Process part 2
    -- Seed pathsTwo with start, DAC & FFT initials and empty map
    let (part_2_res, _) = pathsTwo "svr" False False graph Map.empty
    putStrLn ("Part 2: " ++ show part_2_res)
