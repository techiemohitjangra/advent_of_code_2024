const std = @import("std");
const assert = std.debug.assert;
const expect = std.testing.expect;

pub fn read_data(allocator: *std.mem.Allocator, fileName: []const u8) ![]const u8 {
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

pub fn parse_levels(allocator: *std.mem.Allocator, data: []const u8) ![]const []const u32 {
    var lines = std.mem.split(u8, data, "\n");
    var line_count: usize = 0;
    while (lines.next()) |line| {
        if (line.len == 0) continue;
        line_count += 1;
    }
    lines.reset();

    const level_records: [][]u32 = try allocator.alloc([]u32, line_count);

    var lineIdx: usize = 0;
    while (lines.next()) |line| : (lineIdx += 1) {
        if (line.len == 0) continue;
        var nums = std.mem.split(u8, line, " ");
        var num_count: usize = 0;
        while (nums.next()) |num| {
            if (num.len == 0) continue;
            num_count += 1;
        }
        nums.reset();
        const levels: []u32 = try allocator.alloc(u32, num_count);
        var numIdx: usize = 0;
        while (nums.next()) |num| : (numIdx += 1) {
            if (num.len == 0) continue;
            const number = std.fmt.parseInt(u32, num, 10) catch |err| {
                std.debug.print("Warning: Invalid integer '{s}' skipped. Error: {s}\n", .{ num, @errorName(err) });
                return err;
            };
            levels[numIdx] = number;
        }
        level_records[lineIdx] = levels;
    }
    return level_records;
}

pub fn part1(level_records: []const []const u32) usize {
    var safe_count: usize = 0;
    outer: for (level_records) |levels| {
        var left: usize = 0;
        var right: usize = 1;
        if (levels[left] == levels[right]) continue :outer;
        const ascending: bool = if (levels[0] > levels[1]) false else true;
        while (right < levels.len) {
            if (ascending) {
                const diff: usize = levels[right] - levels[left];
                if (levels[right] > levels[left] and 1 <= diff and diff <= 3) {
                    left += 1;
                    right += 1;
                } else {
                    continue :outer;
                }
            } else {
                const diff: usize = levels[left] - levels[right];
                if (levels[left] > levels[right] and 1 <= diff and diff <= 3) {
                    left += 1;
                    right += 1;
                } else {
                    continue :outer;
                }
            }
        }
        safe_count += 1;
    }
    return safe_count;
}

pub fn part2(level_records: []const []const u32) usize {
    _ = level_records;
    const res: usize = 0;
    return res;
}

pub fn main() !void {
    var allocator = std.heap.page_allocator;
    const inputFile: []const u8 = "day02.input";

    const data: []const u8 = try read_data(&allocator, inputFile);
    defer allocator.free(data);

    const level_records: []const []const u32 = try parse_levels(&allocator, data);
    defer {
        for (level_records) |levels| {
            allocator.free(levels);
        }
        allocator.free(level_records);
    }

    const solutionPart1 = part1(level_records);
    const solutionPart2 = part2(level_records);
    std.debug.print("Solution Part1: {d}\n", .{solutionPart1});
    std.debug.print("Solution Part2: {d}\n", .{solutionPart2});
}

test {
    var test_allocator = std.testing.allocator;
    const testInput: []const u8 = "day02.test";

    const data: []const u8 = try read_data(&test_allocator, testInput);
    defer test_allocator.free(data);

    const level_records: []const []const u32 = try parse_levels(&test_allocator, data);
    defer {
        for (level_records) |levels| {
            test_allocator.free(levels);
        }
        test_allocator.free(level_records);
    }
    const solutionPart1 = part1(level_records);
    try expect(solutionPart1 == 2);
}
