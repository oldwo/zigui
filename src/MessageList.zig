//	MessageList.zig
//2023may05:(VK) Created

const std=@import("std");
const debug=std.debug;
const assert=debug.assert;
const testing=std.testing;
const mem=std.mem;
const math=std.math;
const Allocator=mem.Allocator;

// VARS
//////////////////////////////////////////////////////////////////////////////
// std.heap.GeneralPurposeAllocator(.{}){};

// FUNCTIONS
//////////////////////////////////////////////////////////////////////////////
// TEdit ---------------------------------------------------------------------
// MList ---------------------------------------------------------------------
pub fn MList(comptime T1:type,comptime T2:type) type {
	return struct {
const Self=@This();
const Callback=fn(a1:T1,a2:T2) void;
const Page=struct {
	prev:?*Page,
	next:?*Page,
};//Page

allocator:Allocator,
firstpage:*Page,
lastpage:*Page,

pub fn init(allocator:Allocator) Self {
var page=Page{.prev=null,.next=null};//TODO:allocate!
return Self{
	.allocator=allocator,
	.firstpage=&page,//TODO:allocate!
	.lastpage=&page,
};}//init
pub fn deinit(self:*Self) void {_=self;{}}
pub fn push(self:*Self) void {
	_=self;
	{}
}//push
};}//MList

test "MessageList" {
	var ml=MList(u8,i32).init(testing.allocator);
	defer ml.deinit();

	ml.push();
	try testing.expect(ml.firstpage==ml.lastpage);
}//test
