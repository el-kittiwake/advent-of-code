      * This part stores information about the identity of the program
      * PROGRAM_ID is used by the linker so others can call this as an
      *    external module.
       IDENTIFICATION DIVISION.
       PROGRAM-ID. TREEFARM.
       INSTALLATION. ADVENT OF CODE, DAY 12, PART 1.
       AUTHOR. ERIC LEHTONEN.
       REMARKS. ATTEMPTING THE CHEAP AND EASY SOLUTION TO DAY 12.

      * This part stores information about the system the program will
      *    run on. It is optional if no files are used or no special
      *    hardware is used.
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT INPUT-FILE                   *> Associates a name with an external file
               ASSIGN TO "../d12_input"        *> Specifies the external file
               ORGANIZATION LINE SEQUENTIAL.   *> Plain text file, line delimited

      * This part is used to set up variables and file descriptors.
      * All variables in COBOL are global, and must be explicitly declared.
      * FD: file descriptor, declared earlier in environment
      * INPUT_RECORD is the binding of the FD to a specific memory location.
      *    It has to be in the FILE SECTION
      * PIC (PICTURE) specifies the characteristics of a variable.
      *    X: alphanumeric
      *    <number>: Decimal digits
      *    ( ... ): number of proceeding type
      *    OCCURS ... TIMES: how many elements in an array
      *        01 name 05 individual elements
      *    VALUE: set a default value
       DATA DIVISION.
       FILE SECTION.
       FD  INPUT-FILE.
       01  INPUT-RECORD        PIC X(24).
       
       WORKING-STORAGE SECTION.
       01  EOF-FLAG            PIC X VALUE 'N'.
       01  HASH-TALLY          PIC 99.
       01  DENSITY-TABLE.
           05  DENSITY         OCCURS 6 TIMES PIC 99.
       
       01  REGION-WIDTH        PIC 999.
       01  REGION-HEIGHT       PIC 999.
       01  COUNTS-TABLE.
           05  PRESENT-COUNT   OCCURS 6 TIMES PIC 999.
       01  TOTAL-PRESENTS      PIC 9999.
       01  MIN-SPACE           PIC 9(6).
       01  REGION-CAPACITY     PIC 9999.
       
       01  NO-COUNT            PIC 9999 VALUE 0.
       01  YES-COUNT      PIC 9999 VALUE 0.
       01  MAYBE-COUNT         PIC 9999 VALUE 0.

       01  IDX                 PIC 9.

      * OPEN <mode> <name>: Opens a file descriptor for a certain action.
      * PERFORM: Executes a block of code. If inline it requires an END-PERFORM.
      * IF, paired with END-IF.
      * DISPLAY: Output to terminal, blocks of text and variables acceptable.
      * STOP RUN: ends the program.
       PROCEDURE DIVISION.
           MAIN-LOGIC.
               OPEN INPUT INPUT-FILE
               PERFORM READ-SHAPES
               PERFORM PROCESS-REGIONS
               IF MAYBE-COUNT > 0
                   DISPLAY "WARNING: " MAYBE-COUNT " AMBIGUOUS REGIONS "
                       "RESULT MAY BE UNRELIABLE"
               END-IF
               DISPLAY "PART 1: " YES-COUNT
               DISPLAY "PART 2 DOESN'T EXIST, MERRY LATE CHRISTMAS 2025"
               CLOSE INPUT-FILE
               STOP RUN.

      * === Read and calculate the area of each shape.
      * === May not be necessary for any real input.
      * PERFORM VARYING <variable> FROM <start> BY <increment amount> UNTIL <expression>
      *    Essentially a for loop. Everything up until the END-PERFORM is
      *    repeated UNTIL the final expression is met.
      * READ without a destination essentially ignores it.
      * MOVE <value> TO <variable>: Sets a variable to a value.
      * PERFORM <num> TIMES: loop <num> time
      * INSPECT <string> TALLYING <variable> FOR <limit> <pattern>
      *    <limit>: Either ALL or LEADING (for leftmost characters)
      *    <pattern>: characters to count
      *    REPLACING and CONVERTING are also possible instead of TALLYING
       READ-SHAPES.
           PERFORM VARYING IDX FROM 1 BY 1 UNTIL IDX > 6
               READ INPUT-FILE                       *> header line "0:" - discarded
               MOVE 0 TO HASH-TALLY
               PERFORM 3 TIMES
                   READ INPUT-FILE INTO INPUT-RECORD
                   INSPECT INPUT-RECORD TALLYING HASH-TALLY FOR ALL '#'
               END-PERFORM
               MOVE HASH-TALLY TO DENSITY(IDX)
               READ INPUT-FILE                       *> blank separator - discarded
           END-PERFORM.

      * === Calculate region area and present area
      * === Check for fit and note any borderline areas
      * PERFORM UNTIL <condition>: loops until <condition> is met
      * READ ... AT END <action>: Error handler for end of file.
      *    READ block terminated with END-READ
      * UNSTRING <source> DELIMITED BY <delimiters>: Splits a string
      *    INTO: copy to multiple substrings. At least 2, but as many as
      *    there are splits.
      *    UNSTRING block terminated by END-UNSTRING.
      * ADD <value> TO <value>: sum the two values.
      * COMPUTE <output> <round> = <arithmetic expression>
      *    Perform combined arithmetic rather than needing individual
      *    operator statements.
       PROCESS-REGIONS.
           PERFORM UNTIL EOF-FLAG = 'Y'
               READ INPUT-FILE INTO INPUT-RECORD
                   AT END MOVE 'Y' TO EOF-FLAG
               END-READ
               IF EOF-FLAG NOT = 'Y'
                   UNSTRING INPUT-RECORD DELIMITED BY 'x' OR ': ' OR ' '
                       INTO REGION-WIDTH, REGION-HEIGHT,
                            PRESENT-COUNT(1), PRESENT-COUNT(2),
                            PRESENT-COUNT(3), PRESENT-COUNT(4),
                            PRESENT-COUNT(5), PRESENT-COUNT(6)
                   END-UNSTRING

                   MOVE 0 TO TOTAL-PRESENTS
                   MOVE 0 TO MIN-SPACE
                   PERFORM VARYING IDX FROM 1 BY 1 UNTIL IDX > 6
                      ADD PRESENT-COUNT(IDX) TO TOTAL-PRESENTS
                      COMPUTE MIN-SPACE = MIN-SPACE + PRESENT-COUNT(IDX)
                          * DENSITY(IDX)
                   END-PERFORM
       
                   COMPUTE REGION-CAPACITY = (REGION-WIDTH / 3)
                       * (REGION-HEIGHT / 3)

                   IF MIN-SPACE > REGION-WIDTH * REGION-HEIGHT
                       ADD 1 TO NO-COUNT
                   ELSE IF TOTAL-PRESENTS <= REGION-CAPACITY
                       ADD 1 TO YES-COUNT
                   ELSE
                       ADD 1 TO MAYBE-COUNT
                   END-IF
               END-IF
           END-PERFORM.
