//	C:\vk\DevOS.zig\app\animatext.zig	-animated text render
//2023jul21:(VK) Created
//2023jul23:(VK)+DemoBuf

const std=@import("std");
const do=@import("DevOS");
const Log=do.Log;

pub export const wWinMain=do.main;

const DemoBuf=struct {
fb:do.GBuf,
ny:u32,
//-
var Si:u32=0;
var Sir:*do.IRender=undefined;
var Sh:u16=undefined;
//i:u32,
pub fn setRender(self:*DemoBuf,ir:*do.IRender,h:u16) void {
	//_=self;
	Sir=ir;
	Sh=h;
	do.timer.addTimerr(timerSignal,self,200,199);//10Hz
}//setRender
var Sc:u8=0x2F;
fn bounce(i:usize,lim:usize) i32 {
	const x=@intCast(i32,i%(lim*2));
	return if(x>=lim) @intCast(i32,lim*2)-x else x;
}//bounce
fn paintOne(fb:do.GBuf,i:u32,clr:u8) void {
	const xspan=51;
	const yspan=37;
	var x=i%(xspan*2); if(x>=xspan) x=xspan*2-x;
	var y=i%(yspan*2); if(y>=yspan) y=yspan*2-y;
	do.g8.text(fb,@intCast(i32,x),@intCast(i32,y),do.g8.TRelRect{.x=4,.y=4,.nx=82,.ny=37},"DemoBuf",clr);
}//paintOne
fn timerSignal(ctx:*anyopaque,us:i64) bool {
	const db=@ptrCast(*DemoBuf,@alignCast(8,ctx));
	//_=db;
	_=us;
	paintOne(db.fb,Si,1);
	Si+%=1;
	paintOne(db.fb,Si,0x2F);
	//do.beep();
	const text="WiSEQ71gll1oO0Z Mhan9j^qFE";
const cutr=do.g8.TRelRect{.x=95+bounce(Si,37),.y=1+bounce(Si,19),.nx=133,.ny=41};
	do.g8.fillBox(db.fb,100,3,58,74,254);
	for(0..8)|jj|{const j=@intCast(u8,jj);
		do.g8.text(db.fb,100+j,3+j*7,cutr,text,16+j);
	}//for
	Sir.invalidateWin(Sh);
	//Sclr+%=3;
	return true;
}//timerSignal
};//DemoBuf

pub fn doMain() void {
	var rs=do.OSwin(1280,640,"Animate Text");
	rs.stack.appendNTimes(do.StackWin.Group(0,0,1280,640,0,0),7) catch unreachable;
//	_=rs.addWin(3,@constCast(&do.Bar(4,88, 200,99, 255)));
	var bw=do.BufWin.make(624,512);//(1024,512);
	Log.trace("bw={*} will draw...",.{&bw});
	do.g8.drawColors(bw.fb,4,4);//w,h,*16
	Log.trace("bw.fb={*}w{} will text...",.{bw.fb.p.ptr,bw.fb.w});
	do.g8.text(bw.fb,8,24,do.g8.TRelRect{.x=13,.y=5,.nx=42,.ny=27},"Will animate this",0x1F);
	do.g8.fillBox(bw.fb,100,18,1,84,0x0);
	do.g8.fillBox(bw.fb,108,18,1,84,0x0);
	const text="Will changeimate this";
	const omnir=do.g8.TRelRect{.x=0,.y=0,.nx=342,.ny=227};
	do.g8.text(bw.fb,100,30,omnir,text,0x2F);
	do.g8.text(bw.fb,101,37,do.g8.TRelRect{.x=0,.y=0,.nx=342,.ny=227},text,0x2E);
	do.g8.text(bw.fb,102,44,do.g8.TRelRect{.x=0,.y=0,.nx=342,.ny=227},"Will changeimate this",0x2F);
	do.g8.text(bw.fb,103,51,do.g8.TRelRect{.x=0,.y=0,.nx=342,.ny=227},"Will changeimate this",0x2E);
	do.g8.text(bw.fb,104,58,do.g8.TRelRect{.x=0,.y=0,.nx=342,.ny=227},text,0x2F);
	do.g8.text(bw.fb,105,65,do.g8.TRelRect{.x=0,.y=0,.nx=342,.ny=227},text,0x2E);
	do.g8.text(bw.fb,106,72,do.g8.TRelRect{.x=0,.y=0,.nx=342,.ny=227},text,0x2F);
	do.g8.text(bw.fb,107,79,do.g8.TRelRect{.x=0,.y=0,.nx=342,.ny=227},text,0x2E);
	//Log.log("BufWin.make(1024,512)={}",.{bw});//prints the whole framebuffer
	_=rs.addBuf8(do.BufWin,3,550,50,bw);
	_=rs.addBuf8(DemoBuf,3,100,150,DemoBuf{.fb=do.GBuf{.p=do.a.alloc(u8,@intCast(usize,400*100)) catch unreachable,.w=400},.ny=100});
	_=rs.addWin(3,@constCast(&do.Rect(98,148, 404,104, 155)));
	_=rs.addWin(3,@constCast(&do.Rect(102,152, 82+4+4,37+4+4, 15)));
}//doMain
