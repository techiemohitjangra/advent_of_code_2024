import os
import sys
from typing import List, Optional


def read_data(file_name: str) -> str:
    input_data: str = ""
    with open(file_name, "r") as file:
        return file.read().strip(" \r\n\t")
    return input_data


def uncompress_memory(data: str) -> List[str]:
    memory: List[str] = []
    file_id: int = 0
    isFile: bool = True
    for char in data:
        if (isFile):
            memory += ([f"{file_id}"] * int(char))
            isFile = False
            file_id += 1
        else:
            memory += (["."] * int(char))
            isFile = True
    return memory


def calculate_checksum(memory: List[str]) -> int:
    checksum: int = 0
    first_blank = memory.index(".")
    for idx, value in enumerate(memory[:first_blank]):
        checksum += idx * int(value)
    return checksum


def part1(memory: List[str]) -> int:
    start: int = 0
    end: int = len(memory)-1
    while start < end:
        while memory[start] != ".":
            start += 1
        while not memory[end].isdigit():
            end -= 1
        if start >= end:
            break
        temp = memory[start]
        memory[start] = memory[end]
        memory[end] = temp
    return calculate_checksum(memory)


class Sector:
    sector_type: str
    start: int
    len: int
    id: Optional[int]

    def __init__(self, sector_type: str, start: int, len: int, id: int):
        self.sector_type = sector_type
        self.start = start
        self.len = len
        self.id = id

    def __repr__(self) -> str:
        if self.id:
            return f"{self.id}"*self.len
        else:
            return "." * self.len


def get_memory_sectors(data: str) -> List[Sector]:
    memory_sectors: List[Sector] = []
    file_id: int = 0
    isFile: bool = True
    start_idx: int = 0
    for idx, char in enumerate(data):
        if int(char) == 0:
            continue
        if (isFile):
            memory_sectors.append(
                Sector("file", start_idx, int(char), file_id))
            start_idx += int(char)
            isFile = False
            file_id += 1
        else:
            memory_sectors.append(Sector("blank", start_idx, int(char), None))
            start_idx += int(char)
            isFile = True
    return memory_sectors


def part2(memory_sectors: List[str]) -> int:
    start: int = 0
    end: int = len(memory_sectors)-1
    while start < end:
        while memory_sectors[start][0] != ".":
            start += 1
        while not memory_sectors[end][0].isdigit():
            end -= 1
        file_len: int = 1
        file_id = memory_sectors[end]
        temp_idx: int = end
        while memory_sectors[temp_idx] == file_id:
            temp_idx -= 1
            file_len += 1


if __name__ == "__main__":
    input_file: str = "/home/mohitjangra/learning/advent_of_code_2024/inputs/day09.input"
    test_file: str = "/home/mohitjangra/learning/advent_of_code_2024/tests/day09.test"

    mode = os.sys.argv[1] if len(os.sys.argv) > 1 else "test"
    if mode.strip().lower() == "input":
        compressed_memory = read_data(input_file)

        uncompressed = uncompress_memory(compressed_memory)
        pt1_result = part1(uncompressed)
        assert pt1_result == 6330095022244

        memory_sectors = get_memory_sectors(compressed_memory)
        pt2_result = part2(memory_sectors)
        print(pt2_result)
        # assert pt2_result ==
    elif mode.strip().lower() == "test":
        compressed_memory = read_data(test_file)

        uncompressed = uncompress_memory(compressed_memory)
        assert "".join(
            uncompressed) == "00...111...2...333.44.5555.6666.777.888899"
        pt1_result = part1(uncompressed)
        assert pt1_result == 1928

        memory_sectors = get_memory_sectors(compressed_memory)
        for sector in memory_sectors:
            print(sector, end="")
        print()
        # pt2_result = part2(memory_sectors)
        # print(memory_sectors)
        assert pt2_result == 2858
    else:
        print(f"Usage: {os.sys.argv[0]} [test|input]", file=sys.stderr)
