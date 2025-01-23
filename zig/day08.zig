const std = @import("std");
const Allocator = std.mem.Allocator;

fn Pair(comptime T1: type, comptime T2: type) type {
    return struct {
        first: T1,
        second: T2,
    };
}

const Position = struct {
    y: i32,
    x: i32,

    pub fn sub(self: Position, other: Position) Position {
        return Position{
            .x = self.x - other.x,
            .y = self.y - other.y,
        };
    }

    pub fn add(self: Position, other: Position) Position {
        return Position{
            .x = self.x + other.x,
            .y = self.y + other.y,
        };
    }

    pub fn eq(self: Position, other: Position) bool {
        return self.x == other.x and self.y == other.y;
    }
};

fn read_data(allocator: Allocator, file_name: []const u8) ![]u8 {
    const file = try std.fs.openFileAbsolute(file_name, .{ .mode = .read_only });
    defer file.close();

    const file_stats = try file.stat();
    const buffer: []u8 = try allocator.alloc(u8, file_stats.size);

    const data_read = try file.read(buffer);
    std.debug.assert(data_read == file_stats.size);
    return buffer;
}

fn parse_map(allocator: Allocator, data: []u8) ![][]const u8 {
    var splits = std.mem.split(u8, std.mem.trim(u8, data, " \r\n\t"), "\n");
    var line_count: usize = 0;
    while (splits.next()) |_| : (line_count += 1) {}
    splits.reset();

    const lines: [][]const u8 = try allocator.alloc([]u8, line_count);
    var idx: usize = 0;
    while (splits.next()) |line| : (idx += 1) {
        lines[idx] = line;
    }
    return lines;
}

fn get_antinodes(first: Position, second: Position) Pair(Position, Position) {
    const diff: Position = first.sub(second);
    var left: Position = undefined;
    var right: Position = undefined;
    if (first.sub(diff).eq(second)) {
        left = second.sub(diff);
        right = first.add(diff);
    }
    if (second.sub(diff).eq(first)) {
        left = first.sub(diff);
        right = second.add(diff);
    }
    return Pair(Position, Position){
        .first = left,
        .second = right,
    };
}

fn get_all_antinodes(allocator: Allocator, map: [][]const u8, first: Position, second: Position) !std.hash_map.HashMap(Position, void, std.hash_map.AutoContext(Position), 80) {
    const diff: Position = first.sub(second);
    var set = std.hash_map.HashMap(Position, void, std.hash_map.AutoContext(Position), 80).init(allocator);
    var temp_first = first;
    var temp_second = second;
    try set.put(temp_first, {});
    try set.put(temp_second, {});
    while (0 <= temp_first.x and temp_first.x < map[0].len and 0 <= temp_first.y and temp_first.y < map.len) {
        temp_first = temp_first.sub(diff);
        try set.put(temp_first.sub(diff), {});
    }
    while (0 <= temp_second.x and temp_second.x < map[0].len and 0 <= temp_second.y and temp_second.y < map.len) {
        temp_second = temp_second.add(diff);
        try set.put(temp_second.add(diff), {});
    }
    return set;
}

fn part1(allocator: Allocator, map: [][]const u8) !usize {
    var towers = std.hash_map.HashMap(u8, std.ArrayList(Position), std.hash_map.AutoContext(u8), 80).init(allocator);
    defer towers.deinit();
    for (map, 0..) |row, y| {
        for (row, 0..) |char, x| {
            if (char == '.') {
                continue;
            }
            if (towers.getPtr(char)) |entry| {
                try entry.append(Position{ .y = @intCast(y), .x = @intCast(x) });
            } else {
                try towers.put(char, std.ArrayList(Position).init(allocator));
                try towers.getPtr(char).?.append(Position{ .y = @intCast(y), .x = @intCast(x) });
            }
        }
    }
    var antinodes = std.HashMap(Position, void, std.hash_map.AutoContext(Position), 80).init(allocator);
    defer antinodes.deinit();

    var iter = towers.iterator();
    while (iter.next()) |entry| {
        const freq = entry.key_ptr.*;
        const nodes = entry.value_ptr.*.items;
        for (0..nodes.len) |j| {
            for (j + 1..nodes.len) |i| {
                const pair = get_antinodes(nodes[i], nodes[j]);
                if (0 <= pair.first.x and pair.first.x < map[0].len and 0 <= pair.first.y and pair.first.y < map.len and map[@intCast(pair.first.y)][@intCast(pair.first.x)] != freq) {
                    try antinodes.put(pair.first, {});
                }
                if (0 <= pair.second.x and pair.second.x < map[0].len and 0 <= pair.second.y and pair.second.y < map.len and map[@intCast(pair.second.y)][@intCast(pair.second.x)] != freq) {
                    try antinodes.put(pair.second, {});
                }
            }
        }
        entry.value_ptr.deinit();
    }
    return antinodes.count();
}

fn part2(allocator: Allocator, map: [][]const u8) !usize {
    var towers = std.hash_map.HashMap(u8, std.ArrayList(Position), std.hash_map.AutoContext(u8), 80).init(allocator);
    defer towers.deinit();
    for (map, 0..) |row, y| {
        for (row, 0..) |char, x| {
            if (char == '.') {
                continue;
            }
            if (towers.getPtr(char)) |entry| {
                try entry.append(Position{ .y = @intCast(y), .x = @intCast(x) });
            } else {
                try towers.put(char, std.ArrayList(Position).init(allocator));
                try towers.getPtr(char).?.append(Position{ .y = @intCast(y), .x = @intCast(x) });
            }
        }
    }
    var antinodes = std.HashMap(Position, void, std.hash_map.AutoContext(Position), 80).init(allocator);
    defer antinodes.deinit();

    var iter = towers.iterator();
    while (iter.next()) |entry| {
        const nodes = entry.value_ptr.*.items;
        for (0..nodes.len) |j| {
            for (j + 1..nodes.len) |i| {
                var set = try get_all_antinodes(allocator, map, nodes[i], nodes[j]);
                defer set.deinit();
                var antinode_iter = set.iterator();
                while (antinode_iter.next()) |antinode_entry| {
                    const item = antinode_entry.key_ptr.*;
                    if (0 <= item.x and item.x < map[0].len and 0 <= item.y and item.y < map.len) {
                        try antinodes.put(item, {});
                    }
                }
            }
        }
        entry.value_ptr.deinit();
    }
    return antinodes.count();
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const buffer = try read_data(allocator, "/home/mohitjangra/learning/advent_of_code_2024/inputs/day08.input");
    defer allocator.free(buffer);
    const map = try parse_map(allocator, buffer);
    defer allocator.free(map);

    const pt1_result = try part1(allocator, map);
    try std.testing.expect(pt1_result == 256);
    const pt2_result = try part2(allocator, map);
    try std.testing.expect(pt2_result == 1005);
}

test {
    const allocator = std.testing.allocator;
    const buffer = try read_data(allocator, "/home/mohitjangra/learning/advent_of_code_2024/tests/day08.test");
    defer allocator.free(buffer);
    const map = try parse_map(allocator, buffer);
    defer allocator.free(map);

    const pt1_result = try part1(allocator, map);
    try std.testing.expect(pt1_result == 14);
    const pt2_result = try part2(allocator, map);
    try std.testing.expect(pt2_result == 34);
}
