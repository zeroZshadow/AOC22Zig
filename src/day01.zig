const std = @import("std");
var gpa = std.heap.GeneralPurposeAllocator(.{}){};

const data = @embedFile("../data/day01.txt");

pub fn main() !void {
    defer _ = gpa.deinit();
    var list = std.ArrayList(u32).init(gpa.allocator());
    defer list.deinit();

    var iterator = std.mem.split(u8, data, "\n");

    var elfCalories: u32 = 0;
    while (iterator.next()) |line| {
        if (line.len == 0) {
            try list.append(elfCalories);

            // Next elf
            elfCalories = 0;
            continue;
        }

        //Parse int
        const number = try std.fmt.parseInt(u32, line, 10);
        elfCalories += number;
    }

    std.sort.sort(u32, list.items, {}, std.sort.desc(u32));

    // Part 1
    std.debug.assert(list.items[0] == 66186);
    std.log.info("Highest Calories = {}", .{list.items[0]});

    // Part 2
    var top3Total: u32 = 0;
    for (list.items[0..3]) |calories| top3Total += calories;
    std.debug.assert(top3Total == 196804);
    std.log.info("Top 3 total Calories = {}", .{top3Total});
}
