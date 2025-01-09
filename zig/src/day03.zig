const std = @import("std");
const Allocator = std.mem.Allocator;
const c = @cImport({
    @cInclude("regex.h");
});

fn read_data(allocator: Allocator, file_name: []const u8) ![]u8 {
    const file = try std.fs.cwd().openFile(file_name, std.fs.File.OpenFlags{
        .mode = .read_only,
    });
    defer file.close();

    const file_stats = try file.stat();
    const buffer: []u8 = try allocator.alloc(u8, file_stats.size);

    const data_read = try file.readAll(buffer);
    std.debug.assert(data_read == file_stats.size);

    return buffer;
}

pub fn main() !void {}
