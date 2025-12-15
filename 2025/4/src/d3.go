/**
 * Advent of Code 2025, day 4. Part 2.
 *
 * Notes on functions:
 * os.Open() Returns an OS specific strut with opened file details
 * 			 Returns status, nil = success
 * buffer.NewScanner() Returns a "scanner"
 * fileScanner.Split() Sets the scanning method. (Lines, bytes etc.)
 * fileScanner.Scan()  Returns the current split method without delimiters.
 */
package main

//Buffered IO, formatted IO and "system calls" sort of
import (
	"bufio"
	"fmt"
	"os"
)

var size int = 0

type Field = [][]byte

func main() {
	//File handling.
	filePath := "../d4_input"
	readFile, err := os.Open(filePath)
	if err != nil {
		fmt.Println(err)
		return
	}

	//File reading and parsing
	fileScanner := bufio.NewScanner(readFile)
	fileScanner.Split(bufio.ScanLines)
	var fileLines []string
	for fileScanner.Scan() {
		fileLines = append(fileLines, fileScanner.Text())
	}
	readFile.Close()
	copiedLines := copyArrayToField(fileLines)

	//Puzzle solution.
	size = len(fileLines[0])
	var rolls int = 0
	var iter_count int = 0
	var run bool = true

	for run == true {
		var roll_count int = 0
		var nextIter Field = copyField(copiedLines)

		for y := range size {
			for x := range size {
				if is_PaperRoll(copiedLines[y][x]) {
					if is_Accessible(&copiedLines, x, y) {
						roll_count++
						nextIter[y][x] = '.'
					} else {
						nextIter[y][x] = '@'
					}
				} else {
					nextIter[y][x] = '.'
				}
			}
		}

		rolls += roll_count
		if iter_count == 0 {
			fmt.Println("Number of movable rolls, part 1: ", rolls)
		}
		if roll_count == 0 {
			run = false
		}
		iter_count++
		copiedLines = copyField(nextIter)
	}

	fmt.Println("Number of movable rolls, part 2: ", rolls)
}

// Check if a coordinate would take us under 0 or over maximum size
func is_OutOfBounds(x, y int) bool {
	if x < 0 || x >= size || y < 0 || y >= size {
		return true
	}
	return false
}

// Check if a coordinate contains an @
func is_PaperRoll(char byte) bool {
	return char == '@'
}

// Count the number of @ in the 6 adjacent cells to the cell in question
// Returns true only if count is less than 4
func is_Accessible(field *Field, x, y int) bool {
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
		return true
	}
	return false
}

// Following needed to allow writing to a copy for next rounds
func copyArrayToField(fileLines []string) Field {
	var new Field
	for i, line := range fileLines {
		new = append(new, []byte{})
		for _, char := range line {
			new[i] = append(new[i], byte(char))
		}
	}
	return new
}

func copyField(old Field) Field {
	var new Field = make(Field, len(old))
	for i := range old {
		new[i] = make([]byte, len(old[i]))
		copy(new[i], old[i])
	}
	return new
}
