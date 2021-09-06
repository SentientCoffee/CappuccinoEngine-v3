package winapi;

foreign import "system:kernel32.lib";

// -----------------------------------------------------------------------------------
// Enums
// -----------------------------------------------------------------------------------

// FormatMessage :: enum u32 {
//     AllocateBuffer = 0x0000_0100,  // 1 << 8
//     IgnoreInserts  = 0x0000_0200,  // 1 << 9
//     FromString     = 0x0000_0400,  // 1 << 10
//     FromHModule    = 0x0000_0800,  // 1 << 11
//     FromSystem     = 0x0000_1000,  // 1 << 12
//     ArgumentArray  = 0x0000_2000,  // 1 << 13
//     MaxWidthMask   = 0x0000_00FF,
// }

// -----------------------------------------------------------------------------------

LoadLibrary :: enum u32 {
    AsDatafile            = 0x0000_0002,  // 1 << 1
    WithAlteredSearchPath = 0x0000_0008,  // 1 << 3
    IgnoreCodeAuthLevel   = 0x0000_0010,  // 1 << 4
    AsImageResource       = 0x0000_0020,  // 1 << 5
    AsDatafileExclusive   = 0x0000_0040,  // 1 << 6
    RequireSignedTarget   = 0x0000_0080,  // 1 << 7
    SearchDllLoadDir      = 0x0000_0100,  // 1 << 8
    SearchAppicationDir   = 0x0000_0200,  // 1 << 9
    SearchUserDirs        = 0x0000_0400,  // 1 << 10
    SearchSystem32        = 0x0000_0800,  // 1 << 11
    SearchDefaultDirs     = 0x0000_1000,  // 1 << 12
    SafeCurrentDirs       = 0x0000_1000,  // 1 << 12
}

LoadLibraryFlags :: enum u32 {
    AsDatafile,
    WithAlteredSearchPath,
    IgnoreCodeAuthLevel,
    AsImageResource,
    RequireSignedTarget,
    AsDatafileExclusive,
    SearchDllLoadDir,
    SearchAppicationDir,
    SearchUserDirs,
    SearchSystem32,
    SearchDefaultDirs,
    SafeCurrentDirs,
}

LoadLibrarySet :: bit_set[LoadLibraryFlags; u32];

@(private="file")
LoadLibrarySet_to_u32 :: #force_inline proc(set : LoadLibrarySet) -> (ret : u32) {
    set := set;
    @static flagToBit := [LoadLibraryFlags]u32{
        .AsDatafile            = cast(u32) (LoadLibrary.AsDatafile),
        .WithAlteredSearchPath = cast(u32) (LoadLibrary.WithAlteredSearchPath),
        .IgnoreCodeAuthLevel   = cast(u32) (LoadLibrary.IgnoreCodeAuthLevel),
        .AsImageResource       = cast(u32) (LoadLibrary.AsImageResource),
        .AsDatafileExclusive   = cast(u32) (LoadLibrary.AsDatafileExclusive),
        .RequireSignedTarget   = cast(u32) (LoadLibrary.RequireSignedTarget),
        .SearchDllLoadDir      = cast(u32) (LoadLibrary.SearchDllLoadDir),
        .SearchAppicationDir   = cast(u32) (LoadLibrary.SearchAppicationDir),
        .SearchUserDirs        = cast(u32) (LoadLibrary.SearchUserDirs),
        .SearchSystem32        = cast(u32) (LoadLibrary.SearchSystem32),
        .SearchDefaultDirs     = cast(u32) (LoadLibrary.SearchDefaultDirs),
    };

    if .SafeCurrentDirs in set {
        set += { .SearchDefaultDirs };
    }

    ret = bitset_to_integral(set, flagToBit);
    return ret;
}

// -----------------------------------------------------------------------------------

MemoryAlloc :: enum u32 {
    Commit     = 0x0000_1000,  // 1 << 12
    Reserve    = 0x0000_2000,  // 1 << 13
    Reset      = 0x0000_8000,  // 1 << 15
    TopDown    = 0x0010_0000,  // 1 << 20
    ResetUndo  = 0x1000_0000,  // 1 << 28
    WriteWatch = 0x0020_0000,  // 1 << 21
    Physical   = 0x0040_0000,  // 1 << 22
    LargePages = 0x2000_0000,  // 1 << 29
}

MemoryAllocFlags :: enum u32 {
    Commit,
    Reserve,
    Reset,
    TopDown,
    WriteWatch,
    Physical,
    ResetUndo,
    LargePages,
}

