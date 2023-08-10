//	BufWin.zig	- draw widgets into a frame buffer
//2023may27:(VK) Created
//2023jun04:(VK)+IRender
//2023jul28:(VK)+asIRender
//2023jul31:(VK)+subRender
//2023aug06:(VK)+addChanger
	
//	May this module render forms that remind living beings of the original source
//	of all names, forms, qualities and activities. This Supreme Creator is also
//	the Supreme Enjoyer, who shares His resources in order to increase enjoyment.

const std=@import("std");
const do=@import("DevOS.zig");
const Log=@import("Log.zig");
//const rs=@import("RenderStack.zig");
const IRender=@import("IRender.zig");
const TStackWin=@import("StackWin.zig");
const u=@import("Util.zig");

const BufWin=@This();

// FIELDS
//////////////////////////////////////////////////////////////////////////////
//Fnx:u32,
ny:u32,
fb:do.GBuf,
subRender:?*IRender,

///for subRender
pub const vtable=.{.renderOne=renderOne,.invalidate=invalidate};

// TYPES
//////////////////////////////////////////////////////////////////////////////

// FUNCTIONS
//////////////////////////////////////////////////////////////////////////////
pub fn make(w:u32,h:u32) BufWin {//returns value, on stack or optimized
	return BufWin{
//.Fnx=w,
.ny=h,
.fb=do.GBuf{.p=do.a.alloc(u8,@intCast(usize,w*h)) catch unreachable,.w=w},
.subRender=null,
	};//BufWin
}//make
pub fn setRender(self:*BufWin,ir:*do.IRender,h:u16) void {
	//_=self;
	//_=ir;//.bufWin=bw;	_=h;
	ir.setSignal(h,signal);
	//self.h=h;
	//ir.addMouser(0x00,0xFF,@ptrCast(*const do.IRender.Tcallback,&mouseSignal),self,h);
	//ir.addOmniMouser(0,0x800000,@ptrCast(*const do.IRender.Tcallback,&mouseOmniSignal),self,h);
// fn addRender(self:*IRender,cb:*const RenderList.Tcallback,ctx:*anyopaque,h:u16)
	if(self.subRender)|sr|{
		sr.addChanger(IRender.cbChange,ir,h);
	}//if
}//setRender
pub fn unsetRender(self:*BufWin,ir:*do.IRender) void {
	_=self;_=ir;
}//unsetRender

pub fn asRender(bw:*BufWin) *do.IRender {
	if(bw.subRender)|r| return r else unreachable;
	bw.subRender=IRender.new(bw.fb.w,bw.ny,bw,&.{.renderOne=renderOne,.invalidate=invalidate});
	Log.trace("BufWin={*}'IR={*}",.{bw,bw.subRender.?});
	//subscribe events?
	return bw.subRender.?;
}//asRender

///probably will do without this
pub inline fn addRender(self:*IRender,cb:*const @import("NotifyList.zig").RenderChange.Tcallback,ctx:*anyopaque,h:u16) void {
	_=self;_=cb;_=ctx;_=h;
}//addRender

// PRIVATE -------------------------------------------------------------------
fn renderOne(uhdc:usize,ctx:*anyopaque,clip:*[4]i32,ss:u.TSideSet,sw:*TStackWin) void {
	Log.msg("BufWin.renderOne clip={any} ss={}",.{clip.*,ss});
	_=uhdc;
	const self=@ptrCast(*BufWin,@alignCast(8,ctx));
	//_=ss;
	switch(sw.t) {
	.FREE,.GROUP,.NOTHING=>{},
	.BAR=>{
		//already done in IRender: _=u.intersectRelRect(sw.x,sw.y,sw.w,sw.h,clip,clip[0..]);
		do.g8.fillBox(self.fb,@intCast(u32,clip[0]),@intCast(u32,clip[1]),@intCast(u32,clip[2]),@intCast(u32,clip[3]),sw.clr);
	},//BAR
	.RECT=>{
		do.g8.clipRect(self.fb,clip[0],clip[1],clip[2],clip[3],sw.clr,ss);
	},//RECT
	.BUF8=>|bw|{
		Log.trace("BUF8({},{},)",.{sw.x,sw.y});
		_=bw;//const bwfb=bw.fb();
	},//BUF8
	.DRAW8=>|d|{
		Log.trace("DRAW8{}",.{d});
		unreachable;
	},//DRAW8
	//else =>unreachable,
	}//switch
}//renderOne

fn invalidate(ctx:*anyopaque,x:i32,y:i32,w:i32,h:i32) void {
	const self=@ptrCast(*BufWin,@alignCast(8,ctx));
	Log.begin("BufWin.invalidate({},{},{},{})",.{x,y,w,h});
	if(self.subRender)|sr|{
		sr.rerender();
	}//if
}//invalidate

fn signal(sw:*do.StackWin,h:u16,Asignal:do.StackWin.TSignal) isize {// !0=>consumed
	_=h;
	const self=@ptrCast(*BufWin,@alignCast(8,sw.t.BUF8.ctx));
	const sr=self.subRender orelse return 0;
	return if(switch(Asignal){
	.PAINT=>{sr.rerender();return 0;},
	.MOUSEMOVE=>|m|sr.mouseSignal(m.x,m.y,m.b),
	.MOUSEDOWN=>|m|sr.mouseSignal(m.x,m.y,m.b),
	.MOUSEUP=>|m|sr.mouseSignal(m.x,m.y,m.b),
	else =>unreachable,
	}//switch
	) 1 else 0;//if consumed
}//signal

// TESTS
//////////////////////////////////////////////////////////////////////////////

//BufWin.zig
