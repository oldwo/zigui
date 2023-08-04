//	DevOS.zig	- library root
//2023apr25:(VK) Created
//2023may07:(VK)!works
//2023may08:(VK)+OSwin
//2023may08:(VK)+GBuf
//2023may16:(VK)+say
//2023jun03:(VK)+OSwin,IRender
//2023jun13:(VK)+Timer
//2023jul16:(VK)+beep
//2023jul27:(VK)+IAnyList
	
// Obeisances to The Supreme Absolute Person, who is the only independent enjoyer.
//By his sandhini potency everything is maintained united. By his samvit potency,
//everything is revealed. By his hladini potency, everything brings about bliss.
//Thus everyone is engaged in the service of The Supreme Lord by His three
//pricipal internal energies.

const std=@import("std");
const builtin=@import("builtin");
const winmain=@import("MainMSWin.zig");
pub const Log=@import("Log.zig");
pub const IRender=@import("IRender.zig");
//pub const RenderStack=@import("RenderStack.zig").RenderStack.new;
//pub const StackWin=@import("RenderStack.zig").StackWin;
pub usingnamespace @import("StackWin.zig");
pub const BufWin=@import("BufWin.zig");
pub const PushButton=@import("Widgets/Button.zig");
pub const g8=@import("Graph.zig");
pub const timer=@import("Timer.zig");
pub const IAnyList=@import("IAnyList.zig");

// TYPES
//////////////////////////////////////////////////////////////////////////////
pub const HWND=std.os.windows.HWND;

pub const GBuf=struct {
	p:[]u8,
	w:u32,
};//GBuf

// VARS
//////////////////////////////////////////////////////////////////////////////

var aa=std.heap.GeneralPurposeAllocator(.{}){};
pub const a=aa.allocator();//std.testing.allocator;

// OS
//////////////////////////////////////////////////////////////////////////////
// Main ----------------------------------------------------------------------
comptime {
switch(builtin.os.tag) {
.windows=>{
//NOT ALLOWED:pub inline fn OSwin(...){}
//pub not allowed:const beep=winmain.beep;
},//.windows
.linux=>{},
else=>{}
}//switch
}//comptime

pub const main=winmain.wWinMain;
//pub const OSwin=winmain.OSwin;

pub fn say(text:[]const u8) void {
if (builtin.os.tag==.windows) {
	_=std.ChildProcess.exec(.{.allocator=std.heap.page_allocator,
		.argv=&[_][]const u8{"C:\\Program Files (x86)\\eSpeak\\command_line\\espeak.exe",text},
	}) catch unreachable;
}//.windows
}//say

pub fn beep() void {
if (builtin.os.tag==.windows) {
	_=winmain.MessageBeep(0xFFFFFFFF);//0=MB_OK MB_ICONQUESTION 0x40=MB_ICONINFORMATION MB_ICONWARNING MB_ICONERROR 
}//.windows
}//beep
 
// FUNCTIONS
//////////////////////////////////////////////////////////////////////////////
pub inline fn OSwin(w:u32,h:u32,t:[*:0]const u8) *IRender {
	return winmain.OSwin.new(w,h,t);
}//OSwin

//DevOS.zig
