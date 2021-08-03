package directSound;

import "externals:winapi";
import "core:fmt";

// -----------------------------------------------------------------------------------
// Types
// -----------------------------------------------------------------------------------

CreateProc :: #type proc "std" (device : ^winapi.Guid, dsObject : ^^DirectSound, unknownOuter : ^winapi.Unknown) -> winapi.HResult;

// -----------------------------------------------------------------------------------
// Constants
// -----------------------------------------------------------------------------------

@(private) DSoundDLL :: "dsound.dll";

// -----------------------------------------------------------------------------------
// Enums
// -----------------------------------------------------------------------------------

CooperativeLevel :: enum u32 {
    Normal       = 1,
    Priority     = 2,
    Exclusive    = 3,
    WritePrimary = 4,
}

// -----------------------------------------------------------------------------------

BufferCaps :: enum u32 {
    PrimaryBuffer         = 0x0000_0001,  // 1 << 0
    Static                = 0x0000_0002,  // 1 << 1
    LocalHardware         = 0x0000_0004,  // 1 << 2
    LocalSoftware         = 0x0000_0008,  // 1 << 3
    Control3d             = 0x0000_0010,  // 1 << 4
    ControlFrequency      = 0x0000_0020,  // 1 << 5
    ControlPan            = 0x0000_0040,  // 1 << 6
    ControlVolume         = 0x0000_0080,  // 1 << 7
    ControlPositionNotify = 0x0000_0100,  // 1 << 8
    ControlFx             = 0x0000_0200,  // 1 << 9
    StickyFocus           = 0x0000_0400,  // 1 << 10
    GlobalFocus           = 0x0000_0800,  // 1 << 11
    GetCurrentPosition2   = 0x0000_1000,  // 1 << 12
    Mute3dAtMaxDistance   = 0x0000_2000,  // 1 << 13
    LocationDefer         = 0x0000_4000,  // 1 << 14
    TruePlayPosition      = 0x0000_8000,  // 1 << 15
}

// -----------------------------------------------------------------------------------

WaveFormatTags :: enum u16 {
    Unknown = 0,
    Pcm = 1,
}

// -----------------------------------------------------------------------------------
// Structs
// -----------------------------------------------------------------------------------

Buffer :: struct {
    using bvtbl : ^BufferVtbl,
}

BufferVtbl :: struct {
    using uvtbl        : winapi.UnknownVtbl,
    getCaps            : #type proc "std" (
                            this : ^Buffer,
                            caps : ^BufferCapabilities,
                        ) -> winapi.HResult,

    getCurrentPosition : #type proc "std" (
                            this : ^Buffer,
                            currentPlayCursor, currentWriteCursor : ^winapi.DWord,
                        ) -> winapi.HResult,

    getFormat          : #type proc "std" (
                            this : ^Buffer,
                            format : ^WaveFormatEx,
                            sizeAllocated : winapi.DWord,
                            sizeWritten : ^winapi.DWord,
                        ) -> winapi.HResult,

    getVolume          : #type proc "std" (this : ^Buffer, volume    : ^i32)          -> winapi.HResult,
    getPan             : #type proc "std" (this : ^Buffer, pan       : ^i32)          -> winapi.HResult,
    getFrequency       : #type proc "std" (this : ^Buffer, frequency : ^winapi.DWord) -> winapi.HResult,
    getStatus          : #type proc "std" (this : ^Buffer, status    : ^winapi.DWord) -> winapi.HResult,

    initialize         : #type proc "std" (
                            this : ^Buffer,
                            dsObj : ^DirectSound,
                            description : ^BufferDescription,
                        ) -> winapi.HResult,

    lock               : #type proc "std" (
                            this : ^Buffer,
                            offset, bytes : winapi.DWord,
                            audioPtr1 : ^rawptr, audioBytes1 : ^winapi.DWord,
                            audioPtr2 : ^rawptr, audioBytes2 : ^winapi.DWord,
                            flags : winapi.DWord,
                        ) -> winapi.HResult,

    play               : #type proc "std" (
                            this : ^Buffer,
                            reserved1 : winapi.DWord,
                            priority, flags : winapi.DWord,
                        ) -> winapi.HResult,

    setCurrentPosition : #type proc "std" (this : ^Buffer, position  : winapi.DWord)  -> winapi.HResult,
    setFormat          : #type proc "std" (this : ^Buffer, format    : ^WaveFormatEx) -> winapi.HResult,
    setVolume          : #type proc "std" (this : ^Buffer, volume    : i32)           -> winapi.HResult,
    setPan             : #type proc "std" (this : ^Buffer, pan       : i32)           -> winapi.HResult,
    setFrequency       : #type proc "std" (this : ^Buffer, frequency : winapi.DWord)  -> winapi.HResult,

    stop               : #type proc "std" (buffer : ^Buffer) -> winapi.HResult,

    unlock             : #type proc "std" (
                            this : ^Buffer,
                            audioPtr1 : rawptr, audioBytes1 : winapi.DWord,
                            audioPtr2 : rawptr, audioBytes2 : winapi.DWord,
                        ) -> winapi.HResult,

    restore            : #type proc "std" (buffer : ^Buffer) -> winapi.HResult,
}

