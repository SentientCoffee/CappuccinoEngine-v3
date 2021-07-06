package winapi;

foreign import "system:ole32.lib";

// -----------------------------------------------------------------------------------
// Enums
// -----------------------------------------------------------------------------------

ComInit :: enum u32 {
    MultiThreaded     = 0x0000,
    ApartmentThreaded = 0x0002,
    DisableOle1Dde    = 0x0004,
    SpeedOverMemory   = 0x0008,
}

// -----------------------------------------------------------------------------------
// Structs
// -----------------------------------------------------------------------------------

Unknown :: struct {
    using uvtbl : ^UnknownVtbl,
}

UnknownVtbl :: struct {
    queryInterface : #type proc "std" (this : ^Unknown, refIid : ^Iid, object : ^rawptr) -> HResult,
    addRef         : #type proc "std" (this : ^Unknown) -> u32,
    release        : #type proc "std" (this : ^Unknown) -> u32,
}

// -----------------------------------------------------------------------------------
// Overloads
// -----------------------------------------------------------------------------------

comInitialize :: proc { comInitializeRaw, comInitializeEx };

// -----------------------------------------------------------------------------------
// Procedures
// -----------------------------------------------------------------------------------

comInitializeRaw :: proc(reserved: rawptr)               -> HResult do return wCoInitialize(reserved);
comInitializeEx  :: proc(reserved: rawptr, comInit: u64) -> HResult do return wCoInitializeEx(reserved, comInit);
comUninitialize  :: proc(reserved: rawptr)                          do wCoUninitialize();

// -----------------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------------

@(private="file", default_calling_convention="std")
foreign ole32 {
    @(link_name="CoInitialize")   wCoInitialize   :: proc(reserved: rawptr) -> HResult ---;
    @(link_name="CoInitializeEx") wCoInitializeEx :: proc(reserved: rawptr, coInit: u64) -> HResult ---;
    @(link_name="CoUninitialize") wCoUninitialize :: proc() ---;
}
