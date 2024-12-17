from typing import List


def part1(fileName: str):
    records: List[List[int]] = []
    with open(fileName, "r") as file:
        lines: List[str] = file.readlines()
        for line in lines:
            record: List[int] = [int(level.strip())
                                 for level in line.strip().split()]
            records.append(record)

    increasing: bool = False
    safe_count: int = 0
    for record in records:
        left = 0
        right = 1
        if record[left] < record[right]:
            increasing = True
        elif record[left] > record[right]:
            increasing = False
        else:
            continue

        is_unsafe: bool = False
        if increasing:
            while right < len(record):
                if record[left] < record[right] and 1 <= record[right] - record[left] <= 3:
                    left += 1
                    right += 1
                else:
                    is_unsafe = True
                    break
        else:
            while right < len(record):
                if record[left] > record[right] and 1 <= record[left] - record[right] <= 3:
                    left += 1
                    right += 1
                else:
                    is_unsafe = True
                    break

        if not is_unsafe:
            safe_count += 1
            is_unsafe = False
    print("safe_count: ", safe_count)


def part2(fileName: str):
    records: List[List[int]] = []
    with open(fileName, "r") as file:
        lines: List[str] = file.readlines()
        for line in lines:
            record: List[int] = [int(level.strip())
                                 for level in line.strip().split()]
            records.append(record)

    increasing: bool = False
    safe_count: int = 0
    for record in records:
        left = 0
        right = 1
        if record[left] < record[right]:
            increasing = True
        elif record[left] > record[right]:
            increasing = False
        else:
            continue

        is_unsafe: bool = False
        tolerated: bool = False
        if increasing:
            while right < len(record):
                if record[left] < record[right] and 1 <= record[right] - record[left] <= 3:
                    left += 1
                    right += 1
                else:
                    if not tolerated and record[left] >= record[right]:
                        record.pop(right)
                        tolerated = True
                    elif not tolerated and 1 > record[right] - record[left] > 3:
                        if left - 1 > 0 and record[left]-record[left-1] < record[right]-record[left]:
                            record.pop(left)
                        else:
                            record.pop(right)
                        tolerated = True
                    else:
                        is_unsafe = True
                        break
        else:
            while right < len(record):
                if record[left] > record[right] and 1 <= record[left] - record[right] <= 3:
                    left += 1
                    right += 1
                else:
                    if not tolerated and record[left] <= record[right]:
                        record.pop(right)
                        tolerated = True
                    elif not tolerated and 1 > record[left] - record[right] > 3:
                        if left - 1 > 0 and record[left]-record[left-1] > record[right]-record[left]:
                            record.pop(left)
                        else:
                            record.pop(right)
                        tolerated = True
                    else:
                        is_unsafe = True
                        break

        if not is_unsafe:
            safe_count += 1
            is_unsafe = False
    print("safe_count: ", safe_count)


if __name__ == "__main__":
    fileName: str = "day02.input"
    # fileName: str = "day02.test"
    part1(fileName)
    # TODO: part2 wrong answer
    part2(fileName)
