//	Widgets/Button.zig	- push button widget
//2023may27:(VK) Created
//2023jun22:(VK)+fb
//2023jun23:(VK)+setRender
//2023jul04:(VK)+mouseSignal
//2023jul16:(VK)+hover

// īśhvaraḥ sarva-bhūtānāṁ hṛid-deśhe ‘rjuna tiṣhṭhati
// bhrāmayan sarva-bhūtāni yantrārūḍhāni māyayā (BG 18.61)

const std=@import("std");
const do=@import("../DevOS.zig");
const CLR=do.g8.CLR;

// CONSTS
//////////////////////////////////////////////////////////////////////////////
const PushButton=@This();

const CLR_HOVER:u8=185;
const CLR_BG:u8=144;

// FIELDS
//////////////////////////////////////////////////////////////////////////////
Fx:i32,
Fy:i32,
nx:u32,
ny:u32,
//bufWin:?*do.BufWin,
fb:do.GBuf,
h:u16,
hover:bool,
	
// TYPES
//////////////////////////////////////////////////////////////////////////////
pub const CFG=struct {
	x:i32,
	y:i32,
};

// VARS
//////////////////////////////////////////////////////////////////////////////

// OS
//////////////////////////////////////////////////////////////////////////////
// Main ----------------------------------------------------------------------
comptime {
}//comptime

// FUNCTIONS
//////////////////////////////////////////////////////////////////////////////

// Init ----------------------------------------------------------------------
pub fn make(cfg:CFG) PushButton {//returns value, on stack or optimized
	const w=64;
	const h=40;
	return PushButton{
		.Fx=cfg.x,
		.Fy=0,
		.nx=w,
		.ny=h,
		//.bufWin=null,
		.fb=do.GBuf{.p=do.a.alloc(u8,@intCast(usize,w*h)) catch unreachable,.w=w},
		.h=undefined,
		.hover=false,
	};//PushButton
}//make
pub fn setConfig() void {}
pub fn setRender(self:*PushButton,ir:*do.IRender,h:u16) void {
	//_=self;_=ir;//self.bufWin=bw;
	self.h=h;
	ir.addMouser(0x00,0xFF,@ptrCast(*const do.IRender.Tcallback,&mouseSignal),self,h);
	ir.addOmniMouser(0,0x800000,@ptrCast(*const do.IRender.Tcallback,&mouseOmniSignal),self,h);
}//setRender
pub fn unsetRender(self:*PushButton,ir:*do.IRender) void {
	_=self;_=ir;
}//unsetRender
pub fn setClient() void {}

var Sc:u8=17;
fn mouseSignal(self:*const PushButton,x:i32,y:i32,b:u32,ir:*do.IRender) void {
	std.debug.print("\x1b[93mPBmouse: {},{}b{} ",.{x,y,b});
	self.draw();
	Sc=128-Sc;
	ir.invalidateWin(self.h);
	//_=self;
}//mouseSignal
fn mouseOmniSignal(self:*PushButton,x:i32,y:i32,b:u32,ir:*do.IRender) void {
	std.debug.print("\x1b[93mPBmOuse: {},{}b{} nx={} ",.{x,y,b,self.nx});
	self.hover=0==(b&0x80);
	self.draw();
	ir.invalidateWin(self.h);
}//mouseOmniSignal

fn draw(self:PushButton) void {
	do.g8.fillBox(self.fb,0,0,self.nx,self.ny,if(self.hover) CLR_HOVER else CLR_BG);
	do.g8.drawColors(self.fb,2,1);
	do.g8.fillBox(self.fb,16,18,12,4,0x7);
	do.g8.fillBox(self.fb,6,19,11,4,Sc);
	do.g8.text(self.fb,8,24,do.g8.TRelRect{.x=13,.y=5,.nx=42,.ny=27},"BuTton",0x2F);

}//draw

// Main ----------------------------------------------------------------------

//Button.zig
