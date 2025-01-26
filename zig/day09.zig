const std = @import("std");
const Allocator = std.mem.Allocator;

const File = struct {
    file_id: usize,
    file_size: usize,
    space_after: usize,
    start_idx: usize = 0,
};

fn read_data(allocator: Allocator, filename: []const u8) ![]const u8 {
    const file = try std.fs.openFileAbsolute(filename, .{ .mode = .read_only });
    defer file.close();

    const file_stats = try file.stat();
    const buffer: []u8 = try allocator.alloc(u8, file_stats.size);
    const bytes_read = try file.read(buffer);
    std.debug.assert(file_stats.size == bytes_read);
    return buffer;
}

fn parse_memory(allocator: Allocator, compressed: []const u8) !std.DoublyLinkedList(File) {
    var list = std.DoublyLinkedList(File){};
    var is_file: bool = true;
    var file_id: u32 = 0;
    var start_idx: usize = 0;
    for (std.mem.trim(u8, compressed, " \r\n\t"), 0..) |char, idx| {
        if (is_file) {
            const size: u8 = try std.fmt.parseInt(u8, &[_]u8{char}, 10);
            const node = try allocator.create(std.DoublyLinkedList(File).Node);
            node.data = File{
                .file_id = file_id,
                .file_size = size,
                .start_idx = start_idx,
                .space_after = 0,
            };
            list.append(node);
            file_id += 1;
            start_idx += size;
        } else {
            const space: u8 = try std.fmt.parseInt(u8, &[_]u8{compressed[idx]}, 10);
            if (list.last) |item| {
                item.data.space_after = space;
            }
            start_idx += space;
        }
        is_file = !is_file;
    }
    return list;
}

fn uncompress(allocator: Allocator, data: []const u8) ![]i32 {
    var memory_size: usize = 0;
    for (std.mem.trim(u8, data, " \r\n\t")) |char| {
        memory_size += try std.fmt.parseInt(u8, &[_]u8{char}, 10);
    }
    const buffer: []i32 = try allocator.alloc(i32, memory_size);
    var is_file: bool = true;
    var file_id: u32 = 0;
    var idx: usize = 0;
    for (std.mem.trim(u8, data, " \r\n\t")) |char| {
        var count: u8 = try std.fmt.parseInt(u8, &[_]u8{char}, 10);
        if (is_file) {
            while (count > 0) {
                buffer[idx] = @intCast(file_id);
                count -= 1;
                idx += 1;
            }
            file_id += 1;
        } else {
            while (count > 0) {
                buffer[idx] = -1;
                count -= 1;
                idx += 1;
            }
        }
        is_file = !is_file;
    }
    return buffer;
}

fn print_memory(T: type, memory: T) !void {
    switch (T) {
        std.DoublyLinkedList(File) => {
            var it: ?*std.DoublyLinkedList(File).Node = memory.first;
            while (it) |item| : (it = item.next) {
                for (0..item.data.file_size) |_| {
                    std.debug.print("{d}", .{item.data.file_id});
                }
                for (0..item.data.space_after) |_| {
                    std.debug.print(".", .{});
                }
            }
            std.debug.print("\n", .{});
        },
        []i32 => {
            for (memory) |item| {
                if (item < 0) {
                    std.debug.print(".", .{});
                } else {
                    std.debug.print("{d}", .{item});
                }
            }
            std.debug.print("\n", .{});
        },
        else => {
            return error.InvalidType;
        },
    }
}

fn calculate_checksum(comptime T: type, memory: T) !usize {
    var checksum: usize = 0;
    switch (T) {
        std.DoublyLinkedList(File) => {
            var it: ?*std.DoublyLinkedList(File).Node = memory.first;
            while (it) |item| : (it = item.next) {
                for (item.data.start_idx..item.data.start_idx + item.data.file_size) |idx| {
                    checksum += idx * item.data.file_id;
                }
            }
        },
        []i32 => {
            for (memory, 0..) |item, idx| {
                if (item == -1) continue;
                checksum += @as(usize, @intCast(item)) * @as(usize, @intCast(idx));
            }
        },
        else => {
            return error.InvalidType;
        },
    }
    return checksum;
}

