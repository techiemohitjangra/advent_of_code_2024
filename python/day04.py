from typing import List
import os
import sys


def read_data(file_name: str) -> List[str]:
    lines: List[str] = None
    with open(file_name, "r") as file:
        lines = [line.strip() for line in file.readlines()]
    return lines


def part1(input: List[str]) -> int:
    count: int = 0
    diff: int = 0
    for y, line in enumerate(input):
        for x, char in enumerate(line):
            if (char == 'X'):
                match: str = "XMAS"
                reverse: str = "SAMX"

                # check right
                if x + (len(match) - 1) < len(line) and line[x:x + len(match)] == match:
                    count += 1

                # check left
                if x >= (len(reverse) - 1) and line[x - (len(reverse) - 1):x + 1] == reverse:
                    count += 1

                diff = 0
                # check top
                while y >= (len(match) - 1) and diff < len(match):
                    if (input[y - diff][x] != match[diff]):
                        break
                    diff += 1
                    if (diff == 4):
                        count += 1
                        break

                diff = 0
                # check bottom
                while (y + (len(match) - 1) < len(input) and diff < len(match)):
                    if input[y + diff][x] != match[diff]:
                        break
                    diff += 1
                    if (diff == 4):
                        count += 1
                        break

                diff = 0
                # check top right
                while y >= (len(match) - 1) and x + (len(match) - 1) < len(line) and diff < len(match):
                    if input[y - diff][x + diff] != match[diff]:
                        break
                    diff += 1
                    if diff == 4:
                        count += 1
                        break

                diff = 0
                # check top left
                while y >= (len(match) - 1) and x >= (len(match) - 1) and diff < len(match):
                    if input[y - diff][x - diff] != match[diff]:
                        break
                    diff += 1
                    if diff == 4:
                        count += 1
                        break

                diff = 0
                # check bottom left
                while (y + (len(match) - 1) < len(input) and x >= (len(match) - 1) and diff < len(match)):
                    if input[y + diff][x - diff] != match[diff]:
                        break
                    diff += 1
                    if diff == 4:
                        count += 1
                        break

                diff = 0
                # check bottom right
                while y + (len(match) - 1) < len(input) and x + (len(match) - 1) < len(line) and diff < len(match):
                    if input[y + diff][x + diff] != match[diff]:
                        break
                    diff += 1
                    if diff == 4:
                        count += 1
                        break
    return count


def part2(input: List[str]) -> int:
    count: int = 0
    patterns: List[List[int]] = [
        # M:x, y}, S:x, y}
        [-1, -1, 1, 1],  # top_left-to-bottom_right
        [-1, 1, 1, -1],  # bottom_left-to-top_right
        [1, -1, -1, 1],  # top_right-to-bottom_left
        [1, 1, -1, -1],  # bottom_right-to-top_left
    ]
    for y, line in enumerate(input):
        for x, char in enumerate(line):
            if (char == 'A' and y > 0 and x > 0 and y < (len(input) - 1) and x < (len(line) - 1)):
                tempCount: int = 0
                for item in patterns:
                    if (input[y + item[1]][x + item[0]] == 'M' and input[y + item[3]][x + item[2]] == 'S'):
                        tempCount += 1
                if (tempCount == 2):
                    count += 1
    return count


if __name__ == "__main__":
    input_file: str = "/home/mohitjangra/learning/advent_of_code_2024/inputs/day04.input"
    test_file: str = "/home/mohitjangra/learning/advent_of_code_2024/tests/day04.test"

    mode = os.sys.argv[1] if len(os.sys.argv) > 1 else "test"
    records: List[List[int]]
    if mode.strip().lower() == "input":
        records = read_data(input_file)
        p1_result = part1(records)
        p2_result = part2(records)
        assert p1_result == 2496
        assert p2_result == 1967
    elif mode.strip().lower() == "test":
        records = read_data(test_file)
        p1_result = part1(records)
        p2_result = part2(records)
        assert p1_result == 18
        assert p2_result == 9
    else:
        print(f"Usage: {os.sys.argv[0]} [test|input]", file=sys.stderr)
