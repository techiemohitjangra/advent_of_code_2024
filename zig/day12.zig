const std = @import("std");
const Allocator = std.mem.Allocator;
const HashMap = std.hash_map.HashMap;
const AutoContext = std.hash_map.AutoContext;

const Position = struct {
    y: usize,
    x: usize,
};

const Direction = enum(u2) {
    Up,
    Right,
    Down,
    Left,
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

fn parse_data(allocator: Allocator, data: []const u8) ![][]const u8 {
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

fn traverse_region(map: [][]const u8, y: usize, x: usize, visited: *HashMap(Position, usize, AutoContext(Position), 80)) !void {
    const cell_state: Position = Position{ .y = y, .x = x };
    var edges: usize = 0;
    try visited.put(cell_state, edges);
    // up
    if (y == 0 or map[y - 1][x] != map[y][x]) {
        edges += 1;
    } else if (y > 0 and map[y - 1][x] == map[y][x]) {
        if (!visited.contains(Position{ .y = y - 1, .x = x })) {
            try traverse_region(map, y - 1, x, visited);
        }
    }
    // right
    if (x == map[y].len - 1 or map[y][x + 1] != map[y][x]) {
        edges += 1;
    } else if (x < map[y].len - 1 and map[y][x + 1] == map[y][x]) {
        if (!visited.contains(Position{ .y = y, .x = x + 1 })) {
            try traverse_region(map, y, x + 1, visited);
        }
    }
    // down
    if (y == map.len - 1 or map[y + 1][x] != map[y][x]) {
        edges += 1;
    } else if (y < map.len - 1 and map[y + 1][x] == map[y][x]) {
        if (!visited.contains(Position{ .y = y + 1, .x = x })) {
            try traverse_region(map, y + 1, x, visited);
        }
    }
    // left
    if (x == 0 or map[y][x - 1] != map[y][x]) {
        edges += 1;
    } else if (x > 0 and map[y][x - 1] == map[y][x]) {
        if (!visited.contains(Position{ .y = y, .x = x - 1 })) {
            try traverse_region(map, y, x - 1, visited);
        }
    }
    try visited.put(cell_state, edges);
}

fn part1(allocator: Allocator, map: [][]const u8) !usize {
    var visited_regions = HashMap(
        Position,
        void,
        AutoContext(Position),
        80,
    ).init(allocator);
    defer visited_regions.deinit();

    var res: usize = 0;
    for (map, 0..) |row, y| {
        for (row, 0..) |_, x| {
            if (!visited_regions.contains(Position{ .y = y, .x = x })) {
                var visited_cells = HashMap(
                    Position,
                    usize,
                    AutoContext(Position),
                    80,
                ).init(allocator);
                defer visited_cells.deinit();

                try traverse_region(map, y, x, &visited_cells);
                var edges: usize = 0;
                var iter = visited_cells.iterator();
                while (iter.next()) |entry| {
                    const position = entry.key_ptr.*;
                    edges += entry.value_ptr.*;
                    try visited_regions.put(position, {});
                }
                res += visited_cells.count() * edges;
            }
        }
    }
    return res;
}

fn get_sides(allocator: Allocator, map: [][]const u8, y: usize, x: usize, direction: Direction) usize {
    var visited = HashMap(Position, void, AutoContext(Position), 80).init(allocator);
    defer visited.deinit();
    var sides = 0;
    var current: Position = Position{};
    var next: Position = switch (direction) {
        .Up => if (y > 0 and map[y - 1][x] == map[y][x]) {
            Position{};
        },
    };
    while (!visited.contains(next)) {}
}

fn part2(allocator: Allocator, map: [][]const u8) !usize {
    var visited_regions = HashMap(
        Position,
        void,
        AutoContext(Position),
        80,
    ).init(allocator);
    defer visited_regions.deinit();

    var res: usize = 0;
    for (map, 0..) |row, y| {
        for (row, 0..) |_, x| {
            if (!visited_regions.contains(Position{ .y = y, .x = x })) {
                var visited_cells = HashMap(
                    Position,
                    usize,
                    AutoContext(Position),
                    80,
                ).init(allocator);
                defer visited_cells.deinit();

                try traverse_region(map, y, x, &visited_cells);
                var sides = get_sides(map, y, x);
                res += visited_cells.count() * sides;
            }
        }
    }
    return res;
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const filename: []const u8 = "/home/mohitjangra/learning/advent_of_code_2024/inputs/day12.input";

    const data: []const u8 = try read_data(allocator, filename);
    defer allocator.free(data);

    const map: [][]const u8 = try parse_data(allocator, data);
    defer allocator.free(map);

    const pt1_result: usize = try part1(allocator, map);
    std.debug.print("{d}\n", .{pt1_result});
    // std.debug.assert();
}

test {
    const allocator = std.testing.allocator;
    const filename: []const u8 = "/home/mohitjangra/learning/advent_of_code_2024/tests/day12.test";

    const data: []const u8 = try read_data(allocator, filename);
    defer allocator.free(data);

    const map: [][]const u8 = try parse_data(allocator, data);
    defer allocator.free(map);

    const pt1_result: usize = try part1(allocator, map);
    std.debug.print("{d}\n", .{pt1_result});
    std.debug.assert(pt1_result == 1930);
}

test "sample 1" {
    const allocator = std.testing.allocator;
    const filename: []const u8 = "/home/mohitjangra/learning/advent_of_code_2024/tests/day12.sample1";

    const data: []const u8 = try read_data(allocator, filename);
    defer allocator.free(data);

    const map: [][]const u8 = try parse_data(allocator, data);
    defer allocator.free(map);

    const sample1_result: usize = try part1(allocator, map);
    std.debug.print("{d}\n", .{sample1_result});
    std.debug.assert(sample1_result == 140);
}

test "sample 2" {
    const allocator = std.testing.allocator;
    const filename: []const u8 = "/home/mohitjangra/learning/advent_of_code_2024/tests/day12.sample2";

    const data: []const u8 = try read_data(allocator, filename);
    defer allocator.free(data);

    const map: [][]const u8 = try parse_data(allocator, data);
    defer allocator.free(map);

    const sample2_result: usize = try part1(allocator, map);
    std.debug.print("{d}\n", .{sample2_result});
    std.debug.assert(sample2_result == 772);
}
