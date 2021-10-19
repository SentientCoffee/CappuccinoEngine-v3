package src;

import "core:intrinsics";
import "core:math";
import "core:mem";

import "externals:winapi";
import "externals:xinput";
import "externals:directsound";

win32_BitmapBuffer :: struct {
    info          : winapi.BitmapInfo,
    memory        : rawptr,
    width, height : int,
    pitch         : int,
    bytesPerPixel : i8,
}

win32_SoundOutput :: struct {
    samplesPerSecond, bytesPerSample : uint,
    bufferSize : u32,

    frequency, volume : f32,
    wavePeriod        : f32,
    
    latencySampleCount : uint,
    runningSampleIndex : uint,
    isPlaying, isValid : bool,
}

g_isRunning   := false;
g_backbuffer  := win32_BitmapBuffer{ bytesPerPixel = 4 };
g_soundBuffer : ^directsound.Buffer;

win32Main :: proc() {
    using winapi;

    currentInstance := getModuleHandle();
    if success := comInitialize(); success != 0 {
        dumpLastError("ComInitialize");
        return;
    }

    perfFrequency : i64;
    if success, result := queryPerfomanceFrequency(); !success {
        dumpLastError("QueryPerformanceFrequency");
        return;
    }
    else {
        perfFrequency = result.quadPart;
    }

    xinput.load();
    resizeDibSection(&g_backbuffer, 1280, 720);

    windowClass : WndClassA;
    {
        wp :: proc "std" (window : HWnd, message : WindowMessage, wParam : WParam, lParam : LParam) -> LResult {
            context = g_context;
            return mainWindowProc(window, message, wParam, lParam);
        }

        windowClass = {
            style      = .HRedraw | .VRedraw | .OwnDC,
            windowProc = wp,
            instance   = currentInstance,
            className  = "Win32WindowClass",
        };
    }

    if atomHandle := registerClass(&windowClass); atomHandle == 0 {
        dumpLastError("RegisterClass");
        return;
    }

    window : HWnd;
    {
        useDefault := cast(i32) CreateWindow.UseDefault;
        window = createWindow(
            windowClass.className, "CappuccinoEngine-v3",
            WindowStyle.OverlappedWindow | .Visible,
            useDefault, useDefault, useDefault, useDefault,
            nil, nil, currentInstance, nil,
        );
    }

    if window == nil {
        dumpLastError("CreateWindow");
        return;
    }

    deviceContext := getDc(window);

    sps, bps : uint = 48_000, size_of(i16) * 2;  // 48,000 samples/s, 2-channel 16-bit audio (4 bytes per sample)
    f : f32 = 261.63;  // @Note(Daniel): Middle C frequency is 261.625565 Hz

    sound : win32_SoundOutput = {
        samplesPerSecond   = sps,
        bytesPerSample     = bps,
        bufferSize         = cast(u32) (sps * bps * 4),
        frequency          = f,
        volume             = 3000.0,
        wavePeriod         = cast(f32) sps / f,
        latencySampleCount = sps / 15,
        runningSampleIndex = 0,
        isPlaying          = false,
        isValid            = false,
    };

    g_soundBuffer = directSoundLoad(window, sound.samplesPerSecond, sound.bufferSize);
    clearSoundBuffer(&sound);
    directsound.playBuffer(g_soundBuffer, 0, directsound.BufferPlay.Looping);
    sound.isPlaying = true;

    g_isRunning = true;
    xOffset, yOffset : int;
    _, lastCounter := queryPerfomanceCounter();
    lastCycleCount := intrinsics.read_cycle_counter();

    for g_isRunning {
        if err := mem.free_all(context.temp_allocator); err != .None {
            logError("Temp_allocator", "free_all err == {}", err);
        }

        messageLoop : for true {
            success, msg := peekMessage(nil, 0, 0, PeekMessage.Remove);
            if !success do break messageLoop;

            translateMessage(&msg);
            dispatchMessage(&msg);
        }

        for controllerIndex in 0 ..< xinput.UserMaxCount {
            using controllerState : xinput.State = ---;
            if success := xinput.getState(cast(u32) controllerIndex, &controllerState); success != .Success {
                continue;
            }

            xOffset -= cast(int) gamepad.thumbstickRX / 4096;
            yOffset += cast(int) gamepad.thumbstickRY / 4096;

            f = 512 + (400.0 * cast(f32) gamepad.thumbstickRY / 30_000.0);
            sound.frequency = f;
            sound.wavePeriod = cast(f32) sps / f;
        }

        byteToLock, targetCursor, bytesToWrite : u32;
        if posSuccess, playCursor, _/* writeCursor */ := directsound.getCurrentBufferPosition(g_soundBuffer); posSuccess != .Ok {
            logError("DirectSound", "getCurrentBufferPosition (success == {})", posSuccess);
        }
        else {
            using sound;
            byteToLock   = (cast(u32) (runningSampleIndex * bytesPerSample)) % bufferSize;
            targetCursor = (playCursor + cast(u32) (latencySampleCount * bytesPerSample)) % bufferSize;
            bytesToWrite = bufferSize - byteToLock + targetCursor if byteToLock >= targetCursor else targetCursor - byteToLock;
            isValid = true;
        }
        if sound.isValid do fillSoundBuffer_(&sound, byteToLock, bytesToWrite);

        soundOut : [48_000 * 2]i16;
        count := cast(uint) bytesToWrite / sound.bytesPerSample;
        s := SoundBuffer {
            samplesPerSecond = sound.samplesPerSecond,
            sampleCount = count,
            sampleOut = soundOut[:count * 2],
            volume = sound.volume,
        };

        b := GraphicsBuffer {
            memory = g_backbuffer.memory,
            width = g_backbuffer.width,
            height = g_backbuffer.height,
            pitch = g_backbuffer.pitch,
            bytesPerPixel = g_backbuffer.bytesPerPixel,
        };

        gameUpdateAndRender(&b, xOffset, yOffset, &s, sound.frequency);

        // if sound.isValid do fillSoundBuffer(&sound, &s, byteToLock, bytesToWrite);

        width, height := getWindowDimensions(window);
        copyBufferToWindow(&g_backbuffer, deviceContext, width, height);

        _, endCounter  := queryPerfomanceCounter();
        endCycleCount  := intrinsics.read_cycle_counter();

        counterElapsed := endCounter.quadPart - lastCounter.quadPart;
        cyclesElapsed  := endCycleCount - lastCycleCount;

        msPerFrame := (1000.0 * cast(f32) counterElapsed) / cast(f32) perfFrequency;
        mcPerFrame := cast(f32) cyclesElapsed / (1000_000.0);
        fps := cast(f32) perfFrequency / cast(f32) counterElapsed;

        logTrace("Timer", "{} ms/frame | {} fps | {} Mcpf", msPerFrame, fps, mcPerFrame);

        lastCounter = endCounter;
        lastCycleCount = endCycleCount;
    }
}

