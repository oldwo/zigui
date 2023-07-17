//
const std = @import("std");
const testing = std.testing;

export fn add(a: i32, b: i32) i32 {
    return a + b;
}

test "basic add functionality" {
    try testing.expect(add(3, 7) == 10);
}

const win32 = @import("std").os.windows;
const WINAPI = @import("std").os.windows.WINAPI;

const MessageBoxA=@import("std").os.windows.user32.MessageBoxA;

pub export fn wWinMain(hInstance: win32.HINSTANCE, _: ?win32.HINSTANCE, pCmdLine: [*:0]u16, nCmdShow: c_int) callconv(WINAPI) c_int {
    _ = hInstance;
    _ = nCmdShow;
    _ = pCmdLine;

	_=MessageBoxA(null, "hello", "title", 0);

    return 0;
}
