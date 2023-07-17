//	X:\DARBI\PROG\LIB\DevOS.zig\src\MainMSWin.zig
//2023apr27:(VK) Created
//2023may07:(VK)!works
//2023may08:(VK)+OSwin
//2023may16:(VK)+WM_MOUSE*
//2023jun03:(VK)+IRender
//2023jun09:(VK)+FrameRect
//2023jul08:(VK)+invalidate
//2023jul16:(VK)+beep
	
const std=@import("std");
const w=std.os.windows;
const do=@import("DevOS.zig");
const Log=@import("Log.zig");
const u8to16le=std.unicode.utf8ToUtf16LeStringLiteral;
//const RenderWin=@import("RenderWin.zig").RenderWin;
const TStackWin=@import("StackWin.zig");
const IRender=@import("IRender.zig");
const util=@import("Util.zig");
const CLR=@import("Graph.zig").CLR;

const WINAPI=std.os.windows.WINAPI;
const INT=w.INT;
const user32=w.user32;
const win32=w.win32;
const HWND=w.HWND;
const HDC=w.HDC;
const HBRUSH=w.HBRUSH;
const BOOL=w.BOOL;
const WORD=w.WORD;
const DWORD=w.DWORD;

// VARS
//////////////////////////////////////////////////////////////////////////////
var SInstance:w.HINSTANCE=undefined;
var Gbmi=BITMAPINFO{.bmiHeader=BITMAPINFOHEADER{.biSize=@sizeOf(BITMAPINFOHEADER),
.biWidth=1024,
.biHeight=-768,
.biPlanes=1,
.biBitCount=8,
.biCompression=BI_RGB,
.biSizeImage=0,
.biXPelsPerMeter=9999,
.biYPelsPerMeter=9999,
.biClrUsed=256,
.biClrImportant=0,
},.bmiColors=undefined};//GPal};//=[1]RGBQUAD{.{55,99,199,128}},

//gdi.zig
//============================================================================
pub const BI_RGB = @as(i32, 0);
//pub inline fn LOWORD(dword:DWORD) WORD {return @bitCast(WORD,@intCast(u16,dword&0xffff));}
//pub inline fn HIWORD(dword:DWORD) WORD {return @bitCast(WORD,@intCast(u16,(dword>>16)&0xffff));}
pub inline fn LOWORD(dword:isize) WORD {return @bitCast(WORD,@intCast(u16,dword&0xffff));}
pub inline fn HIWORD(dword:isize) WORD {return @bitCast(WORD,@intCast(u16,(dword>>16)&0xffff));}
//from https://github.com/marlersoft/zigwin32/blob/main/win32/graphics/gdi.zig
pub const RECT=extern struct {left:i32,top:i32,right:i32,bottom:i32};
pub const PAINTSTRUCT=extern struct {hdc:?HDC,fErase:BOOL,rcPaint:RECT,fRestore:BOOL,fIncUpdate:BOOL,rgbReserved:[32]u8};
pub const DIB_USAGE=enum(u32) {RGB_COLORS=0,PAL_COLORS=1};
pub const HGDIOBJ=*opaque{};
pub const HBITMAP=HGDIOBJ;
pub const RGBQUAD=extern struct {rgbBlue:u8,rgbGreen:u8,rgbRed:u8,rgbReserved: u8};
pub const BITMAPINFOHEADER=extern struct {
	biSize:u32,
	biWidth:i32,
	biHeight:i32,
	biPlanes:u16,
	biBitCount:u16,
	biCompression:u32,
	biSizeImage:u32,
	biXPelsPerMeter:i32,
	biYPelsPerMeter:i32,
	biClrUsed:u32,
	biClrImportant:u32,
};//BITMAPINFOHEADER
pub const BITMAPINFO=extern struct {bmiHeader:BITMAPINFOHEADER,bmiColors:[256]RGBQUAD};
pub extern "user32" fn BeginPaint(hWnd:?HWND,lpPaint:?*PAINTSTRUCT) callconv(@import("std").os.windows.WINAPI) ?HDC;
pub extern "user32" fn EndPaint(hWnd:?HWND,lpPaint: ?*const PAINTSTRUCT) callconv(@import("std").os.windows.WINAPI) BOOL;
pub extern "user32" fn FillRect(hDC:?HDC,lprc:?*const RECT,hbr:?HBRUSH,) callconv(WINAPI) i32;
pub extern "user32" fn FrameRect(hDC:?HDC,lprc:?*const RECT,hbr:?HBRUSH,) callconv(WINAPI) i32;
pub extern "gdi32" fn SetDIBits(
	hdc:?HDC,
	hbm:?HBITMAP,
	start:u32,
	cLines:u32,
	lpBits:?*const anyopaque,
	lpbmi:?*const BITMAPINFO,
	ColorUse:DIB_USAGE,
) callconv(@import("std").os.windows.WINAPI) i32;
pub extern "gdi32" fn SetDIBitsToDevice(
	hdc:?HDC,
	xDest:i32,
	yDest:i32,
	w:u32,
	h:u32,
	xSrc:i32,
	ySrc:i32,
	StartScan:u32,
	cLines:u32,
	lpvBits:?*const anyopaque,
	lpbmi:?*const BITMAPINFO,
	ColorUse:DIB_USAGE,
) callconv(@import("std").os.windows.WINAPI) i32;

