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
    AsDatafile               = 0x0000_0002,  // 1 << 1
    WithAlteredSearchPath    = 0x0000_0008,  // 1 << 3
    IgnoreCodeAuthLevel      = 0x0000_0010,  // 1 << 4
    AsImageResource          = 0x0000_0020,  // 1 << 5
    AsDatafileExclusive      = 0x0000_0040,  // 1 << 6
    RequireSignedTarget      = 0x0000_0080,  // 1 << 7
    SearchDllLoadDir         = 0x0000_0100,  // 1 << 8
    SearchAppicationDir      = 0x0000_0200,  // 1 << 9
    SearchUserDirs           = 0x0000_0400,  // 1 << 10
    SearchSystem32           = 0x0000_0800,  // 1 << 11
    SearchDefaultDirs        = 0x0000_1000,  // 1 << 12
    SafeCurrentDirs          = 0x0000_1000,  // 1 << 12
}

LoadLibraryFlags :: enum u32 {
    _                        = 0,  // @Note: necessary due to bit_set semantics
    AsDatafile               = 1,  // 1 << 1,
    WithAlteredSearchPath    = 3,  // 1 << 3,
    IgnoreCodeAuthLevel      = 4,  // 1 << 4,
    AsImageResource          = 5,  // 1 << 5,
    RequireSignedTarget      = 6,  // 1 << 6,
    AsDatafileExclusive      = 7,  // 1 << 7,
    SearchDllLoadDir         = 8,  // 1 << 8,
    SearchAppicationDir      = 9,  // 1 << 9,
    SearchUserDirs           = 10,  // 1 << 10,
    SearchSystem32           = 11,  // 1 << 11,
    SearchDefaultDirs        = 12,  // 1 << 12,
    SafeCurrentDirs          = 12,  // 1 << 12,
}

LoadLibrarySet :: bit_set[LoadLibraryFlags; u32];

// -----------------------------------------------------------------------------------

MemoryAllocType :: enum u32 {
    Commit     = 0x0000_1000,  // 1 << 12
    Reserve    = 0x0000_2000,  // 1 << 13
    Reset      = 0x0000_8000,  // 1 << 15
    TopDown    = 0x0010_0000,  // 1 << 20
    ResetUndo  = 0x1000_0000,  // 1 << 28
    WriteWatch = 0x0020_0000 | Reserve,           // 1 << 21
    Physical   = 0x0040_0000 | Reserve,           // 1 << 22
    LargePages = 0x2000_0000 | Commit | Reserve,  // 1 << 29
}

MemoryAllocFlags :: enum u32 {
    _          = 0,   // @Note: Necessary due to bit_set semantics
    _          = 1,   // @Note: Necessary due to bit_set semantics
    _          = 2,   // @Note: Necessary due to bit_set semantics
    _          = 3,   // @Note: Necessary due to bit_set semantics
    _          = 4,   // @Note: Necessary due to bit_set semantics
    _          = 5,   // @Note: Necessary due to bit_set semantics
    _          = 6,   // @Note: Necessary due to bit_set semantics
    _          = 7,   // @Note: Necessary due to bit_set semantics
    _          = 8,   // @Note: Necessary due to bit_set semantics
    _          = 9,   // @Note: Necessary due to bit_set semantics
    _          = 10,  // @Note: Necessary due to bit_set semantics
    _          = 11,  // @Note: Necessary due to bit_set semantics
    Commit     = 12,  // 1 << 12
    Reserve    = 13,  // 1 << 13
    Reset      = 15,  // 1 << 15
    TopDown    = 20,  // 1 << 20
    WriteWatch = 21,  // 1 << 21
    Physical   = 22,  // 1 << 22
    ResetUndo  = 28,  // 1 << 28
    LargePages = 29,  // 1 << 29
}

MemoryAllocTypeSet :: bit_set[MemoryAllocFlags; u32];

// -----------------------------------------------------------------------------------

