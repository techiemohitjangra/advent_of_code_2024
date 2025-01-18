import os
import sys

from typing import List, Tuple, DefaultDict
from collections import defaultdict
import copy


def read_data(file_name: str) -> List[List[str]]:
    lines: List[List[str]]
    with open(file_name, "r") as file:
        lines = [line.strip() for line in file.readlines()]

    data: List[List[str]] = []
    for line in lines:
        row: List[str] = []
        for char in line.strip():
            row.append(char)
        data.append(row)
    return data


def get_start(mapped_area: List[List[str]]) -> Tuple[int, Tuple[int, int]]:
    dm_idx: int = -1
    start_x, start_y = -1, -1
    for y, row in enumerate(mapped_area):
        for x, col in enumerate(row):
            if col == '.' or col == '#':
                continue
            start_x = x
            start_y = y
            if col == '^':
                dm_idx = 0
                break
            if col == '>':
                dm_idx = 1
                break
            if col == 'v':
                dm_idx = 2
                break
            if col == '<':
                dm_idx = 3
                break
        if start_x > 0 and start_y > 0:
            break
    return (dm_idx, (start_x, start_y))


def part1(mapped_area: List[List[str]]) -> int:
    direction_mapping = [
        [0, -1],  # top (x, y)
        [1, 0],  # right (x, y)
        [0, 1],  # bottom (x, y)
        [-1, 0],  # left (x, y)
    ]
    dm_idx, (x, y) = get_start(mapped_area)
    assert x == 4 or x == 65
    assert y == 6 or y == 37
    assert dm_idx == 0
    next_x: int = x + direction_mapping[dm_idx][0]
    next_y: int = y + direction_mapping[dm_idx][1]
    visited_position = defaultdict(default_factory=lambda: -1)
    while -1 < next_x < len(mapped_area[0]) and -1 < next_y < len(mapped_area):
        # check if next is a obstacle
        if mapped_area[next_y][next_x] == '#':
            dm_idx = (dm_idx + 1) % len(direction_mapping)
        x += direction_mapping[dm_idx][0]
        y += direction_mapping[dm_idx][1]
        visited_position[(y, x)] = dm_idx
        next_y = y + direction_mapping[dm_idx][1]
        next_x = x + direction_mapping[dm_idx][0]
    return len(visited_position.keys())-1  # empty defaultdict has len 1


def get_visited_cells(mapped_area: List[List[str]]) -> DefaultDict[Tuple[int, int], int]:
    direction_mapping = [
        [0, -1],  # top (x, y)
        [1, 0],  # right (x, y)
        [0, 1],  # bottom (x, y)
        [-1, 0],  # left (x, y)
    ]
    dm_idx, (x, y) = get_start(mapped_area)
    assert x == 4 or x == 65
    assert y == 6 or y == 37
    assert dm_idx == 0
    next_x: int = x + direction_mapping[dm_idx][0]
    next_y: int = y + direction_mapping[dm_idx][1]
    visited_position: DefaultDict[Tuple[int, int],
                                  int] = defaultdict(default_factory=lambda: -1)
    while -1 < next_x < len(mapped_area[0]) and -1 < next_y < len(mapped_area):
        # check if next is a obstacle
        if mapped_area[next_y][next_x] == '#':
            dm_idx = (dm_idx + 1) % len(direction_mapping)
        x += direction_mapping[dm_idx][0]
        y += direction_mapping[dm_idx][1]
        visited_position[(y, x)] = dm_idx
        next_y = y + direction_mapping[dm_idx][1]
        next_x = x + direction_mapping[dm_idx][0]
    return visited_position


def has_loop(mapped_area: List[List[str]]) -> bool:
    direction_mapping = [
        [0, -1],  # top (x, y)
        [1, 0],  # right (x, y)
        [0, 1],  # bottom (x, y)
        [-1, 0],  # left (x, y)
    ]
    dm_idx, (x, y) = get_start(mapped_area)
    visited_position = defaultdict(lambda: -1)
    next_x: int = x + direction_mapping[dm_idx][0]
    next_y: int = y + direction_mapping[dm_idx][1]
    while -1 < next_x < len(mapped_area[0]) and -1 < next_y < len(mapped_area):
        if visited_position[(y, x)] == dm_idx:
            return True
        # check if next is a obstacle
        if mapped_area[next_y][next_x] == '#':
            dm_idx = (dm_idx + 1) % len(direction_mapping)
            next_y = y + direction_mapping[dm_idx][1]
            next_x = x + direction_mapping[dm_idx][0]
            continue
        visited_position[(y, x)] = dm_idx
        x += direction_mapping[dm_idx][0]
        y += direction_mapping[dm_idx][1]
        next_y = y + direction_mapping[dm_idx][1]
        next_x = x + direction_mapping[dm_idx][0]
    return False


def part2(mapped_area: List[List[str]]) -> int:
    count: int = 0
    visited_cells: DefaultDict[Tuple[int, int],
                               int] = get_visited_cells(mapped_area)
    (dm_idx, (start_x, start_y)) = get_start(mapped_area)
    for item in visited_cells.keys():
        try:
            y, x = item
            if x == start_x and y == start_y:
                continue
            if not (0 <= y < len(mapped_area)) and not (0 <= x < len(mapped_area[0])):
                continue
            if mapped_area[y][x] == '.':
                copy_map = copy.deepcopy(mapped_area)
                copy_map[y][x] = '#'
                if has_loop(copy_map):
                    count += 1
        except Exception:
            continue
    return count


if __name__ == "__main__":
    input_file: str = "/home/mohitjangra/learning/advent_of_code_2024/inputs/day06.input"
    test_file: str = "/home/mohitjangra/learning/advent_of_code_2024/tests/day06.test"

    mode = os.sys.argv[1] if len(os.sys.argv) > 1 else "test"
    mapped_area: List[List[str]]
    if mode.strip().lower() == "input":
        mapped_area = read_data(input_file)
        p1_result = part1(copy.deepcopy(mapped_area))
        p2_result = part2(copy.deepcopy(mapped_area))
        assert p1_result == 5409
        assert p2_result == 2022
    elif mode.strip().lower() == "test":
        mapped_area = read_data(test_file)
        p1_result = part1(copy.deepcopy(mapped_area))
        p2_result = part2(copy.deepcopy(mapped_area))
        assert p1_result == 41
        assert p2_result == 6
    else:
        print(f"Usage: {os.sys.argv[0]} [test|input]", file=sys.stderr)
