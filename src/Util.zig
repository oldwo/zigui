//	Util.zig	- helper routines
//2023may18:(VK) Created
//2023jun10:(VK)+Log

// ANANTA SESA

const std=@import("std");
//const do=@import("DevOS.zig");
const Log=@import("Log.zig");
const assert=std.debug.assert;
const expect=std.testing.expect;

// TYPES
//////////////////////////////////////////////////////////////////////////////
pub const TSideSet=packed struct {
	left:bool,
	right:bool,
	top:bool,
	bottom:bool,
};//TSideSet

// VARS
//////////////////////////////////////////////////////////////////////////////

// FUNCTIONS
//////////////////////////////////////////////////////////////////////////////
pub inline fn pointInRect(x:i32,y:i32, left:i32,top:i32,w:u32,h:u32) bool {
	if(x<left or y<top) return false;
	if(x>=left+@bitCast(i32,w) or y>=top+@bitCast(i32,h)) return false;
	return true;
}//pointInRect
pub inline fn pointInRectu(x:u32,y:u32, left:u32,top:u32,w:u32,h:u32) bool {
	if(x<left or y<top) return false;
	if(x>=left+w or y>=top+h) return false;
	return true;
}//pointInRectu

pub fn intersectRelRect(x:i32,y:i32,w:i32,h:i32,fig:[*]const i32,dst:[*]i32) TSideSet {//returns clipped sides of fig
//const int *Asrc1,const int *Asrc2,int *Adst) TSideSet {//x_y_nx_ny
//	Log.blue("intersectRelRect({},{},{},{},fig{any})",.{x,y,w,h,fig[0..4]});
	var result=TSideSet{.left=false,.right=false,.top=false,.bottom=false};
	dst[0]=if(x<fig[0]) fig[0] else r:{result.left=true;break:r x;};//rightmost
	const x1=x+@intCast(i32,w);//1-right
	const x2=fig[0]+fig[2];//2-right
	dst[2]=(if(x1<=x2) x1 else r:{result.right=true; break :r x2;})-dst[0];
	if(dst[2]<0) dst[2]=0;

	dst[1]=if(y<fig[1]) fig[1] else r:{result.top=true;break:r y;};//lowest
	const y1=y+@intCast(i32,h);//1-bottom
	const y2=fig[1]+fig[3];//2-bottom
	dst[3]=(if(y1<=y2) y1 else r:{result.bottom=true; break :r y2;})-dst[1];
	if(dst[3]<0) dst[3]=0;
	return result;
}//intersectRelRect

///xywh is figure, returns visible sides
pub fn intersectRelRect2(x:i32,y:i32,w:i32,h:i32,clip:[*]const i32,dst:[*]i32) TSideSet {
//const int *Asrc1,const int *Asrc2,int *Adst) TSideSet {//x_y_nx_ny
	Log.blue("intersectRelRect2(fig{},{},{},{},clip{},{},{},{})",.{x,y,w,h,clip[0],clip[1],clip[2],clip[3]});
	var result=TSideSet{.left=false,.right=false,.top=false,.bottom=false};
	const xf=x+w;//fig-right
	const xc=clip[0]+clip[2];//clip-right
	dst[0]=if(x<clip[0]) clip[0] else r:{result.left=true;break:r x;};//rightmost
	dst[2]=(if(xc<xf) xc else r:{result.right=true; break :r xf;})-dst[0];
	if(dst[2]<0) dst[2]=0;

	const yf=y+h;//fig-bottom
	const yc=clip[1]+clip[3];//clip-bottom
	dst[1]=if(y<clip[1]) clip[1] else r:{result.top=true;break:r y;};//lowest
	dst[3]=(if(yc<yf) yc else r:{result.bottom=true; break :r yf;})-dst[1];
	if(dst[3]<0) dst[3]=0;
	return result;
}//intersectRelRect

const Stup=.{1,'a',"B"};
const Sin:i32=Stup;

pub fn outlineRelRect(x:i32,y:i32,w:i32,h:i32,Asrc2:[4]i32,Adst:*[4]i32) TSideSet {//x_y_nx_ny
	Log.blue("outlineRelRect({},{},{},{},2src{any})",.{x,y,w,h,Asrc2});
	var result=TSideSet{.left=false,.right=false,.top=false,.bottom=false};
	if(0>=w or 0>=h) {Adst.*=Asrc2;return result;}
	if(0>=Asrc2[2] or 0>=Asrc2[3]) {
		Adst[0]=x;
		Adst[1]=y;
		Adst[2]=w;
		Adst[3]=h;
		return result;
	}//if
	//	_=Asrc1;
	Adst[0]=std.math.min(x,Asrc2[0]);
	Adst[1]=std.math.min(y,Asrc2[1]);
	Adst[2]=std.math.max(x+w,Asrc2[0]+Asrc2[2])-Adst[0];//nx
	Adst[3]=std.math.max(y+h,Asrc2[1]+Asrc2[3])-Adst[1];//ny
	return result;
}//OutlineRelRect

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

test "pointInRectu" {
	try expect(pointInRectu(1,1, 1,1,1,1));
	try expect(!pointInRectu(1,1, 1,1,0,0));
	try expect(!pointInRectu(2,1, 1,1,1,1));
	try expect(!pointInRectu(1,2, 1,1,1,1));
	try expect(!pointInRectu(0,1, 1,1,1,1));
	try expect(!pointInRectu(1,0, 1,1,1,1));
}//pointInRectu

test "intersectRelRect" {
	const fig=[4]i32{5,1,3,2};//x,y,w,h
	var dst:[4]i32=undefined;
	const r1=intersectRelRect(5,1,3,2,fig[0..],dst[0..]);
	std.debug.print("r1={}!\ndst.xywh={d}\n",.{r1,dst});
	try expect(@bitCast(u4,TSideSet{.left=false,.right=false,.top=false,.bottom=false})==@bitCast(u4,r1));
	try expect(std.mem.eql(i32,&dst,&[4]i32{5,1,3,2}));
	const r2=intersectRelRect(1,1,1,1,fig[0..],dst[0..]);
	try expect(@bitCast(u4,TSideSet{.left=false,.right=true,.top=false,.bottom=true})==@bitCast(u4,r1));
	try expect(std.mem.eql(i32,&dst,&[4]i32{0,0,1,1}));
	try expect(@bitCast(u4,TSideSet{.left=false,.right=false,.top=false,.bottom=false})==@bitCast(u4,r2));
}//intersectRelRect

//Util.zig
