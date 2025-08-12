const std = @import("std");
const fs = std.fs;

pub fn main() !void {
    var general_purpose_allocator: std.heap.GeneralPurposeAllocator(.{}) = .init;
    const gpa = general_purpose_allocator.allocator();

    var arena_instance = std.heap.ArenaAllocator.init(gpa);
    defer arena_instance.deinit();

    const arean = arena_instance.allocator();

    const preopens = try fs.wasi.preopensAlloc(arean);

    for (preopens.names, 0..) |preopen, i| {
        std.debug.print("{}: {s}\n", .{ i, preopen });
    }
}
