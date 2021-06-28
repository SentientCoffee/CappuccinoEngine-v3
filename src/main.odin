package main;

import "core:fmt";
import "core:mem";
import "core:runtime";
import "core:strings";

import "externals:winapi";

isRunning := false;

bitmapInfo : winapi.BitmapInfo = {};
bitmapMemory : rawptr;

bitmapWidth, bitmapHeight : i32 = 0, 0;
bytesPerPixel : i32 : 4;

main :: proc() {
    using winapi;
    currentInstance := cast(HInstance) getModuleHandle();
    fmt.printf("Instance: 0x{:x}\n", currentInstance);

    windowClass : WndClassA = {
        style      = cast(u32) (ClassStyles.OwnDC | ClassStyles.HRedraw | ClassStyles.VRedraw),
        windowProc = mainWindowProc,
        instance   = currentInstance,
        className  = "Win32WindowClass",
    };

    if atomHandle := registerClassA(&windowClass); atomHandle == 0 {
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

    isRunning = true;
    message : Msg = ---;
    xOffset, yOffset : i32;
    for isRunning {
        if err := mem.free_all(context.temp_allocator); err != .None {
            fmt.printf("Error freeing temp allocator: {}", err);
        }

        for peekMessage(&message, nil, 0, 0, cast(u32) WindowPeekMessage.Remove) {
            if message.message == WindowMessage.Quit do isRunning = false;
            translateMessage(&message);
            dispatchMessage(&message);
        }

        renderWeirdGradient(xOffset, yOffset);
        {
            deviceContext := getDc(window);
            using clientRect : Rect = ---;
            getClientRect(window, &clientRect);
            width  := right  - left;
            height := bottom - top;
            updateMainWindow(deviceContext, clientRect, 0, 0, width, height);
            releaseDc(window, deviceContext);
        }
        xOffset += 1;
    }
}

mainWindowProc :: proc "std" (window: winapi.HWnd, message: winapi.WindowMessage, wParam: winapi.WParam, lParam: winapi.LParam) -> (result : winapi.LResult) {
    using winapi;
    context = runtime.default_context();

    result = 0;
    clientRect : Rect = ---;
    getClientRect(window, &clientRect);

    #partial switch message {
        case .Destroy:
            isRunning = false;
            fmt.printf("{}\n", message);
            outputDebugString(debugCString("{}\n", message));
        case .Size:
            using clientRect;
            width  := right  - left;
            height := bottom - top;
            resizeDibSection(width, height);

            fmt.printf("{} ({}, {})\n", message, width, height);
            outputDebugString(debugCString("{} ({}, {})\n", message, width, height));
        case .Paint:
            using paint : PaintStruct = ---;
            paintDeviceContext := beginPaint(window, &paint);
            {
                using paintRect;
                x := left;
                y := top;
                width  := right  - left;
                height := bottom - top;
                updateMainWindow(paintDeviceContext, clientRect, x, y, width, height);
            }
            endPaint(window, &paint);
        case .Close:
            isRunning = false;
            fmt.printf("{}\n", message);
            outputDebugString(debugCString("{}\n", message));
        case .ActivateApp:
            fmt.printf("{}\n", message);
            outputDebugString(debugCString("{}\n", message));
        case:
            result = defWindowProc(window, message, wParam, lParam);
    }

    return;
}

renderWeirdGradient :: proc(xOffset, yOffset : i32) {
    bitmap := mem.byte_slice(bitmapMemory, cast(int) (bitmapWidth * bitmapHeight * bytesPerPixel));
    pitch := bitmapWidth * bytesPerPixel;
    for y in 0..<bitmapHeight {
        for x in 0..<bitmapWidth {
            index := y * pitch + (x * bytesPerPixel);
            r, g, b, a : u8 = 0, cast(u8) (y + yOffset), cast(u8) (x + xOffset), 0;
            bitmap[index    ] = b;
            bitmap[index + 1] = g;
            bitmap[index + 2] = r;
            bitmap[index + 3] = a;
        }
    }
}

resizeDibSection :: proc(width, height: i32) {
    using winapi;

    if bitmapMemory != nil {
        virtualFree(bitmapMemory, 0, cast(u32) MemoryFreeType.Release);
    }

    bitmapWidth, bitmapHeight = width, height;

    bitmapInfo.size = size_of(bitmapInfo.header);
    bitmapInfo.width = bitmapWidth; bitmapInfo.height = -bitmapHeight;
    bitmapInfo.planes = 1; bitmapInfo.bitCount = .Color32; bitmapInfo.compression = .Rgb;

    bitmapMemorySize := cast(int) (bitmapWidth * bitmapHeight * bytesPerPixel);

    bitmapMemory = virtualAlloc(nil, cast(uint) bitmapMemorySize, cast(u32) MemoryAllocType.Commit, cast(u32) MemoryProtection.ReadWrite);
    if bitmapMemory == nil do dumpLastError("VirtualAlloc");
}

updateMainWindow :: proc(deviceContext : winapi.HDC, windowRect : winapi.Rect, x, y, width, height : i32) {
    using winapi;
    using windowRect;

    windowWidth  := right - left;
    windowHeight := bottom - top;

    success := stretchDiBits(
        deviceContext,
        0, 0, bitmapWidth, bitmapHeight,
        0, 0, windowWidth, windowHeight,
        bitmapMemory, &bitmapInfo,
        .RgbColors, .SourceCopy,
    );

    if success == 0 do dumpLastError("StretchDIBits");
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