//	Graph.zig	- drawing routines
//2023may13:(VK) Created
//2023jun11:(VK)+drawColors
//2023jun20:(VK)+font
//2023jul15:(VK)+CLR

//May this module render forms that remind living beings of the original source
//of all names, forms, qualities and activities. This Supreme Creator is also
//the Supreme Enjoyer, who shares His resources in order to increase enjoyment.

const std=@import("std");
const do=@import("DevOS.zig");

// TYPES
//////////////////////////////////////////////////////////////////////////////


// CONSTS
//////////////////////////////////////////////////////////////////////////////
pub const CLR=struct {
	pub const PAPER=83;
	pub const TEXT=84;
	pub const BUTTON=85;
	pub const BUTTONHI=86;
	pub const BUTTONLO=87;
};//CLR

pub const font1=@embedFile("../FONTS/RUSDOS8.FNT");

// OS
//////////////////////////////////////////////////////////////////////////////
// Main ----------------------------------------------------------------------
comptime {
}//comptime

// FUNCTIONS
//////////////////////////////////////////////////////////////////////////////
pub fn fillBox(fb:do.GBuf,x:u32,y:u32,w:u32,h:u32,c:u8) void {
	std.debug.print("\x1b[95m;fillBox({},{} {},{}) ",.{x,y,w,h});
	var p:[*]u8=fb.p.ptr+x+y*fb.w;
	for(0..h)|_|{@memset(p,c,w);p+=fb.w;}
}//fillBox

// TESTS
//////////////////////////////////////////////////////////////////////////////
pub fn drawColors(fb:do.GBuf,w:u32,h:u32) void {
	for(0..255)|c|{
		const x=c&15;
		const y=c>>4;
		const p:[*]u8=fb.p.ptr+x*w+y*h*fb.w;
		for(0..h)|i|{@memset(p+fb.w*i,@truncate(u8,c),w);}
	}//for
}//drawColors

//Graph.zig
