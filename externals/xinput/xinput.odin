package xinput;

import "externals:winapi";

// -----------------------------------------------------------------------------------
// Types
// -----------------------------------------------------------------------------------

GetStateProc :: #type proc "std" (winapi.DWord, ^State) -> winapi.Error;
SetStateProc :: #type proc "std" (winapi.DWord, ^Vibration) -> winapi.Error;

// -----------------------------------------------------------------------------------
// Constants
// -----------------------------------------------------------------------------------

UserMaxCount :: 4;

@(private) XInput1_4 :: "xinput1_4.dll";
@(private) XInput1_3 :: "xinput1_3.dll";

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
    DPadUp    = 0,  // 1 << 0
    DPadDown  = 1,  // 1 << 1
    DPadLeft  = 2,  // 1 << 2
    DPadRight = 3,  // 1 << 3
    Start     = 4,  // 1 << 4
    Back      = 5,  // 1 << 5
    ThumbL    = 6,  // 1 << 6
    ThumbR    = 7,  // 1 << 7
    ShoulderL = 8,  // 1 << 8
    ShoulderR = 9,  // 1 << 9
    A         = 12,  // 1 << 12
    B         = 13,  // 1 << 13
    X         = 14,  // 1 << 14
    Y         = 15,  // 1 << 15
}

ButtonSet :: bit_set[ButtonFlags; u16];

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
    if xinputLib = loadLibrary(XInput1_4); xinputLib == nil {
        if xinputLib = loadLibrary(XInput1_3); xinputLib == nil do return;
    }

    getState = cast(GetStateProc) getProcAddress(xinputLib, "XInputGetState");
    setState = cast(SetStateProc) getProcAddress(xinputLib, "XInputSetState");
}

gamepadButtonPressed :: #force_inline proc(using gamepad : Gamepad, button : Button) -> bool do return (buttons & cast(u16) button) > 0;

@(private) getStateStub :: proc "std" (userIndex : winapi.DWord, state : ^State)         -> winapi.Error do return .DeviceNotConnected;
@(private) setStateStub :: proc "std" (userIndex : winapi.DWord, vibration : ^Vibration) -> winapi.Error do return .DeviceNotConnected;