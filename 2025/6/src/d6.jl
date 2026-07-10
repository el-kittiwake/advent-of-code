#=
	Day 6, using Julia.
	Part 1: Perform a given operation on a column of numbers. Return the total of all columns.
	Part 2: Read numbers vertically right to left, grouped by operator-delimited
			blocks. Return the total of all blocks. Each number is formed by reading
			the digits in a single column top to bottom, concatenating them and ignoring spaces.
	
	Part 1: 5784380717354
	Part 2: 7996218225744
=#

# =====================
# Function declarations
# =====================
#=
	Open input filename in read mode (default anyway).
	Read the file until EOF then exit the do loop.
	String is returned. No explicit return, value propagates back from do.
	https://www.geeksforgeeks.org/julia/opening-and-reading-a-file-in-julia/
=#
function readFile(filename::String)::String
    open(filename, "r") do f
        read(f, String)
    end
end

#=
	Part 1
	- Calculate size of input data. length(<dimension>)
	- Initialise a counter: <var> = zero(<type>)
		Ensures the correct width of integer.
		https://docs.julialang.org/en/v1/base/numbers/#Base.zero
	- Loop until reaching the end of the array.
	- Test for * or + final row (only these are possible in input files)
	- Calculate result using:
		prod() - multiply whatever is given as parameter
		parse.() - parse values in the given range to UInt64
			broadcasting(.) performs the parse on all values
		https://docs.julialang.org/en/v1/base/numbers/#Base.parse
	- Add current result to count and return once end reached
=#
function partOne(inputData::Vector{Vector{SubString{String}}})::UInt64
	height = length(inputData)
	width = length(inputData[1])

	# Counter initialised with type.
	count = zero(UInt64)

	# Loop over the whole length of a line.
	for c in 1:width
		if inputData[height][c] == "*"
			result = prod(parse.(UInt64, [inputData[r][c] for r in 1:height-1]))
		else
			result = sum(parse.(UInt64, [inputData[r][c] for r in 1:height-1]))
		end

		count += result
	end

	return count
end

#=
	Part 2
	- Calculate size of matrix.
		size(<array>, <dimension>) - for height
	- Initialise a vector for parsed numbers and total counter
	- Loop through the width of the string backwards reverse()
		&& (short circuiting and): if left then do right.
		* is the string concatenation operator.
		|| (short circuiting or): if not left then right
		isempty(<collection>): true if <collection> has no elements
		push!(<destination>, <values>): insert <values> at end of <destination>
		∈: "is in" operator
		empty!(<collection>): clear <collection>
	- Return end result
=#
function partTwo(splitString::Vector{SubString{String}})::UInt64
	height = size(splitString, 1)
	width = length(splitString[1])

	# Matrix declared with its type only. Counter declared.
	currentSet = UInt64[]
	count = zero(UInt64)

	# Loop backwards over the whole length of a line.
	for c in reverse(1:width)
		# Add digit character to whole number string
		newNum = ""
		for i in 1:height-1
			ch = splitString[i][c]
			isdigit(ch) && (newNum *= ch)
		end

		# Add new number to currentSet if it exists
		isempty(newNum) || push!(currentSet, parse(UInt64, newNum))

		# Product or sum currentSet depending on last row value
		if splitString[height][c] ∈ ('*', '+')
			result = splitString[height][c] == '*' ? prod(currentSet) : sum(currentSet)
			count += result
		end

		# If column is all space, clear currentSet and move on
		isempty(newNum) && empty!(currentSet)
	end

	return count
end

# =====================
# "Main"
# =====================
#=
	Read input data
=#
fileLocation = "../d6_input"
fileContents = readFile(fileLocation)

#=
	Process input to array
	filter(<criteria>, <content>) - filter empty lines out
	split(<string>, <delim>) - split strings by delim into array
	allequal(<content>) - check all lines are equal length
	|| (short circuiting or)
		@warn - If failure: warning message to user about unequal line lengths.
=#
splitString = filter(!isempty, split(fileContents, '\n'))
allequal(length.(splitString)) || @warn "Input file line widths not equal. Will likely fail."

#=
	Part 1
	Prepare rows vector then call part 1 function then print the total sum of
		all operations.
	Splits on any number of spaces
	rows is vector of vectors, each vector is one row from input file
	Square brackets collects values into a vector
=#
rows = [split(strip(line), r"\s+") for line in splitString]
countOne = partOne(rows)
println("Part 1: ", countOne)

#=
	Part 2
=#
countTwo = partTwo(splitString)
println("Part 2: ", countTwo)