// -----------------------------------------------------------------------------------

mainWindowProc :: proc(window : winapi.HWnd, message : winapi.WindowMessage, wParam : winapi.WParam, lParam : winapi.LParam) -> (result : winapi.LResult) {
    using winapi;
    result = 0;

    #partial switch message {
        case .Close:
            g_isRunning = false;
            logDebug("WindowMessage", "{}", message);

        case .Destroy:
            g_isRunning = false;
            logDebug("WindowMessage", "{}", message);

        case .Quit:
            g_isRunning = false;
            logDebug("WindowMessage", "{}", message);

        case .ActivateApp:
            logDebug("WindowMessage", "{}", message);

        case .Size:
            width, height := getWindowDimensions(window);
            logDebug("WindowMessage", "{} ({}, {})", message, width, height);

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
                        if keyIsDown  do logDebug("VkCode", "{}, keyDown", vkCode);
                        if keyWasDown do logDebug("VkCode", "{}, keyUp", vkCode);
                    case .F4:
                        if altIsDown && keyIsDown do g_isRunning = false;
                }
            }

        case:
            result = defWindowProc(window, message, wParam, lParam);
    }

    return;
}

// -----------------------------------------------------------------------------------

resizeDibSection :: proc(using buffer : ^win32_BitmapBuffer, bitmapWidth, bitmapHeight: int) {
    using winapi;

    if memory != nil {
        virtualFree(memory, 0, MemoryFree.Release);
    }

    width, height = bitmapWidth, bitmapHeight;
    pitch = width * cast(int) bytesPerPixel;

    info.size = size_of(info.header);
    info.width, info.height = cast(i32) bitmapWidth, cast(i32) -bitmapHeight;
    info.planes = 1; info.bitCount = .Color32; info.compression = .Rgb;

    memorySize := width * height * cast(int) bytesPerPixel;
    allocType  := MemoryAlloc.Commit | .Reserve;
    protection := MemoryProtection.ReadWrite;
    memory = virtualAlloc(nil, cast(uint) memorySize, allocType, protection);

    if memory == nil do dumpLastError("VirtualAlloc");
}

