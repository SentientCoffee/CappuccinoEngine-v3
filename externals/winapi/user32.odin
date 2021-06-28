package winapi;

foreign import "system:user32.lib";

// -----------------------------------------------------------------------------------
// Types
// -----------------------------------------------------------------------------------

WndProc :: distinct #type proc "std" (HWnd, WindowMessage, WParam, LParam) -> LResult;

// -----------------------------------------------------------------------------------
// Enums
// -----------------------------------------------------------------------------------

CreateWindow :: enum i32 {
    UseDefault = -0x8000_0000,
}

ClassStyles :: enum u32 {
    VRedraw         = 0x0000_0001,
    HRedraw         = 0x0000_0002,
    DblClks         = 0x0000_0008,
    OwnDC           = 0x0000_0020,
    ClassDC         = 0x0000_0040,
    ParentDC        = 0x0000_0080,
    NoClose         = 0x0000_0200,
    SaveBits        = 0x0000_0800,
    ByteAlignClient = 0x0000_1000,
    ByteAlignWindow = 0x0000_2000,
    GlobalClass     = 0x0000_4000,
    DropShadow      = 0x0002_0000,
}

QueueStatus :: enum u32 {
    Key            = 0x0001,
    MouseMove      = 0x0002,
    MouseButton    = 0x0004,
    PostMessage    = 0x0008,
    Timer          = 0x0010,
    Paint          = 0x0020,
    SendMessage    = 0x0040,
    Hotkey         = 0x0080,
    AllPostMessage = 0x0100,
    RawInput       = 0x0400,
    Mouse          = MouseMove | MouseButton,
    Input          = Mouse | Key | RawInput,
    AllEvents      = Input | PostMessage | Timer | Paint | Hotkey,
    AllInput       = Input | PostMessage | Timer | Paint | Hotkey | SendMessage,
}

WindowMessage :: enum u32 {
    Create      = 0x0001,
    Destroy     = 0x0002,
    Size        = 0x0005,
    Paint       = 0x000F,
    Close       = 0x0010,
    Quit        = 0x0012,
    ActivateApp = 0x001C,
}

PeekMessage :: enum u32 {
    NoRemove         = 0x0000,
    Remove           = 0x0001,
    NoYield          = 0x0002,
    QueueInput       = cast(u32) (QueueStatus.Input) << 16,
    QueuePaint       = cast(u32) (QueueStatus.Paint) << 16,
    QueueSendMessage = cast(u32) (QueueStatus.SendMessage) << 16,
    QueuePostMessage = cast(u32) (QueueStatus.PostMessage | QueueStatus.Hotkey | QueueStatus.Timer) << 16,
}

WindowSize :: enum u32 {
    Restored  = 0,
    Minimized = 1,
    Maximized = 2,
    MaxShow   = 3,
    MaxHide   = 4,
}

WindowStyle :: enum u32 {
    Overlapped       = 0x0000_0000,
    MaximizeBox      = 0x0001_0000,
    MinimizeBox      = 0x0002_0000,
    ThickFrame       = 0x0004_0000,
    SysMenu          = 0x0008_0000,
    Caption          = 0x00C0_0000,
    Visible          = 0x1000_0000,
    OverlappedWindow = Overlapped | Caption | SysMenu | ThickFrame | MinimizeBox | MaximizeBox,
}

// -----------------------------------------------------------------------------------
// Structs
// -----------------------------------------------------------------------------------

Msg :: struct {
    windowHandle : HWnd,
    message      : WindowMessage,
    wParam       : WParam,
    lParam       : LParam,
    time         : DWord,
    point        : Point,
    private      : DWord,
}

PaintStruct :: struct {
    hdc           : HDC,
    erase         : Bool,
    paintRect     : Rect,
    restore       : Bool,
    includeUpdate : Bool,
    rgbReserved   : [32]byte,
}

WndClassA :: struct {
    style               : u32,
    windowProc          : WndProc,
    clsExtra, wndExtra  : i32,
    instance            : HInstance,
    icon                : HIcon,
    cursor              : HCursor,
    background          : HBrush,
    menuName, className : cstring,
}

WndClassW :: struct {
    style               : u32,
    windowProc          : WndProc,
    clsExtra, wndExtra  : i32,
    instance            : HInstance,
    icon                : HIcon,
    cursor              : HCursor,
    background          : HBrush,
    menuName, className : WString,
}

