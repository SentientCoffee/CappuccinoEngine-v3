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

// -----------------------------------------------------------------------------------

ClassStyle :: enum u32 {
    VRedraw         = 0x0000_0001,  // 1 << 0
    HRedraw         = 0x0000_0002,  // 1 << 1
    DblClks         = 0x0000_0008,  // 1 << 3
    OwnDC           = 0x0000_0020,  // 1 << 5
    ClassDC         = 0x0000_0040,  // 1 << 6
    ParentDC        = 0x0000_0080,  // 1 << 7
    NoClose         = 0x0000_0200,  // 1 << 9
    SaveBits        = 0x0000_0800,  // 1 << 11
    ByteAlignClient = 0x0000_1000,  // 1 << 12
    ByteAlignWindow = 0x0000_2000,  // 1 << 13
    GlobalClass     = 0x0000_4000,  // 1 << 14
    DropShadow      = 0x0002_0000,  // 1 << 17
}

ClassStyleFlags :: enum u32 {
    VRedraw,
    HRedraw,
    DblClks,
    OwnDC,
    ClassDC,
    ParentDC,
    NoClose,
    SaveBits,
    ByteAlignClient,
    ByteAlignWindow,
    GlobalClass,
    DropShadow,
}

ClassStyleSet :: bit_set[ClassStyleFlags; u32];

@(private="file")
ClassStyleSet_to_u32 :: proc(set : ClassStyleSet) -> (ret : u32) {
    set := set;
    @static flagToBit := [ClassStyleFlags]u32{
        .VRedraw         = cast(u32) (ClassStyle.VRedraw),
        .HRedraw         = cast(u32) (ClassStyle.HRedraw),
        .DblClks         = cast(u32) (ClassStyle.DblClks),
        .OwnDC           = cast(u32) (ClassStyle.OwnDC),
        .ClassDC         = cast(u32) (ClassStyle.ClassDC),
        .ParentDC        = cast(u32) (ClassStyle.ParentDC),
        .NoClose         = cast(u32) (ClassStyle.NoClose),
        .SaveBits        = cast(u32) (ClassStyle.SaveBits),
        .ByteAlignClient = cast(u32) (ClassStyle.ByteAlignClient),
        .ByteAlignWindow = cast(u32) (ClassStyle.ByteAlignWindow),
        .GlobalClass     = cast(u32) (ClassStyle.GlobalClass),
        .DropShadow      = cast(u32) (ClassStyle.DropShadow),
    };

    ret = bitset_to_integral(set, flagToBit);
    return ret;
}

// -----------------------------------------------------------------------------------

PeekMessage :: enum u32 {
    NoRemove         = 0x0000,  // 0
    Remove           = 0x0001,  // 1 << 0
    NoYield          = 0x0002,  // 1 << 1
    QueueInput       = cast(u32) (QueueStatus.Input) << 16,
    QueuePaint       = cast(u32) (QueueStatus.Paint) << 16,
    QueueSendMessage = cast(u32) (QueueStatus.SendMessage) << 16,
    QueuePostMessage = cast(u32) (QueueStatus.PostMessage | QueueStatus.Hotkey | QueueStatus.Timer) << 16,
}

PeekMessageFlags :: enum u32 {
    NoRemove,
    Remove,
    NoYield,
    QueueInput,
    QueuePaint,
    QueueSendMessage,
    QueuePostMessage,
}

PeekMessageSet :: bit_set[PeekMessageFlags; u32];

@(private="file")
PeekMessageSet_to_u32 :: #force_inline proc(set : PeekMessageSet) -> (ret : u32) {
    set := set;
    @static flagToBit := [PeekMessageFlags]u32{
        .NoRemove         = cast(u32) (PeekMessage.NoRemove),
        .Remove           = cast(u32) (PeekMessage.Remove),
        .NoYield          = cast(u32) (PeekMessage.NoYield),
        .QueueInput       = cast(u32) (PeekMessage.QueueInput),
        .QueuePaint       = cast(u32) (PeekMessage.QueuePaint),
        .QueueSendMessage = cast(u32) (PeekMessage.QueueSendMessage),
        .QueuePostMessage = cast(u32) (PeekMessage.QueuePostMessage),
    };

    if .NoYield in set && !(set > (set & { .NoRemove, .Remove })) {
        // @Todo(Daniel): Log warning about .NoYield here
        // @Reference: https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-peekmessagea
        set += { .NoRemove };
    }

    ret = bitset_to_integral(set, flagToBit);
    return ret;
}

