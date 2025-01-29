import os
import sys


def read_data(filename: str):
    pass


def part1() -> int:
    pass


def part2() -> int:
    pass


if __name__ == "__main__":
    input_file: str = "/home/mohitjangra/learning/advent_of_code_2024/inputs/day10.input"
    test_file: str = "/home/mohitjangra/learning/advent_of_code_2024/tests/day10.test"

    mode = os.sys.argv[1] if len(os.sys.argv) > 1 else "test"
    if mode.strip().lower() == "input":
        data = read_data()

        pt1_result = part1()
        # assert pt1_result ==

        pt2_result = part2()
        # assert pt2_result ==
    elif mode.strip().lower() == "test":
        data = read_data()

        pt1_result = part1()
        # assert pt1_result ==

        pt2_result = part2()
        # assert pt2_result ==
    else:
        print(f"Usage: {os.sys.argv[0]} [test|input]", file=sys.stderr)
