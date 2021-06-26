package winapi;

foreign import "system:kernel32.lib";

// -----------------------------------------------------------------------------------
// Enums
// -----------------------------------------------------------------------------------

AllocationType :: enum u32 {
    Commit     = 0x0000_1000,
    Reserve    = 0x0000_2000,
    Reset      = 0x0000_8000,
    ResetUndo  = 0x1000_0000,
    LargePages = Commit | Reserve | 0x2000_0000,
    Physical   = Reserve | 0x0040_0000,
    TopDown    = 0x0010_0000,
    WriteWatch = Reserve | 0x0020_0000,
}

FreeType :: enum u32 {
    Decommit             = 0x0000_4000,
    Release              = 0x0000_8000,
    CoalescePlaceholders = Release | 0x0000_0001,
    PreservePlaceholder  = Release | 0x0000_0002,
}

MemoryProtection :: enum u32 {
    NoAccess         = 0x0000_0001,
    ReadOnly         = 0x0000_0002,
    ReadWrite        = 0x0000_0004,
    WriteCopy        = 0x0000_0008,
    Execute          = 0x0000_0010,
    ExecuteRead      = 0x0000_0020,
    ExecuteReadWrite = 0x0000_0040,
    ExecuteWriteCopy = 0x0000_0080,
    Guard            = 0x0000_0100,
    NoCache          = 0x0000_0200,
    WriteCombine     = 0x0000_0400,
    TargetsInvalid   = 0x4000_0000,
    TargetsNoUpdate  = 0x4000_0000,
}

// -----------------------------------------------------------------------------------
// Overloads
// -----------------------------------------------------------------------------------

getLastError      :: proc{ wGetLastError };
virtualAlloc      :: proc{ wVirtualAlloc };
virtualFree       :: proc{ wVirtualFree  };

getModuleHandle   :: proc{   getModuleHandleA,   getModuleHandleW, getModuleHandleN };
outputDebugString :: proc{ outputDebugStringA, outputDebugStringW };

// -----------------------------------------------------------------------------------
// Procedures
// -----------------------------------------------------------------------------------

getModuleHandleN :: proc() -> HModule                     do return wGetModuleHandleA(nil);
getModuleHandleA :: proc(moduleName : cstring) -> HModule do return wGetModuleHandleA(moduleName);
getModuleHandleW :: proc(moduleName : WString) -> HModule do return wGetModuleHandleW(moduleName);

// -----------------------------------------------------------------------------------

outputDebugStringA :: proc(message : cstring) do wOutputDebugStringA(message);
outputDebugStringW :: proc(message : WString) do wOutputDebugStringW(message);

// -----------------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------------

@(private="file", default_calling_convention="std")
foreign kernel32 {
    @(link_name="GetLastError")       wGetLastError       :: proc() -> DWord ---;
    @(link_name="GetModuleHandleA")   wGetModuleHandleA   :: proc(moduleName : cstring) -> HModule ---;
    @(link_name="GetModuleHandleW")   wGetModuleHandleW   :: proc(moduleName : WString) -> HModule ---;

    @(link_name="OutputDebugStringA") wOutputDebugStringA :: proc(message : cstring) ---;
    @(link_name="OutputDebugStringW") wOutputDebugStringW :: proc(message : WString) ---;

    @(link_name="VirtualAlloc")       wVirtualAlloc       :: proc(address : rawptr, size : uint, allocationType : DWord, protection : DWord) -> rawptr ---;
    @(link_name="VirtualFree")        wVirtualFree        :: proc(address : rawptr, size : uint, freeType : DWord) -> Bool ---;
}
