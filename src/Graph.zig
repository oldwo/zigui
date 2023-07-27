//	Graph.zig	- drawing routines
//2023may13:(VK) Created
//2023jun11:(VK)+drawColors
//2023jun20:(VK)+font
//2023jul15:(VK)+CLR
//2023jul18:(VK)+imgAX0
//2023jul20:(VK)+text

//May this module render forms that remind living beings of the original source
//of all names, forms, qualities and activities. This Supreme Creator is also
//the Supreme Enjoyer, who shares His resources in order to increase enjoyment.

const std=@import("std");
const do=@import("DevOS.zig");

// TYPES
//////////////////////////////////////////////////////////////////////////////
pub const TRelRect=struct{x:i32,y:i32,nx:i32,ny:i32};
pub const Tfont=struct {
	rowStep:i32,
	charStep:i32,//0 if variable ///or RowStep*Height
	map:?[]u8,
	baseline:i32,//count of pixels above baseline
	heightbmp:i32,
	leading:i32,
	shifts:[256]struct {
		advance:i8,
		width:u8,
		shift:i8,
		_pad:i8,
		pmap:[*]u8,
	},
};//Tfont

// CONSTS
//////////////////////////////////////////////////////////////////////////////
pub const CLR=struct {
	pub const PAPER=83;
	pub const TEXT=84;
	pub const BUTTON=85;
	pub const BUTTONHI=86;
	pub const BUTTONLO=87;
};//CLR

pub const font1=@embedFile("FONT/RUSDOS8.FNT");

// VARS
//////////////////////////////////////////////////////////////////////////////
var GAnd:u8=0xAA;
var GXor:u8=15;
//int ttoa;//Text to attribute ie color
var Gfont:Tfont=.{.rowStep=0,.charStep=0,.map=null,.baseline=0,.heightbmp=0,.leading=0,.shifts=undefined};

// OS
//////////////////////////////////////////////////////////////////////////////
// Main ----------------------------------------------------------------------
comptime {
}//comptime

// FUNCTIONS
//////////////////////////////////////////////////////////////////////////////
pub fn startup() void {
	install8font(font1,8,8);
}//startup

// BitBlt --------------------------------------------------------------------
pub fn fillBox(fb:do.GBuf,x:u32,y:u32,w:u32,h:u32,c:u8) void {
	std.debug.print("\x1b[95m;fillBox({},{} {},{}) ",.{x,y,w,h});
	var p:[*]u8=fb.p.ptr+x+y*fb.w;
	for(0..h)|_|{@memset(p,c,w);p+=fb.w;}
}//fillBox

pub fn img(fb:do.GBuf,x:u32,y:u32,ASource:*const u8,ASourceStep:i32,Anx:i32,Any:i32) void {
	var pd:[*]u8=fb.p.ptr+x+y*fb.w;
	var ps:[*]u8=ASource;
	for(0..Any)|_|{
		@memcpy(pd,ps,Anx);
		pd+=fb.w;
		ps+=ASourceStep;
	}//for
}//img

pub fn imgAX(fb:do.GBuf,x:u32,y:u32,ASource:*const u8,ASourceStep:i32,Anx:i32,Any:i32) void {
	var pd:[*]u8=fb.p.ptr+x+y*fb.w;
	var ps:[*]u8=ASource;
	for(0..Any)|_|{
		for(pd[0..Anx],ps[0..Anx])|dst,src|{
			dst=src&Gfont.And ^ Gfont.Xor;
		}//for
		pd+=fb.w;
		ps+=ASourceStep;
	}//for
}//imgAX

pub fn imgAX0(fb:do.GBuf,x:u32,y:u32,ASource:[*]const u8,ASourceStep:i32,Anx:i32,Any:i32) void {
	var pd:[*]u8=fb.p.ptr+x+y*fb.w;
	var ps:[*]const u8=ASource;
	for(0..@intCast(u16,Any))|_|{
		for(pd[0..@intCast(u16,Anx)],ps[0..@intCast(u16,Anx)])|*dst,src|{
			if(src!=GXor) dst.*=src&GAnd;
		}//for
		pd+=fb.w;
		@setRuntimeSafety(false);
		ps+=@intCast(usize,ASourceStep);//TODO:accomodate negatives also!
	}//for
}//imgAX0

// Font ----------------------------------------------------------------------
fn install8font(fnt:[*]const u8,w:u8,h:u8) void {
	
	Gfont.map=(if(Gfont.map)|m|
		do.a.realloc(m,@intCast(usize,w)*h*256)
	else	do.a.alloc(u8,@intCast(usize,w)*h*256)) catch unreachable;
	Gfont.rowStep=w;
	Gfont.charStep=w*h;
	Gfont.heightbmp=h;
	var pd:[*]u8=Gfont.map.?.ptr;
	var ps=fnt;
	//MakeFixedFontShifts
	for(0..256)|i|{
		Gfont.shifts[i].advance=@intCast(i8,w);
		Gfont.shifts[i].width=w;
		Gfont.shifts[i].shift=0;
		Gfont.shifts[i].pmap=pd;//Gfont.map+Gfont.charStep*i
		for(0..h)|_|{
			var bits=ps[0];
			for(0..w)|_|{
				pd[0]=if(0==bits&128) 0 else 255;
				bits+%=bits;//shift left
				pd+=1;
			}//for
			ps+=1;
		}//for
	}//for
}//install8font

///TODO:ABounds works as absolute coords
pub fn text(fb:do.GBuf,Ax:i32,Ay:i32,ABounds:TRelRect,AText:[]const u8,AMaskAnd:u8) void {
//fb=PIX8 *ABuf,int ARowStep,int Ax,int Ay,const char *
	//G8FillBox(ABound,Anx,Any,ARowStep,8);///
	GAnd=AMaskAnd;
	GXor=0;
	var x=Ax;
	var y=Ay;
	var height=Gfont.heightbmp;
	var dmap:i32=0;
	//fillBox(fb,@intCast(u32,Ax),@intCast(u32,Ay),8,8,AMaskAnd);//deBUG
	//if(baseline) Ay-=GG8Font.Head.baseline
	if(ABounds.y-y>0) {//optimize as G8ImgA0Clp
		height-=ABounds.y-y;
		dmap=(ABounds.y-y)*Gfont.rowStep;
		y=ABounds.y;
	}//if
	var i=ABounds.y+ABounds.ny-y;
	if(i<height) height=i;
	if(height<=0) return;
	const RightBound=ABounds.x+ABounds.nx;
	const LeftBound=ABounds.x;
	for(AText)|c|{
		const shi=Gfont.shifts[c];
//		const xx=x+shi.shift; TODO:shift
		var w:i32=shi.width;
		if(w>RightBound-x) {w=RightBound-x;}
		var ps:[*]u8=shi.pmap+@intCast(usize,dmap);
		var xx=@intCast(u32,x);
		var cutx=LeftBound-x;
		if(0<cutx) {
			w-=cutx;
			ps+=@intCast(usize,cutx);
			xx=@intCast(u32,LeftBound);
		}//if
		if(w>0)
			imgAX0(fb,xx,@intCast(u32,y),ps,Gfont.rowStep,w,height);
		x+=shi.advance;
	}//for
}//text

pub fn TextWidth(AText:[]const u8,AFontHead:Tfont) i32 {//includes last advance
	const ps=AFontHead.pShifts;
	var w=0;
	for(AText)|c| w+=ps[c].advance;
	return w;
}//TextWidth

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
