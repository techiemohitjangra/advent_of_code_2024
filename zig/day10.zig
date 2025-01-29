const std = @import("std");
const Allocator = std.mem.Allocator;

const Position = struct {
    y: usize,
    x: usize,
};

fn read_data(allocator: Allocator, filename: []const u8) ![]const u8 {
    const file = try std.fs.openFileAbsolute(filename, .{ .mode = .read_only });
    defer file.close();
    const file_stats = try file.stat();
    const buffer: []u8 = try allocator.alloc(u8, file_stats.size);
    const data_read: usize = try file.readAll(buffer);
    std.debug.assert(data_read == file_stats.size);
    return buffer;
}

fn parse_data(allocator: Allocator, data: []const u8) ![][]const u4 {
    var lines_splits = std.mem.split(u8, std.mem.trim(u8, data, " \r\n\t"), "\n");
    var row_count: usize = 0;
    while (lines_splits.next()) |_| : (row_count += 1) {}
    lines_splits.reset();
    const rows = try allocator.alloc([]u4, row_count);
    var row_idx: usize = 0;
    while (lines_splits.next()) |line| : (row_idx += 1) {
        const trimed_line = std.mem.trim(u8, line, " \r\n\t");
        const row = try allocator.alloc(u4, trimed_line.len);
        for (trimed_line, 0..) |char, idx| {
            row[idx] = switch (char) {
                '0' => 0,
                '1' => 1,
                '2' => 2,
                '3' => 3,
                '4' => 4,
                '5' => 5,
                '6' => 6,
                '7' => 7,
                '8' => 8,
                '9' => 9,
                else => return error.InvalidCharacter,
            };
        }
        rows[row_idx] = row;
    }
    return rows;
}

fn traverse_for_score(map: [][]const u4, y: usize, x: usize, destinations: *std.hash_map.HashMap(Position, void, std.hash_map.AutoContext(Position), 80)) !void {
    if (map[y][x] == 9) {
        try destinations.put(Position{ .y = y, .x = x }, {});
        return;
    }
    // up
    if (y > 0 and map[y - 1][x] == map[y][x] + 1) {
        try traverse_for_score(map, y - 1, x, destinations);
    }
    // right
    if (x < map[y].len - 1 and map[y][x + 1] == map[y][x] + 1) {
        try traverse_for_score(map, y, x + 1, destinations);
    }
    // down
    if (y < map.len - 1 and map[y + 1][x] == map[y][x] + 1) {
        try traverse_for_score(map, y + 1, x, destinations);
    }
    // left
    if (x > 0 and map[y][x - 1] == map[y][x] + 1) {
        try traverse_for_score(map, y, x - 1, destinations);
    }
}

fn get_score(allocator: Allocator, map: [][]const u4, y: usize, x: usize) !usize {
    var destinations = std.hash_map.HashMap(Position, void, std.hash_map.AutoContext(Position), 80).init(allocator);
    try traverse_for_score(map, y, x, &destinations);
    return destinations.count();
}

fn part1(allocator: Allocator, map: [][]const u4) !usize {
    var total_score: usize = 0;
    for (map, 0..) |row, y| {
        for (row, 0..) |cell, x| {
            if (cell == 0) {
                total_score += try get_score(allocator, map, y, x);
            }
        }
    }
    return total_score;
}

fn traverse_for_rating(map: [][]const u4, y: usize, x: usize, destinations: *std.ArrayList(Position)) !void {
    if (map[y][x] == 9) {
        try destinations.append(Position{ .y = y, .x = x });
        return;
    }
    // up
    if (y > 0 and map[y - 1][x] == map[y][x] + 1) {
        try traverse_for_rating(map, y - 1, x, destinations);
    }
    // right
    if (x < map[y].len - 1 and map[y][x + 1] == map[y][x] + 1) {
        try traverse_for_rating(map, y, x + 1, destinations);
    }
    // down
    if (y < map.len - 1 and map[y + 1][x] == map[y][x] + 1) {
        try traverse_for_rating(map, y + 1, x, destinations);
    }
    // left
    if (x > 0 and map[y][x - 1] == map[y][x] + 1) {
        try traverse_for_rating(map, y, x - 1, destinations);
    }
}

fn get_rating(allocator: Allocator, map: [][]const u4, y: usize, x: usize) !usize {
    var destinations = std.ArrayList(Position).init(allocator);
    try traverse_for_rating(map, y, x, &destinations);
    return destinations.items.len;
}

fn part2(allocator: Allocator, map: [][]const u4) !usize {
    var total_score: usize = 0;
    for (map, 0..) |row, y| {
        for (row, 0..) |cell, x| {
            if (cell == 0) {
                total_score += try get_rating(allocator, map, y, x);
            }
        }
    }
    return total_score;
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const filename: []const u8 = "/home/mohitjangra/learning/advent_of_code_2024/inputs/day10.input";
    const data = try read_data(allocator, filename);
    defer allocator.free(data);
    const map = try parse_data(allocator, data);
    defer {
        for (map) |row| {
            allocator.free(row);
        }
    }
    const pt1_result = try part1(allocator, map);
    std.debug.assert(pt1_result == 646);
    const pt2_result = try part2(allocator, map);
    std.debug.assert(pt2_result == 1494);
}

test {
    const allocator = std.heap.page_allocator;
    const filename: []const u8 = "/home/mohitjangra/learning/advent_of_code_2024/tests/day10.test";
    const data = try read_data(allocator, filename);
    defer allocator.free(data);
    const map = try parse_data(allocator, data);
    defer {
        for (map) |row| {
            allocator.free(row);
        }
    }
    const pt1_result = try part1(allocator, map);
    try std.testing.expect(pt1_result == 36);

    const pt2_result = try part2(allocator, map);
    try std.testing.expect(pt2_result == 81);
}
