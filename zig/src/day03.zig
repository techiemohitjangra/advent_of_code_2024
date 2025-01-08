const std = @import("std");
const c = @cImport({
    @cInclude("regex.h");
});

const Regex = struct {
    inner: *c.regex_t,

    fn init(pattern: [:0]const u8) !Regex {}
};

pub fn main() !void {}
