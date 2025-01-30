import os
import sys
from typing import List
import copy


def read_data(filename: str):
    line: List[int] = []
    with open(filename, "r") as file:
        data = file.read()
        line = [int(num) for num in data.strip(" \r\n\t").split(" ")]
    return line


def blink(line: List[int]) -> List[int]:
    idx: int = 0
    while idx < len(line):
        if line[idx] == 0:
            line[idx] = 1
        elif len(str(line[idx])) % 2 == 0:
            num_str = str(line[idx])
            num_len = len(num_str)
            line = line[:idx] + [int(num_str[:num_len//2]),
                                 int(num_str[(num_len//2):])] + line[idx+1:]
            idx += 1
        else:
            line[idx] *= 2024
        idx += 1
    return line


def part1(line: List[int], blink_count: int) -> int:
    for _ in range(blink_count):
        line = blink(line)
    return len(line)


def part2(line: List[int], blink_count: int) -> int:
    for _ in range(blink_count):
        line = blink(line)
    return len(line)


if __name__ == "__main__":
    input_file: str = "/home/mohitjangra/learning/advent_of_code_2024/inputs/day11.input"
    test_file: str = "/home/mohitjangra/learning/advent_of_code_2024/tests/day11.test"

    mode = os.sys.argv[1] if len(os.sys.argv) > 1 else "test"
    if mode.strip().lower() == "input":
        line: List[int] = read_data(input_file)

        pt1_result = part1(line, 25)
        assert pt1_result == 185894

        pt2_result = part2(line, 75)
        print(pt2_result)
        # assert pt2_result ==
    elif mode.strip().lower() == "test":
        line: List[int] = read_data(test_file)

        pt1_result_1 = part1(line, 25)
        assert pt1_result_1 == 55312
        pt1_result_2 = part1(line, 6)
        assert pt1_result_2 == 22
    else:
        print(f"Usage: {os.sys.argv[0]} [test|input]", file=sys.stderr)
