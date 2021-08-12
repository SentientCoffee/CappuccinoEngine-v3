package main;

import "core:fmt";
import "core:math";
import "core:mem";
import "core:runtime";
import "core:strings";

import "externals:winapi";
import "externals:xinput";
import "externals:directSound";

BitmapBuffer :: struct {
    info          : winapi.BitmapInfo,
    memory        : rawptr,
    width, height : int,
    pitch         : int,
    bytesPerPixel : i8,
}

SoundOutput :: struct {
    samplesPerSecond, bytesPerSample : uint,
    bufferSize : u32,

    frequency  : f32,
    volume     : f32,
    wavePeriod : f32,

    runningSampleIndex : uint,
    isPlaying          : bool,
}

g_backbuffer  : BitmapBuffer = { bytesPerPixel = 4 };
g_isRunning   := false;
g_soundBuffer : ^directSound.Buffer;

main :: proc() {
    delegateMainWindowProc :: proc "std" (
        window : winapi.HWnd, message : winapi.WindowMessage,
        wParam : winapi.WParam, lParam : winapi.LParam,
    ) -> winapi.LResult {
        context = runtime.default_context();
        return mainWindowProc(window, message, wParam, lParam);
    }

    using winapi;
    currentInstance := getModuleHandle();
    if success := comInitialize(); success != 0 {
        dumpLastError("ComInitialize");
        return;
    }

    xinput.load();
    resizeDibSection(&g_backbuffer, 1280, 720);

    windowClass : WndClassA = {
        style      = ClassStyleSet{ .HRedraw, .VRedraw, .OwnDC },  // @Note(Daniel): Equivalent to (ClassStyle.HRedraw | ClassStyle.VRedraw | ClassStyle.OwnDC)
        windowProc = delegateMainWindowProc,
        instance   = currentInstance,
        className  = "Win32WindowClass",
    };

    if atomHandle := registerClass(&windowClass); atomHandle == 0 {
        debugStr := fmt.tprintf("RegisterClass");
        dumpLastError(debugStr);
        return;
    }

    useDefault := cast(i32) CreateWindow.UseDefault;
    window := createWindow(
        windowClass.className, "CappuccinoEngine-v3",
        OverlappedWindowStyle | { .Visible },        // @Note(Daniel): Equivalent to (WindowStyle.OverlappedWindow | WindowStyle.Visible)
        useDefault, useDefault, useDefault, useDefault,
        nil, nil, currentInstance, nil,
    );

    if window == nil {
        dumpLastError("CreateWindow");
        return;
    }

    deviceContext := getDc(window);

    sps, bps : uint = 48_000, size_of(i16) * 2;  // 48,000 samples/s, 2-channel 16-bit audio
    f : f32 = 261.625565;  // @Note(Daniel): Middle C frequency is 261.625565 Hz

    sound : SoundOutput = {
        samplesPerSecond   = sps,
        bytesPerSample     = bps,
        bufferSize         = cast(u32) (sps * bps),
        frequency          = f,
        volume             = 1000.0,
        wavePeriod         = cast(f32) sps / f,
        runningSampleIndex = 0,
        isPlaying          = false,
    };

    g_soundBuffer = directSoundLoad(window, sound.samplesPerSecond, sound.bufferSize);
    fillSoundBuffer(&sound, 0, sound.bufferSize);
    directSound.playBuffer(buffer = g_soundBuffer, flags = directSound.BufferPlaySet{ .Looping });
    sound.isPlaying = true;

    xOffset, yOffset : int;
    g_isRunning = true;
    for g_isRunning {
        if err := mem.free_all(context.temp_allocator); err != .None {
            consoleError("Temp allocator free all", "err == {}", err);
        }

        message : Msg = ---;
        for peekMessage(&message, nil, 0, 0, cast(u32) PeekMessage.Remove) {
            if message.message == .Quit do g_isRunning = false;
            translateMessage(&message);
            dispatchMessage(&message);
        }

        for controllerIndex in 0 ..< xinput.UserMaxCount {
            using xinput;

            using controllerState : xinput.State = ---;
            if success := xinput.getState(cast(u32) controllerIndex, &controllerState); success != .Success {
                continue;
            }

            xOffset -= cast(int) gamepad.thumbstickRX >> 10;
            yOffset += cast(int) gamepad.thumbstickRY >> 10;
        }

        renderWeirdGradient(&g_backbuffer, xOffset, yOffset);

        posSuccess, playCursor, /* writeCursor */_ := directSound.getCurrentBufferPosition(g_soundBuffer);
        if posSuccess != .Ok {
            consoleError("DirectSound", "getCurrentBufferPosition (success == {})", posSuccess);
        }
        else {
            byteToLock := (cast(u32) (sound.runningSampleIndex * sound.bytesPerSample)) % sound.bufferSize;
            bytesToWrite : u32 =
                byteToLock >= playCursor ? sound.bufferSize - byteToLock + playCursor : playCursor - byteToLock;
            fillSoundBuffer(&sound, byteToLock, bytesToWrite);
        }

        width, height := getWindowDimensions(window);
        copyBufferToWindow(&g_backbuffer, deviceContext, width, height);
    }

}

