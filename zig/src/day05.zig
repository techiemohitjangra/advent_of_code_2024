const std = @import("std");
const assert = std.debug.assert;
const expect = std.testing.expect;
const c = @cImport({
    @cInclude("regex.h");
});

fn Pair(T: type) type {
    return struct {
        first: T,
        second: T,
    };
}

fn read_data(allocator: *std.mem.Allocator, file_name: [:0]const u8) ![]u8 {
    var file: std.fs.File = try std.fs.cwd().openFile(
        file_name,
        std.fs.File.OpenFlags{
            .mode = .read_only,
        },
    );
    defer file.close();

    const file_stats = try file.stat();
    const buffer: []u8 = try allocator.alloc(u8, file_stats.size);
    const data_read: usize = try file.readAll(buffer);
    assert(data_read == file_stats.size);
    return buffer;
}

fn parse_rule(allocator: *std.mem.Allocator, input_data: []u8) !std.AutoHashMap(i32, i32) {
    var rules = std.AutoHashMap(i32, i32).init(allocator.*);

    var lines = std.mem.split(u8, input_data, "\n");
    while (lines.next()) |line| {
        if (0 == std.mem.trim(u8, line, " \n\t\r").len) {
            break;
        }
        var nums = std.mem.split(u8, line, "|");
        var key: i32 = undefined;
        var value: i32 = undefined;
        if (nums.next()) |num| {
            key = try std.fmt.parseInt(i32, std.mem.trim(u8, num, " \n\t\r"), 10);
        }
        if (nums.next()) |num| {
            value = try std.fmt.parseInt(i32, std.mem.trim(u8, num, " \n\t\r"), 10);
        }
        try rules.put(key, value);
    }
    return rules;
}

fn parse_updates(allocator: *std.mem.Allocator, input_data: []u8) !std.ArrayList(std.ArrayList(i32)) {
    var lines = std.mem.split(u8, input_data, "\n");
    while (lines.next()) |line| {
        if (0 != std.mem.trim(u8, line, " \n\t\r").len) {
            continue;
        } else {
            break;
        }
    }

    const updates = std.ArrayList(std.ArrayList(i32)).init(allocator.*);
    while (lines.next()) |line| {
        var updates_records = std.mem.split(u8, line, ",");
        var update = std.ArrayList(i32).init(allocator.*);
        while (updates_records.next()) |u| {
            const num_update = try std.fmt.parseInt(i32, u, 10);
            try update.append(num_update);
        }
        try update.append(update);
    }
    return updates;
}

pub fn main() !void {
    var allocator = std.heap.page_allocator;
    const input_file: *const [11:0]u8 = "day05.input";

    const buffer: []u8 = try read_data(&allocator, input_file);
    defer allocator.free(buffer);

    // std.debug.print("{s}", .{buffer});
}

test "read_data" {
    var allocator = std.testing.allocator;
    const test_file = "day05.test";

    const buffer: []u8 = try read_data(&allocator, test_file);
    defer allocator.free(buffer);

    try expect(buffer.len != 0);
}

test "parse_rules" {
    var allocator = std.testing.allocator;
    const test_file = "day05.test";

    const buffer: []u8 = try read_data(&allocator, test_file);
    defer allocator.free(buffer);

    var rules = try parse_rule(&allocator, buffer);
    defer rules.deinit();

    const rules_count = rules.count();
    try expect(21 == rules_count);
}

test "parse_updates" {
    var allocator = std.testing.allocator;
    const test_file = "day05.test";

    const buffer: []u8 = try read_data(&allocator, test_file);
    defer allocator.free(buffer);

    var updates: std.ArrayList(std.ArrayList(i32)) = try parse_updates(&allocator, buffer);
    defer updates.deinit();

    const updates_count = updates.items.len;
    try expect(6 == updates_count);

    for (updates.items) |update| {
        update.items.len;
    }
}
