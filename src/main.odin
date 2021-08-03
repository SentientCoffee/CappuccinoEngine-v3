package main;

import "core:fmt";
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

g_backbuffer : BitmapBuffer = { bytesPerPixel = 4 };
g_isRunning  := false;

main :: proc() {
    delegateMainWindowProc :: proc "std" (window : winapi.HWnd, message : winapi.WindowMessage, wParam : winapi.WParam, lParam : winapi.LParam) -> winapi.LResult {
        context = runtime.default_context();
        return mainWindowProc(window, message, wParam, lParam);
    }

    using winapi;
    currentInstance := getModuleHandle();
    if success := comInitialize(nil); success != 0 {
        dumpLastError("ComInitialize");
        return;
    }

    xinput.load();
    resizeDibSection(&g_backbuffer, 1280, 720);

    windowClass : WndClassA = {
        style      = ClassStyleSet{ .HRedraw, .VRedraw, .OwnDC },  // @Note: Equivalent to (ClassStyle.HRedraw | ClassStyle.VRedraw | ClassStyle.OwnDC)
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
        OverlappedWindowStyle | { .Visible },        // @Note: Equivalent to (WindowStyle.OverlappedWindow | WindowStyle.Visible)
        useDefault, useDefault, useDefault, useDefault,
        nil, nil, currentInstance, nil,
    );

    if window == nil {
        dumpLastError("CreateWindow");
        return;
    }

    directSound.load(window, 48_000, 48_000 * size_of(i16) * 2);
    deviceContext := getDc(window);
    xOffset, yOffset : int;

    g_isRunning = true;
    for g_isRunning {
        if err := mem.free_all(context.temp_allocator); err != .None {
            consolePrint("Error freeing temp allocator: {}", err);
        }

        message : Msg = ---;
        for peekMessage(&message, nil, 0, 0, cast(u32) PeekMessage.Remove) {
            if message.message == WindowMessage.Quit do g_isRunning = false;
            translateMessage(&message);
            dispatchMessage(&message);
        }

        for controllerIndex in 0..<xinput.UserMaxCount {
            using controllerState : xinput.State = ---;
            if success := xinput.getState(cast(u32) controllerIndex, &controllerState); success != .Success {
                continue;
            }

            using xinput;

            xOffset -= cast(int) gamepad.thumbstickRX >> 10;
            yOffset += cast(int) gamepad.thumbstickRY >> 10;
        }

        width, height := getWindowDimensions(window);
        renderWeirdGradient(&g_backbuffer, xOffset, yOffset);
        copyBufferToWindow(&g_backbuffer, deviceContext, width, height);
    }
}

mainWindowProc :: proc(window : winapi.HWnd, message : winapi.WindowMessage, wParam : winapi.WParam, lParam : winapi.LParam) -> (result : winapi.LResult) {
    using winapi;
    result = 0;

    #partial switch message {
        case .Close:
            g_isRunning = false;
            consolePrint("Window message: {}\n", message);

        case .Destroy:
            g_isRunning = false;
            consolePrint("Window message: {}\n", message);

        case .ActivateApp:
            consolePrint("Window message: {}\n", message);

        case .Size:
            width, height := getWindowDimensions(window);
            consolePrint("Window message: {} ({}, {})\n", message, width, height);

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
                        if keyIsDown  do consolePrint("VkCode: {}, keyDown\n", vkCode);
                        if keyWasDown do consolePrint("VkCode: {}, keyUp\n", vkCode);
                    case .F4:
                        if altIsDown && keyIsDown do g_isRunning = false;
                }
            }

        case:
            result = defWindowProc(window, message, wParam, lParam);
    }

    return;
}

renderWeirdGradient :: proc(using buffer : ^BitmapBuffer, blueOffset, greenOffset : int) {
    bitmap := mem.byte_slice(memory, width * height * cast(int) bytesPerPixel);
    for y in 0..<height {
        for x in 0..<width {
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
    memory = virtualAlloc(nil, cast(uint) memorySize, MemoryAllocTypeSet{ .Commit }, MemoryProtectionTypeSet{ .ReadWrite });
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
    consoleError("Windows fail! {} \n", str);
    consoleError("Last error: {} (0x{:x})\n", err, cast(u32) err);
}

consolePrint :: #force_inline proc(formatString : string, args : ..any) {
    fmt.printf(formatString, ..args);
    winapi.outputDebugString(debugCString(formatString, ..args));
}

consoleError :: #force_inline proc(formatString : string, args : ..any) {
    fmt.eprintf(formatString, ..args);
    winapi.outputDebugString(debugCString(formatString, ..args));
}

debugCString :: #force_inline proc(formatString : string, args : ..any) -> cstring {
    debugStr  := fmt.tprintf(formatString, ..args);
    return strings.clone_to_cstring(debugStr, context.temp_allocator);
}
