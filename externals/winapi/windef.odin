package winapi;

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
// Enums
// -----------------------------------------------------------------------------------

Error :: enum u32 {
    Success            = 0x0000,
    InvalidFunction    = 0x0001,
    InvalidParameter   = 0x0057,
    DeviceNotConnected = 0x048F,
}

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

// -----------------------------------------------------------------------------------
// Utils
// -----------------------------------------------------------------------------------

// bitset_to_integral :: #force_inline proc(set : $SetToCheck/bit_set[$Flags; Integral], flagToBit : $EnumArray/[Flags]$Integral) -> (ret : Integral) {
//     for flag in Flags {
//         if flag in set {
//             ret |= flagToBit[flag];
//         }
//     }

//     return ret;
// }