//	Timer.zig	- OS-independent schedule list
//2023jun12:(VK) Created

// SUDARZANA

const std=@import("std");
const do=@import("DevOS.zig");
const Log=@import("Log.zig");
const assert=std.debug.assert;
const expect=std.testing.expect;

// TYPES
//////////////////////////////////////////////////////////////////////////////
//const Titem=@TypeOf(.{fn()void,*anyopaque});
//@compileLog(.{1,'a',"B"});
const Tcallback=fn(ctx:*anyopaque,us:i64)bool;//f returns:repeat?
const Titem=struct{f:*const Tcallback,ctx:*anyopaque,when:i64,next:i32};

// VARS
//////////////////////////////////////////////////////////////////////////////
var list:std.ArrayList(Titem)=undefined;
var Snext:i64=0;

// FUNCTIONS
//////////////////////////////////////////////////////////////////////////////
pub inline fn init() void {list=@TypeOf(list).init(do.a);}

pub inline fn signal() void {
	const now=std.time.microTimestamp();
	if(now<Snext) return;
	for(list.items,0..)|sig,i|{
		Log.info("sig={}",.{sig});
		if(!sig.f(sig.ctx,now)) {
			_=list.swapRemove(i);//will miss last item this time
		}//if
	}//for
}//signal

/// next=0 means "no repeat", times in microseconds
pub fn addTimer(f:*const Tcallback,ctx:*anyopaque,when:i64,next:i32) void {
	list.append(.{.f=f,.ctx=ctx,.when=when,.next=next}) catch unreachable;
}//addTimer

// TESTS
//////////////////////////////////////////////////////////////////////////////
test "pointInRect" {
//	try expect(!pointInRect(1,1, 1,1,0,0));
}//pointInRect

//Timer.zig
