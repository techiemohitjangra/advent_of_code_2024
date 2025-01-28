import os
import sys
from typing import List, Optional, Union


class FilePage:
    file_id: int
    file_size: int
    space_after: int

    def __init__(self, file_id: int, file_size: int, space_after: int = 0):
        self.file_id = file_id
        self.file_size = file_size
        self.space_after = space_after

    def __repr__(self) -> str:
        return str(self.file_id) * self.file_size + '.' * self.space_after


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


def calculate_checksum(memory: Union[List[str], List[FilePage]]) -> int:
    checksum: int = 0
    if memory is not None and all(isinstance(file_page, FilePage) for file_page in memory):
        idx: int = 0
        for file_page in memory:
            start_idx = idx
            for i in range(start_idx, start_idx + file_page.file_size):
                checksum += idx * file_page.file_id
                idx += 1
            idx += file_page.space_after
    elif memory is not None and all(isinstance(file_page, str) for file_page in memory):
        first_blank = memory.index(".")
        for idx, value in enumerate(memory[:first_blank]):
            checksum += idx * int(value)
    else:
        raise Exception("InvalidType")
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


def construct_file_pages(data: str) -> List[FilePage]:
    file_pages: List[FilePage] = []
    file_id: int = 0
    for idx, char in enumerate(data):
        file: FilePage = None
        if idx % 2 == 0:
            file = FilePage(file_id, int(char))
            file_pages.append(file)
            file_id += 1
        else:
            file_pages[-1].space_after = int(char)
    return file_pages


def part2(file_pages: List[FilePage]) -> int:
    end = len(file_pages) - 1
    while end > 0:
        start = 0
        while file_pages[start].space_after < file_pages[end].file_size and start < end:
            start += 1
        if start >= end:
            end -= 1
            continue
        end_page = file_pages[end]
        file_pages[end-1].space_after += file_pages[end].file_size + \
            file_pages[end].space_after
        end_page.space_after = file_pages[start].space_after - \
            end_page.file_size
        file_pages.remove(file_pages[end])
        file_pages[start].space_after = 0
        file_pages.insert(start+1, end_page)

    return calculate_checksum(file_pages)


if __name__ == "__main__":
    input_file: str = "/home/mohitjangra/learning/advent_of_code_2024/inputs/day09.input"
    test_file: str = "/home/mohitjangra/learning/advent_of_code_2024/tests/day09.test"

    mode = os.sys.argv[1] if len(os.sys.argv) > 1 else "test"
    if mode.strip().lower() == "input":
        compressed_memory = read_data(input_file)

        uncompressed = uncompress_memory(compressed_memory)
        pt1_result = part1(uncompressed)
        assert pt1_result == 6330095022244

        file_pages: List[FilePage] = construct_file_pages(compressed_memory)
        pt2_result = part2(file_pages)
        assert pt2_result == 6359491814941
    elif mode.strip().lower() == "test":
        compressed_memory = read_data(test_file)

        uncompressed = uncompress_memory(compressed_memory)
        assert "".join(
            uncompressed) == "00...111...2...333.44.5555.6666.777.888899"
        pt1_result = part1(uncompressed)
        assert pt1_result == 1928

        file_pages: List[FilePage] = construct_file_pages(compressed_memory)
        assert "".join(
            [str(page) for page in file_pages]) == "00...111...2...333.44.5555.6666.777.888899"
        pt2_result = part2(file_pages)
        assert pt2_result == 2858
    else:
        print(f"Usage: {os.sys.argv[0]} [test|input]", file=sys.stderr)
