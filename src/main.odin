package main;

import "core:fmt";
import "core:os";
import "core:runtime"
import "core:strings";
import "externals:winapi";

isRunning := false;

bitmapInfo : winapi.BitmapInfo = {};
bitmapMemory : rawptr;
bitmapHandle : winapi.HBitmap;
bitmapDeviceContext : winapi.HDC;

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
        fmt.printf("Last error: %", cast(u32) getLastError());
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
        fmt.printf("Last error: %", cast(u32) getLastError());
        return;
    }

    isRunning = true;
    message : Msg = ---;
    for isRunning {
        success := getMessage(&message, nil, 0, 0);
        if !success {
            fmt.println(message);
            fmt.println(getLastError());
            break;
        }

        translateMessage(&message);
        dispatchMessage(&message);
    }
}

mainWindowProc :: proc "std" (window: winapi.HWnd, message: u32, wParam: winapi.WParam, lParam: winapi.LParam) -> (winapi.LResult) {
    using winapi;

    context = runtime.default_context();
    result : LResult = 0;
    msg := WindowMessage(message);

    #partial switch msg {
        case .Destroy:
            isRunning = false;
            fmt.println("WM_DESTROY");
            outputDebugString("WM_DESTROY\n");
        case .Size:
            clientRect : Rect;
            getClientRect(window, &clientRect);
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
                updateMainWindow(paintDeviceContext, x, y, width, height);
                patBlt(paintDeviceContext, x, y, width, height, .Whiteness);
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

    return result;
}

resizeDIBSection :: proc(width, height: i32) {
    using winapi;

    if bitmapHandle != nil {
        deleteObject(bitmapHandle);
    }
    if bitmapDeviceContext == nil {
        bitmapDeviceContext = createCompatibleDC();
    }

    bitmapInfo.size = size_of(bitmapInfo.header);
    bitmapInfo.width = width; bitmapInfo.height = height;
    bitmapInfo.planes = 1; bitmapInfo.bitCount = .Color32; bitmapInfo.compression = .Rgb;

    bitmapHandle = createDIBSection(bitmapDeviceContext, &bitmapInfo, .RgbColors, &bitmapMemory, nil, 0);
}

updateMainWindow :: proc(deviceContext : winapi.HDC, x, y, width, height : i32) {
    using winapi;
    stretchDIBits(deviceContext, x, y, width, height, x, y, width, height, bitmapMemory, &bitmapInfo, .RgbColors, .SourceCopy);
}