// -----------------------------------------------------------------------------------

QueueStatus :: enum u32 {
    Key            = 0x0001,  // 1 << 0
    MouseMove      = 0x0002,  // 1 << 1
    MouseButton    = 0x0004,  // 1 << 2
    PostMessage    = 0x0008,  // 1 << 3
    Timer          = 0x0010,  // 1 << 4
    Paint          = 0x0020,  // 1 << 5
    SendMessage    = 0x0040,  // 1 << 6
    Hotkey         = 0x0080,  // 1 << 7
    AllPostMessage = 0x0100,  // 1 << 8
    RawInput       = 0x0400,  // 1 << 10
    Mouse          = MouseMove | MouseButton,
    Input          = Mouse | Key | RawInput,
    AllEvents      = Input | PostMessage | Timer | Paint | Hotkey,
    AllInput       = Input | PostMessage | Timer | Paint | Hotkey | SendMessage,
}

QueueStatusFlags :: enum u32 {
    Key,
    MouseMove,
    MouseButton,
    PostMessage,
    Timer,
    Paint,
    SendMessage,
    Hotkey,
    AllPostMessage,
    RawInput,
    Mouse,
    Input,
    AllEvents,
    AllInput,
}

QueueStatusSet :: bit_set[QueueStatusFlags; u32];

@(private="file")
QueueStatusSet_to_u32 :: #force_inline proc(set : QueueStatusSet) -> (ret : u32) {
    set := set;
    @static flagToBit := [QueueStatusFlags]u32{
        .Key            = cast(u32) (QueueStatus.Key),
        .MouseMove      = cast(u32) (QueueStatus.MouseMove),
        .MouseButton    = cast(u32) (QueueStatus.MouseButton),
        .PostMessage    = cast(u32) (QueueStatus.PostMessage),
        .Timer          = cast(u32) (QueueStatus.Timer),
        .Paint          = cast(u32) (QueueStatus.Paint),
        .SendMessage    = cast(u32) (QueueStatus.SendMessage),
        .Hotkey         = cast(u32) (QueueStatus.Hotkey),
        .AllPostMessage = cast(u32) (QueueStatus.AllPostMessage),
        .RawInput       = cast(u32) (QueueStatus.RawInput),
        .Mouse          = cast(u32) (QueueStatus.Mouse),
        .Input          = cast(u32) (QueueStatus.Input),
        .AllEvents      = cast(u32) (QueueStatus.AllEvents),
        .AllInput       = cast(u32) (QueueStatus.AllInput),
    };

    

    ret = bitset_to_integral(set, flagToBit);
    return ret;
}

// -----------------------------------------------------------------------------------

