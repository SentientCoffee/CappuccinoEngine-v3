package main;

import "core:runtime";
import "core:fmt";
import "core:os";
import "core:strings";
import winapi "externals:win32";

isRunning := true;

main :: proc() {
    using winapi;

    currentInstance := HInstance(getModuleHandle());
    fmt.printf("instance: %v\n", currentInstance);

    windowClass: WndClassA = {
        style      = u32(ClassStyles.OwnDC | ClassStyles.HRedraw | ClassStyles.VRedraw),
        windowProc = mainWindowProc,
        instance   = currentInstance,
        className  = "Win32WindowClass",
    };

    atomHandle := registerClassA(&windowClass);
    if(atomHandle == 0) {
        fmt.println("RegisterClass Fail!");
        fmt.printf("Atom handle: 0x%04x\n", atomHandle);
        fmt.println(getLastError());
        return;
    }

    windowHandle := createWindow(windowClass.className, "Test window",
        auto_cast(WindowStyle.OverlappedWindow | WindowStyle.Visible),
        cast(i32)CW.UseDefault, cast(i32)CW.UseDefault, cast(i32)CW.UseDefault, cast(i32)CW.UseDefault,
        nil, nil, currentInstance, nil,
    );

    if(windowHandle == nil) {
        fmt.println("CreateWindow Fail!", windowClass);
        fmt.println(getLastError());
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

resizeDIBSection :: proc(width, height: i32) {
    
}

mainWindowProc :: proc "std" (window: winapi.HWnd, message: u32, wParam: winapi.WParam, lParam: winapi.LParam) -> (winapi.LResult) {
    context = runtime.default_context();

    using winapi;
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
            strings.write_i64(&builder, i64(height));
            strings.write_string(&builder, ")\n");
            cstr : cstring = strings.clone_to_cstring(strings.to_string(builder));

            fmt.printf("WM_SIZE (%d, %d)\n", width, height);
            outputDebugString("WM_SIZE\n");
        case .Paint:
            paint : PaintStruct = ---;
            deviceContext := beginPaint(window, &paint);
            x := paint.paintRect.left;
            y := paint.paintRect.top;
            width  := paint.paintRect.right  - paint.paintRect.left;
            height := paint.paintRect.bottom - paint.paintRect.top;
            patBlt(deviceContext, x, y, width, height, .Whiteness);
            success := endPaint(window, &paint);
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