MemoryAllocSet :: bit_set[MemoryAllocFlags; u32];

@(private="file")
MemoryAllocSet_to_u32 :: proc(set : MemoryAllocSet) -> (ret : u32) {
    set := set;
    @static flagToBit := [MemoryAllocFlags]u32{
        .Commit     = cast(u32) (MemoryAlloc.Commit),
        .Reserve    = cast(u32) (MemoryAlloc.Reserve),
        .Reset      = cast(u32) (MemoryAlloc.Reset),
        .TopDown    = cast(u32) (MemoryAlloc.TopDown),
        .WriteWatch = cast(u32) (MemoryAlloc.WriteWatch),
        .Physical   = cast(u32) (MemoryAlloc.Physical),
        .ResetUndo  = cast(u32) (MemoryAlloc.ResetUndo),
        .LargePages = cast(u32) (MemoryAlloc.LargePages),
    };

    if .ResetUndo in set {
        // @Todo(Daniel): Log warning about .ResetUndo here
        set = {};
        set += { .ResetUndo };
    }
    else {
        if .LargePages in set {
            // @Todo(Daniel): Log large page minimum here
            set += { .Commit, .Reserve };
        }

        if .WriteWatch in set {
            set += { .Reserve };
        }
    }


    ret = bitset_to_integral(set, flagToBit);
    return ret;
}

// -----------------------------------------------------------------------------------

MemoryFree :: enum u32 {
    Decommit             = 0x0000_4000,            // 1 << 14
    Release              = 0x0000_8000,            // 1 << 15
    CoalescePlaceholders = 0x0000_0001 | Release,  // 1 << 0
    PreservePlaceholder  = 0x0000_0002 | Release,  // 1 << 1
}

MemoryFreeFlags :: enum u32 {
    Decommit,
    Release,
    CoalescePlaceholders,
    PreservePlaceholder,
}

MemoryFreeSet :: bit_set[MemoryFreeFlags; u32];

@(private="file")
MemoryFreeSet_to_u32 :: #force_inline proc(set : MemoryFreeSet) -> (ret : u32) {
    set := set;
    @static flagToBit := [MemoryFreeFlags]u32{
        .Decommit             = cast(u32) (MemoryFree.Decommit),
        .Release              = cast(u32) (MemoryFree.Release),
        .CoalescePlaceholders = cast(u32) (MemoryFree.CoalescePlaceholders),
        .PreservePlaceholder  = cast(u32) (MemoryFree.PreservePlaceholder),
    };

    ret = bitset_to_integral(set, flagToBit);
    return ret;
}

// -----------------------------------------------------------------------------------

MemoryProtection :: enum u32 {
    NoAccess         = 0x0000_0001,  // 1 << 0
    ReadOnly         = 0x0000_0002,  // 1 << 1
    ReadWrite        = 0x0000_0004,  // 1 << 2
    WriteCopy        = 0x0000_0008,  // 1 << 3
    Execute          = 0x0000_0010,  // 1 << 4
    ExecuteRead      = 0x0000_0020,  // 1 << 5
    ExecuteReadWrite = 0x0000_0040,  // 1 << 6
    ExecuteWriteCopy = 0x0000_0080,  // 1 << 7
    Guard            = 0x0000_0100,  // 1 << 8
    NoCache          = 0x0000_0200,  // 1 << 9
    WriteCombine     = 0x0000_0400,  // 1 << 10
    TargetsInvalid   = 0x4000_0000,  // 1 << 30
    TargetsNoUpdate  = 0x4000_0000,  // 1 << 30
}

MemoryProtectionFlags :: enum u32 {
    NoAccess,
    ReadOnly,
    ReadWrite,
    WriteCopy,
    Execute,
    ExecuteRead,
    ExecuteReadWrite,
    ExecuteWriteCopy,
    Guard,
    NoCache,
    WriteCombine,
    TargetsInvalid,
    TargetsNoUpdate,
}

MemoryProtectionSet :: bit_set[MemoryProtectionFlags; u32];

