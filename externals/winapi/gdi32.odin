package winapi;

foreign import "system:gdi32.lib";

// -----------------------------------------------------------------------------------
// Enums
// -----------------------------------------------------------------------------------

BitmapBitCount :: enum u16 {
    Implied    = 0,
    Monochrome = 1,
    Color4     = 4,
    Color8     = 8,
    Color16    = 16,
    Color32    = 32,
}

BitmapCompression :: enum u32 {
    Rgb       = 0,
    Rle8      = 1,
    Rle4      = 2,
    Bitfields = 3,
    Jpeg      = 4,
    Png       = 5,
}

DIBUsage :: enum u32 {
    RgbColors     = 0,
    PaletteColors = 1,
}

RasterOperation :: enum u32 {
    SourceCopy     = 0x00CC_0020,
    SourcePaint    = 0x00EE_0086,
    SourceAnd      = 0x0088_00C6,
    SourceInvert   = 0x0066_0046,
    SourceErase    = 0x0044_0328,
    NotSourceCopy  = 0x0033_0008,
    NotSourceErase = 0x0011_00A6,
    MergeCopy      = 0x00C0_00CA,
    MergePaint     = 0x00BB_0226,
    PatCopy        = 0x00F0_0021,
    PatPaint       = 0x00FB_0A09,
    PatInvert      = 0x005A_0049,
    DestInvert     = 0x0055_0009,
    Whiteness      = 0x00FF_0062,
    Blackness      = 0x0000_0042,
}

// -----------------------------------------------------------------------------------
// Structs
// -----------------------------------------------------------------------------------

BitmapInfo :: struct {
    using header : BitmapInfoHeader,
    colors       : [1]RgbQuad,
}

BitmapInfoHeader :: struct {
    size             : DWord,
    width, height    : i32,
    planes           : Word,
    bitCount         : BitmapBitCount,
    compression      : BitmapCompression,
    sizeImage        : DWord,
    XPixelsPerMeter  : i32,
    YPixelsPerMeter  : i32,
    ColorsUsed       : DWord,
    ColorsImportant  : DWord,
}

RgbQuad :: struct {
    blue, green, red, reseved : byte,
}

// -----------------------------------------------------------------------------------
// Overloads
// -----------------------------------------------------------------------------------

createCompatibleDC :: proc{ createCompatibleDCHandle, createCompatibleDCNil };

// -----------------------------------------------------------------------------------
// Procedures
// -----------------------------------------------------------------------------------

createCompatibleDCHandle :: proc(hdc : HDC) -> HDC do return wCreateCompatibleDC(hdc);
createCompatibleDCNil    :: proc() -> HDC          do return wCreateCompatibleDC(nil);

// -----------------------------------------------------------------------------------

createDIBSection :: proc(
    hdc : HDC,
    bitmapInfo : ^BitmapInfo, usage : DIBUsage, rawBits : ^rawptr,
    section : Handle, offset : DWord) -> HBitmap
{
    return wCreateDIBSection(hdc, bitmapInfo, u32(usage), rawBits, section, offset);
}

// -----------------------------------------------------------------------------------

deleteObject :: proc(objectHandle : HGdiObj) -> Bool do return wDeleteObject(objectHandle);

patBlt :: proc(hdc : HDC, x, y, width, height : i32, rasterOp : RasterOperation) -> Bool do return wPatBlt(hdc, x, y, width, height, u32(rasterOp));

// -----------------------------------------------------------------------------------

stretchDIBits :: proc(
    hdc : HDC,
    destX, destY, destWidth, destHeight : i32,
    srcX, srcY, srcWidth, srcHeight : i32,
    rawBits : rawptr, bitmapInfo : ^BitmapInfo,
    usage : DIBUsage, rasterOp : RasterOperation) -> i32
{
    return wStretchDIBits(hdc, destX, destY, destWidth, destHeight, srcX, srcY, srcWidth, srcHeight, rawBits, bitmapInfo, u32(usage), u32(rasterOp));
}

// -----------------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------------

@(private="file", default_calling_convention="std")
foreign gdi32 {
    @(link_name="CreateCompatibleDC") wCreateCompatibleDC :: proc(hdc : HDC) -> HDC ---;
    @(link_name="CreateDIBSection")   wCreateDIBSection   :: proc(hdc : HDC, bitmapInfo : ^BitmapInfo, usage : u32, rawBits : ^rawptr, section : Handle, offset : DWord) -> HBitmap ---;
    @(link_name="DeleteObject")       wDeleteObject       :: proc(ho : HGdiObj) -> Bool ---;
    @(link_name="PatBlt")             wPatBlt             :: proc(hdc : HDC, x, y, w, h : i32, rasterOp : u32) -> Bool ---;
    @(link_name="StretchDIBits")      wStretchDIBits      :: proc(
        hdc : HDC,
        destX, destY, destWidth, destHeight : i32,
        srcX, srcY, srcWidth, srcHeight : i32,
        rawBits : rawptr, bitmapInfo : ^BitmapInfo,
        usage : u32, rasterOp : u32,
    ) -> i32 ---;
}
