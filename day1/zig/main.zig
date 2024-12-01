const std = @import("std");
const expect = std.testing.expect;

pub fn main() !void {
    const inputFile: std.fs.File = try std.fs.cwd().openFile(
        "../input.txt",
        // "../test.txt",
        std.fs.File.OpenFlags{
            .mode = .read_only,
        },
    );
    defer inputFile.close();

    const fileStats = try inputFile.stat();

    const buffer: []u8 = try std.heap.page_allocator.alloc(u8, fileStats.size);
    defer std.heap.page_allocator.free(buffer);

    if (buffer.len != fileStats.size) {
        return error.OutOfMemory;
    }

    const data_read = try inputFile.read(buffer);
    std.debug.print("bytes read: {}\n", .{data_read});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        const status = gpa.deinit();
        if (status == .leak) expect(false) catch @panic("gpa leaked");
    }

    const allocator = gpa.allocator();

    var leftList = std.ArrayList(i32).init(allocator);
    defer leftList.deinit();

    var rightList = std.ArrayList(i32).init(allocator);
    defer rightList.deinit();

    var count: usize = 0;
    var toggle: bool = true;
    var numStr: [5]u8 = .{ 0, 0, 0, 0, 0 };

    // parse numbers into left and right lists
    for (buffer) |char| {
        if (std.ascii.isDigit(char)) {
            numStr[count] = char;
            count += 1;
        } else {
            if (std.mem.eql(u8, &numStr, &[_]u8{ 0, 0, 0, 0, 0 })) {
                count = 0;
                continue;
            }
            const num = try std.fmt.parseInt(i32, numStr[0..count], 10);
            if (toggle) {
                try leftList.append(num);
            } else {
                try rightList.append(num);
            }
            toggle = !toggle;
            count = 0;
            numStr = .{ 0, 0, 0, 0, 0 };
        }
    }

    std.mem.sort(i32, leftList.items, {}, std.sort.asc(i32));
    std.mem.sort(i32, rightList.items, {}, std.sort.asc(i32));

    var totalDistance: isize = 0;

    var numCounts = std.AutoHashMap(i32, i32).init(allocator);
    defer numCounts.deinit();

    for (0..rightList.items.len) |index| {
        totalDistance += @abs(rightList.items[index] - leftList.items[index]);
        if (numCounts.get(rightList.items[index])) |numCount| {
            try numCounts.put(rightList.items[index], numCount + 1);
        } else {
            try numCounts.put(rightList.items[index], 1);
        }
    }
    std.debug.print("Part 1:\n", .{});
    std.debug.print("Total distance: {d}\n", .{totalDistance});

    var totalSimilarity: i32 = 0;
    for (leftList.items) |num| {
        totalSimilarity += (numCounts.get(num) orelse 0) * num;
    }
    std.debug.print("Part 2:\n", .{});
    std.debug.print("Total similarity: {d}\n", .{totalSimilarity});
}
