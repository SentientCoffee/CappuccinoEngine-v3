package soundtest;

import "core:mem";
import "core:math";
import "core:runtime";

import "externals:directsound";
import "externals:winapi";

import "src";

g_isRunning := false;
g_soundBuffer : ^directsound.Buffer;
g_context : runtime.Context;

win32_SoundOutput :: struct {
    samplesPerSecond, bytesPerSample : uint,
    bufferSize : u32,

    frequency, volume : f32,
    wavePeriod        : f32,
    tSine             : f32,

    latencySampleCount : uint,
    runningSampleIndex : uint,
    isValid            : bool,
}

SoundBuffer :: struct {
    sampleOut        : []i16,
    sampleCount      : uint,
    samplesPerSecond : uint,
    volume           : f32,
}

main :: proc() {
    using winapi;

    context = setupContext();
    currentInstance := getModuleHandle();

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
        src.dumpLastError("RegisterClass");
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
        src.dumpLastError("CreateWindow");
        return;
    }

    // deviceContext := getDc(window);

    sps, bps : uint = 48_000, size_of(i16) * 2;  // 48,000 samples/s, 2-channel 16-bit audio (4 bytes per sample)
    f : f32 = 261.63;  // @Note(Daniel): Middle C frequency is 261.625565 Hz

    for _ in 0 ..< 2 {
        sound : win32_SoundOutput = {
            samplesPerSecond   = sps,
            bytesPerSample     = bps,
            bufferSize         = cast(u32) (sps * bps * 4),
            frequency          = f,
            volume             = 3000.0,
            tSine              = 0.0,
            wavePeriod         = cast(f32) sps / f,
            latencySampleCount = sps / 15,
            runningSampleIndex = 0,
            isValid            = false,
        };

        g_soundBuffer = directSoundLoad(window, sound.samplesPerSecond, sound.bufferSize);
        clearSoundBuffer(&sound);
        directsound.playBuffer(g_soundBuffer, 0, directsound.BufferPlay.Looping);

        g_isRunning = true;

        for g_isRunning {
            if err := mem.free_all(context.temp_allocator); err != .None {
                src.logError("Temp_allocator", "free_all err == {}", err);
            }

            messageLoop : for {
                success, msg := peekMessage(nil, 0, 0, PeekMessage.Remove);
                if !success do break messageLoop;

                translateMessage(&msg);
                dispatchMessage(&msg);
            }

            lockOffset, targetCursor, lockSize : u32;
            if posSuccess, playCursor, writeCursor := directsound.getCurrentBufferPosition(g_soundBuffer); posSuccess != .Ok {
                src.logError("DirectSound", "getCurrentBufferPosition (success == {})", posSuccess);
            }
            else {
                using sound;
                src.logTrace("Buffer Pos", "Play cursor = {}, Write cursor = {}", playCursor, writeCursor);

                lockOffset   = (cast(u32) (runningSampleIndex * bytesPerSample)) % bufferSize;
                targetCursor = (playCursor + cast(u32) (latencySampleCount * bytesPerSample)) % bufferSize;

                if lockOffset > targetCursor {
                    lockSize = bufferSize - lockOffset + targetCursor;
                }
                else {
                    lockSize = targetCursor - lockOffset;
                }
                isValid = true;
            }

            if sound.isValid do fillSoundBuffer_(&sound, lockOffset, lockSize);
            else do src.logError("Sound", "Invalid sound!");

            // soundOut : [48_000 * 2]i16;
            // count := cast(uint) lockSize / sound.bytesPerSample;
            // s := SoundBuffer {
            //     samplesPerSecond = sound.samplesPerSecond,
            //     sampleCount = count,
            //     sampleOut = soundOut[:count * 2],
            //     volume = sound.volume,
            // };

            // if sound.isValid do fillSoundBuffer(&sound, &s, lockOffset, lockSize);
        }
    }
}

setupContext :: proc() -> runtime.Context {
    using src;
    context.logger = createConsoleLogger(lowestLevel = Debug);
    g_context = context;
    return g_context;
}

