const std = @import("std");
const Allocator = std.mem.Allocator;
const Thread = std.Thread;

const Direction = packed struct {
    dx: i2,
    dy: i2,
};

const CellState = enum(u2) { Empty, Guard, Obstacle };

const Position = struct {
    x: i16,
    y: i16,
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
    map: [][]CellState,
    start: Position,
    next: Position,
    current: Position,
    direction_index: usize,
    out_of_bound: bool,
    visited_positions: std.hash_map.HashMap(Position, usize, std.hash_map.AutoContext(Position), 80),
    visited_list: std.ArrayList(Position),
    allocator: *Allocator,

    pub fn init(allocator: *Allocator, filename: []const u8) !Puzzle {
        const arrayList = std.ArrayList(Position).init(allocator.*);
        const data: []u8 = try Puzzle.read_data(allocator.*, filename);
        var map: [][]CellState = try Puzzle.parse_matrix(allocator.*, data);
        const start_position: Position = try Puzzle.get_start_position(&map);
        const direction_index = 0;
        const next_position = Position{
            .x = start_position.x + Puzzle.directions[direction_index].dx,
            .y = start_position.y + Puzzle.directions[direction_index].dy,
        };

        return Puzzle{
            .visited_list = arrayList,
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
        for (self.map) |row| {
            self.allocator.free(row);
        }
        self.allocator.free(self.map);
        self.visited_list.deinit();
        self.visited_positions.deinit();
    }

    pub fn print(self: *const Puzzle) void {
        for (self.map) |row| {
            for (row) |cell| {
                var char: u8 = undefined;
                switch (cell) {
                    .Guard => char = '^',
                    .Empty => char = '.',
                    .Obstacle => char = '#',
                }
                std.debug.print("{c}", .{char});
            }
            std.debug.print("\n", .{});
        }
    }

    pub fn reset_positions(self: *Puzzle) !void {
        self.map[@as(usize, @intCast(self.current.y))][@as(usize, @intCast(self.current.x))] = .Empty;
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
            if (self.visited_positions.get(self.current)) |_| {} else {
                try self.visited_list.append(self.current);
            }
            try self.visited_positions.put(self.current, self.direction_index);
        }
        return self.visited_positions.count();
    }

    pub fn count_possible_loops_optimized(self: *Puzzle) !usize {
        var loop_count: usize = 0;
        // var hash_map_iterator = self.visited_positions.iterator();
        // while (hash_map_iterator.next()) |item| {
        for (self.visited_list.items) |item| {
            if (std.meta.eql(item, self.start)) continue; // skip starting position
            const y = item.y;
            const x = item.x;
            self.map[@as(usize, @intCast(y))][@as(usize, @intCast(x))] = .Obstacle;
            if (try self.has_loop()) {
                loop_count += 1;
            }
            try self.reset_positions();
            self.map[@as(usize, @intCast(y))][@as(usize, @intCast(x))] = .Empty;
        }
        return loop_count;
    }

    pub fn count_possible_loops(self: *Puzzle) !usize {
        var loop_count: usize = 0;
        for (self.map, 0..) |row, y| {
            for (row, 0..) |cell, x| {
                if (cell == .Obstacle or cell == .Guard) continue;
                self.direction_index = 0;
                self.map[@as(usize, @intCast(y))][@as(usize, @intCast(x))] = .Obstacle;
                if (try self.has_loop()) {
                    loop_count += 1;
                }
                try self.reset_positions();
                self.map[@as(usize, @intCast(y))][@as(usize, @intCast(x))] = .Empty;
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
            // std.time.sleep(100 * 1000 * 1000);
        }
        return false;
    }

    fn move_forward(self: *Puzzle) void {
        if (self.map[@as(usize, @intCast(self.next.y))][@as(usize, @intCast(self.next.x))] == .Obstacle) {
            self.direction_index = @mod(self.direction_index + 1, Puzzle.directions.len);
            self.next.x = self.current.x + Puzzle.directions[self.direction_index].dx;
            self.next.y = self.current.y + Puzzle.directions[self.direction_index].dy;
            return;
        }
        self.map[@as(usize, @intCast(self.current.y))][@as(usize, @intCast(self.current.x))] = .Empty;
        self.current.x += Puzzle.directions[self.direction_index].dx;
        self.current.y += Puzzle.directions[self.direction_index].dy;
        self.map[@as(usize, @intCast(self.current.y))][@as(usize, @intCast(self.current.x))] = .Guard;
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

    fn parse_matrix(allocator: Allocator, data: []u8) ![][]CellState {
        var splits = std.mem.split(u8, std.mem.trim(u8, data, " \n\r\t"), "\n");
        var row_count: usize = 0;
        while (splits.next()) |_| : (row_count += 1) {}
        splits.reset();
        const matrix: [][]CellState = try allocator.alloc([]CellState, row_count);
        var idx: usize = 0;
        while (splits.next()) |line| : (idx += 1) {
            matrix[idx] = try allocator.alloc(CellState, line.len);
            for (line, 0..) |char, char_idx| {
                switch (char) {
                    '.' => matrix[idx][char_idx] = .Empty,
                    '^', '>', '<', 'v' => matrix[idx][char_idx] = .Guard,
                    '#', 'O' => matrix[idx][char_idx] = .Obstacle,
                    else => unreachable,
                }
            }
        }
        return matrix;
    }

    fn get_start_position(map: *const [][]CellState) !Position {
        for (map.*, 0..) |row, y| {
            for (row, 0..) |cell, x| {
                if (cell == .Guard) {
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

    const possible_loop_count: usize = try puzzle.count_possible_loops_optimized();
    std.debug.print("possible_loop_count: {d}\n", .{possible_loop_count});
    try std.testing.expect(possible_loop_count == 6);
}

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

    puzzle.map[2][8] = .Obstacle;

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

test "check for loop with obstacle at y:7,x:6 " {
    var allocator = std.testing.allocator;
    const filename: [:0]const u8 = "day06.test";

    var puzzle = try Puzzle.init(&allocator, filename);
    defer puzzle.deinit();

    puzzle.map[7][6] = .Obstacle;

    const loop_found: bool = try puzzle.has_loop();
    try std.testing.expect(loop_found == true);
}

test "check presence in visited positions" {
    var allocator = std.testing.allocator;
    const filename: [:0]const u8 = "day06.test";

    var puzzle = try Puzzle.init(&allocator, filename);
    defer puzzle.deinit();

    const positions_visited: usize = try puzzle.count_unique_positions_visited();
    try std.testing.expect(positions_visited == 41);

    try std.testing.expect(puzzle.visited_positions.get(Position{ .y = 7, .x = 6 }) == 1);
}

test "possible loop count optimized" {
    var allocator = std.testing.allocator;
    const filename: [:0]const u8 = "day06.test";

    var puzzle = try Puzzle.init(&allocator, filename);
    defer puzzle.deinit();

    const positions_visited: usize = try puzzle.count_unique_positions_visited();
    try std.testing.expect(positions_visited == 41);

    const possible_loop_count: usize = try puzzle.count_possible_loops_optimized();
    std.debug.print("possible_loop_count: {d}\n", .{possible_loop_count});
    try std.testing.expect(possible_loop_count == 6);
}
