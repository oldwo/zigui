//	C:\vk\DevOS.zig\app\nesting.zig	- exercise nested IRender-s
//2023jul28:(VK) Created
//2023aug05:(VK)+mouse

const std=@import("std");
const do=@import("DevOS");
const Log=do.Log;
const testing=std.testing;

// VAR -----------------------------------------------------------------------
var Gir:*do.IRender=undefined;
var oldx:i32=undefined;
var oldy:i32=undefined;
var moving=false;

fn msLog(txt:[]const u8,ms:do.StackWin.Tmouse) void {Log.cyan("ms{s}({},{}b{})",.{txt,ms.x,ms.y,ms.b});}

///		if(sw.wproc)|proc| _=proc(sw.ctx,StackWin.TSignal{.PAINT=.{}});
fn mouseMove(sw:*do.StackWin,h:u16,signal:do.StackWin.TSignal) isize {
	switch(signal) {
	.MOUSEDOWN=>|ms|{msLog("D",ms);oldx=ms.x;oldy=ms.y;moving=0<ms.b&do.IRender.FOCUS;},
	.MOUSEUP=>moving=false,
	.MOUSEMOVE=>|ms|{msLog("M",ms);if(moving){Gir.move(h,sw.x+ms.x-oldx,sw.y+ms.y-oldy);}},
	else=>Log.warn("{}",.{signal})
	}//switch
	return 0;
}//mouseMove

// MAIN ----------------------------------------------------------------------
pub export const wWinMain=do.main;

pub fn doMain() void {
	std.debug.print("doMain!\n \x1b[34mColors",.{});
	var rs=do.OSwin(1680,640,@as([*:0]const u8,"Title1"));
	Log.trace("OSwinIR@{*}",.{rs});
	rs.stack.appendNTimes(do.StackWin.Group(0,0,1680,640,0,0),6) catch unreachable;
	const PB1CFG=do.PushButton.CFG{.x=55,.y=11};
	//var bw=do.BufWin.make(1024,512);//(1024,512);
	//bws.stack.append(do.StackWin.Group(0,0,1024,512,0,0)) catch unreachable;
	//Log.log("BufWin.make(1024,512)={}",.{bw});//prints the whole framebuffer
	var pb=do.PushButton.make(PB1CFG);
	//pb.setBufWin(&bw);
	const bw=rs.addBuf8(do.BufWin,3, 400,22,do.BufWin.make(1024,512),.nest);//makes a copy, only ever use the copy from rs.stack!
	//var bw=rs.stack.items[hbw].t.BUF8.ctx;
	Gir=bw.asRender();
	do.g8.drawColors(bw.fb,4,4);
	_=rs.addBuf8(do.PushButton,3,200,22,pb,.alone);
	_       =Gir.addWin(0,@constCast(&do.Bar(42,0, 900,511, 12+1)));
	const hb=Gir.addWin(0,@constCast(&do.Bar(4,88, 200,99, 205)));
	const hr=Gir.addWin(0,@constCast(&do.Rect(4+5,88+5, 200,99, 3)));
	const hor=rs.addWin(3,@constCast(&do.Rect(99,158, 200,99, 55)));
	_=hor;
	_=hb;
	//Gir=rs;
	Gir.setSignal(hr,mouseMove);
}//doMain