mainWindowProc :: proc(window : winapi.HWnd, message : winapi.WindowMessage, wParam : winapi.WParam, lParam : winapi.LParam) -> (result : winapi.LResult) {
    using winapi;
    result = 0;

    #partial switch message {
        case .Close:
            g_isRunning = false;
            consolePrint("WindowMessage", "{}", message);

        case .Destroy:
            g_isRunning = false;
            consolePrint("WindowMessage", "{}", message);

        case .ActivateApp:
            consolePrint("WindowMessage", "{}", message);

        case .Size:
            width, height := getWindowDimensions(window);
            consolePrint("WindowMessage", "{} ({}, {})", message, width, height);

        case .Paint:
            paint : PaintStruct = ---;
            paintDc := beginPaint(window, &paint);
            {
                width, height := getWindowDimensions(window);
                copyBufferToWindow(&g_backbuffer, paintDc, width, height);
            }
            endPaint(window, &paint);

        case .SysKeyDown: fallthrough;
        case .SysKeyUp:   fallthrough;
        case .KeyDown:    fallthrough;
        case .KeyUp:
            vkCode := cast(VirtualKey) wParam;
            keyIsDown, keyWasDown := (lParam & (1 << 31)) == 0, (lParam & (1 << 30)) != 0;
            altIsDown := (lParam & (1 << 29)) != 0;

            if keyWasDown != keyIsDown {
                #partial switch vkCode {
                    case .W:
                        fallthrough;
                    case .A:
                        fallthrough;
                    case .S:
                        fallthrough;
                    case .D:
                        fallthrough;
                    case .Q:
                        fallthrough;
                    case .E:
                        fallthrough;
                    case .Up:
                        fallthrough;
                    case .Left:
                        fallthrough;
                    case .Down:
                        fallthrough;
                    case .Right:
                        fallthrough;
                    case .Escape:
                        fallthrough;
                    case .Space:
                        if keyIsDown  do consolePrint("VkCode", "{}, keyDown", vkCode);
                        if keyWasDown do consolePrint("VkCode", "{}, keyUp", vkCode);
                    case .F4:
                        if altIsDown && keyIsDown do g_isRunning = false;
                }
            }

        case:
            result = defWindowProc(window, message, wParam, lParam);
    }

    return;
}

directSoundLoad :: proc(window : winapi.HWnd, samplesPerSecond : uint, bufferSize : u32) -> (buffer : ^directSound.Buffer) {
    using directSound;
    buffer = nil;
    dsObj := create();

    if success := setCooperativeLevel(dsObj, window, .Priority); success != .Ok {
        consoleError("DirectSound", "setCooperativeLevel (success == {})", success);
        return nil;
    }

    primaryBuffer : ^Buffer;
    pBufferDesc : BufferDescription = {
        size  = size_of(BufferDescription),
        flags = cast(u32) BufferCaps.PrimaryBuffer,
    };

    if success := createSoundBuffer(dsObj, &primaryBuffer, &pBufferDesc); success != .Ok {
        consoleError("DirectSound", "createSoundBuffer (primary) (success == {})", success);
        return nil;
    }

    consolePrint("DirectSound", "Primary buffer successfully created!");

    ch, bps : u16 = 2, 16; // 2-channel, 16-bit audio
    block := ch * bps / 8;
    waveFormat : WaveFormatEx = {
        formatTag         = cast(u16) WaveFormatTags.Pcm,
        channels          = ch,
        samplesPerSecond  = cast(u32) samplesPerSecond,
        avgBytesPerSecond = cast(u32) (cast(uint) block * samplesPerSecond),
        bitsPerSample     = bps,
        blockAlign        = block,
        size              = 0,
    };

    if success := setBufferFormat(primaryBuffer, &waveFormat); success != .Ok {
        consoleError("DirectSound", "setBufferFormat (primary) (success == {})", success);
        return nil;
    }

    consolePrint("DirectSound", "Primary buffer format set!");

    sBufferDesc : BufferDescription = {
        size        = size_of(BufferDescription),
        flags       = 0,
        bufferBytes = cast(u32) bufferSize,
        waveFormat  = &waveFormat,
    };

    if success := createSoundBuffer(dsObj, &buffer, &sBufferDesc); success != .Ok {
        consoleError("DirectSound", "createSoundBuffer (secondary) (success == {})", success);
        return nil;
    }

    consolePrint("DirectSound", "Secondary buffer successfully created!");
    return buffer;
}

