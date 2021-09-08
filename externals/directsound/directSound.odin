package directsound;

import "core:fmt";
import "core:log";

import "externals:winapi";

// -----------------------------------------------------------------------------------
// Types
// -----------------------------------------------------------------------------------

@(private) CreateProc :: #type proc "std" (device : ^winapi.Guid, dsObject : ^^DirectSound, unknownOuter : ^winapi.Unknown) -> winapi.HResult;

// -----------------------------------------------------------------------------------
// Constants
// -----------------------------------------------------------------------------------

@(private) DSoundDLL :: "dsound.dll";

// -----------------------------------------------------------------------------------
// Enums
// -----------------------------------------------------------------------------------

Error :: enum u32 {
    Ok                  = 0x0000_0000,
    OutOfMemory         = 0x0000_0007,
    NoVirtualization    = 0x0878_000A,
    Incomplete          = 0x0878_0014,
    NoInterface         = 0x0000_01AE,
    Unsupported         = 0x8000_4001,
    Generic             = 0x8000_4005,
    AccessDenied        = 0x8007_0005,
    InvalidParam        = 0x8007_0057,
    Allocated           = 0x8878_000A,
    ControlUnavailable  = 0x8878_001E,
    InvalidCall         = 0x8878_0032,
    PriorityLevelNeeded = 0x8878_0046,
    BadFormat           = 0x8878_0064,
    NoDriver            = 0x8878_0078,
    AlreadyInitialized  = 0x8878_0082,
    BufferLost          = 0x8878_0096,
    OtherAppHasPriority = 0x8878_00A0,
    Uninitialized       = 0x8878_00AA,
    BufferTooSmall      = 0x8878_10B4,
    Ds8Required         = 0x8878_10BE,
    SendLoop            = 0x8878_10C8,
    BadSendBufferGuid   = 0x8878_10D2,
    FxUnavailable       = 0x8878_10DC,
    ObjectNotFound      = 0x8878_1161,
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
    TruePlayPosition      = 0x0000_8000,  // 1 << 15 // @Note: Only needed in Windows Vista?
}

// BufferCapsFlags :: enum u32 {
//     PrimaryBuffer,
//     Static,
//     LocalHardware,
//     LocalSoftware,
//     Control3d,
//     ControlFrequency,
//     ControlPan,
//     ControlVolume,
//     ControlPositionNotify,
//     ControlFx,
//     StickyFocus,
//     GlobalFocus,
//     GetCurrentPosition2,
//     Mute3dAtMaxDistance,
//     LocationDefer,
//     TruePlayPosition,
// }

// BufferCapsSet :: bit_set[BufferCapsFlags; u32];

// @(private="file")
// BufferCapsSet_to_u32 :: #force_inline proc(set : BufferCapsSet) -> (ret : u32) {
//     set := set;
//     static flagToBit := [BufferCapsFlags]u32{
//         .PrimaryBuffer         = cast(u32) (BufferCaps.PrimaryBuffer),
//         .Static                = cast(u32) (BufferCaps.Static),
//         .LocalHardware         = cast(u32) (BufferCaps.LocalHardware),
//         .LocalSoftware         = cast(u32) (BufferCaps.LocalSoftware),
//         .Control3d             = cast(u32) (BufferCaps.Control3d),
//         .ControlFrequency      = cast(u32) (BufferCaps.ControlFrequency),
//         .ControlPan            = cast(u32) (BufferCaps.ControlPan),
//         .ControlVolume         = cast(u32) (BufferCaps.ControlVolume),
//         .ControlPositionNotify = cast(u32) (BufferCaps.ControlPositionNotify),
//         .ControlFx             = cast(u32) (BufferCaps.ControlFx),
//         .StickyFocus           = cast(u32) (BufferCaps.StickyFocus),
//         .GlobalFocus           = cast(u32) (BufferCaps.GlobalFocus),
//         .GetCurrentPosition2   = cast(u32) (BufferCaps.GetCurrentPosition2),
//         .Mute3dAtMaxDistance   = cast(u32) (BufferCaps.Mute3dAtMaxDistance),
//         .LocationDefer         = cast(u32) (BufferCaps.LocationDefer),
//         .TruePlayPosition      = cast(u32) (BufferCaps.TruePlayPosition),
//     };

//     ret = winapi.bitset_to_integral(set, flagToBit);
//     return ret;
// }

// -----------------------------------------------------------------------------------

BufferLock :: enum u32 {
    FromWriteCursor = 0x0000_0001,  // 1 << 0
    EntireBuffer    = 0x0000_0002,  // 1 << 1
}

// BufferLockFlags :: enum u32 {
//     FromWriteCursor,
//     EntireBuffer,
// }

// BufferLockSet :: bit_set[BufferLockFlags; u32];