mainWindowProc :: proc(window : winapi.HWnd, message : winapi.WindowMessage, wParam : winapi.WParam, lParam : winapi.LParam) -> (result : winapi.LResult) {
    if message == .Quit || message == .Close {
        g_isRunning = false;
        return auto_cast 0;
    }

    return winapi.defWindowProc(window, message, wParam, lParam);
}

directSoundLoad :: proc(window : winapi.HWnd, samplesPerSecond : uint, bufferSize : u32) -> (buffer : ^directsound.Buffer) {
    using directsound;
    buffer = nil; success : Error;

    dsObj : ^directsound.DirectSound;
    if success, dsObj = create(); success != .Ok {
        src.logError("DirectSound", "create (success == {})", success);
        return;
    }

    if success = setCooperativeLevel(dsObj, window, .Priority); success != .Ok {
        src.logError("DirectSound", "setCooperativeLevel (success == {})", success);
        return;
    }

    pBufferDesc : BufferDescription = {
        size  = size_of(BufferDescription),
        flags = cast(u32) BufferCaps.PrimaryBuffer,
    };

    primaryBuffer : ^Buffer;
    if success, primaryBuffer = createSoundBuffer(dsObj, pBufferDesc); success != .Ok {
        src.logError("DirectSound", "createSoundBuffer (primary) (success == {})", success);
        return;
    }

    src.logInfo("DirectSound", "Primary buffer successfully created!");

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
        src.logError("DirectSound", "setBufferFormat (primary) (success == {})", success);
        return;
    }

    src.logInfo("DirectSound", "Primary buffer format set!");

    sBufferDesc : BufferDescription = {
        size        = size_of(BufferDescription),
        flags       = 0,
        bufferBytes = cast(u32) bufferSize,
        waveFormat  = &waveFormat,
    };

    if success, buffer = createSoundBuffer(dsObj, sBufferDesc); success != .Ok {
        src.logError("DirectSound", "createSoundBuffer (secondary) (success == {})", success);
        return;
    }

    src.logInfo("DirectSound", "Secondary buffer successfully created!");
    return buffer;
}

// fillSoundBuffer :: proc(using dest : ^win32_SoundOutput, source : ^SoundBuffer, lockOffset, lockSize : u32) {
//     lockSuccess, region1, region1Size, region2, region2Size := directsound.lockBuffer(g_soundBuffer, lockOffset, lockSize);
//     if lockSuccess != .Ok {
//         src.logError("DirectSound", "lockBuffer (success == {})", lockSuccess);
//         return;
//     }

//     sourceIndex := 0;
//     destOut := mem.slice_ptr(cast(^i16) region1, cast(int) region1Size);
//     sampleCount := region1Size / cast(u32) bytesPerSample;

//     // src.logInfo("Sound", "source: {}", source.sampleOut);
//     // src.logInfo("Sound", "source size: {}", lockSize / cast(u32) bytesPerSample);

//     for i in 0 ..< sampleCount {
//         destIndex := i * 2;

//         destOut[destIndex    ] = source.sampleOut[sourceIndex    ];
//         destOut[destIndex + 1] = source.sampleOut[sourceIndex + 1];

//         runningSampleIndex += 1;
//         sourceIndex += 2;
//     }

//     // logDebug("Sound", "dest1 : {}", destOut);
//     // logDebug("Sound", "dest1 size: {}", sampleCount);

//     destOut = mem.slice_ptr(cast(^i16) region2, cast(int) region2Size);
//     sampleCount = region2Size / cast(u32) bytesPerSample;

//     for i in 0 ..< sampleCount {
//         destIndex := i * 2;

//         destOut[destIndex    ] = source.sampleOut[sourceIndex    ];
//         destOut[destIndex + 1] = source.sampleOut[sourceIndex + 1];

//         runningSampleIndex += 1;
//         sourceIndex += 2;
//     }