WndClassExA :: struct {
    size, style         : u32,
    windowProc          : WndProc,
    clsExtra, wndExtra  : i32,
    instance            : HInstance,
    icon                : HIcon,
    cursor              : HCursor,
    background          : HBrush,
    menuName, className : cstring,
    iconSmall           : HIcon,
}

WndClassExW :: struct {
    size, style         : u32,
    windowProc          : WndProc,
    clsExtra, wndExtra  : i32,
    instance            : HInstance,
    icon                : HIcon,
    cursor              : HCursor,
    background          : HBrush,
    menuName, className : WString,
    iconSmall           : HIcon,
}

// -----------------------------------------------------------------------------------
// Overloads
// -----------------------------------------------------------------------------------

beginPaint       :: proc{ wBeginPaint       };
endPaint         :: proc{ wEndPaint         };
getClientRect    :: proc{ wGetClientRect    };
getDc            :: proc{ wGetDc            };
postQuitMessage  :: proc{ wPostQuitMessage  };
releaseDc        :: proc{ wReleaseDc        };
translateMessage :: proc{ wTranslateMessage };

createWindow     :: proc{     createWindowA,  createWindowW,  createWindowExA,  createWindowExW };
defWindowProc    :: proc{    defWindowProcA };
dispatchMessage  :: proc{  dispatchMessageA };
getMessage       :: proc{       getMessageA };
peekMessage      :: proc{      peekMessageA };
registerClass    :: proc{    registerClassA, registerClassW, registerClassExA, registerClassExW };

// -----------------------------------------------------------------------------------
// Procedures
// -----------------------------------------------------------------------------------

createWindowA :: proc(
    className, title : cstring,
    style : DWord,
    x, y, w, h : i32,
    parent : HWnd, menu : HMenu, instance : HInstance,
    param : rawptr) -> HWnd
{
    return createWindowExA(0, className, title, style, x, y, w, h, parent, menu, instance, param);
}

createWindowW :: proc(
    className, title : WString,
    style : DWord,
    x, y, w, h : i32,
    parent : HWnd, menu : HMenu, instance : HInstance,
    param : rawptr) -> HWnd
{
    return createWindowExW(0, className, title, style, x, y, w, h, parent, menu, instance, param);
}

createWindowExA :: proc(
    extended_style: DWord,
    className, title : cstring,
    style : DWord,
    x, y, w, h : i32,
    parent : HWnd, menu : HMenu, instance : HInstance,
    param : rawptr) -> HWnd
{
    return wCreateWindowExA(extended_style, className, title, style, x, y, w, h, parent, menu, instance, param);
}

createWindowExW :: proc(
    extended_style: DWord,
    className, title : WString,
    style : DWord,
    x, y, w, h : i32,
    parent : HWnd, menu : HMenu, instance : HInstance,
    param : rawptr) -> HWnd
{
    return wCreateWindowExW(extended_style, className, title, style, x, y, w, h, parent, menu, instance, param);
}

// -----------------------------------------------------------------------------------

defWindowProcA :: proc(hwnd: HWnd, message: WindowMessage, wParam: WParam, lParam: LParam) -> LResult do return wDefWindowProcA(hwnd, u32(message), wParam, lParam);
defWindowProcW :: proc(hwnd: HWnd, message: WindowMessage, wParam: WParam, lParam: LParam) -> LResult do return wDefWindowProcW(hwnd, u32(message), wParam, lParam);

// -----------------------------------------------------------------------------------

dispatchMessageA :: proc(message : ^Msg) -> LResult do return wDispatchMessageA(message);
dispatchMessageW :: proc(message : ^Msg) -> LResult do return wDispatchMessageW(message);

// -----------------------------------------------------------------------------------

getMessageA :: proc(message : ^Msg, handle : HWnd, messageFilterMin : u32, messageFilterMax : u32) -> Bool do return wGetMessageA(message, handle, messageFilterMin, messageFilterMax);
getMessageW :: proc(message : ^Msg, handle : HWnd, messageFilterMin : u32, messageFilterMax : u32) -> Bool do return wGetMessageW(message, handle, messageFilterMin, messageFilterMax);

// -----------------------------------------------------------------------------------

