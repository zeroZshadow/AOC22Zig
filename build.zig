const std = @import("std");
const Builder = std.build.Builder;
const LibExeObjStep = std.build.LibExeObjStep;

const test_files = [_][]const u8{
    // list any zig files with tests here
};

pub fn build(b: *Builder) !void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    b.setPreferredReleaseMode(.Debug);
    const mode = b.standardReleaseOptions();

    // Set up an exe for each day
    const cwd = std.fs.cwd();
    var day: u32 = 1;
    while (day <= 25) : (day += 1) {
        const dayString = b.fmt("day{:0>2}", .{day});
        const zigFile = b.fmt("src/{s}.zig", .{dayString});

        // Skip days not implemented yet
        var file = std.fs.Dir.openFile(cwd, zigFile, .{}) catch |err| switch (err) {
            error.FileNotFound => break,
            else => return err,
        };
        file.close();

        const exe = b.addExecutable(dayString, zigFile);
        exe.setTarget(target);
        exe.setBuildMode(mode);
        if (mode == .ReleaseSmall) {
            exe.strip = true;
        }
        exe.setMainPkgPath(".");

        const install_cmd = b.addInstallArtifact(exe);
        const run_cmd = exe.run();
        run_cmd.step.dependOn(&install_cmd.step);
        if (b.args) |args| {
            run_cmd.addArgs(args);
        }

        const run_desc = b.fmt("Run {s}", .{dayString});
        const run_step = b.step(dayString, run_desc);
        run_step.dependOn(&run_cmd.step);
    }

    // Set up a step to run all tests
    const test_step = b.step("test", "Run all tests");
    for (test_files) |file| {
        const test_cmd = b.addTest(file);
        test_cmd.setTarget(target);
        test_cmd.setBuildMode(mode);

        test_step.dependOn(&test_cmd.step);
    }
}
