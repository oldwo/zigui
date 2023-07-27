//	build.zig	- DevOS.zig
//2023apr25:(VK) Created
//2023may03:(VK)*v0.11 API
//2023may09:(VK)+cache_root
//2023jul22:(VK)+exe2=animatext

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
	const exe2=b.addExecutable(.{
		.name="animatext",
		.root_source_file=.{.path="app/animatext.zig"},
		.target=target,
		.optimize=optimize,
	});
	exe2.strip=false;

	const devos=b.addModule("DevOS",.{
		.source_file=.{.path="src/DevOS.zig"},
	});
	exe.addModule("DevOS",devos);
	exe2.addModule("DevOS",devos);
	const run_cmd=exe.run();

	const run_step=b.step("run","Run the app");
	run_step.dependOn(&run_cmd.step);

	b.default_step.dependOn(&exe2.step);
	b.installArtifact(exe);
	b.installArtifact(exe2);
	//@import("std").debug.print("Hello! {}\nBye!", .{exe});
	b.step("anib","build Text animation").dependOn(&exe2.step);
	b.step("ani","Text animation demo").dependOn(&exe2.run().step);
}//build
