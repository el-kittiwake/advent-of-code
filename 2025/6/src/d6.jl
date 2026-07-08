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
	Open and read an input filename
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
	- Loop until reaching the end of the array.
	- Test for * or + final row (only these are possible in input files)
	- Calculate result using:
		prod() - multiply whatever is given as parameter
		parse.() - parse values in the given range to UInt64
			broadcasting(.) performs the parse on all values
	- Add current result to count and return once end reached
=#
function partOne(inputData::Vector{Vector{SubString{String}}})::UInt64
	# length(<collection>): number of elements in <collection>
	# https://docs.julialang.org/en/v1/base/collections/#Base.length
	width = length(inputData[1])
	height = length(inputData)

	# var = zero(type) is not necessary, but good Julia practise.
	#	Ensures the correct width of integer.
	# https://docs.julialang.org/en/v1/base/numbers/#Base.zero
	count = zero(UInt64)

	for i in 1:width
		if inputData[height][i] == "*"
			# prod() - Multiply the results of calling the function f on each
			# 	element of an array over the given dimensions.
			# sum() - same for summation
			# https://docs.julialang.org/en/v1/base/collections/#Base.prod
			# https://docs.julialang.org/en/v1/base/collections/#Base.sum
			# parse() - Parse a string as a number of given format
			# https://docs.julialang.org/en/v1/base/numbers/#Base.parse
			result = prod(parse.(UInt64, [inputData[r][i] for r in 1:height-1]))
		else
			result = sum(parse.(UInt64, [inputData[r][i] for r in 1:height-1]))
		end

		count += result
	end

	return count
end

#=
	Part 2
	- Calculate size of matrix.
		size(<array>, <dimension>) - for height
		length(<string>) - for width, due to it being the string we will work on
	- Initialise a vector for parsed numbers and total counter
	- Loop through the width of the string backwards reverse()
		If the whole column contains a digit it is a member number of the set
			Vertically concatenate the individual digits and add the result to a vector
		If the column ends with an operator it is the last column and digit for that set
			Perform the desired operation on the set prod() or sum()
			Add result to current total count
		If the column contains all spaces it is a separator
			Empty the current set vector empty!()
	- Return end result
=#
function partTwo(splitString::Vector{SubString{String}})::UInt64
	width = length(splitString[1])
	height = size(splitString, 1)

	# Matrix declared with its type only.
	currentSet = UInt64[]
	count = zero(UInt64)

	for c in reverse(1:width)
		# any() - Determine whether a condition returns true for any elements
		#		  along the given dimensions of an array.
		# join() - Concatenates given values. Within the conditions given
		# push!() - Adds to collection the given values (parsed from string to num)
		# https://docs.julialang.org/en/v1/base/collections/#Base.push!
		if any(isdigit, splitString[i][c] for i in 1:height-1)
			newNum = join("$(splitString[i][c])" for i in 1:height-1 if isdigit(splitString[i][c]))
			push!(currentSet, parse(UInt64 ,newNum))
		end

		# Checks the last row at loop position for either * or +.
		# ∈ - "element of" x ∈ collection: true if x is in collection. Same as in operator.
		# https://www.juliabloggers.com/what-is-%E2%88%88-in-julia/
		if splitString[height][c] ∈ ('*', '+')
			if splitString[height][c] == '*'
				result = prod(currentSet)
			else
				result = sum(currentSet)
			end

			count += result
		end

		# Like any() but only returns true if all of a given collection matches the
		# condition.
		# empty!() - clears the given array. Prevents reallocation
		# https://docs.julialang.org/en/v1/base/collections/#Base.empty!
		if all(isspace, splitString[i][c] for i in 1:height-1)
			empty!(currentSet)
		end
		
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
	|| @warn - Fail to warning the user about unequal line lengths
=#
splitString = filter(!isempty, split(fileContents, '\n'))
allequal(length.(splitString)) || @warn "Input file line widths not equal. Part 2 may fail."

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
