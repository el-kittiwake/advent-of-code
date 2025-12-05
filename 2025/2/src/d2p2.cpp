#include <fstream>
#include <sstream>
#include <string>
#include <iostream>
#include <vector>
#include <optional>

#define INFILE "../d2-input"

long long total = 0;

std::pair<std::string, std::string> splitNums(const std::string string)
{
	std::pair<std::string, std::string> tmpPair;
	size_t start = 0;
	size_t end = string.find('-');

	tmpPair.first = string.substr(start, end - start);
	start = end + 1;
	tmpPair.second = string.substr(start, end - start);

	return (tmpPair);
}

std::vector<std::pair<std::string, std::string>> splitRanges(const std::string string)
{
	std::vector<std::pair<std::string, std::string>> tmpVec;
	size_t start = 0;
	size_t end = string.find(',');

	while (end != std::string::npos)
	{
		tmpVec.emplace_back(splitNums(string.substr(start, end - start)));
		start = end + 1;
		end = string.find(',', start);
	}
	tmpVec.emplace_back(splitNums(string.substr(start)));

	return (tmpVec);
}

//Answer is 14582313461
int main(void)
{
	//Open file and stream
	std::ifstream inputFileStream(INFILE);
	std::ostringstream stringStream;
    stringStream << inputFileStream.rdbuf();
	inputFileStream.close();
	std::string fileContent = stringStream.str();

	//Make a vector of entries
	std::vector<std::pair<std::string, std::string>> values = splitRanges(fileContent);

	//Loop through values and find invalid IDs
	//https://algo.monster/liteproblems/459
	for (auto range : values) 
	{
		long long start = atoll(range.first.c_str());
		long long end = atoll(range.second.c_str());

		while (start <= end)
		{
			std::string tmp = std::to_string(start);
			std::string tmp2 = tmp + tmp;
			size_t isFound = tmp2.find(tmp, 1);
			if (isFound < tmp.length())
				total += start;
			++start;
		}
	}

	std::cout << "Sum of invalid IDs: " << total << std::endl;
}