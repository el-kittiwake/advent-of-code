#|
 Advent of code 2025, day 7. Racket.
 Resources:
			https://learnxinyminutes.com/racket/
			https://docs.racket-lang.org/guide/
			https://docs.racket-lang.org/reference/

	Racket uses kebab-case by convention.

	Part 1: 1630
	Part 2: 47857642990160
|#

;; Defines the language and modules
;; SRFI/13 is the standard string library.
#lang racket
(require srfi/13)
;; Define file location
;; (define <label> <value>) - binds value to label.
(define file-path "../d7_input")

#|	====	Parse input file to memory	====
	https://www.reddit.com/r/Racket/comments/8bosc3/how_to_read_file_line_by_line_fast/
	https://en.wikipedia.org/wiki/Thunk
	(with-input-from-file <path> <thunk>) opens file and sets current-input-port
	thunk: function used to delay operation until the file is open and ready
	in-lines reads from current-input-port, set by with-input-from-file.
		Produces a sequence of strings from the file in path.
		sequence->list <sequence> : converts that sequence to a list.
		list->vector <list> : converts that list to a vector.
		The result is bound to a name with define.
|#
(define in-file
	(with-input-from-file file-path
		(thunk
			(list->vector (sequence->list (in-lines)))
		)
	)
)

#|	===		Define the starting point	====
	The S character on the top row. Represents the "beam emitter".
	In in-file row 0, return the location of S to variable start-x.
	string-index <string> <target> : find target in string, return index
		Only returns the first match. 
		#\ : prefix for single char
		vector-ref <vector> <location> : return reference to location in vector
|#
(define start-x (string-index (vector-ref in-file 0) #\S))

#|	====	Counting logic	====
	"Beam" propagates downward through the grid.
	(define-values ... ): Binds multiple returns to multiple names.
	for/fold, state carrying loop. Via one or more accumulators declared on entry.
		(for/fold ([<accu1> <init1>][<accu2> <init2>]) ([<clause>]) ... (values <retval1> <retval2>))
	active-cells: hash of column indices with active beams in the current row. hash: key/value table.
		key is x location, value is number of splits at that location
	count: running total of beam splits (^ characters hit by an active beam).
	Inner for/fold processes each active column in the row, building the next
		active set splitting beams at ^, carrying straight through at .
		Returns are fed back to the outer loop as updated accumulators.
		n : current count of splits, updated if needed
	if statement: (if (test) (then) (else) )
	(char=? <char1> <char2> ...) : checks if all <char>s match
	(string-ref <string> <pos>): returns whatever char is at the current position
	let: (let [name (value)] (body) )
	hash-set: (hash-set <hash-table> <key> <value>)
	hash-ref: (hash-ref <hash-table> <key> <default>)
	values: sets values defined earlier
		(let ([new-map <first hash-set>])	; bind result to new-map
		(values <second hash-set>			; body: second hash-set uses the new new-map
		(+ count 1)))
|#
(define-values (final-cells final-count)
	(for/fold
		([active-cells (hash start-x 1)] [count 0])	;; (set start-x) - part 1
		([row (in-vector in-file)])

		(for/fold
			([new-map (hash)] [count count])		;; (new-cells (set)) - part 1
			([(x n) (in-hash active-cells)])		;; ([row (in-vector in-file)]) - part 1
			(if (char=? (string-ref row x) #\^)
				;; Approach for part 1, before seeing part 2
				;(values (set-union new-cells (set (- x 1) (+ x 1))) (+ count 1))
				;(values (set-add new-cells x) count)
				(
					let ([new-map (hash-set new-map (- x 1) (+ n (hash-ref new-map (- x 1) 0)))])
  					(values (hash-set new-map (+ x 1) (+ n (hash-ref new-map (+ x 1) 0))) (+ count 1))
				)																				; true

				(values (hash-set new-map x (+ n (hash-ref new-map x 0))) count)				; else
			)
		)
	)
)

;; printf for a more C like way to output
;; ~a format values for human readable display
(printf "Part 1: ~a\n" final-count)
(printf "Part 2: ~a\n" (apply + (hash-values final-cells)))
