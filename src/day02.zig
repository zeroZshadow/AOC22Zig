const std = @import("std");
var gpa = std.heap.GeneralPurposeAllocator(.{}){};

const data = @embedFile("../data/day02.txt");

const RockPaperScissors = enum(i8) {
    Rock = 1, //A X 1
    Paper = 2, //B Y 2
    Scissors = 3, //C Z 3

    pub fn fromCharacter(pick: u8) RockPaperScissors {
        return switch (pick) {
            'A', 'X' => .Rock,
            'B', 'Y' => .Paper,
            'C', 'Z' => .Scissors,
            else => |character| {
                std.log.err("Unknown pick {c}", .{character});
                @panic("invalid parse");
            },
        };
    }
};

const RoundChoice = enum {
    Lose,
    Draw,
    Win,

    pub fn fromCharacter(pick: u8) RoundChoice {
        return switch (pick) {
            'X' => .Lose,
            'Y' => .Draw,
            'Z' => .Win,
            else => |character| {
                std.log.err("Unknown pick {c}", .{character});
                @panic("invalid parse");
            },
        };
    }
};

pub fn main() !void {
    var iterator = std.mem.split(u8, data, "\n");
    var totalScoreA: u32 = 0;
    var totalScoreB: u32 = 0;
    while (iterator.next()) |line| {
        if (line.len == 0) continue;

        const opponentPick = RockPaperScissors.fromCharacter(line[0]);
        const myPick = RockPaperScissors.fromCharacter(line[2]);
        const goal = RoundChoice.fromCharacter(line[2]);

        // Part 1
        const score = calculateScore(myPick, opponentPick);
        totalScoreA += score;

        // Part 2
        var opponentScoreNormalized = @enumToInt(opponentPick) - 1;
        var pickScore = switch (goal) {
            .Lose => 0 + @mod((opponentScoreNormalized + 2), 3) + 1,
            .Draw => 3 + opponentScoreNormalized + 1,
            .Win => 6 + @mod((opponentScoreNormalized + 1), 3) + 1,
        };
        totalScoreB += @intCast(u32, pickScore);
    }

    // Part 1
    std.debug.assert(totalScoreA == 10624);
    std.log.info("Total score: {}", .{totalScoreA});

    // Part 2
    std.debug.assert(totalScoreB == 14060);
    std.log.info("Target score: {}", .{totalScoreB});
}

fn calculateScore(myPick: RockPaperScissors, opponentPick: RockPaperScissors) u32 {
    const score = @enumToInt(myPick);
    const decision = @enumToInt(opponentPick) - score;
    if (decision == 0) {
        return @intCast(u32, score + 3);
    }

    if (decision < 0) {
        return @intCast(u32, score + 6 * (decision & 1));
    } else {
        return @intCast(u32, score + 6 * (1 - (decision & 1)));
    }
}