peekMessageA :: proc(message : ^Msg, handle : HWnd, messageFilterMin : u32, messageFilterMax : u32, peekMessage : u32) -> Bool do return wPeekMessageA(message, handle, messageFilterMin, messageFilterMax, peekMessage);
peekMessageW :: proc(message : ^Msg, handle : HWnd, messageFilterMin : u32, messageFilterMax : u32, peekMessage : u32) -> Bool do return wPeekMessageW(message, handle, messageFilterMin, messageFilterMax, peekMessage);

// -----------------------------------------------------------------------------------

registerClassA :: proc(windowClass : ^WndClassA)     -> Atom do return wRegisterClassA(windowClass);
registerClassW :: proc(windowClass : ^WndClassW)     -> Atom do return wRegisterClassW(windowClass);
registerClassExA :: proc(windowClass : ^WndClassExA) -> Atom do return wRegisterClassExA(windowClass);
registerClassExW :: proc(windowClass : ^WndClassExW) -> Atom do return wRegisterClassExW(windowClass);

// -----------------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------------

@(private="file", default_calling_convention="std")
foreign user32 {
    @(link_name="BeginPaint")       wBeginPaint       :: proc(window: HWnd, paint: ^PaintStruct) -> HDC ---;

    @(link_name="CreateWindowExA")  wCreateWindowExA  :: proc(
        extended_style : DWord,
        className : cstring, title : cstring, style : DWord,
        x : i32, y : i32, w : i32, h : i32,
        parent : HWnd, menu : HMenu, instance : HInstance,
        param : rawptr,
    ) -> HWnd ---;

    @(link_name="CreateWindowExW")  wCreateWindowExW  :: proc(
        extended_style : DWord,
        className : WString, title : WString, style : DWord,
        x : i32, y : i32, w : i32, h : i32,
        parent : HWnd, menu : HMenu, instance : HInstance,
        param : rawptr,
    ) -> HWnd ---;

    @(link_name="DefWindowProcA")   wDefWindowProcA   :: proc(hwnd : HWnd, message : u32, wParam : WParam, lParam : LParam) -> LResult ---;
    @(link_name="DefWindowProcW")   wDefWindowProcW   :: proc(hwnd : HWnd, message : u32, wParam : WParam, lParam : LParam) -> LResult ---;
    @(link_name="DispatchMessageA") wDispatchMessageA :: proc(message : ^Msg) -> LResult ---;
    @(link_name="DispatchMessageW") wDispatchMessageW :: proc(message : ^Msg) -> LResult ---;

    @(link_name="EndPaint")         wEndPaint         :: proc(window: HWnd, paint: ^PaintStruct) -> Bool ---;

    @(link_name="GetDC")            wGetDc            :: proc(handle : HWnd) -> HDC ---;
    @(link_name="GetMessageA")      wGetMessageA      :: proc(message : ^Msg, handle : HWnd, messageFilterMin : u32, messageFilterMax : u32) -> Bool ---;
    @(link_name="GetMessageW")      wGetMessageW      :: proc(message : ^Msg, handle : HWnd, messageFilterMin : u32, messageFilterMax : u32) -> Bool ---;
    @(link_name="GetClientRect")    wGetClientRect    :: proc(hwnd: HWnd, rect: ^Rect) -> Bool ---;
    
    @(link_name="PeekMessageA")     wPeekMessageA     :: proc(message : ^Msg, handle : HWnd, messageFilterMin : u32, messageFilterMax : u32, removeMessage : u32) -> Bool ---;
    @(link_name="PeekMessageW")     wPeekMessageW     :: proc(message : ^Msg, handle : HWnd, messageFilterMin : u32, messageFilterMax : u32, removeMessage : u32) -> Bool ---;
    @(link_name="PostQuitMessage")  wPostQuitMessage  :: proc(exitCode: i32) ---;
    
    @(link_name="RegisterClassA")   wRegisterClassA   :: proc(windowClass : ^WndClassA)   -> Atom ---;
    @(link_name="RegisterClassW")   wRegisterClassW   :: proc(windowClass : ^WndClassW)   -> Atom ---;
    @(link_name="RegisterClassExA") wRegisterClassExA :: proc(windowClass : ^WndClassExA) -> Atom ---;
    @(link_name="RegisterClassExW") wRegisterClassExW :: proc(windowClass : ^WndClassExW) -> Atom ---;
    @(link_name="ReleaseDC")        wReleaseDc        :: proc(handle : HWnd, hdc : HDC) -> i32 ---;

    @(link_name="TranslateMessage") wTranslateMessage :: proc(message : ^Msg) -> Bool    ---;

}
