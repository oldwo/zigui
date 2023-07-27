//	Log.zig	- print debugging
//2023jun03:(VK) Created

// MADHUSUDANAYA NAMAH

const std=@import("std");
//const do=@import("DevOS.zig");
const assert=std.debug.assert;
const expect=std.testing.expect;

// TYPES
//////////////////////////////////////////////////////////////////////////////

// VARS
//////////////////////////////////////////////////////////////////////////////

// FIELDS
//////////////////////////////////////////////////////////////////////////////

// FUNCTIONS
//////////////////////////////////////////////////////////////////////////////
pub fn txt(t:[]const u8) void {std.debug.print("\x1b[43mL\x1b[m{s} ",.{t});}

pub fn log(comptime fmt:[]const u8,args:anytype) void {
	std.debug.print("\x1b[93m",.{});
	std.debug.print(fmt,args);
	std.debug.print("\x1b[m\n",.{});
}//msg

fn logfn(comptime prefix:[]const u8,comptime postfix:[]const u8) type {return struct{
	fn print(comptime fmt:[]const u8,args:anytype) void {
//std.debug.print("\x1b["++prefix++"m",.{});
std.debug.print(prefix,.{});
std.debug.print(fmt,args);
std.debug.print(postfix,.{});
	}//print
};}//logfn
pub const msg=logfn("\x1b[43m","\x1b[m\n").print;
pub const warn=logfn("\x1b[97;41m","\x1b[m\n").print;
pub const val=logfn("\x1b[36m","\x1b[m ").print;
pub const trace=logfn("\n\x1b[7m","\x1b[m").print;
pub const begin=logfn("\n\x1b[91m","\x1b[m").print;
pub const red=logfn("\x1b[31m","\x1b[m").print;
pub const blue=logfn("\x1b[94m","\x1b[m").print;
pub const info=logfn("\x1b[36;4;7mi\x1b[27m","\x1b[24m\n").print;
pub const single=logfn("\n\x1b[97m","\x1b[m").print;

comptime {inline for(.{.{}})|t|{
	//log("comptime!",.{t});
	_=t;
}}//for

// TESTS
//////////////////////////////////////////////////////////////////////////////
test "pointInRect" {
	//try expect(std.mem.eql(i32,&dst,&[4]i32{0,0,1,1}));
}//intersectRelRect

//Log.zig
