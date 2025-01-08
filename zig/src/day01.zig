const std = @import("std");
const Allocator = std.mem.Allocator;
const expect = std.testing.expect;

fn Pair(comptime T1: type, comptime T2: type) type {
    return struct {
        first: T1,
        second: T2,
    };
}

fn read_data(allocator: Allocator, file_name: []const u8) ![]u8 {
    const file = try std.fs.cwd().openFile(file_name, std.fs.File.OpenFlags{
        .mode = .read_only,
    });
    defer file.close();
    const file_stats = try file.stat();

    const buffer: []u8 = try allocator.alloc(u8, file_stats.size);
    const data_read = try file.read(buffer);

    std.debug.assert(data_read == file_stats.size);

    return buffer;
}

fn parse_data(allocator: Allocator, buffer: []u8) !Pair([]i32, []i32) {
    var splits = std.mem.split(u8, std.mem.trim(u8, buffer, " \n\t\r"), "\n");
    var line_count: usize = 0;
    while (splits.next()) |_| : (line_count += 1) {}
    splits.reset();

    const left = try allocator.alloc(i32, line_count);
    const right = try allocator.alloc(i32, line_count);

    var idx: usize = 0;
    while (splits.next()) |line| : (idx += 1) {
        var nums = std.mem.split(u8, std.mem.trim(u8, line, " \n\t\r"), "   ");
        const left_num = try std.fmt.parseInt(i32, nums.next() orelse "", 10);
        const right_num = try std.fmt.parseInt(i32, nums.next() orelse "", 10);
        left[idx] = left_num;
        right[idx] = right_num;
    }

    return Pair([]i32, []i32){
        .first = left,
        .second = right,
    };
}

fn part1(lists: Pair([]i32, []i32)) u32 {
    var totalDistance: u32 = 0;
    for (0..lists.second.len) |index| {
        totalDistance += @abs(lists.second[index] - lists.first[index]);
    }
    return totalDistance;
}

fn part2(allocator: Allocator, lists: Pair([]i32, []i32)) !i32 {
    var numCounts = std.AutoHashMap(i32, i32).init(allocator);
    defer numCounts.deinit();

    for (lists.second) |item| {
        if (numCounts.get(item)) |count| {
            try numCounts.put(item, count + 1);
        } else {
            try numCounts.put(item, 1);
        }
    }
    var totalSimilarity: i32 = 0;
    for (lists.first) |num| {
        totalSimilarity += (numCounts.get(num) orelse 0) * num;
    }
    return totalSimilarity;
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const data: []u8 = try read_data(allocator, "../../inputs/day01.input");
    defer allocator.free(data);

    const list_pair: Pair([]i32, []i32) = try parse_data(allocator, data);
    std.mem.sort(i32, list_pair.first, {}, std.sort.asc(i32));
    std.mem.sort(i32, list_pair.second, {}, std.sort.asc(i32));

    const totalDistance = part1(list_pair);
    const totalSimilarity = try part2(allocator, list_pair);

    std.debug.assert(totalDistance == 1258579);
    std.debug.assert(totalSimilarity == 23981443);
}

test "day1 test data" {
    const allocator = std.testing.allocator;

    const data: []u8 = try read_data(allocator, "../../tests/day01.test");
    defer allocator.free(data);

    const list_pair: Pair([]i32, []i32) = try parse_data(allocator, data);
    defer {
        allocator.free(list_pair.first);
        allocator.free(list_pair.second);
    }
    std.mem.sort(i32, list_pair.first, {}, std.sort.asc(i32));
    std.mem.sort(i32, list_pair.second, {}, std.sort.asc(i32));

    const totalDistance = part1(list_pair);
    const totalSimilarity = try part2(allocator, list_pair);

    try std.testing.expect(totalDistance == 11);
    try std.testing.expect(totalSimilarity == 31);
}