//user32.zig
pub extern "user32" fn InvalidateRect(hWnd:?HWND,lpRect:?*const RECT,bErase:BOOL) callconv(@import("std").os.windows.WINAPI) BOOL;
pub extern "gdi32" fn CreateSolidBrush(color: u32) callconv(WINAPI) ?HBRUSH;

//system/diagnostics/debug.zig
pub extern "kernel32" fn Beep(dwFreq:u32,dwDuration:u32) callconv(WINAPI) BOOL;
pub extern "user32" fn MessageBeep(uType:u32) callconv(WINAPI) BOOL;

//VARS
//============================================================================
var fb:[768][1024]u8=undefined;
var GPal:[256]RGBQUAD=undefined;

//FUNCTIONS
//============================================================================
var color:usize=0;

//FUNCTIONS
//////////////////////////////////////////////////////////////////////////////
pub fn beep() void {
	MessageBeep(0);
}//beep
 
// Main ----------------------------------------------------------------------

fn palette1(colors:*[256]RGBQUAD) void {
	for(0..256) |i| {
		const u=@truncate(u8,i);
		colors[i].rgbBlue=u;//@truncate
		colors[i].rgbGreen=255-u;
		colors[i].rgbRed=@mulWithOverflow(u,15)[0];//@truncate(u8,u*15);
		colors[i].rgbReserved=255;
	}//for
}//palette1

fn palette2(colors:*[256]RGBQUAD) void {
	for(0..256) |i| {
		const u=@truncate(u8,i);
		colors[i].rgbBlue=u;//@truncate
		colors[i].rgbGreen=u;
		colors[i].rgbRed=u;//@truncate

		colors[i].rgbBlue=u<<2;
		colors[i].rgbGreen=u<<6;
		colors[i].rgbRed=u;
		colors[i].rgbReserved=u;
	}//for
}//palette1

