//	NotifyList.zig
//2023may18:(VK) Created
//2023jun24:(VK)+
//2023jul04:(VK)+signalMouse
//2023jul08:(VK)+MouseList
//2023jul12:(VK)+RenderChange

const std=@import("std");
const assert=std.debug.assert;
const testing=std.testing;
const Allocator=std.mem.Allocator;

const do=@import("DevOS.zig");
const Log=do.Log;

// FUNCTIONS
//////////////////////////////////////////////////////////////////////////////
// NList ---------------------------------------------------------------------
pub fn NList(comptime Tcallback:type,comptime Targ:[]const type) type {
	_=Targ;
	return struct {
const Self=@This();
const Page=struct {
	prev:?*Page,
	next:?*Page,
};//Page
const Titem=struct {
Fxor:u32,
Fand:u32,
cb:*const Tcallback,
ctx:*anyopaque,
};//Tcb

// FIELDS --------------------------------------------------------------------
l:std.ArrayList(Titem),
firstpage:*Page,
lastpage:*Page,

// FUNCTIONS -----------------------------------------------------------------
pub fn init(allocator:Allocator) Self {
var page=Page{.prev=null,.next=null};//TODO:allocate!
return Self{
	//.allocator=allocator,
	.firstpage=&page,//TODO:allocate!
	.lastpage=&page,
	.l=std.ArrayList(Titem).init(allocator),//.{.capacity=0,.allocator=allocator,.items=?},
};}//init
pub fn deinit(self:*Self) void {_=self;{}}
pub fn add(self:*Self,Axor:u32,Aand:u32,cb:*const Tcallback,ctx:*anyopaque) void {
	self.l.append(Titem{.Fxor=Axor,.Fand=Aand,.cb=cb,.ctx=ctx}) catch unreachable;
}//add
pub fn signalMouse(self:*const Self,x:i32,y:i32,b:u32) void {
	std.debug.print("\x1b[5;122hH\x1b[96mNL/mouse: {},{}b{} ",.{x,y,b});
	for(self.l.items)|it|{
		if(0==b^it.Fxor&it.Fand)continue;
		it.cb(it.ctx,x,y,b);
	}//for
}//signalMouse
};}//NList

// RenderChange
//////////////////////////////////////////////////////////////////////////////
pub const RenderChange=struct {
// TYPES ---------------------------------------------------------------------
const Self=@This();
//const Tcallback=do.IRender.Tcallback;
//fn(a1:*const anyopaque,x:i32,y:i32,b:u32)void;
pub const Tcallback=fn(ctx:*anyopaque,h:u16,x:i32,y:i32,nx:i32,ny:i32,ir:*do.IRender)void;
const Titem=struct {
	cb:*const Tcallback,
	ctx:*anyopaque,
	h:u16,
};//Titem
// FIELDS --------------------------------------------------------------------
l:std.ArrayList(Titem),
// FUNCTIONS -----------------------------------------------------------------
pub fn init(allocator:Allocator) Self {return Self{.l=std.ArrayList(Titem).init(allocator)};}//init
pub fn deinit(self:*Self) void {self.l.deinit();}
pub fn add(self:*Self,cb:*const Tcallback,ctx:*anyopaque,h:u16) void {
	self.l.append(Titem{.cb=cb,.ctx=ctx,.h=h}) catch unreachable;
}//add
pub fn del(self:*Self,cb:*const Tcallback,ctx:*anyopaque,h:u16) void {
	for(self.l.items,0..)|it,i|{
		if(it.ctx==ctx and it.cb==cb and it.h==h) _=self.l.swapRemove(i);
	}//for
}//del
pub fn signal(self:*const Self,x:i32,y:i32,nx:i32,ny:i32,ir:*do.IRender) void {
	Log.msg("RenderChange",.{});
	for(self.l.items)|it|{
		it.cb(it.ctx,it.h,x,y,nx,ny,ir);
	}//for
}//signal
};//RenderChange

// MouseList
//////////////////////////////////////////////////////////////////////////////
pub const MouseList=struct {
// TYPES ---------------------------------------------------------------------
const Self=@This();
const Tcallback=do.IRender.Tcallback;
//fn(a1:*const anyopaque,x:i32,y:i32,b:u32)void;
const Titem=struct {
	Fxor:u32,
	Fand:u32,
	cb:*const Tcallback,
	ctx:*anyopaque,
	h:u16,
	z:u16,
};//Titem
// FIELDS --------------------------------------------------------------------
l:std.ArrayList(Titem),
// FUNCTIONS -----------------------------------------------------------------
pub fn init(allocator:Allocator) Self {return Self{.l=std.ArrayList(Titem).init(allocator)};}//init
pub fn deinit(self:*Self) void {self.l.deinit();}
pub fn add(self:*Self,Axor:u32,Aand:u32,cb:*const Tcallback,ctx:*anyopaque,h:u16) void {
	self.l.append(Titem{.Fxor=Axor,.Fand=Aand,.cb=cb,.ctx=ctx,.h=h,.z=0}) catch unreachable;
}//add

};//MouseList

// TESTS
//////////////////////////////////////////////////////////////////////////////
test "NotifyList" {
	var nl=NList(u8,&[_]type{i32}).init(testing.allocator);
	defer nl.deinit();

	nl.push();
	try testing.expect(nl.firstpage==nl.lastpage);
}//test
