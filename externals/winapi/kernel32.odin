package winapi;

foreign import "system:kernel32.lib";

// -----------------------------------------------------------------------------------
// Enums
// -----------------------------------------------------------------------------------

LoadLibrary :: enum u32 {
    AsDatafile               = 0x0000_0002,
    WithAlteredSearchPath    = 0x0000_0008,
    IgnoreCodeAuthLevel      = 0x0000_0010,
    AsImageResource          = 0x0000_0020,
    RequireSignedTarget      = 0x0000_0080,
    AsDatafileExclusive      = 0x0000_0040,
    SearchDllLoadDir         = 0x0000_0100,
    SearchAppicationDir      = 0x0000_0200,
    SearchUserDirs           = 0x0000_0400,
    SearchSystem32           = 0x0000_0800,
    SearchDefaultDirs        = 0x0000_1000,
    SafeCurrentDirs          = 0x0000_1000,
}

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
    CoalescePlaceholders = 0,  // 1 << 0
    PreservePlaceholder  = 1,  // 1 << 1
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

getModuleHandle   :: proc{ getModuleHandleA, getModuleHandleW, getModuleHandleA_nil };
getProcAddress    :: proc{ wGetProcAddress };
loadLibrary       :: proc{ loadLibraryA, loadLibraryW, loadLibraryExA_nil, loadLibraryExW_nil, loadLibraryExA_handle, loadLibraryExW_handle };
outputDebugString :: proc{ outputDebugStringA, outputDebugStringW };
virtualAlloc      :: proc{ virtualAlloc_Set, virtualAlloc_u32 };
virtualFree       :: proc{ virtualFree_Set, virtualFree_u32 };

// -----------------------------------------------------------------------------------
// Procedures
// -----------------------------------------------------------------------------------

getLastError :: proc() -> Error do return cast(Error) wGetLastError();

// -----------------------------------------------------------------------------------

getModuleHandleA_nil :: proc() -> HModule                     do return wGetModuleHandleA(nil);
getModuleHandleA     :: proc(moduleName : cstring) -> HModule do return wGetModuleHandleA(moduleName);
getModuleHandleW     :: proc(moduleName : WString) -> HModule do return wGetModuleHandleW(moduleName);

// -----------------------------------------------------------------------------------

loadLibraryA          :: proc(libFilename : cstring)                               -> HModule do return wLoadLibraryA(libFilename);
loadLibraryExA_nil    :: proc(libFilename : cstring, flags : DWord)                -> HModule do return wLoadLibraryExA(libFilename, nil, flags);
loadLibraryExA_handle :: proc(libFilename : cstring, file : Handle, flags : DWord) -> HModule do return wLoadLibraryExA(libFilename, file, flags);

loadLibraryW          :: proc(libFilename : WString)                               -> HModule do return wLoadLibraryW(libFilename);
loadLibraryExW_nil    :: proc(libFilename : WString, flags : DWord)                -> HModule do return wLoadLibraryExW(libFilename, nil, flags);
loadLibraryExW_handle :: proc(libFilename : WString, file : Handle, flags : DWord) -> HModule do return wLoadLibraryExW(libFilename, file, flags);

// -----------------------------------------------------------------------------------

outputDebugStringA :: proc(message : cstring) do wOutputDebugStringA(message);
outputDebugStringW :: proc(message : WString) do wOutputDebugStringW(message);

// -----------------------------------------------------------------------------------

virtualAlloc_Set :: proc(address : rawptr, size : uint, allocType : MemoryAllocTypeSet, protection : MemoryProtectionTypeSet) -> rawptr {
    return wVirtualAlloc(address, size, transmute(u32) allocType, transmute(u32) protection);
}

virtualAlloc_u32 :: proc(address : rawptr, size : uint, allocType : DWord, protection : DWord) -> rawptr {
    return wVirtualAlloc(address, size, allocType, protection);
}

// -----------------------------------------------------------------------------------

virtualFree_Set :: proc(address : rawptr, size : uint, freeType : MemoryFreeTypeSet) -> Bool {
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
