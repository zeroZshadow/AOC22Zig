const std = @import("std");

const data = @embedFile("../data/day04.txt");

const Range = struct {
    start: usize,
    end: usize,
    len: usize,

    pub fn fromText(text: []const u8) !Range {
        var iterator = std.mem.split(u8, text, "-");
        const start = try std.fmt.parseInt(usize, iterator.next().?, 10);
        const end = try std.fmt.parseInt(usize, iterator.next().?, 10);
        return Range{
            .start = start,
            .end = end,
            .len = end - start,
        };
    }

    pub fn contains(self: Range, other: Range) bool {
        if (self.len < other.len) return other.contains(self);

        if (other.start >= self.start and other.end <= self.end) {
            return true;
        }

        return false;
    }

    pub fn overlaps(self: Range, other: Range) bool {
        if (self.start > other.start) return other.overlaps(self);

        if (other.start - self.start > self.len) {
            return false;
        }

        return true;
    }
};

pub fn main() !void {
    var containsCount: u32 = 0;
    var overlapCount: u32 = 0;

    var lineIterator = std.mem.tokenize(u8, data, "\n");
    while (lineIterator.next()) |line| {
        var pairIteratopr = std.mem.split(u8, line, ",");
        const rangeA = try Range.fromText(pairIteratopr.next().?);
        const rangeB = try Range.fromText(pairIteratopr.next().?);

        if (rangeA.contains(rangeB)) {
            containsCount += 1;
        }

        if (rangeA.overlaps(rangeB)) {
            overlapCount += 1;
        }
    }

    //Part 1
    try std.testing.expectEqual(@as(usize, 528), containsCount);
    std.log.info("Contains count = {}", .{containsCount});

    //Part 2
    try std.testing.expectEqual(@as(usize, 881), overlapCount);
    std.log.info("Overlap count = {}", .{overlapCount});
}