copyBufferToWindow :: proc(buffer : ^win32_BitmapBuffer, deviceContext : winapi.HDC, windowWidth, windowHeight : int) {
    using winapi;

    if success := stretchDiBits(
        deviceContext,
        0, 0, cast(i32) windowWidth, cast(i32) windowHeight,
        0, 0, cast(i32) buffer.width, cast(i32) buffer.height,
        buffer.memory, &buffer.info,
        .RgbColors, .SourceCopy,
    ); success == 0 do logError("Windows", "StretchDiBits");
}

getWindowDimensions :: proc(window : winapi.HWnd) -> (width, height : int) {
    using winapi;
    using clientRect : Rect = ---;
    getClientRect(window, &clientRect);
    width, height = cast(int) (right - left), cast(int) (bottom - top);
    return;
}

// -----------------------------------------------------------------------------------

directSoundLoad :: proc(window : winapi.HWnd, samplesPerSecond : uint, bufferSize : u32) -> (buffer : ^directsound.Buffer) {
    using directsound;
    buffer = nil; success : Error;

    dsObj : ^directsound.DirectSound;
    if success, dsObj = create(); success != .Ok {
        logError("DirectSound", "create (success == {})", success);
        return;
    }

    if success = setCooperativeLevel(dsObj, window, .Priority); success != .Ok {
        logError("DirectSound", "setCooperativeLevel (success == {})", success);
        return;
    }

    pBufferDesc : BufferDescription = {
        size  = size_of(BufferDescription),
        flags = cast(u32) BufferCaps.PrimaryBuffer,
    };

    primaryBuffer : ^Buffer;
    if success, primaryBuffer = createSoundBuffer(dsObj, pBufferDesc); success != .Ok {
        logError("DirectSound", "createSoundBuffer (primary) (success == {})", success);
        return;
    }

    logInfo("DirectSound", "Primary buffer successfully created!");

    ch, bps : u16 = 2, 16; // 2-channel, 16-bit audio
    block := ch * bps / 8;
    waveFormat : WaveFormatEx = {
        formatTag         = .Pcm,
        channels          = ch,
        samplesPerSecond  = cast(u32) samplesPerSecond,
        avgBytesPerSecond = cast(u32) (cast(uint) block * samplesPerSecond),
        bitsPerSample     = bps,
        blockAlign        = block,
        size              = 0,
    };

    if success = setBufferFormat(primaryBuffer, &waveFormat); success != .Ok {
        logError("DirectSound", "setBufferFormat (primary) (success == {})", success);
        return;
    }

    logInfo("DirectSound", "Primary buffer format set!");

    sBufferDesc : BufferDescription = {
        size        = size_of(BufferDescription),
        flags       = 0,
        bufferBytes = cast(u32) bufferSize,
        waveFormat  = &waveFormat,
    };

    if success, buffer = createSoundBuffer(dsObj, sBufferDesc); success != .Ok {
        logError("DirectSound", "createSoundBuffer (secondary) (success == {})", success);
        return;
    }

    logInfo("DirectSound", "Secondary buffer successfully created!");
    return buffer;
}

