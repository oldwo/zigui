//	StackWin.zig	- helper routines
//2023may22:(VK) Created
//2023jun04:(VK)+BUF8
//2023jun15:(VK)+DRAW8
//2023jun16:(VK)+TSignal
//2023jul31:(VK)+wproc,PAINT

// GAORA BHAKTA VINDA

const std=@import("std");
const do=@import("DevOS.zig");
const BufWin=@import("BufWin.zig");
const assert=std.debug.assert;
const expect=std.testing.expect;

// TYPES
//////////////////////////////////////////////////////////////////////////////
const SW=@This();
pub const StackWin=@This();
const SGroup=struct {
	dx:i32,dy:i32,
	//children:[]u16,
};//SGroup
const SDraw=struct {
	f:*fn(ctx:*anyopaque)void,
	ctx:*anyopaque,
};//SDraw
pub const TWin=union(enum) {
	FREE:void,
	GROUP:SGroup,
	BAR:void,
	RECT:void,
	BUF8:struct{ctx:*anyopaque,dfb:usize,
		pub fn fb(self:*const @This())*do.GBuf{return @ptrCast(*do.GBuf,@alignCast(8,@ptrCast([*]u8,self.ctx)+self.dfb));}
	},//BufWin,
	DRAW8:SDraw,
	NOTHING:void,
};//TWin

pub const TSignal=union(enum) {
	MOUSEMOVE:struct{x:i32,y:i32},
	MOUSEDOWN:struct{x:i32,y:i32},
	MOUSEUP:struct{x:i32,y:i32},
	KEYDOWN:struct{k:i32,c:i8},
	KEYUP:struct{k:i32},
	PAINT:struct{},
};//TSignal

pub const TSignalF=fn(ctx:*anyopaque,signal:TSignal)isize;// !0=>consumed
	
// FIELDS
//////////////////////////////////////////////////////////////////////////////
x:i32,y:i32,
w:u32,h:u32,
p:u16=0,//parent
z:u16=0,//do we need this? cached render order
clr:u8,
alpha:u8=255,
t:TWin,
wproc:?*const TSignalF,
ctx:*anyopaque,
	
// VARS
//////////////////////////////////////////////////////////////////////////////

// FUNCTIONS
//////////////////////////////////////////////////////////////////////////////
pub inline fn pointInRect(x:i32,y:i32, left:i32,top:i32,w:u32,h:u32) bool {
	if(x<left or y<top) return false;
	if(x>=left+@bitCast(i32,w) or y>=top+@bitCast(i32,h)) return false;
	return true;
}//pointInRect
pub inline fn Bar(x:i32,y:i32,w:u32,h:u32,clr:u8) SW {
	return SW{.x=x,.y=y,.w=w,.h=h,.clr=clr,.t=TWin{.BAR={}},.wproc=null,.ctx=@constCast(&h)};
}//Bar
pub inline fn Rect(x:i32,y:i32,w:u32,h:u32,clr:u8) SW {return SW{.x=x,.y=y,.w=w,.h=h,.clr=clr,.t=TWin{.RECT={}},.wproc=null,.ctx=@constCast(&h)};}
pub inline fn Group(x:i32,y:i32,w:u32,h:u32,dx:u32,dy:u32) SW {
	return SW{.x=x,.y=y,.w=w,.h=h,.clr=0,.wproc=null,.ctx=@constCast(&h),.t=TWin{.GROUP=.{
		.dx=@intCast(i32,dx),
		.dy=@intCast(i32,dy),
		//.children=&[0]u16{},
	}}};
}//Group

// TESTS
//////////////////////////////////////////////////////////////////////////////
test "pointInRect" {
	try expect(pointInRect(1,1, 1,1,1,1));
	try expect(!pointInRect(1,1, 1,1,0,0));
	try expect(!pointInRect(2,1, 1,1,1,1));
	try expect(!pointInRect(1,2, 1,1,1,1));
	try expect(!pointInRect(0,1, 1,1,1,1));
	try expect(!pointInRect(1,0, 1,1,1,1));
}//pointInRect

//StackWin.zig
