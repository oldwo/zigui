//	IRender.zig	- handles a window stack (I/O). Implementors: RenderWin, RenderStack, RenderGL
//2023may28:(VK) Created
//2023jun11:(VK)+invalidate
//2023jun23:(VK)+
//2023jul08:(VK)+spoilZ; +!mouseSignal
//2023jul09:(VK)+redrawTimerSignal
//2023jul16:(VK)+omniMouseList
//2023jul21:(VK)+keySignal,dumpStack
//2023jul23:(VK)+renderList
//2023jul31:(VK)+setSignal
//2023aug04:(VK)+Fhdc
			
//	May this module render forms that remind living beings of the original source
//	of all names, forms, qualities and activities. This Supreme Creator is also
//	the Supreme Enjoyer, who shares His resources in order to increase enjoyment.

const std=@import("std");
const assert=std.debug.assert;

const do=@import("DevOS.zig");
const Log=@import("Log.zig");
const RenderList=@import("NotifyList.zig").RenderChange;
const MouseList=@import("NotifyList.zig").MouseList;
const g8=@import("Graph.zig");
const u=@import("Util.zig");
const StackWin=@import("StackWin.zig");
const BufWin=@import("BufWin.zig");
const SGroup=@import("RenderStack/Group.zig");

const IRender=@This();

const FOCUS=0x80;
const SERIES=0x40;//double click

// FIELDS
//////////////////////////////////////////////////////////////////////////////
ctx:*anyopaque,
vtable:*const VTable,

stack:std.ArrayList(StackWin),
stackZ:std.ArrayList(TZWin),
w:u32,
h:u32,
renderList:RenderList,
mouseList:MouseList,
omniMouseList:MouseList,
outdatedXYWH:[4]i32,
timer:bool=false,
Fhdc:usize,
	
// VTABLE
//////////////////////////////////////////////////////////////////////////////
pub const VTable=struct {
	/// Render one child
	renderOne:*const fn (hdc:usize,ctx:*anyopaque,clip:*[4]i32,ss:u.TSideSet,sw:*StackWin) void,
	invalidate:*const fn (ctx:*anyopaque,x:i32,y:i32,w:i32,h:i32) void,
};//VTable

// TYPES
//////////////////////////////////////////////////////////////////////////////
pub const Tcallback=fn(a1:*const anyopaque,x:i32,y:i32,a2:u32,ir:*IRender)void;
const TZWin=struct {
	dx:i32,dy:i32,//includes clipxy offsets
	clipxynxy:[4]i32,//clipy:u32,clipnx:u32,clipny:u32,//absolute
	h:u16,parent:u16,//index in stack
	alpha:u8,
};//TZWin

// FUNCTIONS
//////////////////////////////////////////////////////////////////////////////
pub fn new(w:u32,h:u32,ctx:*anyopaque,vtable:*const VTable) *IRender {
	var ir=do.a.create(IRender) catch unreachable;
	ir.w=w;
	ir.h=h;
	ir.ctx=ctx;
	ir.vtable=vtable;
	ir.renderList=@TypeOf(ir.renderList).init(do.a);
	ir.mouseList=@TypeOf(ir.mouseList).init(do.a);
	ir.omniMouseList=@TypeOf(ir.omniMouseList).init(do.a);
	ir.stack=@TypeOf(ir.stack).initCapacity(do.a,16) catch unreachable;
	ir.stackZ=@TypeOf(ir.stackZ).init(do.a);
	ir.stack.append(StackWin.Group(0,0,w,h,0,0)) catch unreachable;
	//main does:ir.stack.appendNTimes(StackWin.Group(0,0,w,h,0,0),7) catch unreachable;
	//ir.stack.items[0].t.GROUP.children=&[6]u16{1,2,3,4,5,6};//TODO:allocate static?
	ir.outdatedXYWH[2]=0;
	ir.outdatedXYWH[3]=0;
	ir.timer=false;
	ir.Fhdc=0;
	return ir;
}//new

