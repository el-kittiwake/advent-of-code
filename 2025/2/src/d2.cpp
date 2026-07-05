/**
 * Advent of Code, day 2, C++
 * 
 * Part 1: 13919717792
 * Part 2: 14582313461
 */
#include <fstream>
#include <sstream>
#include <string>
#include <iostream>
#include <vector>

#define INFILE "../d2_input"

/**
 * @brief Split 12345-67890 into a pair consisting of 12345 and 67890.
 * @returns tmpPair: pair<string1, string2>
 * 
 * @remarks string.substr(<start>, <length>), <length> is optional.
 * string.find(<pattern>): returns the location of the first hit on pattern.
 */
std::pair<std::string, std::string> splitNums(const std::string stringToSplit)
{
	std::pair<std::string, std::string> tmpPair;
	size_t start = 0;
	size_t end = stringToSplit.find('-');

	tmpPair.first = stringToSplit.substr(start, end - start);
	start = end + 1;
	tmpPair.second = stringToSplit.substr(start);

	return (tmpPair);
}

/**
 * @brief Split 12345-67890,12-34,567-8901 into a vector of pairs of constituent
 * 		strings (pair<12345, 67890> etc.).
 * @returns tmpVec: vector<pair<string1, string2>>
 * 
 * @remarks string.substr(<start>, <length>), <length> is optional.
 * vector.emplace_back(<content>): adds <content> to the end of the vector.
 */
std::vector<std::pair<std::string, std::string>> splitRanges(const std::string stringToSplit)
{
	std::vector<std::pair<std::string, std::string>> tmpVec;
	size_t start = 0;
	size_t end = stringToSplit.find(',');

	while (end != std::string::npos)
	{
		tmpVec.emplace_back(splitNums(stringToSplit.substr(start, end - start)));
		start = end + 1;
		end = stringToSplit.find(',', start);
	}
	tmpVec.emplace_back(splitNums(stringToSplit.substr(start)));

	return (tmpVec);
}

/**
 * @brief For part 1. Checks of both numbers of the particular pair.
 * @returns True: if matching
 */
bool checkNums(std::string value)
{
	int len = value.length();

	std::string left = value.substr(0, len / 2);
	std::string right = value.substr(len / 2);

	if (left == right)
		return (true);

	return (false);
}

/**
 * @brief Perform parts 1 and 2 consecutively. 
 * 
 * @remarks std::stoll should handle any errant non-numeric at the end of the
 * 				input string silently or throw an exception loudly.
 *			const auto &range: binds a reference to the element, const ensures
				immutability.
				For readability range could be replaced with [start, end].
 * 			I have to say, inefficient, swapping types all over. Pretty bad.
 */
int main(void)
{
	//Open file, stream, convert to string, close file
	std::ifstream inputFileStream(INFILE);
	std::ostringstream fileStream;
	fileStream << inputFileStream.rdbuf();
	std::string fileContent = fileStream.str();
	inputFileStream.close();

	//Make a vector of entries
	std::vector<std::pair<std::string, std::string>> values = splitRanges(fileContent);

	//Results variables
	long long totalOne = 0;
	long long totalTwo = 0;

	/* 	Part 1
		Loop through values and find invalid IDs
		Accumulate total with invalid IDs
	*/
	for (const auto& range : values) 
	{
		if (range.first.length() % 2 != 0 && range.second.length() == range.first.length())
			continue ;
		else
		{
			long long start = std::stoll(range.first);
			long long end = std::stoll(range.second);

			while (start <= end)
			{
				if (checkNums(std::to_string(start)))
					totalOne += start;
				++start;
			}
		}
	}

	/* 	Part 2
		Loop through values and find invalid IDs
		Accumulate total with invalid IDs
		https://algo.monster/liteproblems/459
	*/
	for (const auto& range : values) 
	{
		long long start = std::stoll(range.first);
		long long end = std::stoll(range.second);

		while (start <= end)
		{
			std::string tmp = std::to_string(start);
			std::string tmp2 = tmp + tmp;
			size_t isFound = tmp2.find(tmp, 1);
			if (isFound < tmp.length())
				totalTwo += start;
			++start;
		}
	}

	// Output results
	std::cout << "Part 1: " << totalOne << "\n";
	std::cout << "Part 2: " << totalTwo << std::endl;
}
