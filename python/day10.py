import os
import sys
from typing import List, Set, Tuple


def read_data(filename: str) -> List[str]:
    lines: List[str] = []
    with open(filename) as file:
        lines = [line.strip(" \r\n\t") for line in file.readlines()]
    return lines


def parse_map(lines: List[str]) -> List[List[int]]:
    map: List[List[int]] = []
    for line in lines:
        row: List[int] = [int(char) for char in line]
        map.append(row)
    return map


def traverse(map: List[List[int]], y: int, x: int, destinations: Set[Tuple[int, int]]) -> None:
    assert y >= 0
    assert x >= 0
    if (map[y][x] == 9):
        if isinstance(destinations, set):
            destinations.add((y, x))
        elif isinstance(destinations, list):
            destinations.append((y, x))
        return
    # up
    if y > 0 and map[y][x]+1 == map[y-1][x]:
        traverse(map, y-1, x, destinations)
    # right
    if x < len(map[y])-1 and map[y][x]+1 == map[y][x+1]:
        traverse(map, y, x+1, destinations)
    # down
    if y < len(map)-1 and map[y][x]+1 == map[y+1][x]:
        traverse(map, y+1, x, destinations)
    # right
    if x > 0 and map[y][x]+1 == map[y][x-1]:
        traverse(map, y, x-1, destinations)


def get_score(map: List[List[int]], y: int, x: int) -> int:
    destinations: Set[Tuple[int, int]] = set()
    traverse(map, y, x, destinations)
    return len(destinations)


def part1(map: List[List[int]]) -> int:
    total_score: int = 0
    for y, row in enumerate(map):
        for x, cell in enumerate(row):
            if cell == 0:
                score = get_score(map, y, x)
                total_score += score
    return total_score


def get_rating(map: List[List[int]], y: int, x: int):
    paths = list()
    traverse(map, y, x, paths)
    return len(paths)


def part2(map: List[List[int]]) -> int:
    total_score: int = 0
    for y, row in enumerate(map):
        for x, cell in enumerate(row):
            if cell == 0:
                score = get_rating(map, y, x)
                total_score += score
    return total_score


if __name__ == "__main__":
    input_file: str = "/home/mohitjangra/learning/advent_of_code_2024/inputs/day10.input"
    test_file: str = "/home/mohitjangra/learning/advent_of_code_2024/tests/day10.test"
    sample_file: str = "/home/mohitjangra/learning/advent_of_code_2024/tests/day10.sample"

    mode = os.sys.argv[1] if len(os.sys.argv) > 1 else "test"
    if mode.strip().lower() == "input":
        data: List[str] = read_data(input_file)
        map: List[List[int]] = parse_map(data)

        pt1_result = part1(map)
        assert pt1_result == 646

        pt2_result = part2(map)
        assert pt2_result == 1494
    elif mode.strip().lower() == "test":
        data: List[str] = read_data(test_file)
        map: List[List[int]] = parse_map(data)

        pt1_result = part1(map)
        assert pt1_result == 36

        pt2_result = part2(map)
        assert pt2_result == 81
    elif mode.strip().lower() == "sample":
        data: List[str] = read_data(sample_file)
        map: List[List[int]] = parse_map(data)

        sample_result = part1(map)
        assert sample_result == 1
    else:
        print(f"Usage: {os.sys.argv[0]} [test|input]", file=sys.stderr)
