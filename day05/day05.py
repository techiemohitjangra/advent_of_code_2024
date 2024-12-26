import os
from typing import List, DefaultDict, Tuple
from collections import defaultdict


def read_data(file_name: str) -> Tuple[DefaultDict[int, List[int]], List[List[int]]]:
    lines: List[str]
    rules: DefaultDict[int, List[int]] = defaultdict(list)
    updates: List[[List[int]]] = []
    with open(file_name, "r") as file:
        lines = [line.strip() for line in file.readlines()]

    areRules: bool = True
    for line in lines:
        if len(line.strip()) == 0:
            areRules = False
            continue
        if areRules:
            key, value = [int(num.strip()) for num in line.strip().split("|")]
            rules[value].append(key)
        else:
            updates.append([int(num.strip())
                           for num in line.strip().split(",")])

    return (rules, updates)


def is_valid_update(update: List[int], rules: DefaultDict[int, List[int]]) -> bool:
    for idx, page in enumerate(update):
        for item in rules[page]:
            if item in update[idx:]:
                return False
    return True


def part1(updates: List[List[int]], rules: DefaultDict[int, List[int]]) -> int:
    middle_total: int = 0
    for update in updates:
        isValid: bool = is_valid_update(update, rules)
        if isValid:
            middle_total += update[len(update)//2]
    return middle_total


def fix_update(update: List[int], rules: DefaultDict[int, List[int]]) -> List[int]:
    i = 0
    j = 0
    while i < len(update):
        j = i + 1
        while j < len(update):
            if update[j] in rules[update[i]]:
                temp = update[i]
                update[i] = update[j]
                update[j] = temp
            else:
                j += 1
        i += 1
    return update


def part2(updates: List[List[int]], rules: DefaultDict[int, List[int]]) -> int:
    middle_total: int = 0
    for update in updates:
        isValid: bool = is_valid_update(update, rules)
        if not isValid:
            res = fix_update(update.copy(), rules)
            print(update, res)
            middle_total += res[len(res)//2]
    return middle_total


if __name__ == "__main__":
    input_file: str = "./day05.input"
    test_file: str = "./day05.test"

    mode = os.sys.argv[1] if len(os.sys.argv) > 1 else "test"
    updates: List[List[int]]
    rules: DefaultDict[int, List[int]]
    if mode.strip().lower() == "input":
        rules, update = read_data(input_file)
    else:
        rules, update = read_data(test_file)

    p1_result = part1(update, rules)
    p2_result = part2(update, rules)
    print("Solution Part1: ", p1_result)
    print("Solution Part2: ", p2_result)
