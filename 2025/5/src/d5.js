/**
 * Advent of Code 2025, day 5, Javascript
 * 
 * Part 1: 868
 * Part 2: 354143734113772
 */

// Import the 'fs' module.
// Synchronous reading of files.
const {readFileSync} = require('fs');

/*
	Using node.js readFileSync to read the file.
	https://www.geeksforgeeks.org/node-js/node-js-fs-readfilesync-method/
	https://nodejs.org/api/fs.html#fsreadfilesyncpath-options
*/
function handleFile(filename)
{
	// Synchronously read the file as utf8
	const contents = readFileSync(filename, 'utf8');
	// Split the read data by new line into an array
	const splitContents = contents.split(/\n/);

	return splitContents;
}

/*
	Parse each range string into a [number, number] pair
	.map() to Number format
	https://www.w3schools.com/js/js_comparisons.asp
*/
function splitRanges(array)
{
	let splitArr = [];

	array.forEach(element =>
	{
		let values = element.split("-")
		values = values.map(function(item)
		{
			return Number(item);
		})
		splitArr.push(values);
	});

	return splitArr;
}

/*
	Check an ingredient against a range.
	True if fresh, false if spoiled.
	Direct return of logical expression.
*/
function isFresh(range, ingredient)
{
	return ingredient >= range[0] && ingredient <= range[1];
}

/*
	Loop through ranges checking for fresh
	array.some(<callbackFn>) method returns true if it finds an element in the
		array that satisfies the provided testing function.
		Otherwise, it returns false
	Once again, direct return is stylistically better.
*/
function loopRanges(ranges, ingredient)
{
	return ranges.some(element =>
	{
		return isFresh(element, ingredient)
	});
}

/*
	Loop through ingredients checking them all to each range
*/
function loopIngredients(ranges, ingredients)
{
	let counter  = 0;
	
	ingredients.forEach(element =>
	{
		if (loopRanges(ranges, element))
			counter++;
	})

	return counter;
}

/*
	Compare a and b from the given position in an array
	Helper for countTotalFresh()
*/
function compareNumbers(a, b, elem = 0)
{
	return a[elem] - b[elem];
}

/*
	Part 2.
	Count the total number of allowable fresh ingredients.
	Keep track of total count and the previous largest value.
	Check if the current lowest element is greater than currentMax.
	If so, the range is entirely new and the whole range is counted.
	Otherwise, if the range extends beyond currentMax, only the new portion is counted.
	Update currentMax to the highest value seen so far.
*/
function countTotalFresh(ranges)
{
	let count = 0;
	let currentMax = -1;

	ranges.forEach(element =>
	{
		if (element[0] > currentMax)
		{
			count += element[1] - element[0] + 1;
			currentMax = element[1];
		}
		else if (element[0] <= currentMax && element[1] > currentMax )
		{
			count += element[1] - currentMax;
			currentMax = element[1];
		}
	})

	return count;
}

// ==================
// Perform everything
// ==================

// Import file to vector of strings
const array = handleFile('../d5_input')
// {'maxArrayLength': null} shows all items no matter how many
// https://techozu.com/show-all-items-console-log-node/

// Calculate ranges for array.slice()
// Ranges: end point of ID ranges
//		   start of ingredient IDs
//		   end of ingredient IDs
const splitRangesTo = array.indexOf('');
const splitIngFrom = splitRangesTo + 1;
const splitIngTo = array.length - 1;

// Split file contents to specific arrays.
// Convert ingredient ID strings to numbers.
const rangesArr = splitRanges(array.slice(0, splitRangesTo));
let ingredientsArr = array.slice(splitIngFrom, splitIngTo);
ingredientsArr = ingredientsArr.map(function(item)
{
	return Number(item);
});

// Part 1 functions
const freshCounter = loopIngredients(rangesArr, ingredientsArr);
console.log("Part 1: ", freshCounter);

// Part 2 functions
// array.toSorted(<compareFn>): sorts array by result of <compareFn>
const sortedRanges = rangesArr.toSorted(compareNumbers);
const totalFreshCounter = countTotalFresh(sortedRanges);
console.log("Part 2: ", totalFreshCounter);