VirtualKey :: enum u32 {
    MouseLeft        = 0x01,
    MouseRight       = 0x02,
    Cancel           = 0x03,
    MouseMiddle      = 0x04,
    MouseX1          = 0x05,
    MouseX2          = 0x06,
    Backspace        = 0x08,
    Tab              = 0x09,
    Clear            = 0x0C,
    Return           = 0x0D,
    Enter            = Return,
    Shift            = 0x10,
    Control          = 0x11,
    Menu             = 0x12,
    Alt              = Menu,
    Pause            = 0x13,
    Capital          = 0x14,
    CapsLock         = Capital,

    // @Incomplete: IME stuff missing

    Escape            = 0x1B,
    Space             = 0x20,
    Prior             = 0x21,
    Next              = 0x22,
    PageUp            = Prior,
    PageDown          = Next,
    End               = 0x23,
    Home              = 0x24,
    Left              = 0x25,
    Up                = 0x26,
    Right             = 0x27,
    Down              = 0x28,
    Select            = 0x29,
    Print             = 0x2A,
    Execute           = 0x2B,
    Snapshot          = 0x2C,
    PrintScreen       = Snapshot,
    Insert            = 0x2D,
    Delete            = 0x2E,
    Help              = 0x2F,

    // @Note: Number row keys
    NumRow0 = 0x30,
    NumRow1 = 0x31,
    NumRow2 = 0x32,
    NumRow3 = 0x33,
    NumRow4 = 0x34,
    NumRow5 = 0x35,
    NumRow6 = 0x36,
    NumRow7 = 0x37,
    NumRow8 = 0x38,
    NumRow9 = 0x39,

    // @Note: ANSI char letter keys
    A = 0x41,
    B = 0x42,
    C = 0x43,
    D = 0x44,
    E = 0x45,
    F = 0x46,
    G = 0x47,
    H = 0x48,
    I = 0x49,
    J = 0x4A,
    K = 0x4B,
    L = 0x4C,
    M = 0x4D,
    N = 0x4E,
    O = 0x4F,
    P = 0x50,
    Q = 0x51,
    R = 0x52,
    S = 0x53,
    T = 0x54,
    U = 0x55,
    V = 0x56,
    W = 0x57,
    X = 0x58,
    Y = 0x59,
    Z = 0x5A,

    LeftWindows  = 0x5B,
    RightWindows = 0x5C,
    Apps         = 0x5D,
    Sleep        = 0x5F,

    // @Note: Numpad keys
    Numpad0   = 0x60,
    Numpad1   = 0x61,
    Numpad2   = 0x62,
    Numpad3   = 0x63,
    Numpad4   = 0x64,
    Numpad5   = 0x65,
    Numpad6   = 0x66,
    Numpad7   = 0x67,
    Numpad8   = 0x68,
    Numpad9   = 0x69,

    Multiply  = 0x6A,
    Add       = 0x6B,
    Separator = 0x6C,
    Subtract  = 0x6D,
    Decimal   = 0x6E,
    Divide    = 0x6F,

    // @Note: Function keys
    F1  = 0x70,
    F2  = 0x71,
    F3  = 0x72,
    F4  = 0x73,
    F5  = 0x74,
    F6  = 0x75,
    F7  = 0x76,
    F8  = 0x77,
    F9  = 0x78,
    F10 = 0x79,
    F11 = 0x7A,
    F12 = 0x7B,
    F13 = 0x7C,
    F14 = 0x7D,
    F15 = 0x7E,
    F16 = 0x7F,
    F17 = 0x80,
    F18 = 0x81,
    F19 = 0x82,
    F20 = 0x83,
    F21 = 0x84,
    F22 = 0x85,
    F23 = 0x86,
    F24 = 0x87,

    NumLock      = 0x90,
    ScrollLock   = 0x91,
    LeftShift    = 0xA0,
    RightShift   = 0xA1,
    LeftControl  = 0xA2,
    RightControl = 0xA3,
    LeftMenu     = 0xA4,
    RightMenu    = 0xA5,
    LeftAlt      = LeftMenu,
    RightAlt     = RightMenu,

    BrowserBack        = 0xA6,
    BrowserForward     = 0xA7,
    BrowserRefresh     = 0xA8,
    BrowserStop        = 0xA9,
    BrowserSearch      = 0xAA,
    BrowserFavorites   = 0xAB,
    BrowserHome        = 0xAC,
    VolumeMute         = 0xAD,
    VolumeDown         = 0xAE,
    VolumeUp           = 0xAF,
    MediaNextTrack     = 0xB0,
    MediaPreviousTrack = 0xB1,
    MediaStop          = 0xB2,
    MediaPlayPause     = 0xB3,
    LaunchMail         = 0xB4,
    LaunchMediaSelect  = 0xB5,
    LaunchApp1         = 0xB6,
    LaunchApp2         = 0xB7,

    OemPlus    = 0xBB,
    OemComma   = 0xBC,
    OemMinus   = 0xBD,
    OemPeriod  = 0xBE,
    Oem2       = 0xBF,
    Oem3       = 0xC0,
    Oem4       = 0xDB,
    Oem5       = 0xDC,
    Oem6       = 0xDD,
    Oem7       = 0xDE,
    Oem8       = 0xDF,
    Oem102     = 0xE2,
    ProcessKey = 0xE5,
    Packet     = 0xE7,
    Attn       = 0xF6,
    CrSel      = 0xF7,
    ExSel      = 0xF8,
    EraseEOF   = 0xF9,
    Play       = 0xFA,
    Zoom       = 0xFB,
    PA1        = 0xFD,
    OemClear   = 0xFE,
}

// -----------------------------------------------------------------------------------

WindowMessage :: enum u32 {
    Create      = 0x0001,
    Destroy     = 0x0002,
    Size        = 0x0005,
    Paint       = 0x000F,
    Close       = 0x0010,
    Quit        = 0x0012,
    ActivateApp = 0x001C,
    KeyDown     = 0x0100,
    KeyUp       = 0x0101,
    SysKeyDown  = 0x0104,
    SysKeyUp    = 0x0105,
}

