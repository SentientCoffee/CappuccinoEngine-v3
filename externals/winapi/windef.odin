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

Bool  :: b32;
Word  :: u16;
DWord :: u32;
Atom  :: Word;

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

LParam    :: distinct int;
LResult   :: distinct int;

WParam    :: distinct uintptr;
WString   :: distinct ^u16;

// -----------------------------------------------------------------------------------
// Structs
// -----------------------------------------------------------------------------------

Point :: struct {
    x, y : i32,
}

Rect :: struct {
    left, top, right, bottom : i32,
}