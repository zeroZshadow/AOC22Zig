const std = @import("std");
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

const data = @embedFile("../data/day05.txt");

pub fn main() !void {
    defer _ = gpa.deinit();
    var stackList = std.ArrayList(std.ArrayList(u8)).init(allocator);
    defer stackList.deinit();
    defer for (stackList.items) |item| item.deinit();

    var lineIterator = std.mem.split(u8, data, "\n");
    // Parse boxes
    while (lineIterator.next()) |line| {
        if (line.len == 0) break;
        if (line[1] == '1') continue;

        var index: u32 = 0;
        while (index * 4 + 1 < line.len) : (index += 1) {
            var item = line[index * 4 + 1];
            switch (item) {
                'A'...'Z' => {},
                else => continue,
            }

            while (index >= stackList.items.len) {
                var newStack = std.ArrayList(u8).init(allocator);

                _ = try stackList.append(newStack);
            }

            try stackList.items[index].append(item);
        }
    }

    // Flip the stacks since we inserted in the reverse order
    for (stackList.items) |stack| {
        std.mem.reverse(u8, stack.items);
    }

    // Parse instructions
    while (lineIterator.next()) |line| {
        if (line.len == 0) break;

        var instructionIter = std.mem.tokenize(u8, line, "move from to");
        var amount = try std.fmt.parseInt(usize, instructionIter.next().?, 10);
        const index = try std.fmt.parseInt(usize, instructionIter.next().?, 10);
        const targetIndex = try std.fmt.parseInt(usize, instructionIter.next().?, 10);

        while (amount > 0) : (amount -= 1) {
            const item = stackList.items[index - 1].pop();
            try stackList.items[targetIndex - 1].append(item);
        }
    }

    // Part 1
    var topItems: []u8 = try allocator.alloc(u8, stackList.items.len);
    defer allocator.free(topItems);
    for (stackList.items) |stack, i| {
        topItems[i] = stack.items[stack.items.len - 1];
    }
    try std.testing.expectEqualStrings("FWSHSPJWM", topItems);
    std.log.info("Top crates are: {s}", .{topItems});
}