var lastHover:u32=undefined;
var lastb:u32=0;
///returns true to stop further processing
pub fn mouseSignal(ir:*IRender,x:i32,y:i32,b:u32) bool {
	std.debug.print("\x1b[5;122hH\x1b[96mir={*}mouseSignal: {},{} {} ",.{&ir,x,y,b});
	var nextHover:u32=std.math.maxInt(u32);
	var bb=b;
	bb|=(lastb^b)<<16;
	bb|=lastHover<<24;
	for(ir.mouseList.l.items)|it|{
		//Log.val("mls{},{},{},{},",.{x,y,b,it});
		//TODO:fill in focus byte
		const sw=ir.stack.items[it.h];
		if(u.pointInRect(x,y,sw.x,sw.y,sw.w,sw.h) and 0!=bb^it.Fxor&it.Fand) it.cb(it.ctx,x,y,bb,ir);
	}//for
	for(ir.omniMouseList.l.items)|it|{
		const sw=ir.stack.items[it.h];
		bb=if(u.pointInRect(x,y,sw.x,sw.y,sw.w,sw.h)) b else b|FOCUS;
		if(0!=bb&FOCUS) nextHover=it.h;
		if(lastHover!=nextHover) bb|=FOCUS<<16;
		if(0==bb^it.Fxor&it.Fand)continue;
		it.cb(it.ctx,x,y,bb|(lastHover<<24)|(nextHover<<8),ir);
	}//for
	lastHover=nextHover;
	lastb=b&0xFF;
	return true;
}//mouseSignal

///returns true to stop further processing
pub fn keySignal(ir:*IRender,k:i32) bool {
	std.debug.print("\x1b[5;122hH\x1b[96mir=keySignal:{} ",.{k});
	if(68==k) ir.dumpStack();
	return true;
}//keySignal

pub fn render(ir:*IRender,hdc:usize,x:i32,y:i32,w:i32,h:i32) void {
	Log.begin("IRender.render xywh={},{},{},{}",.{x,y,w,h});
	if(0==ir.stackZ.items.len) ir.buildZ(0);
//	_=x; _=y; _=w; _=h;
	Log.red("...IRender.render...",.{});
	for(ir.stackZ.items)|zw|{
		var sw=&ir.stack.items[zw.h];
		Log.txt("ZWin");
		Log.log("zw={} sw={}",.{zw,sw});
		//TStackWin *psw=pStack+pZwin[i].h;
	//var TRelRect cl,abs;
		//GetClipAbsRect(pZwin[i].h,&cl,NULL,&abs);
		var clip:[4]i32=undefined;
		Log.log("{}hp={},{} dxy={},{} clip={any}",.{sw.t,zw.h,zw.parent,zw.dx,zw.dy,clip});
		Log.val("sw.xywh={},{}+{},{}",.{sw.x,sw.y,@intCast(i32,sw.w),@intCast(i32,sw.h)});
		const ss=u.intersectRelRect(x,y,w,h,&[4]i32{sw.x,sw.y,@intCast(i32,sw.w),@intCast(i32,sw.h)},clip[0..]);
		if(0==clip[2] or 0==clip[3]) continue;
		if(sw.wproc)|proc| _=proc(sw.ctx,StackWin.TSignal{.PAINT=.{}});
		ir.vtable.renderOne(hdc,ir.ctx,&clip,ss,sw);
	//if(0==clip[2] or 0==clip[3]) continue;
	}//for
}//render

pub fn rerender(self:*IRender) void {
	Log.green("{*}.rerender {any}",.{self,self.outdatedXYWH[0..]});
	self.render(0,self.outdatedXYWH[0],self.outdatedXYWH[1],self.outdatedXYWH[2],self.outdatedXYWH[3]);
	self.outdatedXYWH=[4]i32{0,0,0,0};
}//rerender

pub fn addWin(self:*IRender,p:u16,w:*StackWin) u16 {
	w.p=p;
	assert(.GROUP==self.stack.items[p].t);
	self.spoilZ();
	self.stack.append(w.*) catch unreachable;
	const h=@intCast(u16,self.stack.items.len-1);
	self.invalidateWin(h);
	return h;
}//addWin

