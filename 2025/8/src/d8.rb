=begin
  Advent of code 2025, day 8. Ruby.

  Resources:
            https://learnxinyminutes.com/ruby
            https://www.ruby-lang.org/en/documentation/
            https://en.wikipedia.org/wiki/Kruskal's_algorithm

  Multiline comments need an end
  snake_case by convention
=end

=begin
  ####  Set file variable   ####
  Dynamic and duck typed, so just make the variable what I want.
  Variable is an object like most things in Ruby.
  Variable name starting with capital makes it constant. Convention is all caps.
  String object has methods such as: .length .upcase .sub(<old>, <new>) + * etc.
  https://docs.ruby-lang.org/en/3.4/String.html
=end
FILE_NAME = "../d8_input"

=begin
  #### Open file ####
  Open modes are similar to other languages. r is default.
  Possible methods to fill memory:
      .readlines(path) : reads entire file
      .foreach(path) : iterates linewise
  Array building:
      .map { |line| ... } : iterates over the array returned from readlines,
                            returns new array split by newline.
      line.chomp          : strips trailing newlines
      .split(",")         : splits strings by comma, returns an array of strings
      .map(&:to_i)        : iterates over those arrays converting to integers
                              (&:<method>) call <method> on each element
  For each line, strip the newline, split on commas, convert each part to integer.
  (&:<method>) works for any no-argument method
      map(&:to_s), map(&:upcase), select(&:nil?) etc.
  Note on output: puts <map>.inspect  =  p <map>. puts flattens output
  https://docs.ruby-lang.org/en/3.4/File.html
  https://docs.ruby-lang.org/en/3.4/IO.html
=end
INPUT_MAP = File.readlines(FILE_NAME)
            .map { |line| line.chomp.split(",").map(&:to_i) }

#### Functions for union-find
# Ruby implicitly returns the last expression. No need for return.
# Square root is omitted as it is monotonic, so doesn't affect the ordering.
# https://en.wikipedia.org/wiki/Euclidean_distance
# ** for exponent
def distance(a, b)
  (b[0] - a[0])**2 + (b[1] - a[1])**2 + (b[2] - a[2])**2
end

# Recursive find, checks for root (index = value) and returns
# Otherwise recursively checks and writes root value back down the chain
def find(parent, x)
  return x if parent[x] == x
  parent[x] = find(parent, parent[x])
end

# Merges two nodes' circuits. Returns false if already connected, true if merged.
# find() on both to get roots, attach one root to the other if different.
# True result is the result of `parent[root_a] = root_b` a truthy value.
def union(parent, a, b)
  root_a = find(parent, a)
  root_b = find(parent, b)

  return false if root_a == root_b
  parent[root_a] = root_b
end

=begin
  #### part 1 routine ####
  Set up the "parent", initially each key value is paired with the same value.
    .each() operates on each element in the array
    { |parameter(s)| body } - blocks work depending on what they are attached to
    in .each the p represents each element, the body tells what to do
  Find and union.
      First create an array of all combinations of coordinate pairs.
      Then sort them by distance to each other, ascending order.
      Take only the closest 1000.
      For each of the top 1000, union them.
  Calculate the result.
      parent.keys.group_by { |x| find(parent, x) }
  https://en.wikipedia.org/wiki/Disjoint-set_data_structure
=end
# MakeSet part
parent = INPUT_MAP.each_with_object({}) { |p, h| h[p] = p }

# Union-find part
# combination() returns lazy enumerator, chained to .sort_by and onwards.
# sort_by() calculates the key once (distance()). Uses the "Schwartzian transform".
#   Key is calculated once and paired with the value. Keys are sorted and then
#   discarded leaving the sorted values to be returned.
#   https://docs.ruby-lang.org/en/3.4/Enumerable.html#method-i-sort_by
INPUT_MAP.combination(2)
         .sort_by { |a, b| distance(a, b) }
         .first(1000)
         .each { |a, b| union(parent, a, b) }

# Calculate the result. The product of only the top 3 largest circuits.
# Group nodes by root (circuit), extract sizes, sort ascending, top 3, multiply
part1 = parent.keys.group_by { |x| find(parent, x) }
      .values.map(&:length).max(3).reduce(:*)

#### part 2 routine ####
# MakeSet part
parent = INPUT_MAP.each_with_object({}) { |p, h| h[p] = p }

# Union-find part
# components: Tracks remaining unconnected circuits
# last_pair: Saves the last effective merge
# combination() returns lazy enumerator, chained to .sort_by and onwards.
components = INPUT_MAP.length
last_pair = nil
INPUT_MAP.combination(2)
         .sort_by { |a, b| distance(a, b) }
         .each do |a, b|
            if union(parent, a, b)
              components -= 1
              if components == 1
                last_pair = [a, b]
                break
              end
            end
          end

# Outputs
puts "Part 1: #{part1}"
puts "Part 2: #{last_pair.map(&:first).reduce(:*)}"