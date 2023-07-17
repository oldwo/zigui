//	BufWin.zig	- draw widgets into a frame buffer
//2023may27:(VK) Created
//2023jun04:(VK)+IRender

//	May this module render forms that remind living beings of the original source
//	of all names, forms, qualities and activities. This Supreme Creator is also
//	the Supreme Enjoyer, who shares His resources in order to increase enjoyment.

const std=@import("std");
const do=@import("DevOS.zig");
//const rs=@import("RenderStack.zig");
const IRender=@import("IRender.zig");
const u=@import("Util.zig");

const BufWin=@This();

// FIELDS
//////////////////////////////////////////////////////////////////////////////
//Fnx:u32,
ny:u32,
fb:do.GBuf,

// TYPES
//////////////////////////////////////////////////////////////////////////////

// FUNCTIONS
//////////////////////////////////////////////////////////////////////////////
pub fn make(w:u32,h:u32) BufWin {//returns value, on stack or optimized
	return BufWin{
//.Fnx=w,
.ny=h,
.fb=do.GBuf{.p=do.a.alloc(u8,@intCast(usize,w*h)) catch unreachable,.w=w},
	};//BufWin
}//make
pub fn setRender(self:*BufWin,ir:*do.IRender,h:u16) void {
	_=self;_=ir;//.bufWin=bw;
	_=h;
	//ir.
}//setRender
pub fn unsetRender(self:*BufWin,ir:*do.IRender) void {
	_=self;_=ir;
}//unsetRender

// TESTS
//////////////////////////////////////////////////////////////////////////////

//BufWin.zig