BufferCapabilities :: struct {
    size, flags        : winapi.DWord,
    bufferBytes        : winapi.DWord,
    unlockTransferRate : winapi.DWord,
    playCpuOverhead    : winapi.DWord,
}

BufferDescription :: struct {
    size, flags : winapi.DWord,
    bufferBytes : winapi.DWord,
    reserved    : winapi.DWord,
    waveFormat  : ^WaveFormatEx,
    algorithm3d : winapi.Guid,
}

// -----------------------------------------------------------------------------------

DirectSound :: struct {
    using dsvtbl: ^DirectSoundVtbl,
}

DirectSoundVtbl :: struct {
    using uvtbl : winapi.UnknownVtbl,
    createSoundBuffer : #type proc "std" (
                            this         : ^DirectSound,
                            description  : ^BufferDescription,
                            buffer       : ^^Buffer,
                            unknownOuter : ^winapi.Unknown,
                        ) -> winapi.HResult,

    getCaps : #type proc "std" (this : ^DirectSound, caps : ^DirectSoundCapabilities) -> winapi.HResult,

    duplicateSoundBuffer : #type proc "std" (
                               this : ^DirectSound,
                               bufferOriginal : ^Buffer,
                               bufferDuplicate : ^^Buffer,
                           ) -> winapi.HResult,

    setCooperativeLevel  : #type proc "std" (this : ^DirectSound, window : winapi.HWnd, level : winapi.DWord) -> winapi.HResult,
    compact              : #type proc "std" (this : ^DirectSound)                                             -> winapi.HResult,
    getSpeakerConfig     : #type proc "std" (this : ^DirectSound, speakerConfig : ^winapi.DWord)              -> winapi.HResult,
    setSpeakerConfig     : #type proc "std" (this : ^DirectSound, speakerConfig : winapi.DWord)               -> winapi.HResult,
    initialize           : #type proc "std" (this : ^DirectSound, device : ^winapi.Guid)                      -> winapi.HResult,
}

DirectSoundCapabilities :: struct {
    size, flags,
    minSecondarySampleRate, maxSecondarySampleRate, primaryBuffers,
    maxHwMixingAllBuffers,  maxHWMixingStaticBuffers,  maxHwMixingStreamingBuffers,
    freeHwMixingAllBuffers, freeHWMixingStaticBuffers, freeHwMixingStreamingBuffers,
    maxHw3dAllBuffers,      maxHW3dStaticBuffers,      maxHw3dStreamingBuffers,
    freeHw3dAllBuffers,     freeHW3dStaticBuffers,     freeHw3dStreamingBuffers,
    totalHwMemoryBytes, freeHwMemoryBytes, maxContiguousFreeHwMemoryBytes,
    unlockTransferRateHwBuffers, playCpuOverheadHwBuffers,
    reserved1, reserved2 : winapi.DWord,
}

