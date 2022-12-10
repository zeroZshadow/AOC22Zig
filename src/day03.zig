const std = @import("std");

const data = @embedFile("../data/day03.txt");
const Set = std.bit_set.StaticBitSet(52);

pub fn main() !void {
    var sumOfDuplicates: usize = 0;
    var sumOfBadges: usize = 0;

    var groupSets: [3]Set = undefined;
    var groupIndex: usize = 0;
    var iterator = std.mem.tokenize(u8, data, "\n");
    while (iterator.next()) |line| {
        var set = Set.initEmpty();
        var groupSet = Set.initEmpty();

        const pocketSize = line.len / 2;
        for (line[0..pocketSize]) |item| {
            const index = charToIndex(item);
            set.set(index);
            groupSet.set(index);
        }
        for (line[pocketSize..line.len]) |item| {
            const index = charToIndex(item);
            groupSet.set(index);
            if (set.isSet(index)) {
                sumOfDuplicates += index + 1;
            }
        }

        groupSets[groupIndex] = groupSet;
        if (groupIndex == 2) {
            const intersect = groupSets[0].intersectWith(groupSets[1]).intersectWith(groupSets[2]);
            const index = intersect.findFirstSet().?;
            sumOfBadges += index + 1;
        }

        groupIndex = @mod(groupIndex + 1, 3);
    }

    //Part 1
    try std.testing.expectEqual(@as(usize, 10911), sumOfDuplicates);
    std.log.info("Sum of duplicates = {}", .{sumOfDuplicates});

    //Part 2
    try std.testing.expectEqual(@as(usize, 2602), sumOfBadges);
    std.log.info("Sum of badges = {}", .{sumOfBadges});
}

fn charToIndex(character: u8) usize {
    return switch (character) {
        'a'...'z' => character - 'a',
        'A'...'Z' => character - 'A' + 26,
        else => unreachable,
    };
}
