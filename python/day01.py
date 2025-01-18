from typing import List, Tuple
import os
import sys


def read_data(file_name: str) -> Tuple[List[int], List[int]]:
    left_list: List[int] = []
    right_list: List[int] = []
    with open(file_name) as file:
        lines = file.readlines()
        for line in lines:
            left, right = [int(word.strip()) for word in line.strip().split()]
            left_list.append(left)
            right_list.append(right)
    return (left_list, right_list)


def part1(left_list: List[int], right_list: List[int]) -> int:
    total_distance = 0
    for i in range(len(left_list)):
        total_distance += abs(right_list[i]-left_list[i])
    return total_distance


def part2(left_list: List[int], right_list: List[int]) -> int:
    num_count = {}
    for i in range(len(left_list)):
        if (num_count.get(right_list[i])):
            num_count[right_list[i]] += 1
        else:
            num_count[right_list[i]] = 1
    total_similarity = 0
    for num in left_list:
        if (num_count.get(num)):
            total_similarity += num * num_count.get(num)
    return total_similarity


if __name__ == "__main__":
    input_file: str = "/home/mohitjangra/learning/advent_of_code_2024/inputs/day01.input"
    test_file: str = "/home/mohitjangra/learning/advent_of_code_2024/tests/day01.test"

    mode = os.sys.argv[1] if len(os.sys.argv) > 1 else "test"
    if mode.strip().lower() == "input":
        left_list, right_list = read_data(input_file)
    elif mode.strip().lower() == "test":
        left_list, right_list = read_data(test_file)

    left_list = sorted(left_list)
    right_list = sorted(right_list)

    p1_result = part1(left_list, right_list)
    p2_result = part2(left_list, right_list)

    if mode.strip().lower() == "input":
        assert p1_result == 1258579
        assert p2_result == 23981443
    elif mode.strip().lower() == "test":
        assert p1_result == 11
        assert p2_result == 31
    else:
        print(f"Usage: {os.sys.argv[0]} [test|input]", file=sys.stderr)