// -----------------------------------------------------------------------------------

WaveFormat :: struct {
    formatTag, channels                 : winapi.Word,
    samplesPerSecond, avgBytesPerSecond : winapi.DWord,
    blockAlign                          : winapi.Word,
}

WaveFormatEx :: struct {
    formatTag, channels                 : winapi.Word,
    samplesPerSecond, avgBytesPerSecond : winapi.DWord,
    blockAlign                          : winapi.Word,
    bitsPerSample, size                 : winapi.Word,
}

// -----------------------------------------------------------------------------------
// Procedures
// -----------------------------------------------------------------------------------

load :: proc(window : winapi.HWnd, bufferSize : uint, samplesPerSecond : uint) {
    using winapi;
    
    create : CreateProc = nil;
    dsoundLib : HModule = ---;
    if dsoundLib = loadLibrary(DSoundDLL); dsoundLib == nil {
        // @Todo: Log error here
        return;
    }

    if create = cast(CreateProc) getProcAddress(dsoundLib, "DirectSoundCreate"); create == nil {
        // @Todo: Log error here
        return;
    }

    dsObj : ^DirectSound = ---;
    if success := create(nil, &dsObj, nil); success < 0 {
        fmt.printf("DirectSound: Error {}\n", success);
        return;
    }

    if success := setCooperativeLevel(dsObj, window, .Priority); success < 0 {
        fmt.printf("DirectSound: Error {}\n", success);
        return;
    }
    
    primaryBuffer : ^Buffer = ---;
    pBufferDesc : BufferDescription = {
        size  = size_of(BufferDescription),
        flags = cast(u32) BufferCaps.PrimaryBuffer,
    };

    if success := createSoundBuffer(dsObj, &primaryBuffer, &pBufferDesc); success < 0 {
        fmt.eprintf("DirectSound: Error {}\n", success);
        return;
    }
    
    ch, bps : u16 = 2, 16; // 2-channel, 16-bit audio
    block := ch * bps / 8;
    waveFormat : WaveFormatEx = {
        formatTag         = cast(u16) WaveFormatTags.Pcm,
        channels          = ch,
        samplesPerSecond  = cast(u32) samplesPerSecond,
        avgBytesPerSecond = cast(u32) (block * cast(u16) samplesPerSecond),
        bitsPerSample     = bps,
        blockAlign        = block,
        size              = 0,
    };
    
    if success := setBufferFormat(primaryBuffer, &waveFormat); success < 0 {
        fmt.eprintf("DirectSound: Error {}\n", success);
        return;
    }

    s : cstring = "DirectSound: Primary buffer format set!\n";
    fmt.printf(cast(string) s);
    outputDebugStringA(s);

    secondaryBuffer : ^Buffer = ---;
    sBufferDesc : BufferDescription = {
        size        = size_of(BufferDescription),
        flags       = 0,
        bufferBytes = cast(u32) bufferSize,
        waveFormat  = &waveFormat,
    };
    if success := createSoundBuffer(dsObj, &secondaryBuffer, &sBufferDesc); success < 0 {
        fmt.eprintf("DirectSound: Error {}\n", success);
        return;
    }

    s = "DirectSound: Secondary buffer successfully created!\n";
    fmt.printf(cast(string) s);
    outputDebugStringA(s);
}

setBufferFormat :: #force_inline proc(buffer : ^Buffer, format : ^WaveFormatEx) -> winapi.HResult {
    return buffer->setFormat(format);
}

setCooperativeLevel :: #force_inline proc(dsObj : ^DirectSound, window : winapi.HWnd, level : CooperativeLevel) -> winapi.HResult {
    return dsObj->setCooperativeLevel(window, cast(u32) level);
}

createSoundBuffer :: #force_inline proc(dsObj : ^DirectSound, buffer : ^^Buffer, description : ^BufferDescription) -> winapi.HResult {
    return dsObj->createSoundBuffer(description, buffer, nil);
}