const palette64=struct {
const spread4=[4]u8{0,0x55,0xAA,0xFF};
inline fn q(r:u8,g:u8,b:u8) RGBQUAD {return RGBQUAD{.rgbBlue=b,.rgbGreen=g,.rgbRed=r,.rgbReserved=0};}
const HalfColors=[19]RGBQUAD{
	q(128,0,0),q(0,128,0),q(0,0,128),
	q(128,128,0),q(128,0,128),q(0,128,128),
	q(128,128,128),//70
	q(128,0,255),q(0,128,255),q(0,255,128),
	q(128,255,0),q(255,128,0),q(255,0,128),//74,75,76
	q(128,128,255),q(128,255,128),q(255,128,128),
	q(128,255,255),q(255,128,255),q(255,255,128)
};//HalfColors
fn palette64(colors:*[256]RGBQUAD) void {
	for(0..64) |i| {
	//	const u=@truncate(u8,i);
		colors[i].rgbRed=spread4[(i>>2)&3];
		colors[i].rgbGreen=spread4[i&3];
		colors[i].rgbBlue=spread4[i>>4];
	}//for
	//@compileLog(@sizeOf(@TypeOf(HalfColors)));//=76
	std.debug.assert(76==@sizeOf(@TypeOf(HalfColors)));
	@memcpy(@ptrCast([*]u8,&colors[64]),@ptrCast([*]const u8,&HalfColors),@sizeOf(@TypeOf(HalfColors)));
	colors[CLR.PAPER].rgbRed=205;
	colors[CLR.PAPER].rgbGreen=205;
	colors[CLR.PAPER].rgbBlue=205;
	colors[CLR.TEXT].rgbRed=43;
	colors[CLR.TEXT].rgbGreen=43;
	colors[CLR.TEXT].rgbBlue=43;
	colors[CLR.BUTTON].rgbRed=128;
	colors[CLR.BUTTON].rgbGreen=171;
	colors[CLR.BUTTON].rgbBlue=128;
	colors[CLR.BUTTONHI].rgbRed=171;
	colors[CLR.BUTTONHI].rgbGreen=171;
	colors[CLR.BUTTONHI].rgbBlue=128;
	colors[CLR.BUTTONLO].rgbRed=85;
	colors[CLR.BUTTONLO].rgbGreen=128;
	colors[CLR.BUTTONLO].rgbBlue=85;
}//palette64
}.palette64;

var c1:u8=0;
fn paletteNext() void {
	c1=@addWithOverflow(c1,1)[0];
	GPal[1].rgbBlue=c1;//@truncate
	GPal[1].rgbGreen=c1;
	GPal[1].rgbRed=c1;
	GPal[1].rgbReserved=c1;
}//palette1

fn renderPattern1() void {
//	var c:u8=9;
//	for(0..768) |y| for(0..1024) |x| {fb[y][x]=c;c+=1;};
	for(0..256) |i| {
		const u=@truncate(u8,i);
		fb[i+33][i+99]=u;
		fb[i+1][88]=u;
		fb[22][i+33]=u;
		fb[23][i+33]=u;
		fb[24][i+33]=u;
		//_=i;
		fb[555][i*3+0]=u;
		fb[555][i*3+1]=u;
//		fb[555][i*3+2]=u;
		fb[556][i*3+0]=u;
		fb[556][i*3+1]=u;
		fb[556][i*3+2]=u;
		fb[557][i*3+0]=u;
		fb[557][i*3+1]=u;
		fb[557][i*3+2]=u;
	}//for
	fb[766][1022]=222;
}//renderPattern1

