package winapi;

foreign import "system:gdi32.lib";

// -----------------------------------------------------------------------------------
// Enums
// -----------------------------------------------------------------------------------

RasterOperation :: enum u32 {
    PatCopy   = 0x00F0_0021,
    PatPaint  = 0x00FB_0A09,
    PatInvert = 0x005A_0049,
    Whiteness = 0x00FF_0062,
    Blackness = 0x0000_0042,
}

// -----------------------------------------------------------------------------------
// Procedures
// -----------------------------------------------------------------------------------

patBlt :: proc(hdc : HDC, x, y, width, height : i32, rasterOp : RasterOperation) -> Bool do return wPatBlt(hdc, x, y, width, height, u32(rasterOp));

// -----------------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------------

@(private="file", default_calling_convention="std")
foreign gdi32 {
    @(link_name="PatBlt") wPatBlt :: proc(hdc : HDC, x : i32, y : i32, w : i32, h : i32, rasterOp : u32) -> Bool ---;
}
