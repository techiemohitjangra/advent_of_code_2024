const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const expect = std.testing.expect;

fn Pair(comptime T1: type, comptime T2: type) type {
    return struct {
        first: T1,
        second: T2,
    };
}

fn read_data(allocator: Allocator, file_name: []const u8) ![]u8 {
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

fn parse_rule(line: []const u8) !Pair(i32, i32) {
    var splits = std.mem.split(u8, std.mem.trim(u8, line, " \r\n\t"), "|");
    const nums = Pair(i32, i32){
        .first = try std.fmt.parseInt(i32, std.mem.trim(u8, splits.next().?, " \r\n\t"), 10),
        .second = try std.fmt.parseInt(i32, std.mem.trim(u8, splits.next().?, " \r\n\t"), 10),
    };
    return nums;
}

fn parse_update(allocator: Allocator, line: []const u8) ![]i32 {
    var split_nums = std.mem.split(u8, std.mem.trim(u8, line, " \r\n\t"), ",");
    var num_count: usize = 0;
    while (split_nums.next()) |_| : (num_count += 1) {}
    split_nums.reset();

    const nums = try allocator.alloc(i32, num_count);
    var idx: usize = 0;
    while (split_nums.next()) |num| : (idx += 1) {
        nums[idx] = try std.fmt.parseInt(i32, std.mem.trim(u8, num, " \r\n\t"), 10);
    }
    return nums;
}

fn parse_data(allocator: Allocator, input_data: []u8) !Pair(std.AutoHashMap(i32, std.ArrayList(i32)), std.ArrayList([]i32)) {
    var rules = std.AutoHashMap(i32, std.ArrayList(i32)).init(allocator);
    var updates = std.ArrayList([]i32).init(allocator);

    var are_rules: bool = true;

    var lines = std.mem.split(u8, input_data, "\n");
    while (lines.next()) |line| {
        if (0 == std.mem.trim(u8, line, " \n\t\r").len) {
            are_rules = false;
            continue;
        }
        if (are_rules) {
            const pair = try parse_rule(line);
            if (rules.getPtr(pair.second)) |list| {
                try list.*.append(pair.first);
            } else {
                var new_value = std.ArrayList(i32).init(allocator);
                try new_value.append(pair.first);
                try rules.put(pair.second, new_value);
            }
        } else {
            try updates.append(try parse_update(allocator, line));
        }
    }

    return Pair(std.AutoHashMap(i32, std.ArrayList(i32)), std.ArrayList([]i32)){
        .first = rules,
        .second = updates,
    };
}

fn part1(input: Pair(std.AutoHashMap(i32, std.ArrayList(i32)), std.ArrayList([]i32))) i32 {
    var result: i32 = 0;
    updates: for (input.second.items) |updates| {
        for (updates, 0..) |page, page_idx| {
            if (input.first.get(page)) |list| {
                for (list.items) |item| {
                    for (updates[page_idx + 1 ..]) |page_after| {
                        if (page_after == item) {
                            continue :updates;
                        }
                    }
                }
            }
        }
        result += updates[@as(usize, @intFromFloat(@as(f64, @floatFromInt(updates.len - 1)) / 2.0))];
    }
    return result;
}

fn part2(input: Pair(std.AutoHashMap(i32, std.ArrayList(i32)), std.ArrayList([]i32))) i32 {
    var result: i32 = 0;
    updates: for (input.second.items) |updates| {
        for (updates, 0..) |page, page_idx| {
            if (input.first.get(page)) |list| {
                for (list.items) |item| {
                    for (updates[page_idx + 1 ..]) |page_after| {
                        if (page_after == item) {
                            continue :updates;
                        }
                    }
                }
            }
        }
        result += updates[@as(usize, @intFromFloat(@as(f64, @floatFromInt(updates.len - 1)) / 2.0))];
    }
    return result;
}

pub fn main() !void {
    var allocator = std.heap.page_allocator;
    const input_file: []const u8 = "../../inputs/day05.input";

    const buffer: []u8 = try read_data(allocator, input_file);
    defer allocator.free(buffer);

    var data: Pair(std.AutoHashMap(i32, std.ArrayList(i32)), std.ArrayList([]i32)) = try parse_data(allocator, buffer);
    defer {
        data.first.deinit();
        for (data.second.items) |item| {
            allocator.free(item);
        }
        data.second.deinit();
    }

    const pt1_result = part1(data);
    assert(pt1_result == 5166);

    const pt2_result = part2(data);
    assert(pt2_result == 4697);
}

test "read_data" {
    var allocator = std.testing.allocator;
    const test_file = "../../tests/day05.test";

    const buffer: []u8 = try read_data(allocator, test_file);
    defer allocator.free(buffer);
    try expect(buffer.len != 0);

    var data: Pair(std.AutoHashMap(i32, std.ArrayList(i32)), std.ArrayList([]i32)) = try parse_data(allocator, buffer);
    defer {
        var map_iterator = data.first.iterator();
        while (map_iterator.next()) |item| {
            item.value_ptr.*.deinit();
        }
        data.first.deinit();
        for (data.second.items) |item| {
            allocator.free(item);
        }
        data.second.deinit();
    }

    assert(data.first.count() == 6);
    assert(data.second.items.len == 6);
    assert(data.second.items[0].len == 5);
    assert(data.second.items[1].len == 5);
    assert(data.second.items[2].len == 3);
    assert(data.second.items[3].len == 5);
    assert(data.second.items[4].len == 3);
    assert(data.second.items[5].len == 5);
}

test "part 1" {
    var allocator = std.testing.allocator;
    const test_file = "../../tests/day05.test";

    const buffer: []u8 = try read_data(allocator, test_file);
    defer allocator.free(buffer);
    try expect(buffer.len != 0);

    var data: Pair(std.AutoHashMap(i32, std.ArrayList(i32)), std.ArrayList([]i32)) = try parse_data(allocator, buffer);
    defer {
        var map_iterator = data.first.iterator();
        while (map_iterator.next()) |item| {
            item.value_ptr.*.deinit();
        }
        data.first.deinit();
        for (data.second.items) |item| {
            allocator.free(item);
        }
        data.second.deinit();
    }

    const pt1_result = part1(data);
    try expect(pt1_result == 143);

    const pt2_result = part2(data);
    try expect(pt2_result == 123);
}
