//	build.zig	- DevOS.zig
//2023apr25:(VK) Created
//2023may03:(VK)*v0.11 API
//2023may09:(VK)+cache_root

// https://stackoverflow.com/questions/76206472/how-to-change-the-local-cache-directory-for-the-zig-build-system

const std=@import("std");
const Builder=@import("std").build.Builder;

pub fn build(b:*Builder) void {
	//b.cache_root=.{.path="I:/vkcA"};
	b.cache_root=.{.path="I:/vkcA",.handle=std.fs.openDirAbsolute("I:/",.{}) catch unreachable};
	const target=b.standardTargetOptions(.{});
	const optimize=b.standardOptimizeOption(.{.preferred_optimize_mode=.ReleaseSmall,});
	const exe=b.addExecutable(.{
		.name="demo1",
		.root_source_file=.{.path="app1/main.zig"},
		.target=target,
		.optimize=optimize,
//		.cache_root="I:\\zig",
	});
	//exe.valgrind_support=true;
	exe.strip=false;

	const devos=b.addModule("DevOS",.{
		.source_file=.{.path="src/DevOS.zig"},
	});
	exe.addModule("DevOS",devos);
	const run_cmd=exe.run();

	const run_step=b.step("run","Run the app");
	run_step.dependOn(&run_cmd.step);

	b.default_step.dependOn(&exe.step);
	b.installArtifact(exe);
	//@import("std").debug.print("Hello! {}\nBye!", .{exe});
}//build
