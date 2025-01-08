from typing import List
import os

# TODO: solutions invalid, redo these


def read_data(file_name: str) -> List[str]:
    lines: List[str] = None
    with open(file_name, "r") as file:
        lines = [line.strip() for line in file.readlines()]
    return lines


def part1(fileName: str) -> int:
    pass


def part2(lines: str) -> int:
    count: int = 0
    patterns: List[int] = [
        # M{x, y}, S{x, y}
        [-1, 0, 1, 0],  # left-to-right
        [1, 0, -1, 0],  # right-to-left
        [0, -1, 0, 1],  # top-to-bottom
        [1, 0, -1, 0],  # bottom-to-top
        [1, -1, -1, 1],  # top_right-to-bottom_left
        [-1, -1, 1, 1],  # top_left-to-bottom_right
        [-1, 1, 1, -1],  # bottom_left-to-top_right
        [1, 1, -1, -1],  # bottom_right-to-top_left
    ]

    for y, line in enumerate(lines):
        for x, char in enumerate(line):
            if (char == 'A' and y > 0 and x > 0 and y < (len(lines) - 1) and x < (len(line) - 1)):
                for item in patterns:
                    if (lines[y + item[1]][x + item[0]] == 'M' and
                            lines[y + item[3]][x + item[2]] == 'S'):
                        print(
                            f"{lines[y + item[1]][x + item[0]]}A{lines[y + item[3]][x + item[2]]} y: {y} x: {x}")
                        count += 1
    return count


if __name__ == "__main__":
    input_file: str = "../inputs/day04.input"
    test_file: str = "../tests/day04.test"

    mode = os.sys.argv[1] if len(os.sys.argv) > 1 else "test"
    records: List[List[int]]
    if mode.strip().lower() == "input":
        records = read_data(input_file)
        p1_result = part1(records)
        p2_result = part2(records)
        # assert p1_result == 2496
        print(p2_result)
        assert p2_result == 1967
    elif mode.strip().lower() == "test":
        records = read_data(test_file)
        p1_result = part1(records)
        p2_result = part2(records)
        # assert p1_result == 1967
        print(p2_result)
        assert p2_result == 9
