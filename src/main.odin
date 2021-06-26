package main;

import "core:fmt";
import "core:mem";
import "core:os";
import "core:sys/win32";
import "core:runtime"
import "core:strings";

import "externals:winapi";

isRunning := false;

bitmapInfo : winapi.BitmapInfo = {};
bitmapMemory : rawptr = nil;
bitmapWidth, bitmapHeight : i32 = 0, 0;

main :: proc() {
    using winapi;

    currentInstance := cast(HInstance) getModuleHandle();
    fmt.printf("Instance: %v\n", currentInstance);

    windowClass : WndClassA = {
        style      = u32(ClassStyles.OwnDC | ClassStyles.HRedraw | ClassStyles.VRedraw),
        windowProc = mainWindowProc,
        instance   = currentInstance,
        className  = "Win32WindowClass",
    };

    atomHandle := registerClassA(&windowClass);
    if atomHandle == 0 {
        fmt.println("RegisterClass Fail!");
        fmt.printf("Atom handle: 0x%04x\n", atomHandle);
        fmt.printf("Last error: %v\n", getLastError());
        return;
    }

    useDefault := cast(i32) CreateWindow.UseDefault;
    windowHandle := createWindow(
        windowClass.className, "Test window",
        u32(WindowStyle.OverlappedWindow | WindowStyle.Visible),
        useDefault, useDefault, useDefault, useDefault,
        nil, nil, currentInstance, nil,
    );

    if windowHandle == nil {
        fmt.println("CreateWindow Fail!", windowClass);
        fmt.printf("Last error: %v\n", getLastError());
        return;
    }

    isRunning = true;
    message : Msg = ---;
    for isRunning {
        success := getMessage(&message, nil, 0, 0);
        if !success {
            fmt.println(message);
            fmt.printf("Last error: %v\n", getLastError());
            break;
        }

        translateMessage(&message);
        dispatchMessage(&message);
    }
}

mainWindowProc :: proc "std" (window: winapi.HWnd, message: u32, wParam: winapi.WParam, lParam: winapi.LParam) -> (result : winapi.LResult) {
    using winapi;
    context = runtime.default_context();
    result = 0;

    msg := WindowMessage(message);
    clientRect : Rect;
    getClientRect(window, &clientRect);

    #partial switch msg {
        case .Destroy:
            isRunning = false;
            fmt.println("WM_DESTROY");
            outputDebugString("WM_DESTROY\n");
        case .Size:
            width  := clientRect.right  - clientRect.left;
            height := clientRect.bottom - clientRect.top;
            resizeDIBSection(width, height);

            builder := strings.make_builder();
            strings.write_string(&builder, "WM_SIZE (");
            strings.write_i64(&builder, i64(width));
            strings.write_string(&builder, ", ");
            strings.write_i64(&builder, i64(height));
            strings.write_string(&builder, ")\n");
            cstr : cstring = strings.clone_to_cstring(strings.to_string(builder));

            fmt.printf("WM_SIZE (%d, %d)\n", width, height);
            outputDebugString(cstr);
        case .Paint:
            paint : PaintStruct = ---;
            paintDeviceContext := beginPaint(window, &paint);
            {
                x := paint.paintRect.left;
                y := paint.paintRect.top;
                width  := paint.paintRect.right  - paint.paintRect.left;
                height := paint.paintRect.bottom - paint.paintRect.top;
                updateMainWindow(paintDeviceContext, clientRect, x, y, width, height);
            }
            endPaint(window, &paint);
        case .Close:
            isRunning = false;
            fmt.println("WM_CLOSE");
            outputDebugString("WM_CLOSE\n");
        case .ActivateApp:
            fmt.println("WM_ACTIVATEAPP");
            outputDebugString("WM_ACTIVATEAPP\n");
        case:
            result = defWindowProcA(window, message, wParam, lParam);
    }

    return;
}

resizeDIBSection :: proc(width, height: i32) {
    using winapi;

    if bitmapMemory != nil {
        virtualFree(bitmapMemory, 0, u32(FreeType.Release));
    }

    bitmapWidth, bitmapHeight = width, height;

    bitmapInfo.size = size_of(bitmapInfo.header);
    bitmapInfo.width = bitmapWidth; bitmapInfo.height = -bitmapHeight;
    bitmapInfo.planes = 1; bitmapInfo.bitCount = .Color32; bitmapInfo.compression = .Rgb;

    bytesPerPixel : i32 = 4;
    bitmapMemorySize := uint(bitmapWidth * bitmapHeight * bytesPerPixel);

    bitmapMemory := virtualAlloc(nil, bitmapMemorySize, u32(AllocationType.Commit), u32(MemoryProtection.ReadWrite));
    if bitmapMemory == nil {
        fmt.println("VirtualAlloc Fail!");
        fmt.printf("Last error: %v\n", getLastError());
    }

    bitmap := mem.byte_slice(bitmapMemory, cast(int) bitmapMemorySize);
    for y in 0..<bitmapHeight {
        for x in 0..< bitmapWidth {
            pixel := y * bitmapWidth + x;
            r, g, b, a : u8 = 255, 0, 0, 0;
            bitmap[pixel    ] = b;
            bitmap[pixel + 1] = g;
            bitmap[pixel + 2] = r;
            bitmap[pixel + 3] = a;
        }
    }

    // assert(bitmap != nil);
    // assert(bitmapMemory != nil);
}

updateMainWindow :: proc(deviceContext : winapi.HDC, windowRect : winapi.Rect, x, y, width, height : i32) {
    using winapi;
    using windowRect;

    windowWidth  := right - left;
    windowHeight := bottom - top;

    // assert(bitmapMemory != nil, "Bitmap memory is nil!");
    success := stretchDIBits(
        deviceContext,
        0, 0, bitmapWidth, bitmapHeight,
        0, 0, windowWidth, windowHeight,
        bitmapMemory, &bitmapInfo,
        .RgbColors, .SourceCopy,
    );

    if success == 0 {
        fmt.printf("StretchDIBits fail!\n");
        fmt.printf("Last error: %v\n", getLastError());
    }
}
