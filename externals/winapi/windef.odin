package winapi;

// -----------------------------------------------------------------------------------
// Enums
// -----------------------------------------------------------------------------------

Error :: enum u32 {
    Success            = 0,
    InvalidFunction    = 1,
    InvalidParameter   = 87,
    DeviceNotConnected = 1167,
}

// -----------------------------------------------------------------------------------
// Types
// -----------------------------------------------------------------------------------

Bool    :: b32;
Word    :: u16;
DWord   :: u32;
HResult :: u32;
Atom    :: Word;

Handle    :: distinct rawptr;
HBitmap   :: Handle;
HBrush    :: Handle;
HCursor   :: Handle;
HDC       :: Handle;
HGdiObj   :: Handle;
HIcon     :: Handle;
HInstance :: Handle;
HMenu     :: Handle;
HModule   :: Handle;
HWnd      :: Handle;

Iid :: Guid;

LParam    :: distinct int;
LResult   :: distinct int;

WParam    :: distinct uintptr;
WString   :: distinct ^u16;

// -----------------------------------------------------------------------------------
// Structs
// -----------------------------------------------------------------------------------

Guid :: struct {
    data1 : u32,
    data2 : u16,
    data3 : u16,
    data4 : [8]u8,
}

Point :: struct {
    x, y : i32,
}

Rect :: struct {
    left, top, right, bottom : i32,
}