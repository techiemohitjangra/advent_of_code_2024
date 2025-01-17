const std = @import("std");
const Allocator = std.mem.Allocator;
const Thread = std.Thread;

const DirectionOffset = packed struct {
    dx: i2,
    dy: i2,
};

const Direction = enum(u2) {
    Up = 0,
    Right = 1,
    Down = 2,
    Left = 3,
};

const CellState = enum(u2) { Empty, Guard, Obstacle };

const Position = struct {
    x: i16,
    y: i16,
};

const Puzzle = struct {
    pub const directions: [4]DirectionOffset = [4]DirectionOffset{
        .{ .dx = 0, .dy = -1 }, // up (x, y)
        .{ .dx = 1, .dy = 0 }, // right (x, y)
        .{ .dx = 0, .dy = 1 }, // down (x, y)
        .{ .dx = -1, .dy = 0 }, // left (x, y)
    };

    source_file: []const u8,
    data: []u8,
    map: [][]CellState,
    start: Position,
    next: Position,
    current: Position,
    direction: Direction,
    out_of_bound: bool,
    visited_positions: std.hash_map.HashMap(Position, Direction, std.hash_map.AutoContext(Position), 80),
    allocator: *Allocator,

    pub fn init(allocator: *Allocator, filename: []const u8) !Puzzle {
        const data: []u8 = try Puzzle.read_data(allocator.*, filename);
        var map: [][]CellState = try Puzzle.parse_matrix(allocator.*, data);
        const start_position: Position = try Puzzle.get_start_position(&map);
        const direction: Direction = .Up;
        const next_position = Position{
            .x = start_position.x + Puzzle.directions[@intFromEnum(direction)].dx,
            .y = start_position.y + Puzzle.directions[@intFromEnum(direction)].dy,
        };

        return Puzzle{
            .source_file = filename,
            .data = data,
            .map = map,
            .start = start_position,
            .current = start_position,
            .next = next_position,
            .direction = direction,
            .out_of_bound = false,
            .visited_positions = std.hash_map.HashMap(Position, Direction, std.hash_map.AutoContext(Position), 80).init(allocator.*),
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *Puzzle) void {
        self.allocator.free(self.data);
        for (self.map) |row| {
            self.allocator.free(row);
        }
        self.allocator.free(self.map);
        self.visited_positions.deinit();
    }

    pub fn print(self: *const Puzzle) void {
        for (self.map) |row| {
            for (row) |cell| {
                var char: u8 = undefined;
                switch (cell) {
                    .Guard => {
                        switch (self.direction) {
                            .Up => char = '^',
                            .Right => char = '>',
                            .Down => char = 'v',
                            .Left => char = '<',
                        }
                    },
                    .Empty => char = '.',
                    .Obstacle => char = '#',
                }
                std.debug.print("{c}", .{char});
            }
            std.debug.print("\n", .{});
        }
    }

    pub fn animate(self: *const Puzzle) void {
        std.debug.print("\x1B[2J\x1B[H", .{});
        self.print();
        std.time.sleep(100 * 1000 * 1000);
    }

    pub fn reset_positions(self: *Puzzle) void {
        self.map[@as(usize, @intCast(self.current.y))][@as(usize, @intCast(self.current.x))] = .Empty;
        self.map[@as(usize, @intCast(self.start.y))][@as(usize, @intCast(self.start.x))] = .Guard;
        self.direction = .Up;
        self.current = self.start;
        self.next = Position{
            .x = self.current.x + Puzzle.directions[@intFromEnum(self.direction)].dx,
            .y = self.current.y + Puzzle.directions[@intFromEnum(self.direction)].dy,
        };
    }

    fn find_visited_positions(self: *Puzzle) !void {
        while (0 <= self.next.x and self.next.x < self.map[0].len and 0 <= self.next.y and self.next.y < self.map.len) {
            if (self.map[@as(usize, @intCast(self.next.y))][@as(usize, @intCast(self.next.x))] == .Obstacle) {
                self.rotate();
            } else {
                self.move_forward();
                try self.visited_positions.put(self.current, self.direction);
            }
        }
        self.reset_positions();
    }

    pub fn part1(self: *Puzzle) !usize {
        try self.find_visited_positions();
        return self.visited_positions.count();
    }

    pub fn part2(self: *Puzzle) !usize {
        var loop_count: usize = 0;
        var visited_position_iterator = self.visited_positions.iterator();
        while (visited_position_iterator.next()) |item| {
            self.reset_positions();
            const y = item.key_ptr.y;
            const x = item.key_ptr.x;
            if (self.start.x == x and self.start.y == y) continue;
            self.map[@as(usize, @intCast(y))][@as(usize, @intCast(x))] = .Obstacle;
            if (try self.has_loop()) {
                loop_count += 1;
            }
            self.map[@as(usize, @intCast(y))][@as(usize, @intCast(x))] = .Empty;
        }
        return loop_count;
    }

    pub fn count_possible_loops(self: *Puzzle) !usize {
        var loop_count: usize = 0;
        for (self.map, 0..) |row, y| {
            for (row, 0..) |cell, x| {
                if (cell == .Obstacle or cell == .Guard) continue;
                if (self.start.x == x and self.start.y == y) continue;
                self.map[y][x] = .Obstacle;
                if (try self.has_loop()) {
                    loop_count += 1;
                }
                self.map[y][x] = .Empty;
                self.reset_positions();
            }
        }
        return loop_count;
    }

    pub fn has_loop(self: *Puzzle) !bool {
        var visited_positions = std.hash_map.HashMap(Position, Direction, std.hash_map.AutoContext(Position), 80).init(self.allocator.*);
        defer visited_positions.deinit();
        while (0 <= self.next.x and self.next.x < self.map[0].len and 0 <= self.next.y and self.next.y < self.map.len) {
            if (visited_positions.get(self.current)) |direction| {
                if (direction == self.direction) {
                    return true;
                }
            }
            if (self.map[@as(usize, @intCast(self.next.y))][@as(usize, @intCast(self.next.x))] == .Obstacle) {
                self.rotate();
                continue;
            }
            try visited_positions.put(self.current, self.direction);
            self.move_forward();
        }
        return false;
    }

    fn rotate(self: *Puzzle) void {
        self.direction = switch (self.direction) {
            .Up => .Right,
            .Right => .Down,
            .Down => .Left,
            .Left => .Up,
        };
        self.next.x = self.current.x + Puzzle.directions[@intFromEnum(self.direction)].dx;
        self.next.y = self.current.y + Puzzle.directions[@intFromEnum(self.direction)].dy;
    }

    fn move_forward(self: *Puzzle) void {
        self.map[@as(usize, @intCast(self.current.y))][@as(usize, @intCast(self.current.x))] = .Empty;
        self.current.x += Puzzle.directions[@intFromEnum(self.direction)].dx;
        self.current.y += Puzzle.directions[@intFromEnum(self.direction)].dy;
        self.map[@as(usize, @intCast(self.current.y))][@as(usize, @intCast(self.current.x))] = .Guard;
        self.next.x = self.current.x + Puzzle.directions[@intFromEnum(self.direction)].dx;
        self.next.y = self.current.y + Puzzle.directions[@intFromEnum(self.direction)].dy;
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
    const filename: [:0]const u8 = "../../inputs/day06.input";

    var puzzle = try Puzzle.init(&allocator, filename);
    defer puzzle.deinit();

    const positions_visited: usize = try puzzle.part1();
    std.debug.assert(positions_visited == 5409);

    const possible_loop_count_optimized: usize = try puzzle.part2();
    std.debug.assert(possible_loop_count_optimized == 2022);
}

test "count unique visited position for test data" {
    var allocator = std.testing.allocator;
    const filename: [:0]const u8 = "../../tests/day06.test";

    var puzzle = try Puzzle.init(&allocator, filename);
    defer puzzle.deinit();

    const positions_visited: usize = try puzzle.part1();
    try std.testing.expect(positions_visited == 41);
}

test "count unique visited position for input data" {
    var allocator = std.testing.allocator;
    const filename: [:0]const u8 = "../../inputs/day06.input";

    var puzzle = try Puzzle.init(&allocator, filename);
    defer puzzle.deinit();

    const positions_visited: usize = try puzzle.part1();
    try std.testing.expect(positions_visited == 5409);
}

test "has loop unit test" {
    var allocator = std.testing.allocator;
    const filename: [:0]const u8 = "../../tests/day06.sample";

    var puzzle = try Puzzle.init(&allocator, filename);
    defer puzzle.deinit();

    _ = try puzzle.part1();
    puzzle.reset_positions();

    puzzle.map[3][0] = .Obstacle;
    const found_loop = try puzzle.has_loop();
    try std.testing.expect(found_loop == true);
}

test "possible loop count for test data" {
    var allocator = std.testing.allocator;
    const filename: [:0]const u8 = "../../tests/day06.test";

    var puzzle = try Puzzle.init(&allocator, filename);
    defer puzzle.deinit();

    _ = try puzzle.part1();
    const possible_loop_count: usize = try puzzle.count_possible_loops();
    try std.testing.expect(possible_loop_count == 6);
}

test "possible loop count for input data" {
    var allocator = std.testing.allocator;
    const filename: [:0]const u8 = "../../inputs/day06.input";

    var puzzle = try Puzzle.init(&allocator, filename);
    defer puzzle.deinit();

    _ = try puzzle.part1();
    const possible_loop_count: usize = try puzzle.part2();
    try std.testing.expect(possible_loop_count == 2022);
}