// WindowProc ----------------------------------------------------------------
pub export fn WindowProc(hwnd:HWND,uMsg:w.UINT,wParam:w.WPARAM,lParam:w.LPARAM,
) callconv(w.WINAPI) w.LRESULT {
	//if(user32.WM_MOUSEMOVE==uMsg) std.debug.print("\tWM_MOUSEMOVE {} {} =", .{wParam,lParam});
//std.debug.print("In WindowProc {}\n", .{uMsg});
	const old=user32.GetWindowLongPtrA(hwnd,0);
	//std.debug.print("WindowProc rw={x}\n", .{old});
	if(0==old) {
		if(user32.WM_PAINT==uMsg) {
			var ps:PAINTSTRUCT=undefined;
			paletteNext();
			const hdc:HDC=BeginPaint(hwnd,&ps).?;
		_=FillRect(hdc,&ps.rcPaint,@intToPtr(HBRUSH,color+1));//COLOR_WINDOW+1=COLOR_WINDOWFRAME=6 zero-doesn't-cast
		const rc=SetDIBitsToDevice(hdc, 33,3,1024,768, 0,0, 0,768, &fb,&Gbmi,DIB_USAGE.RGB_COLORS);
		_=rc;
		_=EndPaint(hwnd,&ps);
		color+=1;
		color%=31;
		return 0;
		}//if
		return user32.DefWindowProcW(hwnd,uMsg,wParam,lParam);
	}//if no RenderWin

	const rw=@intToPtr(*IRender,@bitCast(usize,old));
//std.debug.print("rw.w={} ", .{rw.w});
	do.timer.signal();
	switch(uMsg){
	user32.WM_GETMINMAXINFO=>{},
	user32.WM_SETCURSOR=>{},
	user32.WM_MOVE=>{},
	user32.WM_NCHITTEST=>{},
	user32.WM_MOUSEMOVE,user32.WM_LBUTTONDOWN,user32.WM_LBUTTONUP,user32.WM_RBUTTONDOWN,user32.WM_RBUTTONUP,user32.WM_MBUTTONDOWN,user32.WM_MBUTTONUP
		=>{_=rw.mouseSignal(LOWORD(lParam),HIWORD(lParam),@truncate(u32,wParam));},
	user32.WM_LBUTTONDOWN+999=>{_=rw.mouseSignal(LOWORD(lParam),HIWORD(lParam),@truncate(u32,wParam));
		std.debug.print("\x1b[43mLB{},{} b={}\x1b[40m ", .{LOWORD(lParam),HIWORD(lParam),wParam});//wParam==1
		return 0;
	},//WM_LBUTTONDOWN
	user32.WM_KEYDOWN=>{
		const r=RECT{.left=8,.top=9,.right=1024+55,.bottom=888};
		_=InvalidateRect(hwnd,&r,w.FALSE);
		std.debug.print("\x1b[44mKEY{},{}\x1b[40m ", .{wParam,lParam});
		return 0;
	},//WM_KEYDOWN
	user32.WM_KEYUP=>{
		std.debug.print("\x1b[44mUP{}\x1b[40m ", .{wParam});
		//do.say("up");
		return 0;
	},//WM_KEYUP
	user32.WM_WINDOWPOSCHANGED=>{},
	user32.WM_MOVING=>{},
	user32.WM_CLOSE=>{user32.postQuitMessage(0);},
	user32.WM_PAINT=>{
		var ps:PAINTSTRUCT=undefined;
		paletteNext();
		const hdc:HDC=BeginPaint(hwnd,&ps).?;
		var bmi=BITMAPINFO{.bmiHeader=BITMAPINFOHEADER{.biSize=@sizeOf(BITMAPINFOHEADER),
.biWidth=1024,
.biHeight=-768,
.biPlanes=1,
.biBitCount=8,
.biCompression=BI_RGB,
.biSizeImage=0,
.biXPelsPerMeter=9999,
.biYPelsPerMeter=9999,
.biClrUsed=256,
.biClrImportant=0,
		},.bmiColors=GPal,//undefined,//=[1]RGBQUAD{.{55,99,199,128}},
};
		std.debug.print("PainT hdc={} c={} ",.{hdc,color});
//		_=FillRect(hdc,&ps.rcPaint,@intToPtr(HBRUSH,color+1));//COLOR_WINDOW+1=COLOR_WINDOWFRAME=6 zero-doesn't-cast
		rw.render(@ptrToInt(hdc),ps.rcPaint.left,ps.rcPaint.top,ps.rcPaint.right,ps.rcPaint.bottom);
		const rc=SetDIBitsToDevice(hdc, 22,3,10+2+4,768, 0,0, 0,768, &fb,&bmi,DIB_USAGE.RGB_COLORS);
		std.debug.print("\x1b[95mWLong0={} 1={}",.{user32.GetWindowLongPtrA(hwnd,0),user32.GetWindowLongPtrA(hwnd,1)});
		std.debug.print("\x1b[93mSetDIBitsToDevice={} \x1b[37m",.{rc});
		_=EndPaint(hwnd,&ps);
		color+=1;
		color%=31;
		return 0;
	},//WM_PAINT
	else=>{std.debug.print("WM{} ", .{uMsg});}
	}//switch
	return user32.DefWindowProcW(hwnd, uMsg, wParam, lParam);
}//WindowProc

