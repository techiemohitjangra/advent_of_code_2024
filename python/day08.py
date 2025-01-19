import os
import sys
from typing import List, DefaultDict,  Set
from collections import defaultdict


def read_data(file_name: str) -> List[str]:
    lines: List[str] = []
    with open(file_name, "r") as file:
        lines = [line.strip() for line in file.readlines()
                 if len(line.strip(" \n\r\t")) != 0]
    return lines


class Position:
    y: int
    x: int

    def __init__(self, y: int = 0, x: int = 0):
        self.y = y
        self.x = x

    def __repr__(self):
        return f"y:{self.y}, x: {self.x}"

    def __eq__(self, other) -> bool:
        return self.x == other.x and self.y == other.y

    def __sub__(self, other):
        new: Position = Position(self.y - other.y, self.x - other.x)
        return new

    def __add__(self, other):
        new: Position = Position(self.y + other.y, self.x + other.x)
        return new

    def __hash__(self):
        return hash(self.x) ^ (hash(self.y) << 1)


def get_antinodes_double_distance(first: Position, second: Position) -> (Position, Position):
    diff = first - second
    if first - diff == second:
        left = second - diff
        right = first + diff
    if second - diff == first:
        left = first - diff
        right = second + diff
    return left, right


def part1(map: List[str]) -> int:
    towers: DefaultDict[str, List[Position]
                        ] = defaultdict(list)
    # get location of all the towers and their frequency
    for y, line in enumerate(map):
        for x, char in enumerate(line):
            if char == '.':
                continue
            else:
                towers[str(char)].append((y, x))

    antinodes: Set[Position] = set()
    # for each frequency, get antinode location for each pair
    for freq, nodes in towers.items():
        for y in range(len(nodes)):
            for x in range(y+1, len(nodes)):
                first, second = get_antinodes_double_distance(
                    Position(nodes[y][0], nodes[y][1]),
                    Position(nodes[x][0], nodes[x][1]))
                if 0 <= first.x < len(map[0]) and 0 <= first.y < len(map) and map[first.y][first.x] != freq:
                    antinodes.add(first)
                if 0 <= second.x < len(map[0]) and 0 <= second.y < len(map) and map[second.y][second.x] != freq:
                    antinodes.add(second)
    return len(antinodes)


def get_antinodes_along_all_nodes(map: List[str], first: Position, second: Position):
    res = set()
    diff = first - second
    while 0 <= first.x - diff.x < len(map[0]) and 0 <= first.y - diff.y < len(map):
        res.add(first - diff)
        first -= diff
    while 0 <= second.x + diff.x < len(map[0]) and 0 <= second.y + diff.y < len(map):
        res.add(second + diff)
        second += diff
    return res


def part2(map: List[str]) -> int:
    towers: DefaultDict[str, List[Position]
                        ] = defaultdict(list)
    # get location of all the towers and their frequency
    for y, line in enumerate(map):
        for x, char in enumerate(line):
            if char == '.':
                continue
            else:
                towers[str(char)].append((y, x))

    antinodes: Set[Position] = set()
    # for each frequency, get antinode location for each pair
    for freq, nodes in towers.items():
        for y in range(len(nodes)):
            for x in range(y+1, len(nodes)):
                positions = get_antinodes_along_all_nodes(map, Position(
                    nodes[y][0], nodes[y][1]), Position(nodes[x][0], nodes[x][1]))
                for pos in positions:
                    if 0 <= pos.x < len(map[0]) and 0 <= pos.y < len(map):
                        antinodes.add(pos)
    return len(antinodes)


if __name__ == "__main__":
    input_file: str = "/home/mohitjangra/learning/advent_of_code_2024/inputs/day08.input"
    test_file: str = "/home/mohitjangra/learning/advent_of_code_2024/tests/day08.test"

    mode = os.sys.argv[1] if len(os.sys.argv) > 1 else "test"
    if mode.strip().lower() == "input":
        map = read_data(input_file)
        pt1_result = part1(map)
        pt2_result = part2(map)
        assert pt1_result == 256
        assert pt2_result == 1005
    elif mode.strip().lower() == "test":
        map = read_data(test_file)
        pt1_result = part1(map)
        pt2_result = part2(map)
        assert pt1_result == 14
        assert pt2_result == 34
    else:
        print(f"Usage: {os.sys.argv[0]} [test|input]", file=sys.stderr)