// -----------------------------------------------------------------------------------

WindowSize :: enum u32 {
    Restored  = 0,
    Minimized = 1,
    Maximized = 2,
    MaxShow   = 3,
    MaxHide   = 4,
}

// -----------------------------------------------------------------------------------

WindowStyle :: enum u32 {
    Overlapped       = 0x0000_0000,  // 1 << 32
    MaximizeBox      = 0x0001_0000,  // 1 << 16
    MinimizeBox      = 0x0002_0000,  // 1 << 17
    ThickFrame       = 0x0004_0000,  // 1 << 18
    SysMenu          = 0x0008_0000,  // 1 << 19
    HScroll          = 0x0010_0000,  // 1 << 20
    VScroll          = 0x0020_0000,  // 1 << 21
    DialogFrame      = 0x0040_0000,  // 1 << 22
    Border           = 0x0080_0000,  // 1 << 23
    Maximize         = 0x0100_0000,  // 1 << 24
    ClipChildren     = 0x0200_0000,  // 1 << 25
    ClipSiblings     = 0x0400_0000,  // 1 << 26
    Disabled         = 0x0800_0000,  // 1 << 27
    Visible          = 0x1000_0000,  // 1 << 28
    Minimize         = 0x2000_0000,  // 1 << 29
    Child            = 0x4000_0000,  // 1 << 30
    Popup            = 0x8000_0000,  // 1 << 31

    ChildWindow      = Child,
    Group            = MinimizeBox,
    Iconic           = Minimize,
    Tiled            = Overlapped,
    SizeBox          = ThickFrame,
    Caption          = DialogFrame | Border,
    PopupWindow      = Popup | Border | SysMenu,
    OverlappedWindow = Overlapped | Caption | SysMenu | ThickFrame | MinimizeBox | MaximizeBox,
    TiledWindow      = OverlappedWindow,
}

WindowStyleFlags :: enum u32 {
    Overlapped,
    MaximizeBox,
    MinimizeBox,
    ThickFrame,
    SysMenu,
    HScroll,
    VScroll,
    DialogFrame,
    Border,
    Maximize,
    ClipChildren,
    ClipSiblings,
    Disabled,
    Visible,
    Minimize,
    Child,
    Popup,

    ChildWindow,
    Group,
    Iconic,
    Tiled,
    SizeBox,
    Caption,
    PopupWindow,
    OverlappedWindow,
    TiledWindow,
}

WindowStyleSet :: bit_set[WindowStyleFlags; u32];

@(private="file")
WindowStyleSet_to_u32 :: #force_inline proc(set : WindowStyleSet) -> (ret : u32) {
    set := set;
    @static flagToBit := [WindowStyleFlags]u32{
        .Overlapped       = cast(u32) (WindowStyle.Overlapped),
        .MaximizeBox      = cast(u32) (WindowStyle.MaximizeBox),
        .MinimizeBox      = cast(u32) (WindowStyle.MinimizeBox),
        .ThickFrame       = cast(u32) (WindowStyle.ThickFrame),
        .SysMenu          = cast(u32) (WindowStyle.SysMenu),
        .HScroll          = cast(u32) (WindowStyle.HScroll),
        .VScroll          = cast(u32) (WindowStyle.VScroll),
        .DialogFrame      = cast(u32) (WindowStyle.DialogFrame),
        .Border           = cast(u32) (WindowStyle.Border),
        .Maximize         = cast(u32) (WindowStyle.Maximize),
        .ClipChildren     = cast(u32) (WindowStyle.ClipChildren),
        .ClipSiblings     = cast(u32) (WindowStyle.ClipSiblings),
        .Disabled         = cast(u32) (WindowStyle.Disabled),
        .Visible          = cast(u32) (WindowStyle.Visible),
        .Minimize         = cast(u32) (WindowStyle.Minimize),
        .Child            = cast(u32) (WindowStyle.Child),
        .Popup            = cast(u32) (WindowStyle.Popup),

        .ChildWindow      = cast(u32) (WindowStyle.ChildWindow),
        .Group            = cast(u32) (WindowStyle.Group),
        .Iconic           = cast(u32) (WindowStyle.Iconic),
        .Tiled            = cast(u32) (WindowStyle.Tiled),
        .SizeBox          = cast(u32) (WindowStyle.SizeBox),
        .Caption          = cast(u32) (WindowStyle.Caption),
        .PopupWindow      = cast(u32) (WindowStyle.PopupWindow),
        .OverlappedWindow = cast(u32) (WindowStyle.OverlappedWindow),
        .TiledWindow      = cast(u32) (WindowStyle.TiledWindow),
    };

    ret = bitset_to_integral(set, flagToBit);
    return ret;
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