//     // logWarning("Sound", "dest2 : {}", destOut);
//     // logWarning("Sound", "dest2 size: {}", sampleCount);

//     directsound.unlockBuffer(g_soundBuffer, region1, region1Size, region2, region2Size);
// }

fillSoundBuffer_ :: proc(using sound : ^win32_SoundOutput, lockOffset, lockSize : u32) {
    lockSuccess, region1, region1Size, region2, region2Size := directsound.lockBuffer(g_soundBuffer, lockOffset, lockSize);
    if lockSuccess != .Ok {
        src.logError("DirectSound", "lockBuffer (success == {}, lockOffset == {}, lockSize == {})", lockSuccess, lockOffset, lockSize);
        return;
    }

    // sampleOut := mem.slice_ptr(cast(^i16) region1, cast(int) region1Size);
    // sampleCount := region1Size / cast(u32) bytesPerSample;
    // for i in 0 ..< sampleCount {
    //     index := i * 2;

    //     sineValue := math.sin(tSine);
    //     sampleValue := cast(i16) (sineValue * volume);

    //     sampleOut[index    ] = sampleValue;
    //     sampleOut[index + 1] = sampleValue;

    //     tSine += 2.0 * math.PI * (cast(f32) 1.0 / wavePeriod);
    //     runningSampleIndex += 1;
    // }

    // sampleOut = mem.slice_ptr(cast(^i16) region2, cast(int) region2Size);
    // sampleCount = region2Size / cast(u32) bytesPerSample;
    // for i in 0 ..< sampleCount {
    //     index := i * 2;

    //     sineValue := math.sin(tSine);
    //     sampleValue := cast(i16) (sineValue * volume);

    //     sampleOut[index    ] = sampleValue;
    //     sampleOut[index + 1] = sampleValue;

    //     tSine += 2.0 * math.PI * (cast(f32) 1.0 / wavePeriod);
    //     runningSampleIndex += 1;
    // }

    sampleOut   := cast(^i16) region1;
    sampleCount := region1Size / cast(u32) bytesPerSample;
    for _ in 0 ..< sampleCount {
        sineValue := math.sin(tSine);
        sampleValue := cast(i16) (sineValue * volume);

        if sineValue * volume >= 65535 do src.logDebug("Sound", "sample value exceeding bounds! {} ({})", sineValue * volume, sampleValue);

        sampleOut^ = sampleValue;
        sampleOut  = mem.ptr_offset(sampleOut, 1);
        sampleOut^ = sampleValue;
        sampleOut  = mem.ptr_offset(sampleOut, 1);

        tSine += 2.0 * math.PI * (cast(f32) 1.0 / wavePeriod);
        runningSampleIndex += 1;
    }

    sampleOut   = cast(^i16) region2;
    sampleCount = region2Size / cast(u32) bytesPerSample;
    for _ in 0 ..< sampleCount {
        sineValue := math.sin(tSine);
        sampleValue := cast(i16) (sineValue * volume);

        if sineValue * volume >= 65535 do src.logDebug("Sound", "sample value exceeding bounds! {} ({})", sineValue * volume, sampleValue);

        sampleOut^ = sampleValue;
        sampleOut  = mem.ptr_offset(sampleOut, 1);
        sampleOut^ = sampleValue;
        sampleOut  = mem.ptr_offset(sampleOut, 1);

        tSine += 2.0 * math.PI * (cast(f32) 1.0 / wavePeriod);
        runningSampleIndex += 1;
    }

    src.logTrace("Fill Sound Buffer", "{}", runningSampleIndex);

    directsound.unlockBuffer(g_soundBuffer, region1, region1Size, region2, region2Size);
}

clearSoundBuffer :: proc(using sound : ^win32_SoundOutput) {
    lockSuccess, region1, region1Size, region2, region2Size := directsound.lockBuffer(g_soundBuffer, 0, sound.bufferSize);
    if lockSuccess != .Ok {
        src.logError("DirectSound", "lockBuffer (success == {})", lockSuccess);
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
