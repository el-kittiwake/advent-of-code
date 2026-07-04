/**
 * Advent of code, day 1. C
 * 
 * Part 1: 1139
 * Part 2: 6684
 */
#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>

uint16_t partOne(uint8_t* position, int16_t offset)
{
	if (offset > 99)
		*position = offset - 100;
	else if (offset < 0)
		*position = 100 - (offset * -1);
	else
		*position = offset;

	if (*position == 0)
		return (1);

	return (0);
}

uint16_t partTwo(uint8_t* position, int16_t offset, int16_t rotation)
{
	uint16_t zeroes = rotation / 100;

	if (offset == 100)
	{
		*position = 0;
		return (++zeroes);
	}
	else if (offset == 0)
	{
		if (*position != 0) ++zeroes;
		*position = 0;
		return (zeroes);
	}
	else if (offset > 100)
	{
		*position = offset - 100;
		return (++zeroes);
	}
	else if (offset < 0)
	{
		if (*position != 0) ++zeroes;
		*position = 100 - (offset * -1);
		return (zeroes);
	}

	*position = offset;
	return (zeroes);
}

/**
	The offset is calcualted for both parts, from part 1's position as at that
	time the position variables have not been touched and part 1 and part 2 share
	the same position.
 */
int main (void)
{
	static char* file = "../d1_input";
	FILE* fd = fopen(file, "r");
	if (fd == NULL) {
		printf("Input file: %s failed to open.\n", file);
		exit(1);
	}

	char line[6];
	uint16_t part1Zeroes = 0;
	uint16_t part2Zeroes = 0;
	uint8_t part1Position = 50;
	uint8_t part2Position = 50;

	while (fgets(line, sizeof(line), fd))
	{
		char direction = '\0';
		int16_t rotation = 0;
		int8_t sign = 1;
		
		sscanf(&line[0], "%c%hd", &direction, &rotation);
		(direction == 'R') ? (sign = 1) : (sign = -1);

		uint8_t modulo = rotation % 100;
		int16_t offset = part1Position + (modulo * sign);
		part1Zeroes += partOne(&part1Position, offset);
		part2Zeroes += partTwo(&part2Position, offset, rotation);
	}

	printf("Part 1: %d\n", part1Zeroes);
	printf("Part 2: %d\n", part2Zeroes);

	fclose(fd);
}