// -----------------------------------------------------------------------------------

PaintStruct :: struct {
    hdc           : HDC,
    erase         : Bool,
    paintRect     : Rect,
    restore       : Bool,
    includeUpdate : Bool,
    rgbReserved   : [32]byte,
}

// -----------------------------------------------------------------------------------

// @(private)
// WndClassBase :: struct {
//     style               : union{ ClassStyleSet, u32 },
//     windowProc          : WndProc,
//     clsExtra, wndExtra  : i32,
//     instance            : HInstance,
//     icon                : HIcon,
//     cursor              : HCursor,
//     background          : HBrush,
// }

WndClassA :: struct {
    style               : union{ ClassStyleSet, u32 },
    windowProc          : WndProc,
    clsExtra, wndExtra  : i32,
    instance            : HInstance,
    icon                : HIcon,
    cursor              : HCursor,
    background          : HBrush,
    menuName, className : cstring,
}

WndClassW :: struct {
    style               : union{ ClassStyleSet, u32 },
    windowProc          : WndProc,
    clsExtra, wndExtra  : i32,
    instance            : HInstance,
    icon                : HIcon,
    cursor              : HCursor,
    background          : HBrush,
    menuName, className : WString,
}

WndClassExA :: struct {
    size                : u32,
    style               : union{ ClassStyleSet, u32 },
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
    size                : u32,
    style               : union{ ClassStyleSet, u32 },
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

beginPaint       :: proc { wBeginPaint       };
endPaint         :: proc { wEndPaint         };
getClientRect    :: proc { wGetClientRect    };
getDc            :: proc { wGetDc            };
postQuitMessage  :: proc { wPostQuitMessage  };
releaseDc        :: proc { wReleaseDc        };
translateMessage :: proc { wTranslateMessage };

defWindowProc    :: proc { defWindowProcA };
dispatchMessage  :: proc { dispatchMessageA };
getMessage       :: proc { getMessageA };
peekMessage      :: proc { peekMessageA_set, peekMessageA_u32 };
registerClass    :: proc { registerClassA, registerClassW, registerClassExA, registerClassExW };

createWindow :: proc {
    createWindowA_set, createWindowA_u32,
    createWindowW_set, createWindowW_u32,
    createWindowExA_set, createWindowExA_u32,
    createWindowExW_set, createWindowExW_u32,
};

// -----------------------------------------------------------------------------------
// Procedures
// -----------------------------------------------------------------------------------

createWindowA_set :: proc(
    className, title : cstring,
    style : WindowStyleSet,
    x, y, w, h : i32,
    parent : HWnd, menu : HMenu, instance : HInstance,
    param : rawptr) -> HWnd
{
    return createWindowExA_u32(0, className, title, WindowStyleSet_to_u32(style), x, y, w, h, parent, menu, instance, param);
}

createWindowA_u32 :: proc(
    className, title : cstring,
    style : DWord,
    x, y, w, h : i32,
    parent : HWnd, menu : HMenu, instance : HInstance,
    param : rawptr) -> HWnd
{
    return createWindowExA_u32(0, className, title, style, x, y, w, h, parent, menu, instance, param);
}

createWindowW_set :: proc(
    className, title : WString,
    style : WindowStyleSet,
    x, y, w, h : i32,
    parent : HWnd, menu : HMenu, instance : HInstance,
    param : rawptr) -> HWnd
{
    return createWindowExW_u32(0, className, title, WindowStyleSet_to_u32(style), x, y, w, h, parent, menu, instance, param);
}

createWindowW_u32 :: proc(
    className, title : WString,
    style : DWord,
    x, y, w, h : i32,
    parent : HWnd, menu : HMenu, instance : HInstance,
    param : rawptr) -> HWnd
{
    return createWindowExW_u32(0, className, title, style, x, y, w, h, parent, menu, instance, param);
}

createWindowExA_set :: proc(
    extendedStyle : DWord,
    className, title : cstring,
    style : WindowStyleSet,
    x, y, w, h : i32,
    parent : HWnd, menu : HMenu, instance : HInstance,
    param : rawptr) -> HWnd
{
    return wCreateWindowExA(extendedStyle, className, title, WindowStyleSet_to_u32(style), x, y, w, h, parent, menu, instance, param);
}

createWindowExA_u32 :: proc(
    extendedStyle : DWord,
    className, title : cstring,
    style : DWord,
    x, y, w, h : i32,
    parent : HWnd, menu : HMenu, instance : HInstance,
    param : rawptr) -> HWnd
{
    return wCreateWindowExA(extendedStyle, className, title, style, x, y, w, h, parent, menu, instance, param);
}

createWindowExW_set :: proc(
    extendedStyle : DWord,
    className, title : WString,
    style : WindowStyleSet,
    x, y, w, h : i32,
    parent : HWnd, menu : HMenu, instance : HInstance,
    param : rawptr) -> HWnd
{
    return wCreateWindowExW(extendedStyle, className, title, WindowStyleSet_to_u32(style), x, y, w, h, parent, menu, instance, param);
}

createWindowExW_u32 :: proc(
    extendedStyle : DWord,
    className, title : WString,
    style : DWord,
    x, y, w, h : i32,
    parent : HWnd, menu : HMenu, instance : HInstance,
    param : rawptr) -> HWnd
{
    return wCreateWindowExW(extendedStyle, className, title, style, x, y, w, h, parent, menu, instance, param);
}

// -----------------------------------------------------------------------------------

defWindowProcA :: proc(hwnd : HWnd, message : WindowMessage, wParam : WParam, lParam : LParam) -> LResult do return wDefWindowProcA(hwnd, cast(u32) message, wParam, lParam);
defWindowProcW :: proc(hwnd : HWnd, message : WindowMessage, wParam : WParam, lParam : LParam) -> LResult do return wDefWindowProcW(hwnd, cast(u32) message, wParam, lParam);

// -----------------------------------------------------------------------------------

dispatchMessageA :: proc(message : ^Msg) -> LResult do return wDispatchMessageA(message);
dispatchMessageW :: proc(message : ^Msg) -> LResult do return wDispatchMessageW(message);

// -----------------------------------------------------------------------------------

getMessageA :: proc(message : ^Msg, handle : HWnd, messageFilterMin : u32, messageFilterMax : u32) -> Bool do return wGetMessageA(message, handle, messageFilterMin, messageFilterMax);
getMessageW :: proc(message : ^Msg, handle : HWnd, messageFilterMin : u32, messageFilterMax : u32) -> Bool do return wGetMessageW(message, handle, messageFilterMin, messageFilterMax);

// -----------------------------------------------------------------------------------

peekMessageA_set :: proc(message : ^Msg, handle : HWnd, messageFilterMin : u32, messageFilterMax : u32, removeMessage : PeekMessageSet) -> Bool {
    return wPeekMessageA(message, handle, messageFilterMin, messageFilterMax, PeekMessageSet_to_u32(removeMessage));
}
peekMessageA_u32 :: proc(message : ^Msg, handle : HWnd, messageFilterMin : u32, messageFilterMax : u32, removeMessage : u32) -> Bool {
    return wPeekMessageA(message, handle, messageFilterMin, messageFilterMax, removeMessage);
}

peekMessageW_set :: proc(message : ^Msg, handle : HWnd, messageFilterMin : u32, messageFilterMax : u32, removeMessage : PeekMessageSet) -> Bool {
    return wPeekMessageW(message, handle, messageFilterMin, messageFilterMax, PeekMessageSet_to_u32(removeMessage));
}
peekMessageW_u32 :: proc(message : ^Msg, handle : HWnd, messageFilterMin : u32, messageFilterMax : u32, removeMessage : u32) -> Bool {
    return wPeekMessageW(message, handle, messageFilterMin, messageFilterMax, removeMessage);
}

// -----------------------------------------------------------------------------------

registerClassA :: proc(windowClass : ^WndClassA) -> Atom {
    #partial switch type in windowClass.style {
        case ClassStyleSet: windowClass.style = ClassStyleSet_to_u32(type);
    }
    return wRegisterClassA(windowClass);
}
registerClassW :: proc(windowClass : ^WndClassW) -> Atom {
    #partial switch type in windowClass.style {
        case ClassStyleSet: windowClass.style = ClassStyleSet_to_u32(type);
    }
    return wRegisterClassW(windowClass);
}