fn part1(memory: []i32) !usize {
    var start: usize = 0;
    var end: usize = memory.len - 1;

    while (end > start) {
        while (memory[end] == -1) {
            end -= 1;
        }
        while (memory[start] != -1) {
            start += 1;
        }
        if (start < end) {
            std.mem.swap(i32, &memory[start], &memory[end]);
        }
    }
    return try calculate_checksum([]i32, memory);
}

fn part2(memory: *std.DoublyLinkedList(File)) !usize {
    var end = memory.last;
    var temp_end_node: ?*std.DoublyLinkedList(File).Node = undefined;
    while (end) |node| : (end = temp_end_node) {
        temp_end_node = node.prev;
        var start = memory.first;
        while (start) |space| : (start = space.next) {
            if (space == node) break;
            if (space.data.space_after >= node.data.file_size) {
                const temp = node;
                memory.remove(node);
                temp.prev.?.data.space_after += temp.data.file_size + temp.data.space_after;
                temp.data.space_after = space.data.space_after - temp.data.file_size;
                temp.data.start_idx = space.data.start_idx + space.data.file_size;
                memory.insertAfter(space, temp);
                space.data.space_after = 0;
                break;
            }
        }
    }
    return try calculate_checksum(std.DoublyLinkedList(File), memory.*);
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const filename = "/home/mohitjangra/learning/advent_of_code_2024/inputs/day09.input";

    const buffer: []const u8 = try read_data(allocator, filename);
    defer allocator.free(buffer);

    const memory = try uncompress(allocator, buffer);
    defer allocator.free(memory);
    const memory_copy = try uncompress(allocator, buffer);
    defer allocator.free(memory_copy);

    const pt1_result = try part1(memory);
    std.debug.assert(pt1_result == 6330095022244);

    var list = try parse_memory(allocator, buffer);
    defer {
        var it = list.first;
        var next: ?*std.DoublyLinkedList(File).Node = undefined;
        while (it) |item| : (it = next) {
            next = item.next;
            allocator.destroy(item);
        }
    }
    const pt2_result = try part2(&list);
    std.debug.assert(pt2_result == 6359491814941);
}

test {
    const allocator = std.testing.allocator;
    const filename = "/home/mohitjangra/learning/advent_of_code_2024/tests/day09.test";
    const buffer: []const u8 = try read_data(allocator, filename);
    defer allocator.free(buffer);

    const memory = try uncompress(allocator, buffer);
    defer allocator.free(memory);

    const memory_copy = try uncompress(allocator, buffer);
    defer allocator.free(memory_copy);
    const pt1_result = try part1(memory);
    try std.testing.expect(pt1_result == 1928);

    var list = try parse_memory(allocator, buffer);
    defer {
        var it = list.first;
        var next: ?*std.DoublyLinkedList(File).Node = undefined;
        while (it) |item| : (it = next) {
            next = item.next;
            allocator.destroy(item);
        }
    }
    const pt2_result = try part2(&list);
    try std.testing.expect(pt2_result == 2858);
}

test "file linked list" {
    const allocator = std.testing.allocator;
    const filename = "/home/mohitjangra/learning/advent_of_code_2024/tests/day09.test";
    const buffer: []const u8 = try read_data(allocator, filename);
    defer allocator.free(buffer);

    var list = try parse_memory(allocator, buffer);
    defer {
        var it = list.first;
        var next: ?*std.DoublyLinkedList(File).Node = undefined;
        while (it) |item| : (it = next) {
            next = item.next;
            allocator.destroy(item);
        }
    }
    const pt2_result = try part2(&list);
    try std.testing.expect(pt2_result == 2858);
}