// Main ----------------------------------------------------------------------
pub fn wWinMain(hInstance:w.HINSTANCE,hPrevInstance:?w.HINSTANCE,lpCmdLine:?w.LPWSTR,nCmdShow:INT,
) callconv(w.WINAPI) INT {
	_=hPrevInstance;
	_=lpCmdLine;
	SInstance=hInstance;
	//std.debug.print("fb size={} ",.{@sizeOf(@TypeOf(fb))});
	do.timer.init();
	const wc=user32.WNDCLASSEXW{.style=0,.lpfnWndProc=WindowProc,
.cbClsExtra=0,.cbWndExtra=8,.hInstance=hInstance,.hIcon=null,.hCursor=null,.hbrBackground=null,.lpszMenuName=null,.lpszClassName=u8to16le("DevOS"),.hIconSm=null};
	_=user32.RegisterClassExW(&wc);

	const hwnd=user32.CreateWindowExW(0,wc.lpszClassName,wc.lpszClassName,user32.WS_OVERLAPPED,
0,0,
1840,880,
null,null,
hInstance,null);

	std.log.info("OKA`{} nCmdShow={}", .{hwnd.?,nCmdShow});
	Log.info("BBGGRR123456={x}!",.{CreateSolidBrush(0x123456).?});//0x00BBGGRR
	if(hwnd) |window| {
		if(false) _=user32.ShowWindow(window, nCmdShow);
		//_=window;
		//_=nCmdShow;
		//_=user32.MessageBoxW(window, u8to16le("hello"), u8to16le("title"), 0);
	} else {
		const err_code=w.kernel32.GetLastError();
		std.log.err("BAD`{}", .{err_code});
	}//if
		//testing:
	palette1(&GPal);
	palette1(&Gbmi.bmiColors);
	palette64(&Gbmi.bmiColors);
	//Gbmi.bmiColors=GPal;
	renderPattern1();
	fb[1][1]=255;
const gfb=do.GBuf{.p=&fb[0],.w=1024};
	do.g8.fillBox(gfb,0,0,10,10,255);
	@memset(&fb[0],255,500);
	@memset(&fb[3],0,500);

	@import("root").doMain();

	var msg:user32.MSG=undefined;
	while(user32.getMessageA(&msg,null,0,0))|_|{
		//_=user32.TranslateMessage(&msg);
		_=user32.dispatchMessageA(&msg);
	}else|_|{}//while
//	return @as(c_int,msg.wParam);
	return 0;
}//wWinMain