pub fn addBuf8(self:*IRender,comptime T:type,p:u16,x:i32,y:i32,Abw:T) *T {
	assert(.GROUP==self.stack.items[p].t);
	var bw=do.a.create(T) catch unreachable; bw.*=Abw;
	//Log.log("addBuf={}",.{bw});//prints the whole framebuffer
//	self.stack.append(do.StackWin{.x=x+99,.y=y,.w=bw.fb.w,.h=bw.ny,.clr=0,.t=do.TWin{.BUF8=.{	.ctx=bw,.dfb=@offsetOf(T,"fb")	}}}) catch unreachable;
	const i=@truncate(u16,self.stack.items.len);
//	self.stack.items[i].p=p;
	_=self.addWin(p,&do.StackWin{.x=x,.y=y,.w=bw.fb.w,.h=bw.ny,.clr=0,.t=do.TWin{.BUF8=.{
		.ctx=bw,.dfb=@offsetOf(T,"fb")
	}},.wproc=null,.ctx=bw});
	bw.setRender(self,i);
	//return i;//u16
	return bw;
}//addBuf

pub inline fn setSignal(self:*IRender,h:u16,wproc:*const StackWin.TSignalF) void {
	self.stack.items[h].wproc=wproc;
}//setSignal

pub inline fn addRender(self:*IRender,cb:*const RenderList.Tcallback,ctx:*anyopaque,h:u16) void {
	self.renderList.add(cb,ctx,h);
}//addRender

pub inline fn addMouser(self:*IRender,Axor:u32,Aand:u32,cb:*const Tcallback,ctx:*anyopaque,h:u16) void {
	self.mouseList.add(Axor,Aand,cb,ctx,h);
}//addMouser

pub inline fn addOmniMouser(self:*IRender,Axor:u32,Aand:u32,cb:*const Tcallback,ctx:*anyopaque,h:u16) void {
	self.omniMouseList.add(Axor,Aand,cb,ctx,h);
}//addOmniMouser

pub fn invalidate(self:*IRender,x:i32,y:i32,w:i32,h:i32) void {
	Log.begin("IRender.invalidate({},{},{},{}) outdatedXYWH{any}",.{x,y,w,h,self.outdatedXYWH});
	var both:[4]i32=undefined;
	_=u.outlineRelRect(x,y,w,h, self.outdatedXYWH,both[0..]);
	Log.val("inv_both{any} ",.{both});
	if(0==self.Fhdc or both[2]*both[3]<w*h+self.outdatedXYWH[2]*self.outdatedXYWH[3]+1000) {
		self.outdatedXYWH=both;
		Log.val("_skip{any} ",.{self.outdatedXYWH});
		//FNotifyList->NotifyAll(int(&Ax),00);
		if(!self.timer) {
			do.timer.addTimerr(redrawTimerSignal,self,0,0);//ASAP
			self.timer=true;
		}//if
		return;
	}//if
	self.render(self.Fhdc,self.outdatedXYWH[0],self.outdatedXYWH[1],self.outdatedXYWH[2],self.outdatedXYWH[3]);
	//ReRender(FOutdated.x,FOutdated.y,nx,FOutdated.ny);
	self.outdatedXYWH[0]=x;
	self.outdatedXYWH[1]=y;
	self.outdatedXYWH[2]=w;
	self.outdatedXYWH[3]=h;
	//if(o.nx>0 && o.ny>0) ReRender(o.x,o.y,o.nx,o.ny);
	self.vtable.invalidate(self.ctx,x,y,w,h);
}//invalidate

pub fn invalidateWin(self:*IRender,h:u16) void {
	const sw=self.stack.items[h];
	self.invalidate(sw.x,sw.y,@intCast(i32,sw.w),@intCast(i32,sw.h));
}//invalidateWin

