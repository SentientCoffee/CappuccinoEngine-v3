package winapi;

// -----------------------------------------------------------------------------------
// Types
// -----------------------------------------------------------------------------------

Bool  :: distinct b32;
Word  :: distinct u16;
DWord :: distinct u32;

Atom :: Word;

Handle    :: distinct rawptr;
HBrush    :: Handle;
HCursor   :: Handle;
HDC       :: Handle;
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