MemoryFreeType :: enum u32 {
    Decommit             = 0x0000_4000,            // 1 << 14
    Release              = 0x0000_8000,            // 1 << 15
    CoalescePlaceholders = 0x0000_0001 | Release,  // 1 << 0
    PreservePlaceholder  = 0x0000_0002 | Release,  // 1 << 1
}

MemoryFreeFlags :: enum u32 {
    CoalescePlaceholders = 0,   // 1 << 0
    PreservePlaceholder  = 1,   // 1 << 1
    Decommit             = 14,  // 1 << 14
    Release              = 15,  // 1 << 15
}

MemoryFreeTypeSet :: bit_set[MemoryFreeFlags; u32];

// -----------------------------------------------------------------------------------

MemoryProtectionType :: enum u32 {
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
    NoAccess         = 0,   // 1 << 0
    ReadOnly         = 1,   // 1 << 1
    ReadWrite        = 2,   // 1 << 2
    WriteCopy        = 3,   // 1 << 3
    Execute          = 4,   // 1 << 4
    ExecuteRead      = 5,   // 1 << 5
    ExecuteReadWrite = 6,   // 1 << 6
    ExecuteWriteCopy = 7,   // 1 << 7
    Guard            = 8,   // 1 << 8
    NoCache          = 9,   // 1 << 9
    WriteCombine     = 10,  // 1 << 10
    TargetsInvalid   = 30,  // 1 << 30
    TargetsNoUpdate  = 30,  // 1 << 30
}

MemoryProtectionTypeSet :: bit_set[MemoryProtectionFlags; u32];

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
    return wLoadLibraryExA(libFilename, nil, transmute(u32) flags);
}
loadLibraryExA_nil_u32 :: proc(libFilename : cstring, flags : DWord) -> HModule {
    return wLoadLibraryExA(libFilename, nil, flags);
}
loadLibraryExA_handle_set :: proc(libFilename : cstring, file : Handle, flags : LoadLibrarySet) -> HModule {
    return wLoadLibraryExA(libFilename, file, transmute(u32) flags);
}
loadLibraryExA_handle_u32 :: proc(libFilename : cstring, file : Handle, flags : DWord) -> HModule  {
    return wLoadLibraryExA(libFilename, file, flags);
}

loadLibraryW :: proc(libFilename : WString) -> HModule {
    return wLoadLibraryW(libFilename);
}

loadLibraryExW_nil_set :: proc(libFilename : WString, flags : LoadLibrarySet) -> HModule {
    return wLoadLibraryExW(libFilename, nil, transmute(u32) flags);
}
loadLibraryExW_nil_u32    :: proc(libFilename : WString, flags : DWord) -> HModule {
    return wLoadLibraryExW(libFilename, nil, flags);
}
loadLibraryExW_handle_set :: proc(libFilename : WString, file : Handle, flags : LoadLibrarySet) -> HModule {
    return wLoadLibraryExW(libFilename, file, transmute(u32) flags);
}
loadLibraryExW_handle_u32 :: proc(libFilename : WString, file : Handle, flags : DWord) -> HModule {
    return wLoadLibraryExW(libFilename, file, flags);
}

// -----------------------------------------------------------------------------------

outputDebugStringA :: proc(message : cstring) do wOutputDebugStringA(message);
outputDebugStringW :: proc(message : WString) do wOutputDebugStringW(message);

// -----------------------------------------------------------------------------------

virtualAlloc_set :: proc(address : rawptr, size : uint, allocType : MemoryAllocTypeSet, protection : MemoryProtectionTypeSet) -> rawptr {
    return wVirtualAlloc(address, size, transmute(u32) allocType, transmute(u32) protection);
}

virtualAlloc_u32 :: proc(address : rawptr, size : uint, allocType : DWord, protection : DWord) -> rawptr {
    return wVirtualAlloc(address, size, allocType, protection);
}

// -----------------------------------------------------------------------------------

virtualFree_set :: proc(address : rawptr, size : uint, freeType : MemoryFreeTypeSet) -> Bool {
    return wVirtualFree(address, size, transmute(u32) freeType);
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
