from typing import List
import copy
import os


def read_data(file_name: str) -> List[List[int]]:
    records: List[List[int]] = []
    with open(file_name, "r") as file:
        lines: List[str] = file.readlines()
        for line in lines:
            record: List[int] = [int(level.strip())
                                 for level in line.strip().split()]
            records.append(record)
    return records


def is_safe(record: List[int]) -> bool:
    if len(record) < 2:
        return False
    ascending: bool = None
    if record[0] == record[1]:
        return False
    elif record[0] < record[1]:
        ascending = True
    else:
        ascending = False

    left: int = 0
    right: int = 1
    while right < len(record):
        if record[left] == record[right]:
            return False
        if not (1 <= abs(record[right] - record[left]) <= 3):
            # print("increasing or decreasing too rapidly", file=sys.stderr)
            return False
        if ascending:
            if record[left] > record[right]:
                # print("not strictly increasing or ", file=sys.stderr)
                return False
        else:
            if record[left] < record[right]:
                # print("not strictly decreasing or ", file=sys.stderr)
                return False
        left += 1
        right += 1
    return True


def part1(records: List[List[int]]) -> int:
    safe_count: int = 0
    for record in records:
        if is_safe(record):
            safe_count += 1
    return safe_count


def can_make_safe(record: List[int]) -> bool:
    for idx, item in enumerate(record):
        # using list.remove causes issue here if there are duplicate item in
        # the record, when trying to remove the second instance of the
        # duplicate item, list.remove removes the first instance not the second
        temp = record[:idx] + record[idx+1:]
        if is_safe(temp):
            return True
    return False


def part2(records: List[List[int]]) -> int:
    safe_count: int = 0
    for record in records:
        if is_safe(record):
            safe_count += 1
        else:
            if can_make_safe(record):
                safe_count += 1
    return safe_count


if __name__ == "__main__":
    input_file: str = "/home/mohitjangra/learning/advent_of_code_2024/inputs/day02.input"
    test_file: str = "/home/mohitjangra/learning/advent_of_code_2024/tests/day02.test"

    mode = os.sys.argv[1] if len(os.sys.argv) > 1 else "test"
    records: List[List[int]]
    if mode.strip().lower() == "input":
        records = read_data(input_file)
        p1_result = part1(records)
        p2_result = part2(records)
        assert p1_result == 606
        assert p2_result == 644
    elif mode.strip().lower() == "test":
        records = read_data(test_file)
        p1_result = part1(records)
        p2_result = part2(records)
        assert p1_result == 2
        assert p2_result == 4
