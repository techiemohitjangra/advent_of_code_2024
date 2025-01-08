import os
from typing import List, DefaultDict
from collections import defaultdict


class TreeNode:
    value: int
    multipliedNode = None
    addedNode = None
    result: int = 0

    def __init__(self, value: int):
        value: int


def read_data(file_name: str) -> DefaultDict[int, List[int]]:
    lines: List[int] = []
    with open(file_name, "r") as file:
        lines = [line.strip() for line in file.readlines()]

    calibrations: DefaultDict[int, List[int]] = defaultdict(list)
    for line in lines:
        values = line.split(':')
        calibrations[int(values[0])] = [int(value)
                                        for value in values[1].strip().split()]

    return calibrations


def construct_tree(root: TreeNode, items: List[int]) -> TreeNode:
    if root is None and len(items) > 0:
        root = TreeNode(items[0])
        items.pop(0)
        construct_tree(root.addedNode, items)
        construct_tree(root.multipliedNode, items)
    return root


def print_tree(root: TreeNode, spacer: str):
    if root is not None:
        print(root.value)
        print_tree(root.addedNode, spacer + "    ")
        print_tree(root.multipliedNode, spacer + "    ")


def part1(calibrations: DefaultDict[int, List[int]]) -> int:
    pass


def part2(calibrations: DefaultDict[int, List[int]]) -> int:
    pass


if __name__ == "__main__":
    input_file: str = "../inputs/day07.input"
    test_file: str = "../tests/day07.test"

    mode = os.sys.argv[1] if len(os.sys.argv) > 1 else "test"
    calibrations: DefaultDict[int, List[int]]
    if mode.strip().lower() == "input":
        calibrations = read_data(input_file)
    elif mode.strip().lower() == "test":
        calibrations = read_data(test_file)

    key = [key for key in calibrations.keys()][0]
    root = construct_tree(None, calibrations[key])
    print_tree(root, "")

    # p1_result = part1(calibrations)
    # p2_result = part2(calibrations)
    # print("Solution Part1: ", p1_result)
    # print("Solution Part2: ", p2_result)
