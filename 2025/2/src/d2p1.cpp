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

bool checkNums(std::string value)
{
	int len = value.length();

	if (len % 2 != 0)
		return (false);
	
	std::string left = value.substr(0, len / 2);
	std::string right = value.substr(len / 2, len);

	if (left == right)
		return (true);

	return (false);
}

//Answer is 13919717792
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
	for (auto range : values) 
	{
		if (range.first.length() % 2 != 0 && range.second.length() == range.first.length())
			continue ;
		else
		{
			long long start = atoll(range.first.c_str());
			long long end = atoll(range.second.c_str());

			while (start <= end)
			{
				if (checkNums(std::to_string(start)))
					total += start;
				++start;
			}
		}
	}

	std::cout << "Sum of invalid IDs: " << total << std::endl;
}