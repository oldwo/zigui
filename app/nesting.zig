//	C:\vk\DevOS.zig\app\nesting.zig	- exercise nested IRender-s
//2023jul28:(VK) Created

const std=@import("std");
const do=@import("DevOS");
const Log=do.Log;
const testing=std.testing;

pub export const wWinMain=do.main;

pub fn doMain() void {
	std.debug.print("doMain!\n \x1b[34mColors",.{});
	var rs=do.OSwin(1680,640,@as([*:0]const u8,"Title1"));
	Log.trace("OSwinIR@{*}",.{rs});
	rs.stack.appendNTimes(do.StackWin.Group(0,0,1680,640,0,0),6) catch unreachable;
	const PB1CFG=do.PushButton.CFG{.x=55,.y=11};
//	var bw=do.BufWin.make(1024,512);//(1024,512);
	//bws.stack.append(do.StackWin.Group(0,0,1024,512,0,0)) catch unreachable;
	//Log.log("BufWin.make(1024,512)={}",.{bw});//prints the whole framebuffer
	var pb=do.PushButton.make(PB1CFG);
	//pb.setBufWin(&bw);
	const bw=rs.addBuf8(do.BufWin,3,400,22,do.BufWin.make(1024,512));//makes a copy, only ever use the copy from rs.stack!
	//var bw=rs.stack.items[hbw].t.BUF8.ctx;
	var bws=bw.asRender();
	do.g8.drawColors(bw.fb,4,4);
	_=rs.addBuf8(do.PushButton,3,200,22,pb);
	_=bws.addWin(0,@constCast(&do.Bar(4,88, 200,99, 205)));
	_=bws.addWin(0,@constCast(&do.Rect(4+1,88+1, 200,99, 3)));
	_=rs.addWin(3,@constCast(&do.Rect(99,158, 200,99, 55)));
}//doMain
