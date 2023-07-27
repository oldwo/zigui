//	C:\vk\DevOS.zig\app1\main.zig
//2023may07:(VK) Created
//2023may22:(VK)+StackWin-s
//2023jun04:(VK)+Log
//2023jun11:(VK)+drawColors
//2023jun23:(VK)*addBuf8

const std=@import("std");
const do=@import("DevOS");
const testing=std.testing;
const Log=do.Log;

pub export const wWinMain=do.main;

pub fn doMain() void {
	std.debug.print("doMain!\n \x1b[34mColors",.{});
	var rs=do.OSwin(1680,640,@as([*:0]const u8,"Title1"));
	//var rs=do.RenderStack(1680,640);
	//rw.add(0,0,rs);
	_=rs.addWin(3,@constCast(&do.Bar(4,88, 200,99, 255)));
	_=rs.addWin(3,@constCast(&do.Rect(99,158, 200,99, 55)));
	const PB1CFG=do.PushButton.CFG{.x=55,.y=11};
	var bw=do.BufWin.make(1024,512);//(1024,512);
	do.g8.drawColors(bw.fb,4,4);
	//Log.log("BufWin.make(1024,512)={}",.{bw});//prints the whole framebuffer
	var pb=do.PushButton.make(PB1CFG);
	//pb.setBufWin(&bw);
	_=rs.addBuf8(do.BufWin,3,400,22,bw);
	_=rs.addBuf8(do.PushButton,3,200,22,pb);
}//doMain
