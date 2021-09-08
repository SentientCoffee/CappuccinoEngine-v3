package winapi;

foreign import "system:ole32.lib";

// -----------------------------------------------------------------------------------
// Enums
// -----------------------------------------------------------------------------------

ComInit :: enum u64 {
    MultiThreaded     = 0x0000,
    ApartmentThreaded = 0x0002,
    DisableOle1Dde    = 0x0004,
    SpeedOverMemory   = 0x0008,
}

// ComInitFlags :: enum u64 {
//     MultiThreaded,
//     ApartmentThreaded,
//     DisableOle1Dde,
//     SpeedOverMemory,
// }

// ComInitSet :: bit_set[ComInitFlags; u64];

// @(private="file")
// ComInitSet_to_u64 :: #force_inline proc(set : ComInitSet) -> (ret : u64) {
//     set := set;
//     static flagToBit := [ComInitFlags]u64{
//         .MultiThreaded     = cast(u64) (ComInitFlags.MultiThreaded),
//         .ApartmentThreaded = cast(u64) (ComInitFlags.ApartmentThreaded),
//         .DisableOle1Dde    = cast(u64) (ComInitFlags.DisableOle1Dde),
//         .SpeedOverMemory   = cast(u64) (ComInitFlags.SpeedOverMemory),
//     };

//     if set >= { .MultiThreaded, .ApartmentThreaded } {
//         // @Todo(Daniel): Log about .MultiThreaded/.ApartmentThreaded here
//         // @Reference: https://docs.microsoft.com/en-us/windows/win32/api/objbase/ne-objbase-coinit

//         set -= { .ApartmentThreaded };
//     }

//     ret = bitset_to_integral(set, flagToBit);
//     return ret;
// }

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

comInitialize   :: proc { comInitialize_nil, comInitialize_rawptr, /* comInitializeEx_set, */ comInitializeEx_enum, comInitializeEx_u64, comInitializeEx_u32 };
comUninitialize :: proc { wCoUninitialize };

// -----------------------------------------------------------------------------------
// Procedures
// -----------------------------------------------------------------------------------

comInitialize_nil    :: proc()                  -> HResult do return wCoInitialize(nil);
comInitialize_rawptr :: proc(reserved : rawptr) -> HResult do return wCoInitialize(reserved);

// comInitializeEx_set :: proc(reserved : rawptr, comInit : ComInitSet) -> HResult {
//     return wCoInitializeEx(reserved, ComInitSet_to_u64(comInit));
// }
comInitializeEx_enum :: proc(reserved : rawptr, comInit : ComInit) -> HResult {
    return wCoInitializeEx(reserved, cast(u64) comInit);
}
comInitializeEx_u64 :: proc(reserved : rawptr, comInit : u64) -> HResult {
    return wCoInitializeEx(reserved, comInit);
}
comInitializeEx_u32 :: proc(reserved : rawptr, comInit : u32) -> HResult {
    return wCoInitializeEx(reserved, cast(u64) comInit);
}

// -----------------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------------

@(private="file", default_calling_convention="std")
foreign ole32 {
    @(link_name="CoInitialize")   wCoInitialize   :: proc(reserved : rawptr) -> HResult ---;
    @(link_name="CoInitializeEx") wCoInitializeEx :: proc(reserved : rawptr, coInit : u64) -> HResult ---;
    @(link_name="CoUninitialize") wCoUninitialize :: proc() ---;
}
