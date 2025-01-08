const std = @import("std");
const assert = std.debug.assert;
const expect = std.testing.expect;

fn read_data(allocator: *std.mem.Allocator, fileName: []const u8) ![]u8 {
    var file: std.fs.File = try std.fs.cwd().openFile(
        fileName,
        std.fs.File.OpenFlags{
            .mode = .read_only,
        },
    );
    defer file.close;

    const file_stats = try file.stat();
    const buffer: []u8 = try allocator.alloc(u8, file_stats.size);

    const readData = try file.readAll(buffer);
    assert(readData == file_stats.size);
    if (readData != file_stats.size) {
        std.debug.print("failed to read all data\n", .{});
        std.process.exit(1);
    }
    return buffer;
}

fn parse_data(allocator: *std.mem.Allocator, data: []u8) ![][]const u8 {
    var line_count: usize = 0;
    var lines_strings = std.mem.split(u8, data, "\n");
    while (lines_strings.next()) |line| {
        const tempLine = std.mem.trim(u8, line, " \n\t");
        if (tempLine.len > 0) {
            line_count += 1;
        }
    }
    lines_strings.reset();
    var lines: [][]const u8 = try allocator.alloc([]u8, line_count);
    var idx: usize = 0;
    while (lines_strings.next()) |line| : (idx += 1) {
        if (line.len > 0) {
            lines[idx] = line;
        }
    }
    return lines;
}

fn part1(input: [][]const u8) i32 {
    var count: i32 = 0;
    var diff: usize = 0;
    for (input, 0..) |line, y| {
        for (line, 0..) |char, x| {
            if (char == 'X') {
                const match: *const [4:0]u8 = "XMAS";
                const reverse: *const [4:0]u8 = "SAMX";

                // check right
                if (x + (match.len - 1) < line.len and std.mem.eql(u8, line[x .. x + match.len], match)) {
                    count += 1;
                }

                // check left
                if (x >= (reverse.len - 1) and std.mem.eql(u8, line[x - (reverse.len - 1) .. x + 1], reverse)) {
                    count += 1;
                }

                diff = 0;
                // check top
                while (y >= (match.len - 1) and diff < match.len) {
                    if (input[y - diff][x] != match[diff]) {
                        break;
                    }
                    diff += 1;
                    if (diff == 4) {
                        count += 1;
                        break;
                    }
                }

                diff = 0;
                // check bottom
                while (y + (match.len - 1) < input.len and diff < match.len) {
                    if (input[y + diff][x] != match[diff]) {
                        break;
                    }
                    diff += 1;
                    if (diff == 4) {
                        count += 1;
                        break;
                    }
                }

                diff = 0;
                // check top right
                while (y >= (match.len - 1) and x + (match.len - 1) < line.len and diff < match.len) {
                    if (input[y - diff][x + diff] != match[diff]) {
                        break;
                    }
                    diff += 1;
                    if (diff == 4) {
                        count += 1;
                        break;
                    }
                }

                diff = 0;
                // check top left
                while (y >= (match.len - 1) and x >= (match.len - 1) and diff < match.len) {
                    if (input[y - diff][x - diff] != match[diff]) {
                        break;
                    }
                    diff += 1;
                    if (diff == 4) {
                        count += 1;
                        break;
                    }
                }

                diff = 0;
                // check bottom left
                while (y + (match.len - 1) < input.len and x >= (match.len - 1) and diff < match.len) {
                    if (input[y + diff][x - diff] != match[diff]) {
                        break;
                    }
                    diff += 1;
                    if (diff == 4) {
                        count += 1;
                        break;
                    }
                }

                diff = 0;
                // check bottom right
                while (y + (match.len - 1) < input.len and x + (match.len - 1) < line.len and diff < match.len) {
                    if (input[y + diff][x + diff] != match[diff]) {
                        break;
                    }
                    diff += 1;
                    if (diff == 4) {
                        count += 1;
                        break;
                    }
                }
            }
        }
    }
    return count;
}

fn part2(input: [][]const u8) i32 {
    var count: i32 = 0;
    const patterns: [4][4]i32 = [4][4]i32{
        // M{x, y},S{x, y}
        .{ -1, -1, 1, 1 }, // top_left-to-bottom_right
        .{ -1, 1, 1, -1 }, // bottom_left-to-top_right
        .{ 1, -1, -1, 1 }, // top_right-to-bottom_left
        .{ 1, 1, -1, -1 }, // bottom_right-to-top_left
    };
    for (input, 0..) |line, y| {
        for (line, 0..) |char, x| {
            if (char == 'A' and y > 0 and x > 0 and y < (input.len - 1) and x < (line.len - 1)) {
                var tempCount: usize = 0;
                for (patterns) |item| {
                    if (input[@as(usize, @intCast(@as(i32, @intCast(y)) + item[1]))][@as(usize, @intCast(@as(i32, @intCast(x)) + item[0]))] == 'M' and
                        input[@as(usize, @intCast(@as(i32, @intCast(y)) + item[3]))][@as(usize, @intCast(@as(i32, @intCast(x)) + item[2]))] == 'S')
                    {
                        tempCount += 1;
                    }
                }
                if (tempCount == 2) {
                    count += 1;
                    // std.debug.print("y: {d} x: {d}\n", .{ y, x });
                }
            }
        }
    }
    return count;
}

pub fn main() !void {
    var allocator = std.heap.page_allocator;
    const buffer: []u8 = try read_data(&allocator, "day04.input");
    defer allocator.free(buffer);

    const input: [][]const u8 = try parse_data(&allocator, buffer);
    defer allocator.free(input);

    const part1Solution: i32 = part1(input);
    assert(part1Solution == 2496);
    std.debug.print("Part1: {d}\n", .{part1Solution});

    const part2Solution: i32 = part2(input);
    assert(part1Solution == 1967);
    std.debug.print("Part2: {d}\n", .{part2Solution});
}

test "part1" {
    var test_allocator = std.testing.allocator;
    const buffer: []u8 = try read_data(&test_allocator, "day04.test");
    defer test_allocator.free(buffer);
    const input: [][]const u8 = try parse_data(&test_allocator, buffer);
    defer test_allocator.free(input);

    const part1Solution: i32 = part1(input);
    std.debug.print("Part1: {d}\n", .{part1Solution});
    try expect(part1Solution == 18);
}

test "part2" {
    var test_allocator = std.testing.allocator;
    const buffer: []u8 = try read_data(&test_allocator, "day04.test");
    defer test_allocator.free(buffer);
    const input: [][]const u8 = try parse_data(&test_allocator, buffer);
    defer test_allocator.free(input);

    const part2Solution: i32 = part2(input);
    try expect(part2Solution == 1967);
}