// @(private="file")
// BufferLockSet_to_u32 :: #force_inline proc(set : BufferLockSet) -> (ret : u32) {
//     set := set;
//     static flagToBit := [BufferLockFlags]u32{
//         .FromWriteCursor = cast(u32) (BufferLock.FromWriteCursor),
//         .EntireBuffer    = cast(u32) (BufferLock.EntireBuffer),
//     };

//     ret = winapi.bitset_to_integral(set, flagToBit);
//     return ret;
// }

// -----------------------------------------------------------------------------------

BufferPlay :: enum u32 {
    Looping             = 0x0000_00001,  // 1 << 0
    LocalHardware       = 0x0000_00002,  // 1 << 1
    LocalSoftware       = 0x0000_00004,  // 1 << 2
    TerminateByTime     = 0x0000_00008,  // 1 << 3
    TerminateByDistance = 0x0000_00010,  // 1 << 4
    TerminateByPriority = 0x0000_00020,  // 1 << 5
}

// BufferPlayFlags :: enum u32 {
//     Looping,
//     LocalHardware,
//     LocalSoftware,
//     TerminateByTime,
//     TerminateByDistance,
//     TerminateByPriority,
// }

// BufferPlaySet :: bit_set[BufferPlayFlags; u32];

// @(private="file")
// BufferPlaySet_to_u32 :: #force_inline proc(set : BufferPlaySet) -> (ret : u32) {
//     set := set;
//     static flagToBit := [BufferPlayFlags]u32{
//         .Looping             = cast(u32) (BufferPlay.Looping),
//         .LocalHardware       = cast(u32) (BufferPlay.LocalHardware),
//         .LocalSoftware       = cast(u32) (BufferPlay.LocalSoftware),
//         .TerminateByTime     = cast(u32) (BufferPlay.TerminateByTime),
//         .TerminateByDistance = cast(u32) (BufferPlay.TerminateByDistance),
//         .TerminateByPriority = cast(u32) (BufferPlay.TerminateByPriority),
//     };

//     if set >= { .LocalSoftware, .LocalHardware } {
//         //
//         // @Todo(Daniel): Log warning about LocalSoftware/LocalHardware here
//         // @Reference: https://docs.microsoft.com/en-us/previous-versions/windows/desktop/ee418074(v=vs.85)
//         //

//         if .LocalHardware in set && set > (set & { .TerminateByTime, .TerminateByDistance, .TerminateByPriority }) {
//             set -= { .LocalSoftware };
//         }
//         else {
//             set -= { .LocalHardware, .TerminateByTime, .TerminateByDistance, .TerminateByPriority };
//         }
//     }

//     ret = winapi.bitset_to_integral(set, flagToBit);
//     return ret;
// }

// -----------------------------------------------------------------------------------

CooperativeLevel :: enum u32 {
    Normal       = 1,
    Priority     = 2,
    Exclusive    = 3,
    WritePrimary = 4,
}

// -----------------------------------------------------------------------------------

WaveFormatTag :: enum u16 {
    Unknown = 0,
    Pcm     = 1,
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
    size, flags, bufferBytes : winapi.DWord,
    unlockTransferRate       : winapi.DWord,
    playCpuOverhead          : winapi.DWord,
}

BufferDescription :: struct {
    size, flags           : winapi.DWord,
    bufferBytes, reserved : winapi.DWord,
    waveFormat            : ^WaveFormatEx,
    algorithm3d           : winapi.Guid,
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
    formatTag                           : WaveFormatTag,
    channels                            : winapi.Word,
    samplesPerSecond, avgBytesPerSecond : winapi.DWord,
    blockAlign                          : winapi.Word,
}

WaveFormatEx :: struct {
    formatTag                           : WaveFormatTag,
    channels                            : winapi.Word,
    samplesPerSecond, avgBytesPerSecond : winapi.DWord,
    blockAlign                          : winapi.Word,
    bitsPerSample, size                 : winapi.Word,
}

// -----------------------------------------------------------------------------------
// Overloads
// -----------------------------------------------------------------------------------

lockBuffer :: proc { /* lockBuffer_set, */ lockBuffer_enum, lockBuffer_u32 };
playBuffer :: proc { /* playBuffer_set, */ playBuffer_enum, playBuffer_u32 };

// -----------------------------------------------------------------------------------
// Procedures
// -----------------------------------------------------------------------------------

create :: proc() -> (err : Error, dsObj : ^DirectSound) {
    err, dsObj = .Uninitialized, nil;

    dsoundLib : winapi.HModule = ---;
    if dsoundLib = winapi.loadLibrary(DSoundDLL); dsoundLib == nil {
        dsoundError("loadLibrary (dsoundLib == {})", dsoundLib);
        return;
    }

    dsoundLog("Loaded {}", DSoundDLL);

    createProc : CreateProc = nil;
    if createProc = cast(CreateProc) winapi.getProcAddress(dsoundLib, "DirectSoundCreate"); createProc == nil {
        dsoundError("getProcAddress (createProc == {})", createProc);
        return;
    }

    if err = cast(Error) createProc(nil, &dsObj, nil); err != .Ok {
        dsoundError("directSoundCreate (success == {})", err);
        return;
    }

    return;
}