// PRIVATE -------------------------------------------------------------------
fn buildZ(self:*IRender,Ah:u16) void {
//very simple, if pZwin contains only parent context
//could pre-adding of drawable coords speed up?
//could pre-exclusion of overlapped areas be more efficient?
	//Log.red("IRender.buildZ");
	if(0==Ah) {
		Log.begin("IRender.re-buildZ",.{});
		self.stackZ.clearRetainingCapacity();
		self.stackZ.ensureTotalCapacity(self.stack.items.len) catch unreachable;
		//Log.msg(LOG_BEGIN,"TRenderStack::BuildZ(0)");
		//if(nZwin) Log.msg(LOG_TRACE,"re-BuildZ n=%d",nZwin);
//		@memset(@ptrCast([*]u8,self.stackZ.items.ptr),0,@sizeOf(TZWin));
//		var p0=&self.stackZ.items[0];//NO! .addOne();
//		p0.clipnx=self.w;
//		p0.clipny=self.h;
	}//if
	//GROUP needs one potential next: if(nZwin+1>=maxZwin) {pZwin=(TZWin*)mustrealloc(pZwin,sizeof(*pZwin)*(maxZwin+=maxStack>>2));}//if
	//pZwin[nZwin].h=Ah;
	Log.log("Ah={}t={}",.{Ah,self.stack.items[Ah].t});
	switch(self.stack.items[Ah].t) {
	.GROUP=>|gg|{
		//var g=&self.stack.items[Ah];
		var child=TZWin{.dx=gg.dx,.dy=gg.dy,.clipxynxy=[4]i32{0,0,@intCast(i32,self.w),@intCast(i32,self.h)},.h=0,.parent=Ah,.alpha=0};//self.stackZ.addOne();//bak
		var rr:[4]i32=[4]i32{0,0,@intCast(i32,self.w),@intCast(i32,self.h)};
		if(0<Ah) {//read parent
			var pz=self.stackZ.items[self.stack.items[self.stack.items[Ah].p].z];
			child.dx+=pz.dx;
			child.dy+=pz.dy;
			rr=pz.clipxynxy;
			self.stackZ.items.len-=1;//remove myself
		}//if
//TRelRect rr={bak.dx+=g.x,bak.dy+=g.y,g.nx,g.ny};
		child.dx+=gg.dx;
		child.dy+=gg.dy;
//	const r1=u.intersectRelRect(5,1,3,2,fig[0..],rr[0..]);
		_=u.intersectRelRect(child.clipxynxy[0],child.clipxynxy[1],child.clipxynxy[2],child.clipxynxy[3], &rr,child.clipxynxy[0..]);
		//for(gg.children)|i|{
		for(self.stack.items,0..)|*w,i|{
			if(i==Ah) continue;
			if(w.p!=Ah) continue;
			child.h=@truncate(u16,i);
			self.stackZ.append(child) catch unreachable;
			self.buildZ(@intCast(u16,i));
		}//while
		return;
	},//GROUP
	//case BUFWIN:	case LINE:	case DRAW8R:
	.BAR,.RECT,.BUF8,.DRAW8=>{
		self.stack.items[Ah].z=@intCast(u16,self.stackZ.items.len-1);
//		var ph=self.stackZ.addOne();
	},//CHILD
	.FREE,.NOTHING=>{}
	}//switch
}//buildZ

fn spoilZ(self:*IRender) void {
	self.stackZ.clearRetainingCapacity();
}//spoilZ

fn redrawTimerSignal(ctx:*anyopaque,us:i64) bool {
	_=us;
	const ir=@ptrCast(*IRender,@alignCast(8,ctx));
	Log.begin("IRender.redrawTimerSignal outdatedXYWH={any} ctxOSWin={*}",.{ir.outdatedXYWH,ir.ctx});
	ir.vtable.invalidate(ir.ctx,ir.outdatedXYWH[0],ir.outdatedXYWH[1],ir.outdatedXYWH[2],ir.outdatedXYWH[3]);
	ir.outdatedXYWH=[4]i32{0,0,0,0};
	ir.timer=false;
	return false;//no repeat
}//redrawTimerSignal

fn dumpStack(self:IRender) void {
	Log.warn("Dumping {}#stack",.{self.stack.items.len});
	for(self.stack.items)|sw|{
		Log.pink("{s}{?*}",.{@tagName(sw.t),sw.wproc});
		Log.info("{any}",.{sw});
	}//for
}//dumpStack
	
// TESTS
//////////////////////////////////////////////////////////////////////////////
test "IRender" {
	//_=RenderStack.new(64,64);
}//test
