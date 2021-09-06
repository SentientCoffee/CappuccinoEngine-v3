package xinput;

import "core:fmt";
import "core:strings";
import "externals:winapi";

// -----------------------------------------------------------------------------------
// Types
// -----------------------------------------------------------------------------------

GetStateProc :: #type proc "std" (winapi.DWord, ^State) -> winapi.Error;
SetStateProc :: #type proc "std" (winapi.DWord, ^Vibration) -> winapi.Error;

// -----------------------------------------------------------------------------------
// Constants
// -----------------------------------------------------------------------------------

UserMaxCount            :: 4;
GamepadThumbLDeadzone   :: 7849;
GamepadThumbRDeadzone   :: 8689;
GamepadTriggerThreshold :: 30;

@(private) XInput1_4   :: "xinput1_4.dll";
@(private) XInput1_3   :: "xinput1_3.dll";
@(private) XInput9_1_0 :: "xinput9_1_0.dll";

// -----------------------------------------------------------------------------------
// Enums
// -----------------------------------------------------------------------------------

Button :: enum u16 {
    DPadUp    = 0x0001,  // 1 << 0
    DPadDown  = 0x0002,  // 1 << 1
    DPadLeft  = 0x0004,  // 1 << 2
    DPadRight = 0x0008,  // 1 << 3
    Start     = 0x0010,  // 1 << 4
    Back      = 0x0020,  // 1 << 5
    ThumbL    = 0x0040,  // 1 << 6
    ThumbR    = 0x0080,  // 1 << 7
    ShoulderL = 0x0100,  // 1 << 8
    ShoulderR = 0x0200,  // 1 << 9
    A         = 0x1000,  // 1 << 12
    B         = 0x2000,  // 1 << 13
    X         = 0x4000,  // 1 << 14
    Y         = 0x8000,  // 1 << 15
}

ButtonFlags :: enum u16 {
    DPadUp,
    DPadDown,
    DPadLeft,
    DPadRight,
    Start,
    Back,
    ThumbL,
    ThumbR,
    ShoulderL,
    ShoulderR,
    A,
    B,
    X,
    Y,
}

ButtonSet :: bit_set[ButtonFlags; u16];

ButtonSet_to_u16 :: proc(set : ButtonSet) -> (ret : u16) {
    set := set;
    @static flagToBit := [ButtonFlags]u16{
        .DPadUp    = cast(u16) (Button.DPadUp),
        .DPadDown  = cast(u16) (Button.DPadDown),
        .DPadLeft  = cast(u16) (Button.DPadLeft),
        .DPadRight = cast(u16) (Button.DPadRight),
        .Start     = cast(u16) (Button.Start),
        .Back      = cast(u16) (Button.Back),
        .ThumbL    = cast(u16) (Button.ThumbL),
        .ThumbR    = cast(u16) (Button.ThumbR),
        .ShoulderL = cast(u16) (Button.ShoulderL),
        .ShoulderR = cast(u16) (Button.ShoulderR),
        .A         = cast(u16) (Button.A),
        .B         = cast(u16) (Button.B),
        .X         = cast(u16) (Button.X),
        .Y         = cast(u16) (Button.Y),
    };

    ret = winapi.bitset_to_integral(set, flagToBit);
    return ret;
}

// -----------------------------------------------------------------------------------
// Structs
// -----------------------------------------------------------------------------------

Gamepad :: struct {
    buttons : winapi.Word,
    triggerL    , triggerR     : u8,
    thumbstickLX, thumbstickLY : i16,
    thumbstickRX, thumbstickRY : i16,
}

State :: struct {
    packetNumber : winapi.DWord,
    gamepad      : Gamepad,
}

Vibration :: struct {
    motorSpeedL, motorSpeedR : winapi.Word,
}

// -----------------------------------------------------------------------------------
// Procedures
// -----------------------------------------------------------------------------------

getState := getStateStub;
setState := setStateStub;

load :: proc() {
    using winapi;
    xinputLib : HModule = ---;
    xinputVersion : string = XInput1_4;

    if xinputLib = loadLibrary(XInput1_4); xinputLib == nil {
        if xinputLib = loadLibrary(XInput9_1_0); xinputLib == nil {
            if xinputLib = loadLibrary(XInput1_3); xinputLib == nil {
                xinputError("loadLibrary (xinputLib == {})", xinputLib);
                return;
            }
            else {
                xinputVersion = XInput1_3;
            }
        }
        else {
            xinputVersion = XInput9_1_0;
        }
    }

    xinputLog("Loaded {}", xinputVersion);

    if getState = cast(GetStateProc) getProcAddress(xinputLib, "XInputGetState"); getState == nil {
        xinputError("getProcAddress (getState == {})", getState);
        getState = getStateStub;
    }
    if setState = cast(SetStateProc) getProcAddress(xinputLib, "XInputSetState"); setState == nil {
        xinputError("getProcAddress (getState == {})", setState);
        setState = setStateStub;
    }
}

gamepadButtonPressed :: #force_inline proc(using gamepad : Gamepad, button : Button) -> bool {
    return (buttons & cast(u16) button) > 0;
}

// -----------------------------------------------------------------------------------

@(private) getStateStub : GetStateProc : proc "std" (userIndex : winapi.DWord, state : ^State)         -> winapi.Error do return .DeviceNotConnected;
@(private) setStateStub : SetStateProc : proc "std" (userIndex : winapi.DWord, vibration : ^Vibration) -> winapi.Error do return .DeviceNotConnected;

// @Todo(Daniel): Change these to context.logger

@(private)
xinputLog :: #force_inline proc(errString : string, args : ..any) {
    str := fmt.tprintf(errString, ..args);
    consolePrint("[XInput]: {}\n", str);
}

@(private)
xinputError :: #force_inline proc(errString : string, args : ..any) {
    str := fmt.tprintf(errString, ..args);
    consolePrint("[XInput] Error: {}\n", str);
}

@(private)
consolePrint :: #force_inline proc(formatString : string, args : ..any) {
    fmt.printf(formatString, ..args);
    winapi.outputDebugString(debugCString(formatString, ..args));

    debugCString :: #force_inline proc(formatString : string, args : ..any) -> cstring {
        debugStr  := fmt.tprintf(formatString, ..args);
        return strings.clone_to_cstring(debugStr, context.temp_allocator);
    }
}