// DirectSound member procs
// -----------------------------------------------------------------------------------

setCooperativeLevel :: #force_inline proc(dsObj : ^DirectSound, window : winapi.HWnd, level : CooperativeLevel) -> Error {
    return cast(Error) dsObj->setCooperativeLevel(window, cast(u32) level);
}

createSoundBuffer :: proc(dsObj : ^DirectSound, description : BufferDescription) -> (err : Error, buffer : ^Buffer) {
    description := description;
    err = cast(Error) dsObj->createSoundBuffer(&description, &buffer, nil);
    return;
}

// Buffer member procs
// -----------------------------------------------------------------------------------

getCurrentBufferPosition :: #force_inline proc(buffer : ^Buffer) -> (
    err : Error,
    currentPlayCursor, currentWriteCursor : winapi.DWord,
) {
    currentPlayCursor, currentWriteCursor = 0, 0;
    e := buffer->getCurrentPosition(&currentPlayCursor, &currentWriteCursor);
    err = cast(Error) e;
    return;
}

// lockBuffer_set :: #force_inline proc(
//     buffer : ^Buffer,
//     writePointer, bytesToWrite : winapi.DWord,
//     flags : BufferLockSet,
// ) -> (
//     err : Error,
//     audioRegion1 : rawptr, region1Size : winapi.DWord,
//     audioRegion2 : rawptr, region2Size : winapi.DWord,
// ) {
//     return lockBuffer_u32(buffer, writePointer, bytesToWrite, BufferLockSet_to_u32(flags));
// }
lockBuffer_enum :: #force_inline proc(
    buffer : ^Buffer,
    writePointer, bytesToWrite : winapi.DWord,
    flags : BufferLock,
) -> (
    err : Error,
    audioRegion1 : rawptr, region1Size : winapi.DWord,
    audioRegion2 : rawptr, region2Size : winapi.DWord,
) {
    return lockBuffer_u32(buffer, writePointer, bytesToWrite, cast(u32) flags);
}
lockBuffer_u32 :: proc(
    buffer : ^Buffer,
    writePointer, bytesToWrite : winapi.DWord,
    flags : winapi.DWord = 0,
) -> (
    err : Error,
    audioRegion1 : rawptr, region1Size : winapi.DWord,
    audioRegion2 : rawptr, region2Size : winapi.DWord,
) {
    audioRegion1, audioRegion2 = nil, nil;
    region1Size,  region2Size  = 0, 0;
    err = .Uninitialized;

    if(buffer == nil) do return;

    e := buffer->lock(
        writePointer, bytesToWrite,
        &audioRegion1, &region1Size,
        &audioRegion2, &region2Size,
        flags,
    );

    err = cast(Error) e;
    return;
}

// playBuffer_set :: #force_inline proc(buffer : ^Buffer, priority : winapi.DWord = 0, flags : BufferPlaySet) -> Error {
//     return cast(Error) buffer->play(0, priority, BufferPlaySet_to_u32(flags));
// }
playBuffer_enum :: #force_inline proc(buffer : ^Buffer, priority : winapi.DWord = 0, flags : BufferPlay) -> Error {
    return cast(Error) buffer->play(0, priority, cast(u32) flags);
}
playBuffer_u32 :: #force_inline proc(buffer : ^Buffer, priority : winapi.DWord = 0, flags : u32 = 0) -> Error {
    return cast(Error) buffer->play(0, priority, flags);
}

setBufferFormat :: #force_inline proc(buffer : ^Buffer, format : ^WaveFormatEx) -> Error {
    return cast(Error) buffer->setFormat(format);
}

unlockBuffer :: #force_inline proc(
    buffer : ^Buffer,
    audioRegion1 : rawptr, region1Size : winapi.DWord,
    audioRegion2 : rawptr, region2Size : winapi.DWord,
) -> Error {
    return cast(Error) buffer->unlock(audioRegion1, region1Size, audioRegion2, region2Size);
}

// -----------------------------------------------------------------------------------

// @Todo(Daniel): Change these to context.logger

@(private)
dsoundLog :: #force_inline proc(fmtString : string, args : ..any) {
    str := fmt.tprintf(fmtString, ..args);
    log.infof("[DirectSound]: {}\n", str);
}

@(private)
dsoundError :: #force_inline proc(fmtString : string, args : ..any) {
    str := fmt.tprintf(fmtString, ..args);
    log.errorf("[DirectSound] Error: {}\n", str);
}

// @(private)
// consolePrint :: #force_inline proc(formatString : string, args : ..any) {
//     fmt.printf(formatString, ..args);
//     winapi.outputDebugString(debugCString(formatString, ..args));

//     debugCString :: #force_inline proc(formatString : string, args : ..any) -> cstring {
//         debugStr  := fmt.tprintf(formatString, ..args);
//         return strings.clone_to_cstring(debugStr, context.temp_allocator);
//     }
// }
