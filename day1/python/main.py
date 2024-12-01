def run():
    # fileName = "../test.txt"
    fileName = "../input.txt"
    with open(fileName, "r") as inputFile:
        lines = inputFile.readlines()
        left = []
        right = []
        for line in lines:
            nums = [word.strip() for word in line.split()]
            left.append(int(nums[0]))
            right.append(int(nums[1]))
        left = sorted(left)
        right = sorted(right)
        total_distance = 0
        num_count = {}
        for i in range(len(left)):
            total_distance += abs(right[i]-left[i])
            if (num_count.get(right[i])):
                num_count[right[i]] += 1
            else:
                num_count[right[i]] = 1

        print("Part 1")
        print(f"Total distance: {total_distance}")

        total_similarity = 0
        for num in left:
            if (num_count.get(num)):
                total_similarity += num * num_count.get(num)

        print("Part 2")
        print(f"Total similarity: {total_similarity}")


if __name__ == "__main__":
    run()