registerClassExA :: proc(windowClass : ^WndClassExA) -> Atom {
    #partial switch type in windowClass.style {
        case ClassStyleSet: windowClass.style = ClassStyleSet_to_u32(type);
    }
    return wRegisterClassExA(windowClass);
}

registerClassExW :: proc(windowClass : ^WndClassExW) -> Atom {
    #partial switch type in windowClass.style {
        case ClassStyleSet: windowClass.style = ClassStyleSet_to_u32(type);
    }
    return wRegisterClassExW(windowClass);
}

// -----------------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------------

@(private="file", default_calling_convention="std")
foreign user32 {
    @(link_name="BeginPaint")       wBeginPaint       :: proc(window : HWnd, paint : ^PaintStruct) -> HDC ---;

    @(link_name="CreateWindowExA")  wCreateWindowExA  :: proc(
        extendedStyle : DWord,
        className : cstring, title : cstring, style : DWord,
        x : i32, y : i32, w : i32, h : i32,
        parent : HWnd, menu : HMenu, instance : HInstance,
        param : rawptr,
    ) -> HWnd ---;

    @(link_name="CreateWindowExW")  wCreateWindowExW  :: proc(
        extendedStyle : DWord,
        className : WString, title : WString, style : DWord,
        x : i32, y : i32, w : i32, h : i32,
        parent : HWnd, menu : HMenu, instance : HInstance,
        param : rawptr,
    ) -> HWnd ---;

    @(link_name="DefWindowProcA")   wDefWindowProcA   :: proc(hwnd : HWnd, message : u32, wParam : WParam, lParam : LParam) -> LResult ---;
    @(link_name="DefWindowProcW")   wDefWindowProcW   :: proc(hwnd : HWnd, message : u32, wParam : WParam, lParam : LParam) -> LResult ---;
    @(link_name="DispatchMessageA") wDispatchMessageA :: proc(message : ^Msg) -> LResult ---;
    @(link_name="DispatchMessageW") wDispatchMessageW :: proc(message : ^Msg) -> LResult ---;

    @(link_name="EndPaint")         wEndPaint         :: proc(window : HWnd, paint : ^PaintStruct) -> Bool ---;

    @(link_name="GetDC")            wGetDc            :: proc(handle : HWnd) -> HDC ---;
    @(link_name="GetMessageA")      wGetMessageA      :: proc(message : ^Msg, handle : HWnd, messageFilterMin : u32, messageFilterMax : u32) -> Bool ---;
    @(link_name="GetMessageW")      wGetMessageW      :: proc(message : ^Msg, handle : HWnd, messageFilterMin : u32, messageFilterMax : u32) -> Bool ---;
    @(link_name="GetClientRect")    wGetClientRect    :: proc(hwnd : HWnd, rect : ^Rect) -> Bool ---;

    @(link_name="PeekMessageA")     wPeekMessageA     :: proc(message : ^Msg, handle : HWnd, messageFilterMin : u32, messageFilterMax : u32, removeMessage : u32) -> Bool ---;
    @(link_name="PeekMessageW")     wPeekMessageW     :: proc(message : ^Msg, handle : HWnd, messageFilterMin : u32, messageFilterMax : u32, removeMessage : u32) -> Bool ---;
    @(link_name="PostQuitMessage")  wPostQuitMessage  :: proc(exitCode : i32) ---;

    @(link_name="RegisterClassA")   wRegisterClassA   :: proc(windowClass : ^WndClassA)   -> Atom ---;
    @(link_name="RegisterClassW")   wRegisterClassW   :: proc(windowClass : ^WndClassW)   -> Atom ---;
    @(link_name="RegisterClassExA") wRegisterClassExA :: proc(windowClass : ^WndClassExA) -> Atom ---;
    @(link_name="RegisterClassExW") wRegisterClassExW :: proc(windowClass : ^WndClassExW) -> Atom ---;
    @(link_name="ReleaseDC")        wReleaseDc        :: proc(handle : HWnd, hdc : HDC) -> i32 ---;

    @(link_name="TranslateMessage") wTranslateMessage :: proc(message : ^Msg) -> Bool    ---;

}
