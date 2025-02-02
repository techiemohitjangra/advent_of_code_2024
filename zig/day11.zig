const std = @import("std");
const Allocator = std.mem.Allocator;

fn read_data(allocator: Allocator, filename: []const u8) ![]const u8 {
    const file = try std.fs.openFileAbsolute(filename, .{ .mode = .read_only });
    defer file.close();
    const file_stats = try file.stat();
    const buffer: []u8 = try allocator.alloc(u8, file_stats.size);
    const data_read = try file.readAll(buffer);
    std.debug.assert(data_read == file_stats.size);
    return buffer;
}

fn parse_data(allocator: Allocator, data: []const u8) !std.DoublyLinkedList(u32) {
    var splits = std.mem.split(u8, std.mem.trim(u8, data, " \r\n\t"), " ");
    var num_count: usize = 0;
    while (splits.next()) |_| : (num_count += 1) {}
    splits.reset();
    var list = std.DoublyLinkedList(u32){};
    while (splits.next()) |num_str| {
        const num: u32 = try std.fmt.parseInt(u32, num_str, 10);
        const node = try allocator.create(std.DoublyLinkedList(u32).Node);
        node.data = num;
        list.append(node);
    }
    return list;
}

fn blink(allocator: Allocator, list: std.DoublyLinkedList(u32)) !std.DoublyLinkedList(u32) {
    var it = list.first;
    while (it) |node| : (it = node.next) {
        var buffer: [32]u8 = undefined;
        try std.fmt.format(buffer[0..], "{}", .{node.data});
        if (node.data == 0) {
            node.data = 1;
        } else if (buffer.len % 2 == 0) {
            var new_node = try allocator.create(std.DoublyLinkedList(u32).Node);
            node.data = try std.fmt.parseInt(u32, buffer[0 .. buffer.len / 2], 10);
            new_node.data = try std.fmt.parseInt(u32, buffer[buffer.len / 2 ..], 10);
            list.insertAfter(node, new_node);
            it = node.next;
        } else {
            node.data *= 2024;
        }
    }
}

fn part1(allocator: Allocator, list: std.DoublyLinkedList(u32), blink_count: usize) !usize {
    var it = list.first;
    while (it) |node| : (it = node.next) {
        std.debug.print("{} ", .{node.data});
    }
    std.debug.print("\n", .{});
    var temp_list = list;
    for (0..blink_count) |_| {
        temp_list = try blink(allocator, temp_list);
        it = temp_list.first;
        while (it) |node| : (it = node.next) {
            std.debug.print("{} ", .{node.data});
            try blink(allocator, list);
        }
        std.debug.print("\n", .{});
    }
    return temp_list.len;
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const filename: []const u8 = "/home/mohitjangra/learning/advent_of_code_2024/inputs/day11.input";
    const data = try read_data(allocator, filename);
    defer allocator.free(data);

    const list = try parse_data(allocator, data);
    defer {
        var temp: ?*std.DoublyLinkedList(u32).Node = undefined;
        var it = list.first;
        while (it) |node| : (it = temp) {
            temp = node.next;
            allocator.destroy(node);
        }
    }
}

test {
    const allocator = std.testing.allocator;
    const filename: []const u8 = "/home/mohitjangra/learning/advent_of_code_2024/tests/day11.test";
    const data = try read_data(allocator, filename);
    defer allocator.free(data);

    const list = try parse_data(allocator, data);
    defer {
        var temp: ?*std.DoublyLinkedList(u32).Node = undefined;
        var it = list.first;
        while (it) |node| : (it = temp) {
            temp = node.next;
            allocator.destroy(node);
        }
    }

    const pt1_sample = try part1(allocator, list, 6);
    try std.testing.expect(pt1_sample == 22);

    // const pt1_result = try part1(allocator, list, 25);
    // try std.testing.expect(pt1_result == 185894);
}