//OSwin
//////////////////////////////////////////////////////////////////////////////
var cmp=0;
pub const OSwin=struct {
	hwnd:HWND,
	pub fn new(wi:u32,he:u32,t:[*:0]const u8) *IRender {
		const hwnd=user32.CreateWindowExA(0,"DevOS",t,user32.WS_OVERLAPPED|user32.WS_SYSMENU|user32.WS_VISIBLE,0,0,
@intCast(i32,wi),@intCast(i32,he),
null,null,SInstance,null) orelse unreachable;
		const oswin=do.a.create(OSwin) catch unreachable;
		oswin.hwnd=hwnd;
		var r=IRender.new(wi,he,oswin,&.{.renderOne=renderOne,.invalidate=invalidate});
		//const old=user32.SetWindowLongPtrA(r.hwnd,0,0x1234567887654329);
		const old=user32.SetWindowLongPtrA(hwnd,0,@bitCast(w.LONG_PTR,@ptrToInt(r)));
		std.debug.print("\x1b[96mOLDWLong0={} ",.{old});
	//_=user32.ShowWindow(r,5);//nCmdShow=5
		return r;
	}//new
	fn renderOne(uhdc:usize,ctx:*anyopaque,clip:*[4]i32,ss:util.TSideSet,sw:*TStackWin) void {
		Log.msg("MSWin.renderOne"); std.debug.print("clip={any} ",.{clip.*});
		const hdc=@intToPtr(HDC,uhdc);//was ?HDC TODO:reject zero
		const rect=@ptrCast(*RECT,clip);
		_=ss;
		_=ctx;
		switch(sw.t) {
		.FREE,.GROUP,.NOTHING=>{},
		.BAR=>{
			rect.right+=rect.left;
			rect.bottom+=rect.top;
			_=FillRect(hdc,rect,@intToPtr(HBRUSH,color+1));//COLOR_WINDOW+1=COLOR_WINDOWFRAME=6 zero-doesn't-cast
		},//BAR
		.RECT=>{
			rect.left=sw.x;
			rect.right=sw.x+@intCast(i32,sw.w);
			rect.top=sw.y;
			rect.bottom=sw.y+@intCast(i32,sw.h);
			Log.trace("GDI-FrameRect rect={}",.{rect});
			_=FrameRect(hdc,rect,CreateSolidBrush(@bitCast(u32,GPal[sw.clr])));//0x00DD5522 0x00BBGGRR
			//TODO:DeleteObject(brush)
		},//RECT
		.BUF8=>|bw|{
			Log.trace("BUF8",.{});
			const bwfb=bw.fb();
			Gbmi.bmiHeader.biWidth=@bitCast(i32,sw.w);
			Gbmi.bmiHeader.biHeight=-@bitCast(i32,sw.h);
			_=SetDIBitsToDevice(hdc,sw.x,sw.y,sw.w,sw.h, 0,0, 0,sw.h, bwfb.p.ptr,&Gbmi,DIB_USAGE.RGB_COLORS);//xyw.w.fb.p.ptr &fb
		},//BUF8
		.DRAW8=>|d|{
			Log.trace("DRAW8{}",.{d});
			unreachable;
		},//DRAW8
		//else =>unreachable,
		}//switch
	}//renderOne
	//fn invalidate(ctx:*anyopaque,rect:*const[4]i32) void {
	fn invalidate(ctx:*anyopaque,x:i32,y:i32,wi:i32,he:i32) void {
		Log.begin("MSW.invalidate({},{},{},{})",.{x,y,wi,he});
		//const r=RECT{.left=rect[0],.top=rect[1],.right=rect[0]+rect[2],.bottom=rect[1]+rect[3]};
		const r=RECT{.left=x,.top=y,.right=x+wi,.bottom=y+he};
		//const r=@ptrCast(*RECT,rect);
		const self=@ptrCast(*OSwin,@alignCast(8,ctx));
		_=InvalidateRect(self.hwnd,&r,w.FALSE);
		Log.trace("MSWinvalidated{} ",.{r});
	}//invalidate
};//OSwin

pub fn OSwinN(wi:i32,he:i32) HWND {
	const r=user32.CreateWindowExA(0,"DevOS","wc.lpszClassName",user32.WS_OVERLAPPED|user32.WS_SYSMENU,0,0,
wi,he,
null,null,SInstance,null) orelse unreachable;
	_=user32.ShowWindow(r,5);//nCmdShow=5
	std.debug.print("\x1b[93mWLong0={} 1={}",.{user32.GetWindowLongPtrA(r,0),user32.GetWindowLongPtrA(r,1)});
	return r;
}//OSwin
