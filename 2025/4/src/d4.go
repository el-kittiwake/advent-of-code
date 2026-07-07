/**
 * Advent of Code 2025, day 4. Golang.
 *
 * Part 1: 1416
 * Part 2: 9086
 */
package main

//Buffered IO, formatted IO and system calls
import (
	"bufio"
	"fmt"
	"os"
)

// Line size global because it is used in several places.
var size int = 0

// Alias definition for the byte array used to store the input data
type Field = [][]byte

/*
Assignments:

	:= short declaration. For local variables with inferable type.

File operations:

	os.Open() Returns an OS specific struct with opened file details
				Returns status, nil = success
	bufio.NewScanner() Returns a scanner. A type for reading input piece-by-piece
		Be that lines, words, or bytes. Without me having to manage buffering.
	fileScanner.Split() Sets the split function. (Lines, bytes etc.)
		ScanLines: linewise, stripped of newline.
		ScanLines is the default. so it is here only for information.
	fileScanner.Scan()  Returns true if read success, false if error or EOF.
		append(<slice>, <elements>) Returns elements appended to slice.
		fileScanner.Bytes() Returns bytes from the split.
		`append([]byte(nil), ...` appending to a nil forces reallocation.
			Required because .Bytes() returns a slice pointing to the scanner's
			buffer. Which would be destroyed on the next iteration.
		... unpack a slice's elements into variadic params rather than one param

Puzzle solution:

	make(<type>, <size>) allocate and initialise a new object of type and size
		Initial make() creates a Field of <size> elements.
		Looped make() fills each Field element with <size> nulled bytes
*/
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
	//fileScanner.Split(bufio.ScanLines)
	var inputLines Field
	for fileScanner.Scan() {
		inputLines = append(inputLines, append([]byte(nil), fileScanner.Bytes()...))
	}
	if err := fileScanner.Err(); err != nil {
		fmt.Println(err)
		return
	}
	readFile.Close()

	//Puzzle solution.
	size = len(inputLines[0])
	var rollTotal int = 0
	var iterCount int = 0
	var runFlag bool = true

	// Run through the whole input until no more rolls can be accessed.
	//
	// nextIter has to be a new buffer because removals must happen based on the
	// inputLines state before any removal. Editing inputLines directly would
	// make later cells in the same pass see already-removed neighbours,
	// corrupting the count.
	for runFlag == true {
		rollCount := 0
		// make(Field, size) only allocates the outer slice nil row.
		// Each row needs its own make([]byte, size). Go has no single call that
		// allocates a full 2D shape at once.
		nextIter := make(Field, size)
		for i := range nextIter {
			nextIter[i] = make([]byte, size)
		}

		// Loop through the current roll/space field (inputLines)
		// Update next roll/space field (nextIter)
		for y := range size {
			for x := range size {
				if isPaperRoll(inputLines[y][x]) {
					if isAccessible(inputLines, x, y) {
						rollCount++
						nextIter[y][x] = '.'
					} else {
						nextIter[y][x] = '@'
					}
				} else {
					nextIter[y][x] = '.'
				}
			}
		}

		if rollCount == 0 {
			runFlag = false
		}

		rollTotal += rollCount
		if iterCount == 0 {
			fmt.Println("Part 1: ", rollTotal)
		}

		iterCount++
		inputLines = nextIter
	}

	fmt.Println("Part 2: ", rollTotal)
}

// Check if a coordinate would take us under 0 or over maximum size
func isOutOfBounds(x, y int) bool {
	if x < 0 || x >= size || y < 0 || y >= size {
		return true
	}
	return false
}

// Check if a coordinate contains an @
func isPaperRoll(char byte) bool {
	return char == '@'
}

/*
Count the number of @ in the 8 adjacent cells to the cell in question.
Returns true only if count is less than 4.
Neighbour list omits (0,0) by design as there is no need to check itself.
Out-of-bounds is not an error and is treated as "no roll".
*/
func isAccessible(field Field, x, y int) bool {
	var neighbours = [8][2]int{
		{-1, -1}, {0, -1}, {1, -1},
		{-1, 0}, {1, 0},
		{-1, 1}, {0, 1}, {1, 1},
	}
	var count int = 0

	for _, d := range neighbours {
		nx, ny := x+d[0], y+d[1]
		if !isOutOfBounds(nx, ny) && isPaperRoll(field[ny][nx]) {
			count++
		}
	}

	return count < 4
}