@(private="file")
MemoryProtectionSet_to_u32 :: #force_inline proc(set : MemoryProtectionSet) -> (ret : u32) {
    set := set;
    @static flagToBit := [MemoryProtectionFlags]u32{
        .NoAccess         = cast(u32) (MemoryProtection.NoAccess),
        .ReadOnly         = cast(u32) (MemoryProtection.ReadOnly),
        .ReadWrite        = cast(u32) (MemoryProtection.ReadWrite),
        .WriteCopy        = cast(u32) (MemoryProtection.WriteCopy),
        .Execute          = cast(u32) (MemoryProtection.Execute),
        .ExecuteRead      = cast(u32) (MemoryProtection.ExecuteRead),
        .ExecuteReadWrite = cast(u32) (MemoryProtection.ExecuteReadWrite),
        .ExecuteWriteCopy = cast(u32) (MemoryProtection.ExecuteWriteCopy),
        .Guard            = cast(u32) (MemoryProtection.Guard),
        .NoCache          = cast(u32) (MemoryProtection.NoCache),
        .WriteCombine     = cast(u32) (MemoryProtection.WriteCombine),
        .TargetsInvalid   = cast(u32) (MemoryProtection.TargetsInvalid),
        .TargetsNoUpdate  = cast(u32) (MemoryProtection.TargetsNoUpdate),
    };

    if set >= { .NoAccess, .Guard } {
        // @Todo(Daniel): Log warning about .Guard here
        set -= { .Guard };
    }

    if (set & { .NoAccess, .Guard, .NoCache, .WriteCombine }) > { .NoCache } {
        // @Todo(Daniel): Log warning about .NoCache here
        set -= { .NoCache };
    }

    if (set & { .NoAccess, .Guard, .NoCache, .WriteCombine }) > { .WriteCombine } {
        // @Todo(Daniel): Log warning about .WriteCombine here
        set -= { .WriteCombine };
    }

    ret = bitset_to_integral(set, flagToBit);
    return ret;
}

// -----------------------------------------------------------------------------------
// Overloads
// -----------------------------------------------------------------------------------

// formatMessage     :: proc { formatMessageA, formatMessageW };
getModuleHandle   :: proc { getModuleHandleA, getModuleHandleW, getModuleHandleA_nil };
getProcAddress    :: proc { wGetProcAddress };
outputDebugString :: proc { outputDebugStringA, outputDebugStringW };
virtualAlloc      :: proc { virtualAlloc_set, virtualAlloc_u32 };
virtualFree       :: proc { virtualFree_set, virtualFree_u32 };

loadLibrary :: proc {
    loadLibraryA, loadLibraryW,
    loadLibraryExA_nil_set, loadLibraryExA_nil_u32,
    loadLibraryExW_nil_set, loadLibraryExW_nil_u32,
    loadLibraryExA_handle_set, loadLibraryExA_handle_u32,
    loadLibraryExW_handle_set, loadLibraryExW_handle_u32,
};

// -----------------------------------------------------------------------------------
// Procedures
// -----------------------------------------------------------------------------------

// formatMessageA :: proc(
//     flags : DWord,
//     source : rawptr,
//     messageId : DWord, languageId : DWord,
//     buffer : cstring, size : u32,
// ) -> DWord {
//     return wFormatMessageA(flags, source, messageId, languageId, buffer, size, nil);
// }

// formatMessageW :: proc(
//     flags : DWord,
//     source : rawptr,
//     messageId : DWord, languageId : DWord,
//     buffer : WString, size : u32,
// ) -> DWord {
//     return wFormatMessageW(flags, source, messageId, languageId, buffer, size, nil);
// }

// -----------------------------------------------------------------------------------

getLastError :: proc() -> Error do return cast(Error) wGetLastError();

// -----------------------------------------------------------------------------------

getModuleHandleA_nil :: proc() -> HModule                     do return wGetModuleHandleA(nil);
getModuleHandleA     :: proc(moduleName : cstring) -> HModule do return wGetModuleHandleA(moduleName);
getModuleHandleW     :: proc(moduleName : WString) -> HModule do return wGetModuleHandleW(moduleName);

// -----------------------------------------------------------------------------------

loadLibraryA :: proc(libFilename : cstring) -> HModule {
    return wLoadLibraryA(libFilename);
}

loadLibraryExA_nil_set :: proc(libFilename : cstring, flags : LoadLibrarySet) -> HModule {
    return wLoadLibraryExA(libFilename, nil, LoadLibrarySet_to_u32(flags));
}
loadLibraryExA_nil_u32 :: proc(libFilename : cstring, flags : DWord) -> HModule {
    return wLoadLibraryExA(libFilename, nil, flags);
}
loadLibraryExA_handle_set :: proc(libFilename : cstring, file : Handle, flags : LoadLibrarySet) -> HModule {
    return wLoadLibraryExA(libFilename, file, LoadLibrarySet_to_u32(flags));
}
loadLibraryExA_handle_u32 :: proc(libFilename : cstring, file : Handle, flags : DWord) -> HModule  {
    return wLoadLibraryExA(libFilename, file, flags);
}

