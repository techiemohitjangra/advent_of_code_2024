import re


def part1(fileName: str):
    data: str
    with open(fileName, "r") as file:
        data = file.read().strip()
    matches = re.findall("mul\\((\\d{1,3}),\\.*(\\d{1,3})\\)", data)
    res: int = 0
    for match in matches:
        res += int(match[0]) * int(match[1])
    return res


def part2_regex(fileName: str):
    data: str
    with open(fileName, "r") as file:
        data = file.read().strip()
    newdata = re.sub(r"don't\(\).*?(do\(\))", r'', data, flags=re.DOTALL)
    matches = re.findall("mul\\((\\d{1,3}),\\.*?(\\d{1,3})\\)", newdata)
    res: int = 0
    for match in matches:
        res += int(match[0]) * int(match[1])
    return res


if __name__ == "__main__":
    inputFile: str = "./day3.input"
    test1: str = "./day3.test1"
    test2: str = "./day3.test2"
    p1_result = part1(inputFile)
    p2_result = part2_regex(inputFile)
    print(p1_result)
    print(p2_result)
    # with open("day3.result", "r") as file:
    #     if file.read() != 0:
    #         exit(0)

    with open("day3.result", "w+") as file:
        bytes_read = file.read()
        if str(bytes_read) == "":
            result = [str(p1_result)+"\n", str(p2_result)+"\n"]
            file.writelines(result)
