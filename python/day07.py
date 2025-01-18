import os
import sys
from typing import List, DefaultDict
from collections import defaultdict


def read_data(file_name: str) -> DefaultDict[int, List[int]]:
    lines: List[str] = []
    with open(file_name, "r") as file:
        lines = [line.strip() for line in file.readlines()]

    calibrations: DefaultDict[int, List[int]] = defaultdict(list)
    for line in lines:
        values = line.split(':')
        calibrations[int(values[0].strip())] = [int(value.strip())
                                                for value in values[1].strip().split()]

    return calibrations


def two_operator_check(target: int, nums: List[int], result: int):
    pass


def three_operator_check(target: int, nums: List[int], result: int):
    pass


def part1(calibrations: DefaultDict[int, List[int]]) -> int:
    pass


def part2(calibrations: DefaultDict[int, List[int]]) -> int:
    pass


if __name__ == "__main__":
    input_file: str = "/home/mohitjangra/learning/advent_of_code_2024/inputs/day07.input"
    test_file: str = "/home/mohitjangra/learning/advent_of_code_2024/tests/day07.test"

    mode = os.sys.argv[1] if len(os.sys.argv) > 1 else "test"
    calibrations: DefaultDict[int, List[int]]
    if mode.strip().lower() == "input":
        calibrations = read_data(input_file)
        pt1_result = part1(calibrations)
        pt2_result = part2(calibrations)
        assert pt1_result == 882304362421
        assert pt2_result == 145149066755184
    elif mode.strip().lower() == "test":
        calibrations = read_data(test_file)
        pt1_result = part1(calibrations)
        pt2_result = part2(calibrations)
        assert pt1_result == 3749
        assert pt2_result == 11387
    else:
        print(f"Usage: {os.sys.argv[0]} [test|input]", file=sys.stderr)