loadLibraryW :: proc(libFilename : WString) -> HModule {
    return wLoadLibraryW(libFilename);
}

loadLibraryExW_nil_set :: proc(libFilename : WString, flags : LoadLibrarySet) -> HModule {
    return wLoadLibraryExW(libFilename, nil, LoadLibrarySet_to_u32(flags));
}
loadLibraryExW_nil_u32    :: proc(libFilename : WString, flags : DWord) -> HModule {
    return wLoadLibraryExW(libFilename, nil, flags);
}
loadLibraryExW_handle_set :: proc(libFilename : WString, file : Handle, flags : LoadLibrarySet) -> HModule {
    return wLoadLibraryExW(libFilename, file, LoadLibrarySet_to_u32(flags));
}
loadLibraryExW_handle_u32 :: proc(libFilename : WString, file : Handle, flags : DWord) -> HModule {
    return wLoadLibraryExW(libFilename, file, flags);
}

// -----------------------------------------------------------------------------------

outputDebugStringA :: proc(message : cstring) do wOutputDebugStringA(message);
outputDebugStringW :: proc(message : WString) do wOutputDebugStringW(message);

// ------------------------------------------------Type-----------------------------------

virtualAlloc_set :: proc(address : rawptr, size : uint, allocType : MemoryAllocSet, protection : MemoryProtectionSet) -> rawptr {
    return wVirtualAlloc(address, size, MemoryAllocSet_to_u32(allocType), MemoryProtectionSet_to_u32(protection));
}

virtualAlloc_u32 :: proc(address : rawptr, size : uint, allocType : DWord, protection : DWord) -> rawptr {
    return wVirtualAlloc(address, size, allocType, protection);
}

// -----------------------------------------------------------------------------------

virtualFree_set :: proc(address : rawptr, size : uint, freeType : MemoryFreeSet) -> Bool {
    return wVirtualFree(address, size, MemoryFreeSet_to_u32(freeType));
}

virtualFree_u32 :: proc(address : rawptr, size : uint, freeType : DWord) -> Bool {
    return wVirtualFree(address, size, freeType);
}

// -----------------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------------

@(private="file", default_calling_convention="std")
foreign kernel32 {
    // @(link_name="FormatMessageA")     wFormatMessageA     :: proc(flags : DWord, source : rawptr, messageId : DWord, languageId : DWord, buffer : cstring, size : u32, args : rawptr) -> DWord ---;
    // @(link_name="FormatMessageW")     wFormatMessageW     :: proc(flags : DWord, source : rawptr, messageId : DWord, languageId : DWord, buffer : WString, size : u32, args : rawptr) -> DWord ---;

    @(link_name="GetLastError")       wGetLastError       :: proc() -> DWord ---;
    @(link_name="GetModuleHandleA")   wGetModuleHandleA   :: proc(moduleName : cstring) -> HModule ---;
    @(link_name="GetModuleHandleW")   wGetModuleHandleW   :: proc(moduleName : WString) -> HModule ---;
    @(link_name="GetProcAddress")     wGetProcAddress     :: proc(module : HModule, procName : cstring) -> rawptr ---;

    @(link_name="LoadLibraryA")       wLoadLibraryA       :: proc(libFilename : cstring) -> HModule ---;
    @(link_name="LoadLibraryW")       wLoadLibraryW       :: proc(libFilename : WString) -> HModule ---;
    @(link_name="LoadLibraryExA")     wLoadLibraryExA     :: proc(libFilename : cstring, file : Handle, flags : DWord) -> HModule ---;
    @(link_name="LoadLibraryExW")     wLoadLibraryExW     :: proc(libFilename : WString, file : Handle, flags : DWord) -> HModule ---;

    @(link_name="OutputDebugStringA") wOutputDebugStringA :: proc(message : cstring) ---;
    @(link_name="OutputDebugStringW") wOutputDebugStringW :: proc(message : WString) ---;

    @(link_name="VirtualAlloc")       wVirtualAlloc       :: proc(address : rawptr, size : uint, allocType : DWord, protection : DWord) -> rawptr ---;
    @(link_name="VirtualFree")        wVirtualFree        :: proc(address : rawptr, size : uint, freeType : DWord) -> Bool ---;
}