fillSoundBuffer :: proc(using dest : ^win32_SoundOutput, source : ^SoundBuffer, byteToLock, bytesToWrite : u32) {
    lockSuccess, region1, region1Size, region2, region2Size := directsound.lockBuffer(g_soundBuffer, byteToLock, bytesToWrite);
    if lockSuccess != .Ok {
        logError("DirectSound", "lockBuffer (success == {})", lockSuccess);
        return;
    }

    sourceIndex := 0;
    destOut := mem.slice_ptr(cast(^i16) region1, cast(int) region1Size);
    sampleCount := region1Size / cast(u32) bytesPerSample;

    // logInfo("Sound", "source: {}", source.sampleOut);
    // logInfo("Sound", "source size: {}", bytesToWrite / cast(u32) bytesPerSample);

    for i in 0 ..< sampleCount {
        destIndex := i * 2;

        destOut[destIndex    ] = source.sampleOut[sourceIndex    ];
        destOut[destIndex + 1] = source.sampleOut[sourceIndex + 1];

        runningSampleIndex += 1;
        sourceIndex += 2;
    }

    // logDebug("Sound", "dest1 : {}", destOut);
    // logDebug("Sound", "dest1 size: {}", sampleCount);

    destOut = mem.slice_ptr(cast(^i16) region2, cast(int) region2Size);
    sampleCount = region2Size / cast(u32) bytesPerSample;

    for i in 0 ..< sampleCount {
        destIndex := i * 2;

        destOut[destIndex    ] = source.sampleOut[sourceIndex    ];
        destOut[destIndex + 1] = source.sampleOut[sourceIndex + 1];

        runningSampleIndex += 1;
        sourceIndex += 2;
    }

    // logWarning("Sound", "dest2 : {}", destOut);
    // logWarning("Sound", "dest2 size: {}", sampleCount);

    directsound.unlockBuffer(g_soundBuffer, region1, region1Size, region2, region2Size);
}

fillSoundBuffer_ :: proc(using sound : ^win32_SoundOutput, byteToLock, bytesToWrite : u32) {
    lockSuccess, region1, region1Size, region2, region2Size := directsound.lockBuffer(g_soundBuffer, byteToLock, bytesToWrite);
    if lockSuccess != .Ok {
        logError("DirectSound", "lockBuffer (success == {})", lockSuccess);
        return;
    }

    @static tSine : f32 = 0;

    sampleOut := mem.slice_ptr(cast(^i16) region1, cast(int) region1Size);
    sampleCount := region1Size / cast(u32) bytesPerSample;
    for i in 0 ..< sampleCount {
        index := i * 2;

        sineValue := math.sin(tSine);
        sampleValue := cast(i16) (sineValue * volume);

        sampleOut[index    ] = sampleValue;
        sampleOut[index + 1] = sampleValue;

        tSine += 2.0 * math.PI * (cast(f32) 1.0 / wavePeriod);
        runningSampleIndex += 1;
    }

    sampleOut = mem.slice_ptr(cast(^i16) region2, cast(int) region2Size);
    sampleCount = region2Size / cast(u32) bytesPerSample;
    for i in 0 ..< sampleCount {
        index := i * 2;

        sineValue := math.sin(tSine);
        sampleValue := cast(i16) (sineValue * volume);

        sampleOut[index    ] = sampleValue;
        sampleOut[index + 1] = sampleValue;

        tSine += 2.0 * math.PI * (cast(f32) 1.0 / wavePeriod);
        runningSampleIndex += 1;
    }

    directsound.unlockBuffer(g_soundBuffer, region1, region1Size, region2, region2Size);
}

clearSoundBuffer :: proc(using sound : ^win32_SoundOutput) {
    lockSuccess, region1, region1Size, region2, region2Size := directsound.lockBuffer(g_soundBuffer, 0, sound.bufferSize);
    if lockSuccess != .Ok {
        logError("DirectSound", "lockBuffer (success == {})", lockSuccess);
        return;
    }

    destOut := mem.byte_slice(region1, cast(int) region1Size);
    for i in 0 ..< region1Size {
        destOut[i] = 0;
    }

    destOut = mem.byte_slice(region2, cast(int) region2Size);
    for i in 0 ..< region2Size {
        destOut[i] = 0;
    }

    directsound.unlockBuffer(g_soundBuffer, region1, region1Size, region2, region2Size);
}