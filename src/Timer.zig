//	Timer.zig	- OS-independent schedule list
//2023jun12:(VK) Created
//2023jul24:(VK)+repeat

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
//	if(now<Snext) return;
	Snext=std.math.maxInt(i64);
	Log.blue("{}t",.{list.items.len});
	for(list.items)|*sig|{
		if(sig.when>now) continue;
		//Log.info("sig={}",.{sig});
		if(!sig.f(sig.ctx,now) or 0==sig.next) {
			sig.when=0;//Shrinking the list mid-iteration crashes:_=list.swapRemove(i);//will miss last item this time
		} else {sig.when+=sig.next;}//if
		if(sig.when<Snext) Snext=sig.when;
	}//for
	var i=list.items.len;
	while(i>0) {
		i-=1;
		if(0==list.items[i].when) _=list.swapRemove(i);
	}//while
}//signal

/// next=0 means "no repeat", times in microseconds
pub fn addTimerAbs(f:*const Tcallback,ctx:*anyopaque,when:i64,next:i32) void {
	list.append(.{.f=f,.ctx=ctx,.when=when,.next=next}) catch unreachable;
}//addTimerAbs

pub fn addTimerr(f:*const Tcallback,ctx:*anyopaque,delayms:i32,nextms:i32) void {
	addTimerAbs(f,ctx,std.time.microTimestamp()+delayms*1000,nextms*1000);
}//addTimer

// TESTS
//////////////////////////////////////////////////////////////////////////////
test "pointInRect" {
//	try expect(!pointInRect(1,1, 1,1,0,0));
}//pointInRect

//Timer.zig
