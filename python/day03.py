import os
import re


def read_data(file_name: str) -> str:
    data: str
    with open(file_name, "r") as file:
        data = file.read().strip()
    return data


def part1(data: str) -> int:
    matches = re.findall("mul\\((\\d{1,3}),\\.*(\\d{1,3})\\)", data)
    res: int = 0
    for match in matches:
        res += int(match[0]) * int(match[1])
    return res


def part2(data: str) -> int:
    newdata = re.sub(r"don't\(\).*?(do\(\))", r'', data, flags=re.DOTALL)
    matches = re.findall("mul\\((\\d{1,3}),\\.*?(\\d{1,3})\\)", newdata)
    res: int = 0
    for match in matches:
        res += int(match[0]) * int(match[1])
    return res


if __name__ == "__main__":
    input_file: str = "../inputs/day03.input"
    test_file1: str = "../tests/day03.test1"
    test_file2: str = "../tests/day03.test2"

    mode = os.sys.argv[1] if len(os.sys.argv) > 1 else "test"
    data: str
    if mode.strip().lower() == "input":
        data = read_data(input_file)
        p1_result = part1(data)
        p2_result = part2(data)
        assert p1_result == 173731097
        assert p2_result == 93729253
    elif mode.strip().lower() == "test":
        test_data1 = read_data(test_file1)
        p1_result = part1(test_data1)
        test_data2 = read_data(test_file2)
        p2_result = part2(test_data2)
        assert p1_result == 161
        assert p2_result == 48
