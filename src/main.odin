package main;

import "core:fmt";
import "core:mem";
import "core:runtime";
import "core:strings";

import "externals:winapi";

BitmapBuffer :: struct {
    info          : winapi.BitmapInfo,
    memory        : rawptr,
    width, height : int,
    pitch         : int,
    bytesPerPixel : i8,
}

g_backbuffer : BitmapBuffer = { bytesPerPixel = 4 };
g_isRunning := false;

main :: proc() {
    delegateMainWindowProc :: proc "std" (window: winapi.HWnd, message: winapi.WindowMessage, wParam: winapi.WParam, lParam: winapi.LParam) -> winapi.LResult {
        context = runtime.default_context();
        return mainWindowProc(window, message, wParam, lParam);
    }

    using winapi;
    currentInstance := cast(HInstance) getModuleHandle();
    resizeDibSection(&g_backbuffer, 1280, 720);

    windowClass : WndClassA = {
        style      = cast(u32) (ClassStyles.HRedraw | ClassStyles.VRedraw | ClassStyles.OwnDC),
        windowProc = delegateMainWindowProc,
        instance   = currentInstance,
        className  = "Win32WindowClass",
    };

    if atomHandle := registerClass(&windowClass); atomHandle == 0 {
        debugStr := fmt.tprintf("RegisterClass: Atom 0x{:x}", atomHandle);
        dumpLastError(debugStr);
        return;
    }

    useDefault := cast(i32) CreateWindow.UseDefault;
    window := createWindow(
        windowClass.className, "CappuccinoEngine-v3",
        cast(u32) (WindowStyle.OverlappedWindow | WindowStyle.Visible),
        useDefault, useDefault, useDefault, useDefault,
        nil, nil, currentInstance, nil,
    );

    if window == nil {
        dumpLastError("CreateWindow");
        return;
    }

    deviceContext := getDc(window);
    xOffset, yOffset : int;

    g_isRunning = true;
    for g_isRunning {
        if err := mem.free_all(context.temp_allocator); err != .None {
            fmt.printf("Error freeing temp allocator: {}", err);
        }

        message : Msg = ---;
        for peekMessage(&message, nil, 0, 0, cast(u32) PeekMessage.Remove) {
            if message.message == WindowMessage.Quit do g_isRunning = false;
            translateMessage(&message);
            dispatchMessage(&message);
        }



        width, height := getWindowDimensions(window);
        renderWeirdGradient(g_backbuffer, xOffset, yOffset);
        copyBufferToWindow(deviceContext, &g_backbuffer, width, height);

        xOffset += 1; yOffset += 2;
    }
}

mainWindowProc :: proc(window: winapi.HWnd, message: winapi.WindowMessage, wParam: winapi.WParam, lParam: winapi.LParam) -> (result : winapi.LResult) {
    using winapi;
    result = 0;

    #partial switch message {
        case .Close:
            g_isRunning = false;
            fmt.printf("{}\n", message);
            outputDebugString(debugCString("{}\n", message));
        case .Destroy:
            g_isRunning = false;
            fmt.printf("{}\n", message);
            outputDebugString(debugCString("{}\n", message));
        case .ActivateApp:
            fmt.printf("{}\n", message);
            outputDebugString(debugCString("{}\n", message));
        case .Size:
            width, height := getWindowDimensions(window);
            fmt.printf("{} ({}, {})\n", message, width, height);
            outputDebugString(debugCString("{} ({}, {})\n", message, width, height));
        case .Paint:
            paint : PaintStruct = ---;
            paintDc := beginPaint(window, &paint);
            {
                width, height := getWindowDimensions(window);
                copyBufferToWindow(paintDc, &g_backbuffer, width, height);
            }
            endPaint(window, &paint);
        case:
            result = defWindowProc(window, message, wParam, lParam);
    }

    return;
}

renderWeirdGradient :: proc(using buffer : BitmapBuffer, blueOffset, greenOffset : int) {
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
        virtualFree(memory, 0, cast(u32) MemoryFreeType.Release);
    }

    width, height = bitmapWidth, bitmapHeight;
    pitch = width * cast(int) bytesPerPixel;

    info.size = size_of(info.header);
    info.width, info.height = cast(i32) bitmapWidth, cast(i32) -bitmapHeight;
    info.planes = 1; info.bitCount = .Color32; info.compression = .Rgb;

    memorySize := width * height * cast(int) bytesPerPixel;

    memory = virtualAlloc(nil, cast(uint) memorySize, cast(u32) MemoryAllocType.Commit, cast(u32) MemoryProtection.ReadWrite);
    if memory == nil do dumpLastError("VirtualAlloc");
}

copyBufferToWindow :: proc(deviceContext : winapi.HDC, buffer : ^BitmapBuffer, windowWidth, windowHeight : int) {
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

debugCString :: #force_inline proc(formatString : string, arguments : ..any) -> cstring {
    debugStr  := fmt.tprintf(formatString, ..arguments);
    return strings.clone_to_cstring(debugStr, context.temp_allocator);
}

dumpLastError :: #force_inline proc(error : string) {
    using winapi;
    fmt.printf("Windows fail! {} \n", error);
    fmt.printf("Last error: 0x{:x}\n", getLastError());
}