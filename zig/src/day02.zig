const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const expect = std.testing.expect;

fn read_data(allocator: Allocator, fileName: []const u8) ![]u8 {
    const file: std.fs.File = std.fs.cwd().openFile(
        fileName,
        std.fs.File.OpenFlags{ .mode = .read_only },
    ) catch |err| {
        std.debug.print("Failed to open file '{s}': {s}\n", .{ fileName, @errorName(err) });
        return err;
    };
    defer file.close();
    const fileStats: std.fs.File.Stat = try file.stat();

    const buffer: []u8 = try allocator.alloc(u8, fileStats.size);

    const dataRead: usize = try file.readAll(buffer);
    std.debug.assert(dataRead == fileStats.size);
    return buffer;
}

fn parse_levels(allocator: Allocator, data: []u8) ![][]i32 {
    var lines = std.mem.split(u8, std.mem.trim(u8, data, " \r\n\t"), "\n");
    var line_count: usize = 0;
    while (lines.next()) |_| : (line_count += 1) {}
    lines.reset();

    const level_records: [][]i32 = try allocator.alloc([]i32, line_count);

    var lineIdx: usize = 0;
    while (lines.next()) |line| : (lineIdx += 1) {
        var nums = std.mem.split(u8, std.mem.trim(u8, line, " /r/n/t"), " ");
        var num_count: usize = 0;
        while (nums.next()) |_| : (num_count += 1) {}
        nums.reset();
        const levels: []i32 = try allocator.alloc(i32, num_count);
        var numIdx: usize = 0;
        while (nums.next()) |num_str| : (numIdx += 1) {
            const number = std.fmt.parseInt(i32, std.mem.trim(u8, num_str, " /r/n/t"), 10) catch |err| {
                std.debug.print("Warning: Invalid integer '{s}' skipped. Error: {s}\n", .{ num_str, @errorName(err) });
                return err;
            };
            levels[numIdx] = number;
        }
        level_records[lineIdx] = levels;
    }
    return level_records;
}

fn is_safe(record: []i32) bool {
    var ascending: bool = undefined;
    if (record[0] == record[1]) {
        return false;
    } else if (record[0] < record[1]) {
        ascending = true;
    } else {
        ascending = false;
    }

    var left: usize = 0;
    var right: usize = 1;
    while (right < record.len) {
        if (record[left] == record[right] or @abs(record[left] - record[right]) > 3) {
            return false;
        }
        if (ascending) {
            if (record[left] > record[right]) {
                return false;
            }
        } else {
            if (record[left] < record[right]) {
                return false;
            }
        }
        left += 1;
        right += 1;
    }
    return true;
}

fn part1(level_records: [][]i32) usize {
    var safe_count: usize = 0;
    for (level_records) |record| {
        if (is_safe(record)) {
            safe_count += 1;
        }
    }
    return safe_count;
}

fn can_make_safe(allocator: Allocator, record: []i32) !bool {
    for (0..record.len) |i| {
        var array_list = std.ArrayList(i32).init(allocator);
        defer array_list.deinit();
        try array_list.appendSlice(record);
        _ = array_list.orderedRemove(i);
        if (is_safe(array_list.items)) {
            return true;
        }
    }

    return false;
}

fn part2(allocator: Allocator, level_records: [][]i32) !usize {
    var safe_count: usize = 0;
    for (level_records) |record| {
        if (is_safe(record)) {
            safe_count += 1;
        } else {
            if (try can_make_safe(allocator, record)) {
                safe_count += 1;
            }
        }
    }
    return safe_count;
}

pub fn main() !void {
    var allocator = std.heap.page_allocator;
    const inputFile: []const u8 = "../../inputs/day02.input";

    const data: []u8 = try read_data(allocator, inputFile);
    defer allocator.free(data);

    const level_records: [][]i32 = try parse_levels(allocator, data);
    defer {
        for (level_records) |levels| {
            allocator.free(levels);
        }
        allocator.free(level_records);
    }

    const pt1_result = part1(level_records);
    std.debug.assert(pt1_result == 606);
    const pt2_result = try part2(allocator, level_records);
    std.debug.assert(pt2_result == 644);
}

test {
    var allocator = std.testing.allocator;
    const testInput: []const u8 = "../../tests/day02.test";

    const data: []u8 = try read_data(allocator, testInput);
    defer allocator.free(data);

    const level_records: [][]i32 = try parse_levels(allocator, data);
    defer {
        for (level_records) |levels| {
            allocator.free(levels);
        }
        allocator.free(level_records);
    }

    const pt1_result = part1(level_records);
    try expect(pt1_result == 2);
    const pt2_result = try part2(allocator, level_records);
    try expect(pt2_result == 4);
}
