# Advent of code 2025, day 10, Python

import re
import itertools
import sys
import pulp # needs install

# Current file to work on.
fileName = "../d10_input"

def light_to_bits(lights: str) -> int:
    """
    Convert the desired light state string to an integer bitmask.
    '#' (on) becomes '1', '.' (off) becomes '0'
    eg. ".##." -> "0110" -> 6

    str.maketrans(<input>, <output>): create a translation table
    <string>.translate(<table>): translate string using given table
    int(<string>, <string base>): convert base 2 string into integer
    """
    trans_table = str.maketrans('#.', '10')
    translated = lights.translate(trans_table)
    bits = int(translated, 2)

    return bits

def buttons_to_bits(button_str: str, num_lights: int) -> int:
    """
    Convert a single button's wiring schematic to a bitmask.
    1 << (num_lights - 1 - index): converts from numeric position into bit position.
    eg. button "0,2" with 4 lights -> bits 3 and 1 -> 0b1010 -> 10

    <string>.split(<delimiter>): split the <string> into a list by <delimiter>
    <<: shift bits left
    sum(<list>): adds together all values created by bit shifting.
    [...]: list comprehension, returns a list of whatever the loop inside produces.
    """
    indices = [int(num) for num in button_str.split(',')]
    bits    = [1 << (num_lights - 1 - i) for i in indices]

    return sum(bits)

def part_1(lights: str, buttons: list[str]) -> int:
    """
    Find the minimum number of button presses to match the target light state.
    Loop from 1 to the number of buttons present and loop through each combination
        of the current number of buttons.

    itertools: a module with various functions enabling different iterators
    .combinations(<list>, <number of items>): iterate through <list> combining
        each element with the others. Do this until the combinations are
        <number of items> long.
    """
    lights_int = light_to_bits(lights)
    buttons_int_masks = [buttons_to_bits(button, len(lights)) for button in buttons]

    for i in range(1, len(buttons_int_masks) + 1):
        for combination in itertools.combinations(buttons_int_masks, i):
            # XOR all button masks in this combination together.
            # If the result matches the target, this combination is a solution.
            xor_result = 0
            for button_mask in combination:
                xor_result ^= button_mask
            if xor_result == lights_int:
                return len(combination)
    
    # If no solution is found something is most likely wrong with the input.
    print("Something went wrong with part 1")
    sys.exit(1)

def part_2(buttons: list[str], joltage: str) -> int:
    """
    Find the minimum number of button presses to match the target joltage state.
        Joltage gives the exact total number of toggles required per light.
    PuLP: Python Linear Programming. Library for working with and solving linear
        programming problems. One of many methods, but this seems most modern.

    pulp.LpProblem(<name>, <objective type>): Sets up a problem and set objective
        function type.
    pulp.LpVariable.dicts(<name>, <source>, <lower bound>, <data type>): creates
        one integer variable per button, keyed by index. lowBound=0 prevents negative
        press counts. cat='Integer' enforces whole numbers.
    pulp.lpSum(<list>): builds a linear expression by summing PuLP variables.
        Used both for the objective (total presses) and per-light constraints
        (sum of presses affecting light must equal joltage[light]).
    problem.solve(): invokes the CBC solver. msg=False suppresses its output.
    pulp.value(problem.objective): retrieves the minimised total press count.
    """
    joltage_ints = [int(num) for num in joltage.split(',')]
    button_indices = [[int(num) for num in butt.split(',')] for butt in buttons]

    problem = pulp.LpProblem("AoC-2025_day-10_part-2", pulp.LpMinimize)
    variables = pulp.LpVariable.dicts("buttons", range(len(button_indices)), lowBound=0, cat='Integer', )
    for light in range(len(joltage_ints)):
        problem += pulp.lpSum(
            [variables[j] for j, indices in enumerate(button_indices) if light in indices]
        ) == joltage_ints[light]
    problem += pulp.lpSum(variables.values())

    problem.solve(pulp.PULP_CBC_CMD(msg=False))
    if (problem.status != 1):
        print("Something went wrong with part 2")
        sys.exit(1)

    count = int(pulp.value(problem.objective))
    return count

if __name__ == "__main__":
    part_1_val = 0
    part_2_val = 0
    
    with open(fileName) as fd:
        for currLine in fd:
            # Extract the three sections of each line using regex.
            # .group(<capturing group>): tells which capturing group to return
            lights  = re.search(r'\[([#\.]+)\]', currLine).group(1)
            buttons = re.findall(r'\(([\d,]+)\)', currLine)
            joltage = re.search(r'\{([\d,]+)\}', currLine).group(1)
            
            part_1_val += part_1(lights, buttons)
            part_2_val += part_2(buttons, joltage)

    # F-strings (formatted strings) are preferred in modern python.
    print(f"Part 1: {part_1_val}")
    print(f"Part 2: {part_2_val}")
