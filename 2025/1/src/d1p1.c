#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>

void error_exit(void)
{
	perror("Exiting. Error: ");
	exit (1);
}

//1139 is the correct answer
int main (void)
{
	static char *file = "../d1p1_input";
	FILE* fd = fopen(file, "r");
	if (fd == NULL)
		error_exit();

	char line[6];
	uint16_t zeroes = 0;
	uint8_t position = 50;
	int8_t sign = 1;

	while (fgets(line, sizeof(line), fd))
	{
		(line[0] == 'R') ? (sign = 1) : (sign = -1);
		line[0] = '+';
		
		int16_t rotation = atoi(line);
		uint8_t modulo = rotation % 100;
		int16_t offset = position + (modulo * sign);

		if (offset > 99)
			position = offset - 100;
		else if (offset < 0)
			position = 100 - (offset * -1);
		else
			position = offset;

		if (position == 0)
			++zeroes;
	}

	printf("Number of 0 stops: %d\n", zeroes);
	fclose(fd);
}