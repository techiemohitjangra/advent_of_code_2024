const std = @import("std");
const Allocator = std.mem.Allocator;

const Calibrations = struct {
    calibrations: std.hash_map.HashMap(i64, []i64, std.hash_map.AutoContext(i64), 80),

    pub fn init(allocator: Allocator, filename: []const u8) !Calibrations {
        const buffer = try read_data(allocator, filename);
        defer allocator.free(buffer);
        const calibrations = try parse_data(allocator, buffer);
        return Calibrations{
            .calibrations = calibrations,
        };
    }

    pub fn deinit(self: *Calibrations, allocator: Allocator) void {
        var iter = self.calibrations.iterator();
        while (iter.next()) |entry| {
            const values = entry.value_ptr.*;
            allocator.free(values);
        }
        self.calibrations.deinit();
    }

    pub fn read_data(allocator: Allocator, filename: []const u8) ![]u8 {
        const file = try std.fs.openFileAbsolute(filename, .{ .mode = .read_only });
        defer file.close();

        const file_stats = try file.stat();
        const buffer: []u8 = try allocator.alloc(u8, file_stats.size);

        const data_read = try file.read(buffer);
        std.debug.assert(data_read == file_stats.size);
        return buffer;
    }

    pub fn parse_data(allocator: Allocator, buffer: []u8) !std.hash_map.HashMap(i64, []i64, std.hash_map.AutoContext(i64), 80) {
        var data = std.hash_map.HashMap(i64, []i64, std.hash_map.AutoContext(i64), 80).init(allocator);
        var lines: std.mem.SplitIterator(u8, .sequence) = std.mem.split(u8, std.mem.trim(u8, buffer, " \r\n\t"), "\n");
        while (lines.next()) |line| {
            var target_and_nums: std.mem.SplitIterator(u8, .sequence) = std.mem.split(u8, std.mem.trim(u8, line, " \r\n\t"), ":");
            if (target_and_nums.next()) |target_string| {
                const target: i64 = try std.fmt.parseInt(i64, std.mem.trim(u8, target_string, " \r\n\t"), 10);
                if (target_and_nums.next()) |value_string| {
                    var nums_str = std.mem.split(u8, std.mem.trim(u8, value_string, " \r\n\t"), " ");
                    var num_count: usize = 0;
                    while (nums_str.next()) |_| : (num_count += 1) {}
                    nums_str.reset();
                    const nums = try allocator.alloc(i64, num_count);
                    var idx: usize = 0;
                    while (nums_str.next()) |num_str| : (idx += 1) {
                        nums[idx] = try std.fmt.parseInt(i64, std.mem.trim(u8, num_str, " "), 10);
                    }
                    try data.put(target, nums);
                }
            }
        }
        return data;
    }

    pub fn print(self: *const Calibrations) void {
        var iter = self.calibrations.iterator();
        while (iter.next()) |entry| {
            std.debug.print("{d}: {any}\n", .{ entry.key_ptr.*, entry.value_ptr.* });
        }
    }

    fn two_operator_check(target: i64, nums: []i64, res: i64) bool {
        if (res == target and nums.len == 0) return true;
        if (nums.len < 1) return false;
        const add = two_operator_check(target, nums[1..], res + nums[0]);
        const mult = two_operator_check(target, nums[1..], res * nums[0]);
        if (add or mult) {
            return true;
        }
        return false;
    }

    fn digit_count(num: usize) i64 {
        if (num == 0) return 1;
        var temp: usize = num;
        var count: i64 = 0;
        while (temp != 0) : (count += 1) {
            temp = temp / 10;
        }
        return count;
    }

    pub fn three_operator_check(target: i64, nums: []i64, res: i64) bool {
        if (res == target and nums.len == 0) return true;
        if (nums.len < 1) return false;
        const add = three_operator_check(target, nums[1..], res + nums[0]);
        const mult = three_operator_check(target, nums[1..], res * nums[0]);
        const concat = three_operator_check(target, nums[1..], res * std.math.pow(i64, 10, digit_count(@intCast(nums[0]))) + nums[0]);
        if (add or mult or concat) {
            return true;
        }
        return false;
    }

    pub fn part1(self: *Calibrations) i64 {
        var res: i64 = 0;
        var iter = self.calibrations.iterator();
        while (iter.next()) |entry| {
            const nums = entry.value_ptr.*;
            if (two_operator_check(entry.key_ptr.*, nums[1..], nums[0])) {
                res += entry.key_ptr.*;
            }
        }
        return res;
    }

    pub fn part2(self: *Calibrations) i64 {
        var res: i64 = 0;
        var iter = self.calibrations.iterator();
        while (iter.next()) |entry| {
            const nums = entry.value_ptr.*;
            if (two_operator_check(entry.key_ptr.*, nums[1..], nums[0])) {
                res += entry.key_ptr.*;
            } else if (three_operator_check(entry.key_ptr.*, nums[1..], nums[0])) {
                res += entry.key_ptr.*;
            }
        }
        return res;
    }
};

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const filename: []const u8 = "/home/mohitjangra/learning/advent_of_code_2024/inputs/day07.input";
    var calib: Calibrations = try Calibrations.init(allocator, filename);
    defer calib.deinit(allocator);

    const pt1_result = calib.part1();
    std.debug.assert(pt1_result == 882304362421);

    const pt2_result = calib.part2();
    std.debug.assert(pt2_result == 145149066755184);
}

test {
    const allocator = std.testing.allocator;
    const filename: []const u8 = "/home/mohitjangra/learning/advent_of_code_2024/tests/day07.test";
    var calib: Calibrations = try Calibrations.init(allocator, filename);
    defer calib.deinit(allocator);

    const pt1_result = calib.part1();
    try std.testing.expect(pt1_result == 3749);

    const pt2_result = calib.part2();
    try std.testing.expect(pt2_result == 11387);
}

test "digit count test" {
    const first: isize = 1234;
    const second: isize = 90871234;
    const third: isize = 987234;
    try std.testing.expect(Calibrations.digit_count(first) == 4);
    try std.testing.expect(Calibrations.digit_count(second) == 8);
    try std.testing.expect(Calibrations.digit_count(third) == 6);
}

test "three_operator_check test" {
    const allocator = std.testing.allocator;
    const filename: []const u8 = "/home/mohitjangra/learning/advent_of_code_2024/tests/day07.sample";
    var calib: Calibrations = try Calibrations.init(allocator, filename);
    defer calib.deinit(allocator);

    var iter = calib.calibrations.iterator();
    while (iter.next()) |entry| {
        const target = entry.key_ptr.*;
        const nums = entry.value_ptr.*;
        try std.testing.expect(Calibrations.three_operator_check(target, nums[1..], nums[0]) == true);
    }
}
