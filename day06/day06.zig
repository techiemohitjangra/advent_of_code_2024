const std = @import("std");
const Allocator = std.mem.Allocator;
const Thread = std.Thread;

const Direction = packed struct {
    dx: i4,
    dy: i4,
};

const Position = struct {
    x: isize,
    y: isize,
};

const Puzzle = struct {
    pub const directions: [4]Direction = [4]Direction{
        .{ .dx = 0, .dy = -1 }, // top (x, y)
        .{ .dx = 1, .dy = 0 }, // right (x, y)
        .{ .dx = 0, .dy = 1 }, // bottom (x, y)
        .{ .dx = -1, .dy = 0 }, // left (x, y)
    };

    source_file: []const u8,
    data: []u8,
    map: [][]u8,
    start: Position,
    next: Position,
    current: Position,
    direction_index: usize,
    out_of_bound: bool,
    visited_positions: std.hash_map.HashMap(Position, usize, std.hash_map.AutoContext(Position), 80),
    allocator: *Allocator,

    pub fn init(allocator: *Allocator, filename: []const u8) !Puzzle {
        const data: []u8 = try Puzzle.read_data(allocator.*, filename);
        var map: [][]u8 = try Puzzle.parse_matrix(allocator.*, data);
        const start_position: Position = try Puzzle.get_start_position(&map);
        const direction_index = 0;
        const next_position = Position{
            .x = start_position.x + Puzzle.directions[direction_index].dx,
            .y = start_position.y + Puzzle.directions[direction_index].dy,
        };

        return Puzzle{
            .source_file = filename,
            .data = data,
            .map = map,
            .start = start_position,
            .current = start_position,
            .next = next_position,
            .direction_index = 0,
            .out_of_bound = false,
            .visited_positions = std.hash_map.HashMap(Position, usize, std.hash_map.AutoContext(Position), 80).init(allocator.*),
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *Puzzle) void {
        self.allocator.free(self.data);
        self.allocator.free(self.map);
        self.visited_positions.deinit();
    }

    pub fn print(self: *const Puzzle) void {
        for (self.map) |row| {
            std.debug.print("{s}\n", .{row});
        }
    }

    pub fn reset_positions(self: *Puzzle) !void {
        self.map[@as(usize, @intCast(self.current.y))][@as(usize, @intCast(self.current.x))] = '.';
        self.direction_index = 0;
        self.current = self.start;
        self.next = Position{
            .x = self.start.x + Puzzle.directions[self.direction_index].dx,
            .y = self.start.y + Puzzle.directions[self.direction_index].dy,
        };
    }

    pub fn count_unique_positions_visited(self: *Puzzle) !usize {
        while (0 <= self.next.x and self.next.x < self.map[0].len and 0 <= self.next.y and self.next.y < self.map.len) {
            self.move_forward();
            // std.debug.print("\x1b[2J\x1b[H", .{});
            // for (self.map) |row| {
            //     std.debug.print("{s}\n", .{row});
            // }
            // std.time.sleep(100 * 1000 * 1000);
            try self.visited_positions.put(self.current, self.direction_index);
        }
        return self.visited_positions.count();
    }

    pub fn count_possible_loops_optimized(self: *Puzzle) !usize {
        var loop_count: usize = 0;
        var hash_map_iterator = self.visited_positions.iterator();
        while (hash_map_iterator.next()) |item| {
            const y = item.key_ptr.y;
            const x = item.key_ptr.x;
            if (std.meta.eql(item.key_ptr.*, self.start)) continue; // skip starting position
            self.map[@as(usize, @intCast(y))][@as(usize, @intCast(x))] = '#';
            if (try self.has_loop()) {
                loop_count += 1;
            }
            try self.reset_positions();
            self.map[@as(usize, @intCast(y))][@as(usize, @intCast(x))] = '.';
        }
        return loop_count;
    }

    pub fn count_possible_loops(self: *Puzzle) !usize {
        var loop_count: usize = 0;
        for (self.map, 0..) |row, y| {
            for (row, 0..) |cell, x| {
                if ('#' == cell or '^' == cell) continue;
                self.direction_index = 0;
                self.map[@as(usize, @intCast(y))][@as(usize, @intCast(x))] = '#';
                if (try self.has_loop()) {
                    loop_count += 1;
                }
                try self.reset_positions();
                self.map[@as(usize, @intCast(y))][@as(usize, @intCast(x))] = '.';
                // std.debug.print("\x1b[2J\x1b[H", .{});
                // std.debug.print("y: {d}, x: {d}\n", .{ y, x });
                // std.debug.print("{d}\n", .{loop_count});
            }
        }
        return loop_count;
    }

    pub fn has_loop(self: *Puzzle) !bool {
        var visited_positions = std.hash_map.HashMap(Position, usize, std.hash_map.AutoContext(Position), 80).init(self.allocator.*);
        defer visited_positions.deinit();
        while (0 <= self.next.x and self.next.x < self.map[0].len and 0 <= self.next.y and self.next.y < self.map.len) {
            if (visited_positions.get(self.current)) |direction_index| {
                if (direction_index == self.direction_index) {
                    return true;
                }
            }
            try visited_positions.put(self.current, self.direction_index);
            self.move_forward();
            // std.debug.print("\x1b[2J\x1b[H", .{});
            // for (self.map) |row| {
            //     std.debug.print("{s}\n", .{row});
            // }
            // std.time.sleep(20 * 1000 * 1000);
        }
        return false;
    }

    fn move_forward(self: *Puzzle) void {
        if (self.map[@as(usize, @intCast(self.next.y))][@as(usize, @intCast(self.next.x))] == '#') {
            self.direction_index = @mod(self.direction_index + 1, Puzzle.directions.len);
            self.next.x = self.current.x + Puzzle.directions[self.direction_index].dx;
            self.next.y = self.current.y + Puzzle.directions[self.direction_index].dy;
            return;
        }
        self.map[@as(usize, @intCast(self.current.y))][@as(usize, @intCast(self.current.x))] = '.';
        self.current.x += Puzzle.directions[self.direction_index].dx;
        self.current.y += Puzzle.directions[self.direction_index].dy;
        self.map[@as(usize, @intCast(self.current.y))][@as(usize, @intCast(self.current.x))] = '^';
        self.next.x = self.current.x + Puzzle.directions[self.direction_index].dx;
        self.next.y = self.current.y + Puzzle.directions[self.direction_index].dy;
    }

    fn read_data(allocator: Allocator, filename: []const u8) ![]u8 {
        const file = try std.fs.cwd().openFile(filename, std.fs.File.OpenFlags{
            .mode = .read_only,
        });
        defer file.close();

        const file_stats: std.fs.File.Stat = try file.stat();
        const buffer: []u8 = try allocator.alloc(u8, file_stats.size);
        const bytes_read: usize = try file.readAll(buffer);
        std.debug.assert(bytes_read == file_stats.size);
        return buffer;
    }

    fn parse_matrix(allocator: Allocator, data: []u8) ![][]u8 {
        var splits = std.mem.split(u8, std.mem.trim(u8, data, " \n\r\t"), "\n");
        var row_count: usize = 0;
        while (splits.next()) |_| : (row_count += 1) {}
        splits.reset();
        const matrix: [][]u8 = try allocator.alloc([]u8, row_count);
        var idx: usize = 0;
        while (splits.next()) |line| : (idx += 1) {
            matrix[idx] = @constCast(line);
        }
        return matrix;
    }

    fn get_start_position(map: *const [][]u8) !Position {
        for (map.*, 0..) |row, y| {
            for (row, 0..) |cell, x| {
                if (cell == '^') {
                    return Position{ .y = @intCast(y), .x = @intCast(x) };
                }
            }
        }
        return error.StartPositionNotFound;
    }
};

pub fn main() !void {
    var allocator = std.heap.page_allocator;
    const filename: [:0]const u8 = "day06.input";

    var puzzle = try Puzzle.init(&allocator, filename);
    defer puzzle.deinit();

    const positions_visited: usize = try puzzle.count_unique_positions_visited();
    try std.testing.expect(positions_visited == 5409);
    std.debug.print("positions_visited: {d}\n", .{positions_visited});

    const possible_loop_count: usize = try puzzle.count_possible_loops();
    std.debug.print("possible_loop_count: {d}\n", .{possible_loop_count});
    try std.testing.expect(possible_loop_count == 6);
}

// test "on input data y:1, x:37" {
//     var allocator = std.testing.allocator;
//     const filename: [:0]const u8 = "day06.input";
//
//     var puzzle = try Puzzle.init(&allocator, filename);
//     defer puzzle.deinit();
//
//     puzzle.map[1][37] = '#';
//     const possible_loop_count: usize = try puzzle.count_possible_loops();
//     std.debug.print("possible_loop_count: {d}\n", .{possible_loop_count});
// }

test "unique prositions visited by guard" {
    var allocator = std.testing.allocator;
    const filename: [:0]const u8 = "day06.test";

    var puzzle = try Puzzle.init(&allocator, filename);
    defer puzzle.deinit();

    const positions_visited: usize = try puzzle.count_unique_positions_visited();
    try std.testing.expect(positions_visited == 41);
}

test "has_loop check in test input" {
    var allocator = std.testing.allocator;
    const filename: [:0]const u8 = "day06.test";

    var puzzle = try Puzzle.init(&allocator, filename);
    defer puzzle.deinit();

    const has_loop: bool = try puzzle.has_loop();
    try std.testing.expect(has_loop == false);
}

test "has_loop check for two obstacle one after another without taking steps, and causing two turns" {
    var allocator = std.testing.allocator;
    const filename: [:0]const u8 = "day06.test";

    var puzzle = try Puzzle.init(&allocator, filename);
    defer puzzle.deinit();

    puzzle.map[2][8] = '#';

    const has_loop: bool = try puzzle.has_loop();
    try std.testing.expect(has_loop == false);
}

test "possible loop count" {
    var allocator = std.testing.allocator;
    const filename: [:0]const u8 = "day06.test";

    var puzzle = try Puzzle.init(&allocator, filename);
    defer puzzle.deinit();

    const possible_loop_count: usize = try puzzle.count_possible_loops();
    try std.testing.expect(possible_loop_count == 6);
}

// test "possible loop count optimized" {
//     var allocator = std.testing.allocator;
//     const filename: [:0]const u8 = "day06.test";
//
//     var puzzle = try Puzzle.init(&allocator, filename);
//     defer puzzle.deinit();
//
//     const positions_visited: usize = try puzzle.count_unique_positions_visited();
//     try std.testing.expect(positions_visited == 41);
//
//     const possible_loop_count: usize = try puzzle.count_possible_loops_optimized();
//     std.debug.print("possible_loop_count: {d}\n", .{possible_loop_count});
//     try std.testing.expect(possible_loop_count == 6);
// }
