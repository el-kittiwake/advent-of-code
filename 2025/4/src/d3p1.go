/**
 * Advent of Code 2025, day 4.
 *
 * Notes on functions:
 * os.Open() Returns an OS specific strut with opened file details
 * 			 Returns status, nil = success
 * buffer.NewScanner() Returns a "scanner"
 * fileScanner.Split() Sets the scanning method. (Lines, bytes etc.)
 * fileScanner.Scan()  Returns the current split method without delimiters.
 */
package main

import (
	"bufio"
	"fmt"
	"os"
)

var size int = 0

func main() {
	filePath := "../d4_input"
	readFile, err := os.Open(filePath)
	if err != nil {
		fmt.Println(err)
	}

	fileScanner := bufio.NewScanner(readFile)
	fileScanner.Split(bufio.ScanLines)
	var fileLines []string
	for fileScanner.Scan() {
		fileLines = append(fileLines, fileScanner.Text())
	}
	readFile.Close()

	size = len(fileLines[0])
	var rolls int = 0

	for y := 0; y < size; y++ {
		for x := 0; x < size; x++ {
			if is_PaperRoll(fileLines[y][x]) {
				rolls += count_AdjacentCells(&fileLines, x, y)
			}
		}
	}

	fmt.Println("Number of movable rolls: ", rolls)
}

func is_OutOfBounds(x, y int) bool {
	if x < 0 || x >= size || y < 0 || y >= size {
		return true
	}
	return false
}

func is_PaperRoll(char byte) bool {
	if char == '@' {
		return true
	}
	return false
}

func count_AdjacentCells(field *[]string, x, y int) int {
	var count int = 0

	for b := -1; b < 2; b++ {
		for a := -1; a < 2; a++ {
			if !is_OutOfBounds(x+a, y+b) && (a != 0 || b != 0) {
				if is_PaperRoll((*field)[y+b][x+a]) {
					count++
				}
			}
		}
	}

	if count < 4 {
		return 1
	}
	return 0
}
