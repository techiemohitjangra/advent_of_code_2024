from typing import List


def part1(fileName: str):
    pass


def part2(fileName: str):
    count: int = 0
    lines: List[str] = None
    with open(fileName, "r") as file:
        lines = [line.strip() for line in file.readlines()]

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
    inputFile: str = "./day04.input"
    test: str = "./day04.test"
    p1_result = part1(test)
    p2_result = part2(test)
    file = open(test)
    input = "\n".join([line.strip() for line in file.readlines()])
    print(input)
    # print(p1_result)
    print(p2_result)
    file.close()