fillSoundBuffer :: proc(using sound : ^SoundOutput, byteToLock, bytesToWrite : u32) {
    lockSuccess, region1, region1Size, region2, region2Size :=
        directSound.lockBuffer(g_soundBuffer, byteToLock, bytesToWrite);
    if lockSuccess != .Ok {
        consoleError("DirectSound", "lockBuffer (success == {})", lockSuccess);
        return;
    }

    sampleOut := mem.slice_ptr(cast(^i16) region1, cast(int) region1Size);
    sampleCount := region1Size / cast(u32) bytesPerSample;
    for i in 0 ..< sampleCount {
        index := i * 2;

        t := 2.0 * math.PI * (cast(f32) runningSampleIndex / cast(f32) wavePeriod);
        sineValue := math.sin(t);
        sampleValue := cast(i16) (sineValue * volume);

        sampleOut[index    ] = sampleValue;
        sampleOut[index + 1] = sampleValue;
        runningSampleIndex += 1;
    }

    sampleOut = mem.slice_ptr(cast(^i16) region2, cast(int) region2Size);
    sampleCount = region2Size / cast(u32) bytesPerSample;
    for i in 0 ..< sampleCount {
        index := i * 2;

        t := 2.0 * math.PI * (cast(f32) runningSampleIndex / wavePeriod);
        sineValue := math.sin(t);
        sampleValue := cast(i16) (sineValue * volume);

        sampleOut[index    ] = sampleValue;
        sampleOut[index + 1] = sampleValue;
        runningSampleIndex += 1;
    }

    directSound.unlockBuffer(g_soundBuffer, region1, region1Size, region2, region2Size);
}

renderWeirdGradient :: proc(using buffer : ^BitmapBuffer, blueOffset, greenOffset : int) {
    bitmap := mem.byte_slice(memory, width * height * cast(int) bytesPerPixel);
    for y in 0 ..< height {
        for x in 0 ..< width {
            index := y * pitch + (x * cast(int) bytesPerPixel);
            r, g, b, a : u8 = 0, cast(u8) (y + greenOffset), cast(u8) (x + blueOffset), 0;
            bitmap[index    ] = b;
            bitmap[index + 1] = g;
            bitmap[index + 2] = r;
            bitmap[index + 3] = a;
        }
    }
}

resizeDibSection :: proc(using buffer : ^BitmapBuffer, bitmapWidth, bitmapHeight: int) {
    using winapi;

    if memory != nil {
        virtualFree(memory, 0, MemoryFreeTypeSet{ .Release });
    }

    width, height = bitmapWidth, bitmapHeight;
    pitch = width * cast(int) bytesPerPixel;

    info.size = size_of(info.header);
    info.width, info.height = cast(i32) bitmapWidth, cast(i32) -bitmapHeight;
    info.planes = 1; info.bitCount = .Color32; info.compression = .Rgb;

    memorySize := width * height * cast(int) bytesPerPixel;
    memory = virtualAlloc(nil, cast(uint) memorySize, MemoryAllocTypeSet{ .Reserve, .Commit }, MemoryProtectionTypeSet{ .ReadWrite });
    if memory == nil do dumpLastError("VirtualAlloc");
}

copyBufferToWindow :: proc(buffer : ^BitmapBuffer, deviceContext : winapi.HDC, windowWidth, windowHeight : int) {
    using winapi;

    if success := stretchDiBits(
        deviceContext,
        0, 0, cast(i32) windowWidth, cast(i32) windowHeight,
        0, 0, cast(i32) buffer.width, cast(i32) buffer.height,
        buffer.memory, &buffer.info,
        .RgbColors, .SourceCopy,
    ); success == 0 do dumpLastError("StretchDIBits");
}

getWindowDimensions :: proc(window : winapi.HWnd) -> (width, height : int) {
    using winapi;
    using clientRect : Rect = ---;
    getClientRect(window, &clientRect);
    width, height = cast(int) (right - left), cast(int) (bottom - top);
    return;
}

// ----------------------------------------------------------------------------------------------

dumpLastError :: #force_inline proc(errString : string, args : ..any) {
    using winapi;
    str := fmt.tprintf(errString, ..args);
    err := getLastError();
    consolePrint("Windows", "{}\nLast error: {} (0x{:x})\n", str, err, cast(u32) err);
}

consolePrint :: #force_inline proc(ident : string, formatString : string, args : ..any) {
    str := fmt.tprintf("[{}]: {}\n", ident, formatString);
    fmt.printf(str, ..args);
    winapi.outputDebugString(debugCString(str, ..args));
}

consoleError :: #force_inline proc(ident : string, formatString : string, args : ..any) {
    str := fmt.tprintf("{} fail! {}\n", ident, formatString);
    fmt.printf(str, ..args);
    winapi.outputDebugString(debugCString(str, ..args));
}

debugCString :: #force_inline proc(formatString : string, args : ..any) -> cstring {
    debugStr  := fmt.tprintf(formatString, ..args);
    return strings.clone_to_cstring(debugStr, context.temp_allocator);
}
